
# ECR에 올라간 최신 이미지 tag가져오기
```
# latest image name
IMAGE_TAG=$(aws ecr describe-images \
  --repository-name $ECR_REPOSITORY_NAME \
  --query 'sort_by(imageDetails,& imagePushedAt)[-1].imageTags[0]' \
  --output text)

# Pull From AWS ECR
docker pull $ECR_REGISTRY/ecr:$IMAGE_TAG
```

# health_check_type   = "ELB"
- 헬스체크가 ELB 이면, 헬스 체크 결과를 바탕으로 인스턴스가 "Unhealthy" 상태로 판정되면, Auto Scaling이 해당 인스턴스를 종료 후 교체
- 이 방식은 애플리케이션 레벨의 이상까지 탐지 가능하기 때문에, 단순 인스턴스 상태가 아닌 실제 서비스 응답 실패까지 커버
- 따라서 일반적으로 애플리케이션을 서비스 중인 환경에서는 ELB 헬스 체크를 사용하는 것이 안정성과 회복력을 높이는 데 유리

서비스(어플리케이션)를 올리지 않았기 때문에 헬스체크시 Unhealthy 상태가 되면서 사라진 것. 

| 항목         | EC2 헬스 체크            | ELB 헬스 체크                       |
|--------------|--------------------------|-------------------------------------|
| 체크 주체    | EC2 자체 상태            | 로드 밸런서 헬스 체크               |
| 체크 범위    | 시스템/하드웨어 수준     | 애플리케이션 응답(포트/경로)까지    |
| 사용 대상    | 테스트, 단순 인프라      | 실제 서비스 운영 환경              |
| 조건 없음    | 가능                     | Target Group 필요                   |


# 오류
### The deploymentOption value is set to WITH_TRAFFIC_CONTROL, but either no load balancer was specified in elbInfoList or no target group was specified in targetGroupInfoList.
- target_group_pair_info 에서 elb_info로 변경하니 정상적으로 실행됨.
- elb_info는 어떤 ELB를 사용할지 지정하여 로드밸런서 자체를 설정한다.
- target_group_pair_info의 prod_traffic_route는 사용자의 실제 트래픽이 들어올 리스너 ARN을 지정한다.