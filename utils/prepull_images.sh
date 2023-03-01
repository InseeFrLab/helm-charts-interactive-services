#!/bin/bash

export KUBERNETES_NAMESPACE=`cat /var/run/secrets/kubernetes.io/serviceaccount/namespace`

env | grep -i KUBERNETES_NAMESPACE

pip install -y kubernetes
python prepull_images.py $KUBERNETES_NAMESPACE
