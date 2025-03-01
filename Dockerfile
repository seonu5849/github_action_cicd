# 두 단계로 빌드를 분리함으로써, 각 단계가 독립적으로 최적화됩니다.
# 런타임 환경은 빌드 도구를 포함하지 않아 더 작은 크기의 이미지를 만들 수 있습니다.

# 빌드 단계
FROM eclipse-temurin:21-jdk-alpine AS builder
WORKDIR /builder

ARG JAR_NAME=github_action
ARG JAR_PATH=build/libs/${JAR_NAME}.jar

# shinemuscat-api.jar를 application.jar로 복사한다.
COPY ${JAR_PATH} application.jar

# Spring Boot JAR 파일을 여러 레이어로 추출하고 extracted 디렉터리에 저장
# JAR 파일의 크기를 분리하고 성능을 최적화하며, 배포 효율성을 높이기 위한 레이아웃을 제공합니다.
# --layers : jar 파일을 분리된 레이어로 추출
# --destination extracted : 추출된 파일을 extracted 디렉더리에 저장
RUN java -Djarmode=tools -jar application.jar extract --layers --destination extracted


# 실행 단계
FROM eclipse-temurin:21-jre-alpine
WORKDIR /application

# 환경
ENV PROFILE=local_docker

# builder 단계에서 추출한 파일을 복사
# dependencies : 의존성 라이브러리
# spring-boot-loader : 스프링부트 로더
# snapshot-dependencies : 런타임에 필요한 스냅샷 의존성
# application : 애플리케이션 코드
COPY --from=builder /builder/extracted/dependencies/ ./
COPY --from=builder /builder/extracted/spring-boot-loader/ ./
COPY --from=builder /builder/extracted/snapshot-dependencies/ ./
COPY --from=builder /builder/extracted/application/ ./

# 컨테이너가 시작될 때, 아래 명령어로 애플리케이션 자동으로 실행시킴
ENTRYPOINT ["java", "-jar", "application.jar", "--spring.profiles.active=${PROFILE}"]