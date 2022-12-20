"""Prepare a DaemonSet manifest to pre-pull a list of given images."""
from pathlib import Path
import os
import json

import yaml


PROJECT_PATH = Path(__file__).resolve().parents[1]

# Extract list of images to pre-pull from charts
images_to_prepull = []
charts = [f.name for f in os.scandir(PROJECT_PATH / "charts") if f.is_dir() and f.name != "library-chart"]
for chart in charts:
    schema_path = PROJECT_PATH / "charts" / chart / "values.schema.json"
    with open(schema_path, "r") as file_in:
        chart_schema = json.load(file_in)
    images = chart_schema["properties"]["service"]["properties"]["image"]["properties"]["version"]["enum"]
    images_to_prepull.extend(images)

# Fill DaemonSet template with one init container per image to pre-pull
with open(PROJECT_PATH / "utils" / "prepull-daemon-template.yaml", "r") as file_in:
    daemon_template = yaml.safe_load(file_in)

for image in images_to_prepull:
    init_container = {
        "name": image.split("/")[1].split(":")[0],
        "image": image,
        "resources": {"limits": {"cpu": "100m", "memory": "100Mi"}}
    }
    daemon_template["spec"]["template"]["spec"]["initContainers"].append(init_container)

with open(PROJECT_PATH / "utils" / "prepull-daemon-manifest.yaml", "w") as file_out:
    yaml.dump(daemon_template, file_out)
