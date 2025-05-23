# Github action으로 EC2 배포

## build
```
## GitHub Actions 대시보드에 표시될 워크플로 이름
name: EC2 CI/CD
## 실행 시 "Deploy to [대상] by @사용자명" 형식으로 표시
run-name: Deploy to ${{ inputs.deploy_target }} by @${{ github.actor }}

## 트리거 설정 (이벤트 발생 시 워크플로 실행)
on:
  push:
    branches: [ "main" ]  ## main 브랜치에 push 이벤트 발생 시 실행
#  pull_request:         ## 주석 해제 시 main 브랜치 PR 이벤트로도 실행
#    branches: [ "main" ]

jobs:
  build:
    ## 셀프호스팅 러너 사용 (GitHub 호스트 대신 사용자 인프라 사용)
    runs-on: ubuntu-latest

    steps:
      ## 저장소 코드 체크아웃 (필수 초기 단계)
      - uses: actions/checkout@v4  ## 버전 v4의 공식 체크아웃 액션 사용

      ## ubuntu 서버에 java를 설치하기 때문에 필요하지 않다 생각되어 주석
      - name: Set up JDK 21
        uses: actions/setup-java@v4
        with:
          java-version: '21'
          distribution: 'temurin'
        env:
          JAVA_HOME: ${{ env.JAVA_HOME_21_X64 }}  ## 환경변수 강제 설정

      ## java 버전 확인
      - name: Check Java Version
        run: java -version

      ## gradle의 실행권한 부여와 build 수행
      - name: Grant execute permission for gradlew
        run: chmod +x gradlew

      ## Gradle 빌드
      - name: Build with Gradle
        run: ./gradlew clean build --exclude-task test
      
      ## 빌드해서 생긴 JAR 파일을 깃허브 아티팩트로 업로드
      - name: Upload build artifact
        uses: actions/upload-artifact@v4
        with:
          name: github_action
          path: build/libs/github_action.jar
```
- EC2에 올릴 jar를 **actions/upload-artifact@v4**을 통해 아티펙트에 업로드

## deploy
- 아티팩트에서 JAR를 다운로드 한다.
  ```
      ## 빌드작업한 JAR파일을 아티펙트에서 다운로드
      - name: Download build artifact
        uses: actions/download-artifact@v4
        with:
          name: github_action
          path: build/libs/
    ```
- 그 후 EC2로 배포
    ```
      ## EC2에 배포
      # EC2 SSH 키를 private_key.pem 파일로 저장 ( 위치는 GitHub 서버 )
      # SCP를 사용하여 JAR 파일을 EC2 서버로 복사
      - name: Deploy to EC2
        run: |
          echo "${{secrets.SSH_PRIVATE_KEY}}" > shinemuscat.pem
          chmod 600 shinemuscat.pem
          scp -i shinemuscat.pem -o StrictHostKeyChecking=no ./build/libs/github_action.jar ${{secrets.USER}}@${{secrets.EC2}}:/home/${{secrets.USER}}/github_action.jar
          rm -f private_key.pem
    ```

### 만날 수 있는 메시지
```
Warning: Permanently added '***' (ED25519) to the list of known hosts.
```
- 이 메시지는 오류가 아니라 정상적인 SSH 동작입니다. SSH 클라이언트가 처음으로 특정 서버에 연결할 때 서버의 호스트 키를 로컬 시스템의 known_hosts 파일에 추가했음을 알리는 경고 메시지입니다.