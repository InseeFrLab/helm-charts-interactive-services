"""Pre-pull images from the Onyxia catalog on the SSP Cloud workers."""
from pathlib import Path
import os
import sys
import json
import logging
from random import randint
import time
import requests
from typing import Tuple, List, Dict, Any

import yaml
import kubernetes
from kubernetes.client.exceptions import ApiException


logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(message)s')

PROJECT_PATH = Path(__file__).resolve().parents[1]


def configure_kube_api() -> Tuple[kubernetes.client.AppsV1Api, kubernetes.client.CoreV1Api]:
    """
    Configure Kubernetes Python API.

    This function initializes the Kubernetes client and returns both the AppsV1Api
    and CoreV1Api clients to interact with Kubernetes resources.

    Returns:
        A tuple containing the AppsV1Api and CoreV1Api clients.
    """
    kube_config = kubernetes.config.load_incluster_config()
    with kubernetes.client.ApiClient(kube_config) as api_client:
        kube_apps_api = kubernetes.client.AppsV1Api(api_client)
    kube_core_api = kubernetes.client.CoreV1Api()
    return kube_apps_api, kube_core_api


def check_image_exists(image) -> bool:
    """
    Check if a given tag exists for a Docker image in DockerHub.

    Parameters:
    image (str): Full name of the Docker image, including tag (e.g., "inseefrlab/onyxia-base:latest").

    Returns:
    bool: True if the tag exists, False otherwise.
    """
    repository, tag = image.split(":")
    url = f"https://hub.docker.com/v2/repositories/{repository}/tags/{tag}/"
    response = requests.get(url)

    if response.status_code != 200:
        logging.info(f"Image {image} not found on DockerHub, skipped from prepull job.")
        return False

    time.sleep(1)

    return True


def build_manifest(kind: str, images_to_prepull: List[str], image_type: str) -> Dict[str, Any]:
    """
    Build a generic Kubernetes manifest with init containers to pre-pull images.

    Args:
        kind: The kind of Kubernetes resource (e.g., Deployment, DaemonSet).
        images_to_prepull: List of images to be pre-pulled.
        image_type: Type of images to pre-pull ('cpu', 'gpu' or 'any').

    Returns:
        Dict[str, Any]: A Kubernetes manifest dictionary.
    """
    if images_to_prepull is None:
        # Extract list of images to pre-pull from charts
        images_to_prepull = []
        charts = [f.name for f in os.scandir(PROJECT_PATH / "charts")
                  if f.is_dir() and f.name != "library-chart"]
        # Filter images if specified in `image_type`
        if image_type == "cpu":
            charts = [image for image in charts if "gpu" not in image]
        if image_type == "gpu":
            charts = [image for image in charts if "gpu" in image]
        # Generate manifest with one init container for image to pre-pull
        for chart in charts:
            schema_path = PROJECT_PATH / "charts" / chart / "values.schema.json"
            with open(schema_path, "r") as file_in:
                chart_schema = json.load(file_in)
            images = chart_schema["properties"]["service"]["properties"]["image"]["properties"]["version"]["listEnum"]
            images_to_prepull.extend(images)

    # Filter out images that don't exist on DockerHub
    images_to_prepull = [image for image in images_to_prepull if check_image_exists(image)]

    # Open the manifest template
    with open(PROJECT_PATH / "utils" / "prepull_template.yaml", "r") as file_in:
        manifest = yaml.safe_load(file_in)

    # Set the Kind of the manifest
    manifest["kind"] = kind
    manifest["metadata"]["name"] = f"prepull-{image_type}"

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


def prepull_deployment(namespace: str,
                       images_to_prepull: List[str],
                       image_type: str
                       ) -> None:
    """
    Run a Kubernetes Deployment to pre-pull images on the global registry cache.

    Args:
        namespace: The Kubernetes namespace in which the Deployment is created.
        images_to_prepull: List of images to pre-pull.
        image_type: Type of images to pre-pull ('cpu' or 'gpu').

    Returns:
        None
    """
    kube_apps_api, kube_core_api = configure_kube_api()

    # Build manifest
    manifest = build_manifest(kind="Deployment",
                              images_to_prepull=images_to_prepull,
                              image_type=image_type
                              )
    label_name = f"prepull-deployment-{image_type}-" + str(randint(100000, 999999))
    manifest["metadata"]["labels"]["name"] = label_name
    manifest["spec"]["template"]["metadata"]["labels"]["name"] = label_name
    manifest["spec"]["selector"]["matchLabels"]["name"] = label_name
    logging.info(f'Pulling {len(manifest["spec"]["template"]["spec"]["initContainers"])} images')

    # Create deployment
    kube_apps_api.create_namespaced_deployment(namespace=namespace,
                                               body=manifest)

    # Check status periodically until the end
    TIMEOUT = 36000
    start_time = time.time()
    while True:
        time.sleep(10)  # let the deployment set itself up & sleep before the next check
        try:
            # Check the time elapsed and break the loop if timeout is reached
            elapsed_time = time.time() - start_time
            if elapsed_time > TIMEOUT:
                raise TimeoutError("Timed out waiting for DaemonSet rollout to complete.")

            deployment_info = kube_apps_api.list_namespaced_deployment(namespace=namespace,
                                                                       label_selector=f"name={label_name}"
                                                                       )

            # Fetch the DaemonSet status
            current_number = deployment_info.to_dict()["items"][0]["status"]["ready_replicas"]

            # If the number of updated pods matches the desired number of scheduled pods,
            # rollout is done
            if current_number == 1:
                logging.info("Deployment successfully rolled out.")
                break
        except ApiException as e:
            logging.error(f"Exception when calling AppsV1Api->list_namespaced_daemon_set: {e}")
        except TimeoutError as e:
            logging.error(e)
            break


def prepull_daemon(namespace: str,
                   images_to_prepull: List[str],
                   image_type: str
                   ) -> None:
    """
    Run a Kubernetes DaemonSet to pre-pull images on each worker node's cache.

    Args:
        namespace: The Kubernetes namespace in which the DaemonSet is created.
        images_to_prepull: List of images to pre-pull.
        image_type: Type of images to pre-pull ('cpu' or 'gpu').

    Returns:
        None
    """
    kube_apps_api, kube_core_api = configure_kube_api()

    # Build manifest
    manifest = build_manifest(kind="DaemonSet",
                              images_to_prepull=images_to_prepull,
                              image_type=image_type
                              )
    label_name = f"prepull-daemonset-{image_type}-" + str(randint(100000, 999999))
    manifest["metadata"]["labels"]["name"] = label_name
    manifest["spec"]["template"]["metadata"]["labels"]["name"] = label_name
    manifest["spec"]["selector"]["matchLabels"]["name"] = label_name
    logging.info(f'Pulling {len(manifest["spec"]["template"]["spec"]["initContainers"])} images')

    # Create DaemonSet
    kube_apps_api.create_namespaced_daemon_set(namespace=namespace,
                                               body=manifest)

    # Check status periodically until the end
    TIMEOUT = 36000
    start_time = time.time()
    counter_n_daemons_ready = 0
    while True:
        time.sleep(10)  # let the daemonset set itself up & sleep before the next check
        try:
            # Check the time elapsed and break the loop if timeout is reached
            elapsed_time = time.time() - start_time
            if elapsed_time > TIMEOUT:
                raise TimeoutError("Timed out waiting for DaemonSet rollout to complete.")

            daemon_info = kube_apps_api.list_namespaced_daemon_set(namespace=namespace,
                                                                   label_selector=f"name={label_name}"
                                                                   )

            # Get total number of daemons that will be launched
            desired_number = daemon_info.to_dict()["items"][0]["status"]["desired_number_scheduled"]

            # Fetch the DaemonSet status
            n_daemons_ready = daemon_info.to_dict()["items"][0]["status"]["number_ready"]

            if n_daemons_ready > counter_n_daemons_ready:
                logging.info(f'{n_daemons_ready}/{desired_number} daemons done.')
                counter_n_daemons_ready = n_daemons_ready

            # If the number of updated pods matches the desired number of
            # scheduled pods, rollout is done
            if desired_number == n_daemons_ready:
                logging.info("DaemonSet successfully rolled out.")
                break
        except ApiException as e:
            logging.error(f"Exception when calling AppsV1Api->list_namespaced_daemon_set: {e}")
        except TimeoutError as e:
            logging.error(e)
            break


def prepull_images(namespace: str,
                   images_to_prepull: List[str] = None,
                   image_type: str = "any"
                   ) -> None:
    """
    Full procedure to pre-pull Docker images in a Kubernetes cluster.

    This function first creates a Deployment to pull images into the global registry cache,
    followed by a DaemonSet to distribute the images across each worker node's cache.

    Args:
        namespace: The Kubernetes namespace where resources are deployed.
        images_to_prepull: List of images to pre-pull. Defaults to None.
        image_type: The type of images to pre-pull ('cpu' or 'gpu'). Defaults to 'any'.

    Raises:
        ValueError: If 'image_type' is not one of 'cpu', 'gpu' or 'any'.

    Returns:
        None
    """
    # Validate parameters
    if image_type not in ["cpu", "gpu", "any"]:
        raise ValueError('image_type must be either "cpu", "gpu" or "any"')

    # 1st step : create a Deployment to pull the images in the global registry cache once
    logging.info('1st step : Deployment')
    prepull_deployment(namespace=namespace,
                       images_to_prepull=images_to_prepull,
                       image_type=image_type
                       )

    # 2nd step : create a DaemonSet to pull the images in each worker's local cache
    logging.info('2nd step : DaemonSet')
    prepull_daemon(namespace=namespace,
                   images_to_prepull=images_to_prepull,
                   image_type=image_type
                   )


if __name__ == "__main__":

    NAMESPACE = sys.argv[1]
    logging.info(f'STARTING PREPULL PROCESS IN NAMESPACE {NAMESPACE}')

    if len(sys.argv) == 2:
        # Pulling all images specified in the charts of the catalog
        try:
            logging.info('FIRST BATCH : CPU IMAGES')
            prepull_images(namespace=NAMESPACE, image_type="cpu")
            logging.info('SECOND BATCH : GPU IMAGES')
            prepull_images(namespace=NAMESPACE, image_type="gpu")
            logging.info('PRE-PULL PROCESS DONE')
        except ApiException as e:
            if e.status == 410:  # "Reason: Expired: too old resource version"
                logging.info('Error 410 ("too old resource version"), retrying.')
                prepull_images(namespace=NAMESPACE)

    elif len(sys.argv) == 3:
        # Pulling a list of specified images
        images_to_prepull = sys.argv[2].split(",")
        prepull_images(namespace=NAMESPACE,
                       images_to_prepull=images_to_prepull,
                       image_type="cpu"
                       )
