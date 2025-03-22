#!/bin/bash

GITHUB_WORKSPACE=/home/ubuntu/actions-runner/_work/github_action_cicd/github_action_cicd
WORKSPACES=/home/ubuntu/workspaces

# ApiDockerfile을 통해 application.jar를 이미지로 생성
echo "build application image"
sudo docker buildx build -t AppImage -f ../infra/ApiDockerfile .

# Application 이미지를 tar로 만들기
echo "Docker Image to Tar"
sudo docker save AppImage > AppImage.tar

# tar를 각 app 컨테이너 서버로 전송
echo "Send Tar for Application container server"
sudo docker cp ./AppImage.tar

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

echo "Clean build and image"
sudo docker buildx prune
sudo docker image prune
