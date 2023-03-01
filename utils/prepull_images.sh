#!/bin/bash

pip install kubernetes

KUBERNETES_NAMESPACE=`cat /var/run/secrets/kubernetes.io/serviceaccount/namespace`
python prepull_images.py $KUBERNETES_NAMESPACE
