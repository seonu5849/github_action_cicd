## Terraform

### Variables
- 외부 입력: variables는 Terraform 구성 파일 외부에서 값을 입력받기 위해 사용됩니다. 즉, 사용자는 Terraform을 실행할 때 변수에 값을 전달할 수 있습니다.

- 입력 값: 변수는 Terraform 구성 파일 외부에서 값을 받기 때문에, 사용자가 Terraform을 실행할 때 값을 지정할 수 있습니다.

- 선언 및 할당: 변수는 variable 블록에서 선언되고, 값은 외부에서 전달됩니다.

예시: 
```
variable "environment" {
type        = string
description = "Environment name"
}

resource "example_resource" "example" {
env = var.environment
}
```

### Locals
- 내부 계산: locals는 Terraform 구성 파일 내에서 계산된 값을 저장하고 재사용하기 위해 사용됩니다.

- 내부 값: 로컬 변수는 Terraform 구성 파일 내에서 계산되거나 정의된 값을 저장합니다.

- 선언 및 할당: 로컬 변수는 locals 블록에서 선언되고, 값은 바로 할당됩니다.

예시: 
```
locals {
  environment = "production"
}

resource "example_resource" "example" {
  env = local.environment
}
```

### 주요 차이점
| 특징    | 	Variables         | 	Locals             |
|-------|--------------------|---------------------|
| 값의 출처 | 	외부 입력             | 	내부 계산              |
| 값 할당  | 	Terraform 실행 시 전달 | 	구성 파일 내에서 할당       |
| 사용 목적 | 	외부 입력을 받기 위해      | 	내부 계산된 값을 재사용하기 위해 |