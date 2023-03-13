#!/bin/bash

pip install kubernetes

kubectl delete deployments.apps --ignore-not-found=true prepull
kubectl delete daemonsets.apps --ignore-not-found=true prepull

KUBERNETES_NAMESPACE=`cat /var/run/secrets/kubernetes.io/serviceaccount/namespace`

python prepull_images.py $KUBERNETES_NAMESPACE
