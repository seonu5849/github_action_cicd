#!/bin/bash

AWS_REGION=ap-northeast-2
ECR_REGISTRY=350386634560.dkr.ecr.ap-northeast-2.amazonaws.com
CONTAINER_NAME=shinemuscat-api

# AWS ECR Login
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY/ecr

# latest image name
IMAGE_TAG=$(aws ecr describe-images \
  --repository-name ecr \
  --query 'sort_by(imageDetails,& imagePushedAt)[-1].imageTags[0]' \
  --output text)

# Pull From AWS ECR
docker pull $ECR_REGISTRY/ecr:$IMAGE_TAG

# Docker images
docker images

# Start Application
docker run -d --name $CONTAINER_NAME --env PROFILE=aws -p 80:8080 $ECR_REGISTRY/ecr:$IMAGE_TAG

# Prune Images and Container
docker image prune -af
docker container prune -f