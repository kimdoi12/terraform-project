#!/usr/bin/env bash
## INFO: https://docs.docker.com/engine/install/ubuntu/

sudo yum update -y
sudo yum install -y git
sudo amazon-linux-extras install docker
sudo service docker start
sudo usermod -a -G docker ec2-user

# Install dependencies
sudo amazon-linux-extras install epel -y && sudo yum install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  lsb-release 

sudo chmod 666 /var/run/docker.sock

cd /home/ec2-user
git clone https://github.com/daphnen7777/post.git

cd /home/ec2-user/post/nginxweb

docker build -t nginxweb:1.0 .

docker run --name nginxweb -d -p 80:80 nginxweb:1.0

#www.Dockerhub.com 이미지 pull
docker pull gibeom01/awsnginx:v1.0

docker run --name gb-awsnginx -d -p 80:80 gibeom01/awsnginx:v1.0
 
#AWS ECR 이미지 pull
sudo yum install -y aws-cli

#AWS CLI 접속 키 부여
cat <<EOF > ~/.aws/credentials
[default]
aws_access_key_id = AKIAXTORPK7KOJIXBUOD #키 넣으세요.
aws_secret_access_key = 51ssGBvU6v4mOFxkqG0ep7eNH5kxLgHpzXKU9XgT #키 넣으세요.
EOF

cat <<EOF > ~/.aws/config
[default]
region = ap-northeast-2
output = None
EOF

aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin 522814707668.dkr.ecr.ap-northeast-2.amazonaws.com

if ! aws ecr describe-repositories --repository-names nginx-webserver --region ap-northeast-2; then
    aws ecr create-repository --repository-name nginx-webserver --region ap-northeast-2
else
    echo "Repository already exists"
fi

docker build -t nginx-webserver .

docker tag nginx-webserver 522814707668.dkr.ecr.ap-northeast-2.amazonaws.com/nginx-webserver:1.0

docker push 522814707668.dkr.ecr.ap-northeast-2.amazonaws.com/nginx-webserver:1.0

docker run --name nginx-webserver -p 8080:80 -d --restart always 522814707668.dkr.ecr.ap-northeast-2.amazonaws.com/nginx-webserver:1.0
