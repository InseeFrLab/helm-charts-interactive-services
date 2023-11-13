#!/bin/bash

kubectl delete deployments.apps --ignore-not-found=true prepull-cpu prepull-gpu
kubectl delete daemonsets.apps --ignore-not-found=true prepull-cpu prepull-gpu

pip install -q kubernetes

KUBERNETES_NAMESPACE=`cat /var/run/secrets/kubernetes.io/serviceaccount/namespace`

# IMAGES_TO_PREPULL='inseefrlab/onyxia-jupyter-python:py3.11.4,inseefrlab/onyxia-jupyter-python:py3.10.12'
python prepull_images.py $KUBERNETES_NAMESPACE $IMAGES_TO_PREPULL

kubectl delete deployments.apps --ignore-not-found=true prepull-cpu prepull-gpu
kubectl delete daemonsets.apps --ignore-not-found=true prepull-cpu prepull-gpu
