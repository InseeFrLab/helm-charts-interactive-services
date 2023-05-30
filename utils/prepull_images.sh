#!/bin/bash

kubectl delete deployments.apps --ignore-not-found=true prepull
kubectl delete daemonsets.apps --ignore-not-found=true prepull

pip install kubernetes

KUBERNETES_NAMESPACE=`cat /var/run/secrets/kubernetes.io/serviceaccount/namespace`

# IMAGES_TO_PREPULL='inseefrlab/onyxia-vscode-python:py3.10.9'
python prepull_images.py $KUBERNETES_NAMESPACE $IMAGES_TO_PREPULL
