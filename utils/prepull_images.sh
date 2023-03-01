#!/bin/bash

KUBERNETES_NAMESPACE=`cat /var/run/secrets/kubernetes.io/serviceaccount/namespace`

pip install -y kubernetes
python prepull_images.py $KUBERNETES_NAMESPACE
