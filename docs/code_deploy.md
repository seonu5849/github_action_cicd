
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
- ## The deploymentOption value is set to WITH_TRAFFIC_CONTROL, but either no load balancer was specified in elbInfoList or no target group was specified in targetGroupInfoList.
  - target_group_pair_info 에서 elb_info로 변경하니 정상적으로 실행됨.
  - elb_info는 어떤 ELB를 사용할지 지정하여 로드밸런서 자체를 설정한다.
  - target_group_pair_info의 prod_traffic_route는 사용자의 실제 트래픽이 들어올 리스너 ARN을 지정한다.

- ## The IAM role arn:aws:iam::350386634560:role/shinemuscat-ec2-role does not give you permission to perform operations in the following AWS service: AmazonAutoScaling. Contact your AWS administrator if you need help. If you are an AWS administrator, you can grant permissions to your users or groups by creating IAM policies.
  - https://ydeer.tistory.com/317
  - https://docs.aws.amazon.com/ko_kr/codedeploy/latest/userguide/getting-started-create-service-role.html
  - 테라폼에 아래와 같이 설정 정보를 추가한다.
    ```
    resource "aws_iam_role_policy_attachment" "attach-codedeploy" {
      role       = aws_iam_role.ec2-role.name
      policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
    
      depends_on = [aws_iam_role.ec2-role]
    }
    
    resource "aws_iam_role_policy" "codedeploy_autoscaling_custom_policy" {
      name = "CodeDeployAutoScalingPermissions"
      role = aws_iam_role.ec2-role.name
    
      policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
          {
            Effect = "Allow",
            Action = [
              "iam:PassRole",
              "ec2:CreateTags",
              "ec2:RunInstances"
            ],
            Resource = "*"
          }
        ]
      })
    }
    ```

공식 사이트 설명에 따르면 EC2/온프레미스 배포의 경우 AWSCodeDeployRole 정책을 연결해야하며,
시작 템플릿으로 Auto Scaling 그룹을 생성한 경우 다음의 권한을 추가해야한다고 설명에 있다.
- ec2:RunInstances
- ec2:CreateTags
- iam:PassRole

- ## The overall deployment failed because too many individual instances failed deployment, too few healthy instances are available for deployment, or some instances in your deployment group are experiencing problems.
- 인스턴스에서 aws-cli가 너무 늦게 설치가 되는 바람에 code-deploy-agent가 늦게 설치가 되었고 그로 인해 동작하지 못해서 생긴 문제
- ```
  ####### aws setup (binary 방식) #######
  sudo apt-get install unzip -y
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  ```
- binary 방식으로 변경하여 10분이상 걸리던 것을 1분안에 수행되도록 변경


- ## AllowTraffic
  - 원인
    - 로드밸런서에 등록된 인스턴스의 Health Status가 unhealthy인 경우 위와 같은 에러가 발생
    - ```
      sudo apt install -y nginx
      # 헬스 체크용 경로 추가
      echo "OK" | sudo tee /var/www/html/health
      # nginx 설정 확인 및 재시작
      sudo systemctl restart nginx
      ```
      - 임시로 nginx를 통해 health check를 진행

- ## ScriptFailed : There is no ACTIVE Load Balancer named 'shinemuscat-alb' (Service: AmazonElasticLoadBalancing; Status Code: 400; Error Code: LoadBalancerNotFound; Request ID: 90a835ad-dcbf-4163-829a-94a54691f444; Proxy: null)