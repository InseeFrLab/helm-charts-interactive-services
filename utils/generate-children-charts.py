"""Generate children charts from parent template."""
from pathlib import Path
import json
import shutil
import os

import yaml


PROJECT_PATH = Path(__file__).resolve().parents[1]

with open(PROJECT_PATH / "utils" / "charts-inheritance.yaml", "r") as file_in:
    parameters = yaml.safe_load(file_in)

for parent in parameters:

    # Retrieve list of parent's images
    parent_dir = PROJECT_PATH / "charts" / parent
    with open(parent_dir / "values.schema.json", "r") as file_in:
        parent_schema = json.load(file_in)
    images_parent = parent_schema["properties"]["service"]["properties"]["image"]["properties"]["version"]["listEnum"]
    for child in parameters[parent]:
        print(f"Building {child} from {parent}.")
        child_dir = PROJECT_PATH / "charts" / child

        # Remove the child chart if it exists 
        if os.path.exists(child_dir):
            shutil.rmtree(child_dir)

        # Create child chart as a copy of parent chart
        shutil.copytree(src=parent_dir, dst=child_dir, dirs_exist_ok=True, ignore=shutil.ignore_patterns('README.md'))

        # Correct Chart metadata
        description_child = parameters[parent][child]["description"]
        with open(child_dir / "Chart.yaml", "r") as file_in:
            child_chart = yaml.safe_load(file_in)

        child_chart["name"] = child
        child_chart["description"] = description_child

        with open(child_dir / "Chart.yaml", "w") as file_out:
            yaml.dump(child_chart, file_out, sort_keys=False)

        # Fill child schema with proper values
        if "images" in parameters[parent][child]:
            # If images are specified in children.yaml, use them
            images_child = parameters[parent][child]["images"]
        else:
            # Otherwise, infer them from the list of images of the parent chart
            child_no_gpu = child.split("-gpu")[0]
            images_child = [image.replace(parent, child_no_gpu) for image in images_parent
                            if "onyxia" in image]
            images_child = [image + "-gpu" if "-gpu" in child else image
                            for image in images_child] 
        with open(child_dir / "values.schema.json", "r") as file_in:
            child_schema = json.load(file_in)

        child_schema["properties"]["service"]["properties"]["image"]["properties"]["version"]["listEnum"] = images_child
        child_schema["properties"]["service"]["properties"]["image"]["properties"]["version"]["default"] = images_child[0]
        child_schema["properties"]["service"]["properties"]["image"]["properties"]["custom"]["properties"]["version"]["default"] = images_child[0]

        # Add gpu config to child schema of gpu images
        if child.endswith("-gpu"):
            gpu_limits = {
                "description": "GPU to allocate to this instance. This is also requested",
                "type": "string",
                "default": "1",
                "render": "slider",
                "sliderMin": 1,
                "sliderMax": 3,
                "sliderStep": 1,
                "sliderUnit": "",
                "x-onyxia": {
                  "overwriteDefaultWith": "region.resources.gpu",
                  "useRegionSliderConfig": "gpu"
                }
                }
            child_schema["properties"]["resources"]["properties"]["limits"]["properties"]["nvidia.com/gpu"] = gpu_limits

        with open(child_dir / "values.schema.json", "w") as file_out:
            json.dump(child_schema, file_out, indent=2, sort_keys=False)

        with open(child_dir / "values.yaml", "r") as file_in:
            child_values = yaml.safe_load(file_in)

        child_values["service"]["image"]["version"] = images_child[0]
        child_values["service"]["image"]["custom"]["version"] = images_child[0]

        with open(child_dir / "values.yaml", "w") as file_out:
            yaml.dump(child_values, file_out, sort_keys=False)
