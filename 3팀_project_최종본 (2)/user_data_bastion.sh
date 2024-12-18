#!/bin/bash

# .ssh 디렉토리 생성 및 권한 설정
sudo mkdir -p /home/ec2-user/.ssh
sudo chown ec2-user:ec2-user /home/ec2-user/.ssh

# Base64로 인코딩된 프라이빗 키를 디코딩하여 저장
echo "${private_key}" | base64 --decode | sudo tee /home/ec2-user/.ssh/gibeom01.pem

# 프라이빗 키의 적절한 권한 설정
sudo chmod 600 /home/ec2-user/.ssh/gibeom01.pem
sudo chown ec2-user:ec2-user /home/ec2-user/.ssh/gibeom01.pem
