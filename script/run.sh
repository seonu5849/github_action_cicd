#!/bin/bash

JAR=/home/ubuntu/github_action.jar

echo "Stoping exiting Application..."
## -a : 프로세스ID(PID)와 함께 전체 명령어 출력
## -f : 프로세스 이름뿐만 아니라 명령줄 전체에서 검색 (github_action.jar 포함)
## awk '{print $1}' : awk는 텍스트 처리도구, '{print $1}'는 출력된 결과의 첫 번째 열(PID) 추출
## xargs : 앞에서 받은 입력(PID)을 인수로 전달
## -r : 입력이 없으면 명령어를 실행하지 않음 (안전장치)
## kill -9 : 강제 종료 신호를 해당 PID에 전달하여 프로세스 종료
pgrep -af $JAR | awk '{print $1}' | xargs -r kill -9;

echo "Starting the new Application..."
nohup java -jar $JAR --spring.profiles.active=local-docker > api.log &

echo "Successfully start Application!"
pgrep -af $JAR