
### github aciton 변수 등록
- secrets.CICD => CICD 인스턴스 host ip
- secrets.USER => ec2인스턴스의 계정 이름
- secrets.SSH_PRIVATE_KEY => pem key
- secrets.APP_1 => app-1의 private ip
- secrets.APP_2 => app-2의 private ip
- secrets.ECR => ecr uri

위 사항을 입력하고, 배포할때 ecr에 로그인 후 push, pull을 진행한 후
받은 이미지로 application을 실행


### 안되는 부분
- 이미지를 ecr로 push했을 때 덮어쓰기가 되면서 하나의 이미지만 남을 줄 알았으나
- 이미지를 덮어쓰긴 하지만 기존 있던 이미지의 tag(이름)을 지우고 새롭게 생긴다.
- 그래서 이미지가 계속 쌓이는 문제가 있다.

### application을 private subnet으로 이동
- private subnet으로 application으로 이동하면 외부에서 접근하려면 alb(aws load balance)를 사용해야 한다.
- terraform으로 alb를 생성하면 되는데 현재는 모든 포트를 8080으로 맞춰 놓음 (application이 8080이기 때문)
- alb를 사용하면 들어오는 구조가 listener를 타고 target_group을 통해 application에 연결되는 구조인듯 하다.
- listener는 80포트로 하고 target_group이나 target_group_attachment는 8080으로 변경해서도 테스트해보면 좋을 듯 하다.
- 이유는 80포트로 하면 주소창에 포트를 적지 않아도 된다.