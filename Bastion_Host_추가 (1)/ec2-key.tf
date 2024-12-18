# Private Key 생성 (terraform이 관리)
resource "tls_private_key" "aws_private_keypair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Key Pair 생성 (AWS에 공개키 등록)
resource "aws_key_pair" "aws-ssh-keypair" {
  key_name   = "aws-ssh-keypair"
  public_key = tls_private_key.aws_private_keypair.public_key_openssh

  tags = {
    Name = "aws-ssh-keypair"
  }
}

# 로컬에 Private Key 저장
resource "local_file" "aws-ssh-keypair" {
  content  = tls_private_key.aws_private_keypair.private_key_pem
  filename = "${path.module}/aws-ssh-keypair.pem"
  file_permission = "0600"
}
