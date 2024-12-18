# Private Key 생성
resource "tls_private_key" "aws_private_keypair" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Key Pair 생성 (AWS에 공개키 등록)
resource "aws_key_pair" "aws-ssh-keypair" {
  key_name   = "aws-ssh-keypair" # AWS에 등록할 키 쌍 이름
  public_key = tls_private_key.aws_private_keypair.public_key_openssh

  tags = {
    Name = "aws-ssh-keypair"
  }
}

# 로컬에 Private Key 저장
resource "local_file" "gibeom_private_key" {
  content  = tls_private_key.aws_private_keypair.private_key_pem
  filename = "${path.module}/gibeom01.pem"  # 로컬에 저장할 파일 이름
  file_permission = "0600"
}

# Base64로 인코딩된 Private Key
locals {
  encoded_private_key = base64encode(local_file.gibeom_private_key.content)
}