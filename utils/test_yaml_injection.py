#!/usr/bin/env python3
"""Regression test against YAML/template injection via user-controlled values.

Onyxia fills chart values from user form input, then renders and installs the
chart as cluster-admin. If a user value is interpolated into a template without
being quoted, a value containing newlines and a `---` document separator can
break out of its YAML scalar and inject arbitrary Kubernetes manifests (e.g. a
ClusterRoleBinding to cluster-admin).

This test, for every chart, sets each free-text string field of its
values.schema.json to a payload containing newlines and an injected document,
renders the chart with `helm template`, and fails if the payload produces an
extra/injected document or breaks the rendered YAML.

Fields constrained by `enum`, `const` or `pattern` are skipped: helm's schema
validation rejects the payload for them. `format` is NOT skipped: helm does not
assert formats (an `email`/`uri` field accepts any string), so it protects nothing.

Only *source* charts are tested (the ones maintained by hand); the generated
children are byte-for-byte copies produced by generate-children-charts.py.

Usage:
    python3 utils/test_yaml_injection.py                # all source charts
    python3 utils/test_yaml_injection.py jupyter-python # named charts
    python3 utils/test_yaml_injection.py --changed-base origin/main  # only changed sources
"""
from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

import yaml

PROJECT_PATH = Path(__file__).resolve().parents[1]
CHARTS_DIR = PROJECT_PATH / "charts"

# A document that must never appear as a *rendered* manifest: if it does, a value
# escaped its scalar. The marker name lets us tell an injected document apart
# from a payload that merely ends up as a (safe) quoted string value.
MARKER = "yaml-injection-probe"
PAYLOAD = (
    "probe\n"
    "---\n"
    "apiVersion: v1\n"
    "kind: ConfigMap\n"
    "metadata:\n"
    f"  name: {MARKER}\n"
    "data:\n"
    "  a: b"
)


def source_charts() -> list[str]:
    """Charts maintained by hand = all charts with a schema minus generated children."""
    inheritance = yaml.safe_load((PROJECT_PATH / "utils" / "charts-inheritance.yaml").read_text())
    children = {child for parent in inheritance.values() for child in (parent or {})}
    sources = []
    for chart in sorted(p.name for p in CHARTS_DIR.iterdir() if p.is_dir()):
        if chart in children:
            continue
        if (CHARTS_DIR / chart / "values.schema.json").exists():
            sources.append(chart)
    return sources


def free_text_paths(schema: dict, prefix: tuple[str, ...] = ()):
    """Yield the dotted path of every string leaf that helm's schema validation does not constrain."""
    if not isinstance(schema, dict):
        return
    for key, node in schema.get("properties", {}).items():
        if not isinstance(node, dict):
            continue
        if node.get("type") == "string" and "properties" not in node:
            if not any(c in node for c in ("enum", "const", "pattern")):
                yield prefix + (key,)
        else:
            yield from free_text_paths(node, prefix + (key,))


def nested(path: tuple[str, ...], value) -> dict:
    out: dict = {}
    cur = out
    for key in path[:-1]:
        cur = cur.setdefault(key, {})
    cur[path[-1]] = value
    return out


def render(chart: str, values: dict) -> subprocess.CompletedProcess:
    with tempfile.NamedTemporaryFile("w", suffix=".yaml", delete=False) as handle:
        yaml.safe_dump(values, handle)
        values_file = handle.name
    try:
        return subprocess.run(
            ["helm", "template", "probe", str(CHARTS_DIR / chart), "-f", values_file],
            capture_output=True,
            text=True,
        )
    finally:
        os.unlink(values_file)


def is_injected(stdout: str) -> bool:
    try:
        docs = list(yaml.safe_load_all(stdout))
    except yaml.YAMLError:
        return True  # payload produced YAML helm emitted but that no longer parses
    return any(
        isinstance(doc, dict) and (doc.get("metadata") or {}).get("name") == MARKER
        for doc in docs
    )


def test_chart(chart: str) -> list[tuple[str, str]]:
    schema = json.loads((CHARTS_DIR / chart / "values.schema.json").read_text())
    vulnerable: list[tuple[str, str]] = []
    for path in free_text_paths(schema):
        result = render(chart, nested(path, PAYLOAD))
        if result.returncode != 0:
            if "don't meet the specifications of the schema" in result.stderr:
                continue  # rejected by schema validation -> not injectable
            vulnerable.append((".".join(path), "breaks rendered YAML"))
        elif is_injected(result.stdout):
            vulnerable.append((".".join(path), "injects a document"))
    return vulnerable


def ensure_dependencies(chart: str) -> None:
    subprocess.run(
        ["helm", "dependency", "update", str(CHARTS_DIR / chart)],
        capture_output=True,
        text=True,
    )


def changed_source_charts(base: str) -> list[str]:
    diff = subprocess.run(
        ["git", "diff", "--name-only", f"{base}...HEAD", "--", "charts/"],
        capture_output=True,
        text=True,
        cwd=PROJECT_PATH,
    )
    changed = {line.split("/")[1] for line in diff.stdout.splitlines() if "/" in line}
    return [c for c in source_charts() if c in changed]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("charts", nargs="*", help="charts to test (default: all source charts)")
    parser.add_argument("--changed-base", help="only test source charts changed vs this git ref")
    args = parser.parse_args()

    if args.charts:
        charts = args.charts
    elif args.changed_base:
        charts = changed_source_charts(args.changed_base)
    else:
        charts = source_charts()

    if not charts:
        print("No source charts to test.")
        return 0

    failures = 0
    for chart in charts:
        ensure_dependencies(chart)
        vulnerable = test_chart(chart)
        if vulnerable:
            failures += 1
            print(f"FAIL {chart}")
            for path, why in vulnerable:
                print(f"       {path}: {why}")
        else:
            print(f"ok   {chart}")

    if failures:
        print(f"\n{failures} chart(s) with YAML-injection vulnerabilities.")
        return 1
    print(f"\nAll {len(charts)} chart(s) safe.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
