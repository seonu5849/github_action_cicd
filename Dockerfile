# Build Container
FROM eclipse-temurin:21.0.2_13-jre

# 작업 디렉토리 설정
WORKDIR /build

# 이것은 대상 폴더의 빌드 JAR 파일을 가리킨다.
ARG JAR_NAME=github_action
ARG JAR_PATH=build/libs/${JAR_NAME}.jar

# JAR 파일을 작업 디렉토리에 복사하여 Application.jar로 이름을 바꾼다.
        COPY ${JAR_PATH} application.jar

# Spring Boot JAR 파일을 여러 레이어로 추출하고 extracted 디렉터리에 저장
# JAR 파일의 크기를 분리하고 성능을 최적화하며, 배포 효율성을 높이기 위한 레이아웃을 제공합니다.
# --layers : jar 파일을 분리된 레이어로 추출
# --destination extracted : 추출된 파일을 extracted 디렉더리에 저장
RUN java -Djarmode=tools -jar application.jar extract --layers --destination extracted


# Runtime Container
FROM eclipse-temurin:21.0.2_13-jre

WORKDIR /application

# builder 단계에서 추출한 파일을 복사
# dependencies : 의존성 라이브러리
# spring-boot-loader : 스프링부트 로더
# snapshot-dependencies : 런타임에 필요한 스냅샷 의존성
# application : 애플리케이션 코드
COPY --from=builder /builder/extracted/dependencies/ ./
COPY --from=builder /builder/extracted/spring-boot-loader/ ./
COPY --from=builder /builder/extracted/snapshot-dependencies/ ./
COPY --from=builder /builder/extracted/application/ ./

# CDS 교육 실행을 실행하십시오
RUN java -XX:ArchiveClassesAtExit=application.jsa -Dspring.context.exit=onRefresh -jar application.jar

# Start the application
ENTRYPOINT ["java", "-jar", "application.jar", "--spring.profiles.active=local-docker"]