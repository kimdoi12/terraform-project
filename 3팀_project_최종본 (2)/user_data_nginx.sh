#!/usr/bin/env bash

# 시스템 업데이트 및 Docker 설치
sudo yum update -y
sudo yum install -y git
sudo amazon-linux-extras install -y docker
sudo systemctl start docker
sudo usermod -a -G docker ec2-user

# 의존성 설치
sudo amazon-linux-extras install -y epel && sudo yum install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  lsb-release 

sudo chmod 666 /var/run/docker.sock # Docker 소켓 권한 설정

# GitHub 코드 클론
cd /home/ec2-user
git clone https://github.com/daphnen7777/post.git

cd /home/ec2-user/post/nginxweb

# Docker 이미지 빌드 및 실행
docker build -t nginxweb:1.0 .

docker run --name nginxweb -d -p 8080:80 nginxweb:1.0

# www.Dockerhub.com 이미지 pull 및 실행
docker pull gibeom01/awsnginx:v1.0

docker run --name gb-awsnginx -d -p 8090:80 gibeom01/awsnginx:v1.0
 
# AWS CLI 설치
sudo yum install -y aws-cli

# AWS CLI 인증 정보 설정
cat <<EOF > ~/.aws/credentials
[default]
aws_access_key_id = #키 넣으세요.
aws_secret_access_key = #키 넣으세요.
EOF

cat <<EOF > ~/.aws/config
[default]
region = ap-northeast-2
output = None
EOF

# ECR 로그인
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin 522814707668.dkr.ecr.ap-northeast-2.amazonaws.com

# ECR 리포지토리 생성
if ! aws ecr describe-repositories --repository-names nginx-webserver --region ap-northeast-2; then
    aws ecr create-repository --repository-name nginx-webserver --region ap-northeast-2
else
    echo "Repository already exists"
fi

# Docker 이미지 빌드 및 ECR 푸시
docker build -t nginx-webserver .

docker tag nginx-webserver 522814707668.dkr.ecr.ap-northeast-2.amazonaws.com/nginx-webserver:1.0

docker push 522814707668.dkr.ecr.ap-northeast-2.amazonaws.com/nginx-webserver:1.0

# ECR 컨테이너 실행
docker run --name nginx-webserver -p 8070:80 -d --restart always 522814707668.dkr.ecr.ap-northeast-2.amazonaws.com/nginx-webserver:1.0
