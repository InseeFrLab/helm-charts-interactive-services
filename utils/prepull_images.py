"""Prepare a DaemonSet manifest to pre-pull a list of given images."""
from pathlib import Path
import os
import sys
import json

import yaml
import kubernetes


PROJECT_PATH = Path(__file__).resolve().parents[1]


def configure_kube_api(namespace):
    """Configure Kubernetes Python API."""
    kube_config = kubernetes.config.load_incluster_config()
    with kubernetes.client.ApiClient(kube_config) as api_client:
        kube_apps_api = kubernetes.client.AppsV1Api(api_client)
    kube_core_api = kubernetes.client.CoreV1Api()
    return kube_apps_api, kube_core_api


def build_manifest():
    # Extract list of images to pre-pull from charts
    images_to_prepull = []
    charts = [f.name for f in os.scandir(PROJECT_PATH / "charts") 
              if f.is_dir() and f.name != "library-chart"]
    for chart in charts:
        schema_path = PROJECT_PATH / "charts" / chart / "values.schema.json"
        with open(schema_path, "r") as file_in:
            chart_schema = json.load(file_in)
        images = chart_schema["properties"]["service"]["properties"]["image"]["properties"]["version"]["listEnum"]
        images_to_prepull.extend(images)

    # Fill template with one init container per image to pre-pull
    with open(PROJECT_PATH / "utils" / "prepull_template.yaml", "r") as file_in:
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

    return manifest


def prepull_deployment(namespace):
    kube_apps_api, kube_core_api = configure_kube_api(namespace=namespace)
    manifest = build_manifest()
    manifest["kind"] = "Deployment"
    kube_apps_api.create_namespaced_deployment(namespace=namespace,
                                               body=manifest)

    # Wait for the Deployment to be in Running state and remove it
    w = kubernetes.watch.Watch()
    for event in w.stream(kube_core_api.list_namespaced_pod,
                          namespace=namespace,
                          label_selector="name=prepull"
                          ):
        pod_state = event['object'].status.phase
        if pod_state == "Running":
            w.stop()
            kube_apps_api.delete_namespaced_deployment(namespace=NAMESPACE, 
                                                       name="prepull")
            break


def prepull_daemon(namespace):
    kube_apps_api, kube_core_api = configure_kube_api(namespace=namespace)
    manifest = build_manifest()
    manifest["kind"] = "DaemonSet"
    kube_apps_api.create_namespaced_daemon_set(namespace=namespace,
                                               body=manifest)

    # Wait for all daemons to be in Running state and remove the DaemonSet
    w = kubernetes.watch.Watch()
    for event in w.stream(kube_apps_api.list_namespaced_daemon_set,
                          namespace=namespace,
                          label_selector="name=prepull"):
        n_daemons_ready = event['object'].status.number_ready
        if n_daemons_ready == 11:
            w.stop()
            kube_apps_api.delete_namespaced_daemon_set(namespace=NAMESPACE, 
                                                       name="prepull")
            break


if __name__ == "__main__":

    NAMESPACE = sys.argv[1]

    # 1st step : create a Deployment to pull the images in the global registry cache once
    prepull_deployment(namespace=NAMESPACE)

    # 2nd step : create a DaemonSet to pull the images in each worker's local cache
    prepull_daemon(namespace=NAMESPACE)
