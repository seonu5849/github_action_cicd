#!/bin/bash

GITHUB_WORKSPACE=/home/ubuntu/actions-runner/_work/github_action_cicd/github_action_cicd
WORKSPACES=/home/ubuntu/workspaces

echo "Create Workspaces Directory"
if [ ! -d ~/workspaces ]; then
  mkdir ~/workspaces
fi

cd $WORKSPACES
echo "Copy Docker-Compose and DockerFile to Workspaces"
cp $GITHUB_WORKSPACE/infra/api-docker-compose.yml .
cp $GITHUB_WORKSPACE/infra/ApiDockerfile .
cp $GITHUB_WORKSPACE/build/libs/github_action.jar .

echo "Starting the new Application..."
sudo docker compose -f $WORKSPACES/api-docker-compose.yml up -d --build
