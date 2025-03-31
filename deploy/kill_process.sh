#!/bin/bash

IMAGE_NAME=shinemuscat-api

# Running Application Stop
docker stop $IMAGE_NAME || true

# Remove Application Docker Container
docker rm $IMAGE_NAME || true