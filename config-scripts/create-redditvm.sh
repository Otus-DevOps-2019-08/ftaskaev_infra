#!/bin/bash

$(which gcloud) compute instances create reddit-ap \
    --image-family reddit-full \
    --machine-type=f1-micro \
    --tags puma-server \
    --restart-on-failure

