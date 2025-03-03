# AWS EC2 여러개 생성하기

- 우선 배열로 생성하고자 하는 이름을 지정
```
variable "instance_names" {
    default = ["shinemuscat-cicd", "shinemuscat-app-1", "shinemuscat-app-2"]
}
```

- 그리고 EC2를 생성
```
resource "aws_instance" "shinemuscat" {
  count = length(var.instance_names)
  ami           = "ami-024ea438ab0376a47" # ubuntu
  instance_type = "t2.micro"
  key_name = aws_key_pair.terraform-key-pair.key_name # Key Pair 연결

  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]

  tags = {
    Name = var.instance_names[count.index] # 인스턴스 이름
  }
}
```

### is not authorized to perform 오류 - ec2:RunInstances
- 사용자 권한이 없는 경우 어떤 동작을 수행하고자 할때 발생
- 즉, 권한이 없어서 생기는 문제
- 이게 맞는 해결책인지는 모르지만 일단 새로운 IAM 사용자를 만드니 해결이됨
- 왠지 mac이랑 window랑 번갈아쓰면서 알수없는 오류가 발생한듯 하다.