"""Prepare a DaemonSet manifest to pre-pull a list of given images."""
from pathlib import Path
import os
import sys
import json

import yaml
import kubernetes


PROJECT_PATH = Path(__file__).resolve().parents[1]

# Configure Kubernetes Python API
NAMESPACE = sys.argv[1]
kube_config = kubernetes.config.load_incluster_config()
with kubernetes.client.ApiClient(kube_config) as api_client:
    kube_apps_api = kubernetes.client.AppsV1Api(api_client)
kube_core_api = kubernetes.client.CoreV1Api()

# Extract list of images to pre-pull from charts
images_to_prepull = []
charts = [f.name for f in os.scandir(PROJECT_PATH / "charts") if f.is_dir() and f.name != "library-chart"]
for chart in charts:
    schema_path = PROJECT_PATH / "charts" / chart / "values.schema.json"
    with open(schema_path, "r") as file_in:
        chart_schema = json.load(file_in)
    images = chart_schema["properties"]["service"]["properties"]["image"]["properties"]["version"]["enum"]
    images_to_prepull.extend(images)

# Fill template with one init container per image to pre-pull
with open(PROJECT_PATH / "utils" / "prepull-template.yaml", "r") as file_in:
    manifest = yaml.safe_load(file_in)

for image in images_to_prepull:
    init_container = {
        "name": image.split("/")[1].replace(":", "-").replace(".", "-"),
        "image": image,
        "command": ['bash', '-c', 'echo image pulled.'],
        "imagePullPolicy": "Always",
        "resources": {"limits": {"cpu": "100m", "memory": "100Mi"}}
    }
    manifest["spec"]["template"]["spec"]["initContainers"].append(init_container)

# 1st step : create a Deployment to pull the images in the global registry cache once
manifest["kind"] = "Deployment"
kube_apps_api.create_namespaced_deployment(namespace=NAMESPACE, body=manifest)

# Wait for the Deployment to be in Running state and remove it
w = kubernetes.watch.Watch()
for event in w.stream(kube_core_api.list_namespaced_pod, namespace=NAMESPACE,
                      label_selector="name=prepull"):
    pod_state = event['object'].status.phase
    if pod_state == "Running":
        w.stop()
        # kube_apps_api.delete_namespaced_deployment(namespace=NAMESPACE, name="prepull")
        break

# 2nd step : create a DaemonSet to pull the images from cache on all workers
manifest["kind"] = "DaemonSet"
kube_apps_api.create_namespaced_daemon_set(namespace=NAMESPACE, body=manifest)
res = kube_apps_api.list_namespaced_daemon_set(namespace=NAMESPACE,
                                               label_selector="name=prepull")

# Wait for all daemons to be in Running state and remove the DaemonSet
w = kubernetes.watch.Watch()
for event in w.stream(kube_apps_api.list_namespaced_daemon_set,
                      namespace=NAMESPACE,
                      label_selector="name=prepull"):
    n_daemons_ready = event['object'].status.number_ready
    if n_daemons_ready == 11:
        w.stop()
        # kube_apps_api.delete_namespaced_daemon_set(namespace=NAMESPACE, name="prepull")
        break
