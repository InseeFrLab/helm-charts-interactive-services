"""Pre-pull images from the Onyxia catalog on the SSP Cloud workers."""
from pathlib import Path
import os
import sys
import json
import logging
from random import randint
import time

import yaml
import kubernetes
from kubernetes.client.exceptions import ApiException


logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(message)s')

PROJECT_PATH = Path(__file__).resolve().parents[1]


def configure_kube_api():
    """Configure Kubernetes Python API."""
    kube_config = kubernetes.config.load_incluster_config()
    with kubernetes.client.ApiClient(kube_config) as api_client:
        kube_apps_api = kubernetes.client.AppsV1Api(api_client)
    kube_core_api = kubernetes.client.CoreV1Api()
    return kube_apps_api, kube_core_api


def build_manifest(kind, images_to_prepull=None):
    """Build generic manifest with init containers to pre-pull images."""
    if images_to_prepull is None:
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

    # Open the manifest template
    with open(PROJECT_PATH / "utils" / "prepull_template.yaml", "r") as file_in:
        manifest = yaml.safe_load(file_in)

    # Set the Kind of the manifest
    manifest["kind"] = kind

    # Fill template with one init container per image to pre-pull
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


def prepull_deployment(namespace, images_to_prepull=None):
    """Run a Deployment to pre-pull the images on the global registry cache."""
    kube_apps_api, kube_core_api = configure_kube_api()
    manifest = build_manifest(kind="Deployment",
                              images_to_prepull=images_to_prepull)
    label_name = "prepull-deployment-" + str(randint(100000, 999999))
    manifest["metadata"]["labels"]["name"] = label_name
    manifest["spec"]["template"]["metadata"]["labels"]["name"] = label_name
    manifest["spec"]["selector"]["matchLabels"]["name"] = label_name
    kube_apps_api.create_namespaced_deployment(namespace=namespace,
                                               body=manifest)

    # Wait for the Deployment to be in Running state and remove it
    w = kubernetes.watch.Watch()
    for event in w.stream(kube_core_api.list_namespaced_pod,
                          namespace=namespace,
                          label_selector=f"name={label_name}",
                          timeout_seconds=0
                          ):
        pod_state = event['object'].status.phase
        if pod_state == "Running":
            w.stop()
            break


def prepull_daemon(namespace, images_to_prepull=None):
    """Run a DaemonSet to pre-pull the images on each worker's cache."""
    kube_apps_api, kube_core_api = configure_kube_api()
    manifest = build_manifest(kind="DaemonSet",
                              images_to_prepull=images_to_prepull)
    label_name = "prepull-daemonset-" + str(randint(100000, 999999))
    manifest["metadata"]["labels"]["name"] = label_name
    manifest["spec"]["template"]["metadata"]["labels"]["name"] = label_name
    manifest["spec"]["selector"]["matchLabels"]["name"] = label_name
    kube_apps_api.create_namespaced_daemon_set(namespace=namespace,
                                               body=manifest)


    timeout=36000
    start_time = time.time()
    while True:
        time.sleep(30) # let the daemonset set itself up & sleep before the next check 
        try:
            # Check the time elapsed and break the loop if timeout is reached
            elapsed_time = time.time() - start_time
            if elapsed_time > timeout:
                raise TimeoutError("Timed out waiting for DaemonSet rollout to complete.")

            daemon_info = kube_apps_api.list_namespaced_daemon_set(namespace=namespace,
                                                           label_selector=f"name={label_name}")

            # Get total number of daemons that will be launched
            desired_number = daemon_info.to_dict()["items"][0]["status"]["desired_number_scheduled"]

            # Fetch the DaemonSet status
            current_number = daemon_info.to_dict()["items"][0]["status"]["number_ready"]         

            # If the number of updated pods matches the desired number of scheduled pods, rollout is done
            if desired_number == current_number:
                print(f"DaemonSet prepull in namespace {namespace} has successfully rolled out in {elapsed_time} sec.")
                break
            else:
                print(f"Waiting for DaemonSet prepull rollout to finish: {current_number} out of {desired_number} new pods have been updated...")

        except ApiException as e:
            print(f"Exception when calling AppsV1Api->list_namespaced_daemon_set: {e}")
        except TimeoutError as e:
            print(e)
            break

def prepull_images(namespace, images_to_prepull=None):
    """Full prepull procedure."""
    # 1st step : create a Deployment to pull the images in the global registry cache once
    logging.info('1st step : Deployment')
    prepull_deployment(namespace=namespace, images_to_prepull=images_to_prepull)

    # 2nd step : create a DaemonSet to pull the images in each worker's local cache
    logging.info('2nd step : DaemonSet')
    prepull_daemon(namespace=namespace, images_to_prepull=images_to_prepull)

    logging.info('Prepull job done')


if __name__ == "__main__":

    NAMESPACE = sys.argv[1]

    if len(sys.argv) == 2:
        # Pulling all images specified in the charts of the catalog
        try:
            prepull_images(namespace=NAMESPACE)
        except ApiException as e:
            if e.status == 410:  # "Reason: Expired: too old resource version"
                logging.info('Error 410 ("too old resource version"), retrying.')
                prepull_images(namespace=NAMESPACE)

    elif len(sys.argv) == 3:
        # Pulling a list of specified images
        images_to_prepull = sys.argv[2].split(",")
        prepull_images(namespace=NAMESPACE, images_to_prepull=images_to_prepull)
