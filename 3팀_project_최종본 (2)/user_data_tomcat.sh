#!/bin/bash

# 시스템 업데이트 및 Docker 설치
sudo amazon-linux-extras install -y epel
sudo yum install -y git
sudo amazon-linux-extras install -y docker
sudo systemctl start docker
sudo usermod -a -G docker ec2-user
sudo yum install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  lsb-release 

sudo chmod 666 /var/run/docker.sock # Docker 소켓 권한 설정

# Tomcat, Java 환경변수 설정
cat <<EOF >> /etc/profile

export CATALINA_HOME=/usr/local/tomcat
export JAVA_HOME=/usr/lib/jvm/java-17
export PATH=$PATH:$JAVA_HOME/bin
export CLASSPATH=$JAVA_HOME/lib
EOF

# Clone 리포지토리 및 Docker 빌드, 실행
cd /home/ec2-user
git clone https://github.com/daphnen7777/post.git

sudo mv -f /home/ec2-user/post/post/ /home/ec2-user/post/tomcatwas/
cd /home/ec2-user/post/tomcatwas

docker build -t tomcatwas:1.0 .

docker run -d --name tomcatwas -p 8080:8080 tomcatwas:1.0

# Bastion Host 설정 안내
echo "Bastion Host 설정을 위해 AWS Management Console을 사용하여 보안 그룹을 수정하세요."
echo "1. AWS Management Console에 로그인하세요."
echo "2. EC2 대시보드로 이동하세요."
echo "3. Bastion Host의 보안 그룹을 선택하세요."
echo "4. '인바운드 규칙' 탭을 클릭하세요."
echo "5. SSH (포트 22) 접근을 허용하기 위해 '편집'을 클릭한 후 다음 규칙을 추가하세요:"
echo "   - 유형: SSH"
echo "   - 프로토콜: TCP"
echo "   - 포트: 22"
echo "   - 소스: 192.168.10.0/24 (서브넷의 퍼블릭 IP)"
echo "6. Tomcat(포트 8080)에 대한 접근을 허용하기 위해 다음 규칙을 추가하세요:"
echo "   - 유형: Custom TCP"
echo "   - 프로토콜: TCP"
echo "   - 포트: 8080"
echo "   - 소스: SEC-PRD-VPC (Tomcat 인스턴스의 보안 그룹 ID)"
echo "7. 변경사항을 저장하세요."

# MariaDB 설치 및 데이터베이스 초기화
sudo yum install -y mariadb-server mariadb

sudo systemctl start mariadb
sudo systemctl enable mariadb

# 데이터베이스 및 사용자 생성
sudo mysql <<EOF
FLUSH PRIVILEGES;
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('root');
CREATE USER 'root'@'%' IDENTIFIED BY 'root';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
CREATE DATABASE practice_board;
USE practice_board;
CREATE TABLE post (
  num INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(50) NOT NULL,
  writer VARCHAR(50) NOT NULL,
  content TEXT NOT NULL,
  reg_date DATETIME NOT NULL
);
EOF

sudo systemctl restart mariadb
sudo systemctl enable mariadb
