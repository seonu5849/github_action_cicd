#!/bin/bash

CONTAINER_NAME=shinemuscat-api

# Running Application Stop
docker stop $CONTAINER_NAME || true

# Remove Application Docker Container
docker rm $CONTAINER_NAME || true