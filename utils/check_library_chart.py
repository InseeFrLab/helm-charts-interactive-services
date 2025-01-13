#!/usr/bin/env python3
"""
Validates that library-chart modifications are published separately from changes that use them.
If library-chart updates are detected alongside changes in dependent charts, raises a warning
to ensure proper chart versioning and publishing order.
"""

import argparse
import re
import subprocess
from packaging.version import Version
from pathlib import Path
from typing import Any

class CalledProcessError(RuntimeError):
    pass

def cmd_output(*cmd: str, retcode: int | None = 0, **kwargs: Any) -> str:
    kwargs.setdefault('stdout', subprocess.PIPE)
    kwargs.setdefault('stderr', subprocess.PIPE)
    proc = subprocess.Popen(cmd, **kwargs)
    stdout, stderr = proc.communicate()
    stdout = stdout.decode()
    if retcode is not None and proc.returncode != retcode:
        raise CalledProcessError(cmd, retcode, proc.returncode, stdout, stderr)
    return stdout

def version_change(path: Path | str) -> tuple[Version, Version] | None:
    diff = cmd_output('git', 'diff', '--staged', path)
    match = re.search(r'\n\-version:\s*([0-9\.]+)\s*\n\+version:\s*([0-9\.]+)\s*\n', diff)
    return (Version(match.group(1)), Version(match.group(2))) if match else None

def library_chart_version_change(path: Path | str) -> tuple[Version, Version] | None:
    diff = cmd_output('git', 'diff', '--staged', path)
    match = re.search(r'\n\s+-\s+name:\s*library-chart\s*\n-\s+version:\s*([0-9\.]+)\s*\n\+\s+version:\s*([0-9\.]+)\s*\n', diff)
    return (Version(match.group(1)), Version(match.group(2))) if match else None

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '-b', '--branch', action='append',
        help='Restrict check to this branch',
    )
    parser.add_argument(
        '-s', '--strict-version', action='store_true',
        dest='strict_version',
        help='Only warn if the exact bumped version of library-chart is reused in other charts',
    )
    args = parser.parse_args()

    try:
        # If the hook is restricted to some (other) branches, return
        if args.branch and cmd_output("git", "rev-parse", "--abbrev-ref", "HEAD").strip() not in args.branch:
            return 0

        lc_version_change = version_change("charts/library-chart/Chart.yaml")
        # If library-chart is not version bumped then no problem
        if not lc_version_change:
            return 0

        # Retrieve all changed files
        changed_files = set([Path(file) for file in cmd_output('git', 'diff', '--staged', '--name-only').splitlines()])
        # Retrieve all library-chart updates in charts
        chart_updates = [ (file, library_chart_version_change(file)) for file in changed_files if file.name == 'Chart.yaml' ]
        issues = [
            chart_file
            for chart_file, version_changes in chart_updates
            if version_changes and
              (not args.strict_version or version_changes[1] == lc_version_change[1])
        ]
        if issues:
            print(f"The version of `library-chart` was bumped to {lc_version_change[1]} and simultaneously reused in the following charts before it is released.")
            for chart_file in issues:
                print("  -", chart_file)
            print("Push the `library-chart` update before using it in other charts.")
            return 1
        return 0

    except CalledProcessError:
        return 0

if __name__ == "__main__":
    raise SystemExit(main())
