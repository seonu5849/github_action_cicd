
# ECR
ecr을 시작하려면 ec2 인스턴스에 awscli가 설치되어야하고 docker도 설치 되어야 한다.
```
sudo snap install aws-cli --classic
```

근데 자동화를 위해서 ec2 생성 user-data에 넣었는데 이게 생각보다 오래걸린다.
만약 아직 설치 중이라면
```
snap changes
```
을 통해서 설치 중인 프로세스들을 확인 할 수 있다.

## 도커에 로그인 설정 추가
```
aws configure
```
위 명령어를 통해 IAM 정보를 입력한다.

그 다음 
```
docker login -u AWS -p HXzgrf9wpMvm9apISU+5wz0xunEJ1EroJ4MrrNAP 350386634560.dkr.ecr.ap-northeast-2.amazonaws.com
```
이렇게 입력했지만 어째서인지

```
WARNING! Using --password via the CLI is insecure. Use --password-stdin.
Error response from daemon: login attempt to https://350386634560.dkr.ecr.ap-northeast-2.amazonaws.com/v2/ failed with status: 400 Bad Request
```
이라는 메시지를 받았다.
일단 `WARNING! Using --password via the CLI is insecure. Use --password-stdin.`은 -p보단 --password-stdin을 사용하라는 것이다.
왜냐하면 -p는 영구적으로 저장이 되기 때문에 --password-stdin을 사용하는 것을 권장한다고 한다.

```
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin 350386634560.dkr.ecr.ap-northeast-2.amazonaws.com
```
위 명령어를 입력하면
```
WARNING! Your credentials are stored unencrypted in '/home/ubuntu/.docker/config.json'.
Configure a credential helper to remove this warning. See
https://docs.docker.com/go/credential-store/

Login Succeeded
```
이런 메시지를 받을 수 있다. 일단 로그인은 성공했다.

```
sudo vi /home/ubuntu/.docker/config.json

}
        "auths": {
                "350386634560.dkr.ecr.ap-northeast-2.amazonaws.com": {
                        "auth": "QVdTOmV5SndZWGxzYjJGa0lqb2lNV3c0TUVwSE1EYzNhRFZIV1dscmRYaHhjSFoyVjNaT1VWazViMGgwU1dKamNqSk5NVEpIYUZwb1dXOXZPVzFSVXpFeE1HMHdhbFJaWWpWcWRHNTJXRWxEWXpWVVdUaE1aVzlpVUhwMk4wWkZSa05NZHk5cE5VdHpkMFp6YWpKWWFrMTNWMFZHWkcxdU4xRnFWSGxMTmxscmJXbFpXbE5zZURJdmNqaHZjRlJrY1VzellqTkVhVXBhU2pjM1puWmlSbU5CVmxvM2RFTm9ia3hoWmxCVUwxUlRUak5HUW1ZMWRGWlpkbU5EUWtWSVMzVTRZVXh0ZUU1R05XTkJWV1JuYUhOaWVUWm1VbEowV1hRMWRYZDVibEZxVVd4UWFuZEdPVFZ5U1ZGU1pWcHZWSFU0TDJrNE5TdFBjakp6VGxCWmF6aFhXbGxrTkhSSVUwUjNRbEpSUTBwc1dqaDRjVFZMZWs5dldIUkZZazVoTm5wMlZtVjZTblp3WWxwVmVsRnBSRU5EZFRNck4yVnJjM2xwWTI5UFp6QjZRbmxyY21WbGRsVlRhekpIVFhSeFQySndWVzhyZVdoNFZESk5hV0p3Y3pSR1VVcDFVM0ZsUWs5UlozSXdXbTVxU2t4M1UzbHJjMWs1THpkTVkzZFZVV1Y2YURkVWVGRlZMeTh2T0M5WVlVVjNXRzh4VGl0SFUzVnBXVTkwVFVwdWFWVlJkV05XV2tOSk1WUmFNbkJHTkVKTWJITm1iREZMTnpBeFZUZDJaVkYxTW5wMU5tZDFOSEJvVW1jNWFtOUhjbEJSYVN0YWVrTkxVRGhvZG1GTlZqRjJlREJzV1Zwb2NFeFdXVzVIU2l0T2JWVjJUR3BpTTJSbmRqTlNkR3BQVWpoclRDOWFOR3RET1ZGSVJHZFdTMmgxWTFKNGJqaGtkVkZhUmpVMlZHTTRkbk0yZUc5WVYwUjRkRGw0VGtNM1FtbEZaRlo2VWpCVk4zTlVaWEZLYzJFclduTXhSV0ZWVkVwd2JVRjZlU3N2YW5GVVpHbHBjRGhCTldaRVIzUnpha2M1UzNKelpITnNiREJRWWtoRFJpdHhWVlZFTTFSUmIxUk5LekY1ZWxnd1NqTk1OREpSTVRSR2NXZGFkek5oUlZsbE5XazFhQ3RyUkVKb2JFTkZMMjFUUmpSc05uVnNTRXhqUkRGbGJFeFRRMkpRWmpSb1JsZHhabkprVEROSVUxTXlVRkZaTnpBNFRtaGFRVU5NUWpKbmJGcHJTMHR1WTNaNE0yeHdSRXd2VWxWV1ZqVkxSVGs0Y1dVclduSnlNRVIwU1RrMGVHTTRRMjVZWVRoU2RYSkZSa2N5VGtsQlFWWnlTV2hIWmxaTFdsQlFXRk56Y0V4bk5HSlhhazFuTm5sUk9XbEtjR1l4U2k5alNtbHZXVTh5SzJ4dE1VeGFRbUZWVld0MmNYUTBlRmN4ZFhST1VsRjBWbkIzTW5KYU5IZGxOMU4xZG1zdk5sUnJOelEzTUVwdlJWSnJVRk0xYkdOYWRXbFVPR3h4T1hwNlJUa3ZSMlpqYzB4RVFWcG9Wa1o0TXprMldFWjRNamN2Y1VsMVFWWlpNaXQ2YlRoNVZsWTBla0ZMZFU0NWVuRjVkaTlPV0RWYVlsSk5NMDgzYm1WSFVYRnFRbE5MWlVoa2NVUktOV1l6TjBadWEzaFRaM0JuVGxWbmNYRm1TSE40TmpJclZ6ZFVhbmhMU0hCdWFXczFVV1ZrZEVwSU9VNUdlalZDVEZSV1JsWTVMMjgyV2tsNWRFcGpTM0ZHV2pRNFR6SnlXbXhQV1dablJTdFJaMkU0UVVSVFV6UkdXaUlzSW1SaGRHRnJaWGtpT2lKQlVVbENRVWhvUVU5ellWY3laMXBPTURsWFRuUk9SMnRaWXpoeGNERXhlRk5vV2k5a2NrVkZiM2t4U0dzNFRGaFhaMFpoYjBwMFJqbDVhVEphTjBWMlFVUXlOeXRNTUc5QlFVRkJabXBDT0VKbmEzRm9hMmxIT1hjd1FrSjNZV2RpZWtKMFFXZEZRVTFIWjBkRFUzRkhVMGxpTTBSUlJVaEJWRUZsUW1kc1oyaHJaMEphVVUxRlFWTTBkMFZSVVUxRWNWaE1ielZoYlhwNWJuRkJOWGM1UVdkRlVXZEVkVFpqYVdoaU16VllSMHhQT1ROVlZXSTVVRmxGVUdaSGVXNXBTMUF6VVRGQlJWUktSa1kwYW1VM2NtcFFiMUpCZW01bFlUUjFUWFJrWkUwek5qRXhka280ZWpaa2FVOUJORTR2ZG1oRlNVRTlQU0lzSW5abGNuTnBiMjRpT2lJeUlpd2lkSGx3WlNJNklrUkJWRUZmUzBWWklpd2laWGh3YVhKaGRHbHZiaUk2TVRjME1qVTJOemczTkgwPQ=="
                }
        }
}
```
"/home/ubuntu/.docker/config.json"을 들어가면 위와 같이 작성이 되어 있다.
사용자의 인증 정보를 암호화하지 않고 파일에 저장하고 있음을 알려주는 것이다.

## docker로 ecr에 push or pull

### push
```
docker tag {이미지:버전} {ecr-uri}:{이미지이름}
docker tag shinemuscat-api:latest  350386634560.dkr.ecr.ap-northeast-2.amazonaws.com/ecr:shinemuscat-api
```
위 명령어를 통해 image를 tagging한다 (git의 commit과 비슷)

```
docker push {ecr-uri}:{이미지이름}
docker push 350386634560.dkr.ecr.ap-northeast-2.amazonaws.com/ecr:shinemuscat-api
```
위 명령어를 통해 tagging한 이미지를 aws-ecr로 올리면 된다.

```
ubuntu@ip-10-0-1-139:~$ docker tag shinemuscat-api:latest  350386634560.dkr.ecr.ap-northeast-2.amazonaws.com/ecr:shinemuscat-api
ubuntu@ip-10-0-1-139:~$ docker push 350386634560.dkr.ecr.ap-northeast-2.amazonaws.com/ecr:shinemuscat-api
The push refers to repository [350386634560.dkr.ecr.ap-northeast-2.amazonaws.com/ecr]
baed02a909d1: Pushed
33131c76ab38: Pushed
1ad87e42f391: Pushed
1ccd0345aa79: Pushed
4a31297e6baa: Pushed
822032205b9c: Pushed
93509ae705ea: Pushed
8f5df01935a3: Pushed
08000c18d16d: Pushed
shinemuscat-api: digest: sha256:7c53e7099132865a9b13325fd5a75b1dec99ef0bcf4886e1daf3f99062c764aa size: 2408
```
정상적으로 처리되면 위와 같이 진행되며 ecr-repo에도 이미지가 담긴 것을 확인할 수 있다.

### pull
- 예시
```
docker pull <aws_account_id>.dkr.ecr.<region>.amazonaws.com/<my-repository:tag>
```
- 실제
```
docker pull 350386634560.dkr.ecr.ap-northeast-2.amazonaws.com/ecr:shinemuscat-api
```

- 성공 시
```
ubuntu@ip-10-0-1-20:~$ docker pull 350386634560.dkr.ecr.ap-northeast-2.amazonaws.com/ecr:shinemuscat-api
shinemuscat-api: Pulling from ecr
f18232174bc9: Already exists                                                                                                                                                                                                        
c3f73af09931: Already exists                                                                                                                                                                                                        
729fc64ae8c1: Already exists                                                                                                                                                                                                        
28bd55152645: Already exists                                                                                                                                                                                                        
2fa1f65d07a3: Already exists                                                                                                                                                                                                        
5be8fbec5e23: Already exists                                                                                                                                                                                                        
6575af838101: Already exists                                                                                                                                                                                                        
f2c2ccf8d176: Already exists                                                                                                                                                                                                        
a0a790b87763: Already exists                                                                                                                                                                                                        
Digest: sha256:42e9276c6ce6219a3b3e1e02d415d8deaf7aae0441de89e8502e1c1608bfdb7c
Status: Downloaded newer image for 350386634560.dkr.ecr.ap-northeast-2.amazonaws.com/ecr:shinemuscat-api
350386634560.dkr.ecr.ap-northeast-2.amazonaws.com/ecr:shinemuscat-api
ubuntu@ip-10-0-1-20:~$ docker images
REPOSITORY                                              TAG               IMAGE ID       CREATED         SIZE
350386634560.dkr.ecr.ap-northeast-2.amazonaws.com/ecr   shinemuscat-api   d369371ac10f   9 minutes ago   261MB
```