#!/bin/bash

mamba install -y python-kubernetes
python prepull_images.py "$@"
