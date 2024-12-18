output "module_path" {
  value = path.module
}

# Bastion Host 생성 (Public Subnet)
resource "aws_instance" "bastion-Host" {
  ami           = "ami-08b09b6acd8d62254"
  instance_type = "t2.micro"
  subnet_id         = aws_subnet.SEC-PRD-VPC-NGINX-PUB-2A.id
  key_name      = "aws-ssh-keypair" # 사용자 키 페어

  vpc_security_group_ids   = [aws_security_group.SEC-PRD-VPC-bastion-PUB-SG-2A.id]

  tags = {
    Name = "bastion-Host"
  }
}

resource "aws_instance" "ec2_3t_tomcat" {
  ami           		= "ami-08b09b6acd8d62254" 
  instance_type 		= "t2.micro"
  subnet_id          		= aws_subnet.SEC-PRD-VPC-TOMCAT-PRI-2A.id
  key_name      		= aws_key_pair.aws-ssh-keypair.key_name
  vpc_security_group_ids 	= [aws_security_group.VEC-PRD-VPC-TOMCAT-PRI-SG-2A.id]
  user_data 		= file("${path.module}/user_data_tomcat.sh")

  tags = {
    Name 		= "ec2_3T_tomcat"
  }
}

resource "aws_instance" "ec2_3t_nginx_v1" {
  ami           		= "ami-08b09b6acd8d62254"
  instance_type 		= "t2.micro"
  iam_instance_profile 	= aws_iam_instance_profile.nginx_instance_profile.name
  subnet_id              	= aws_subnet.SEC-PRD-VPC-NGINX-PUB-2A.id
  vpc_security_group_ids 	= [aws_security_group.SEC-PRD-VPC-NGINX-PUB-SG-2A.id]
  key_name      		= aws_key_pair.aws-ssh-keypair.key_name
  user_data 		= file("${path.module}/user_data_nginx.sh")

  tags = {
    Name 		= "ec2_3t_nginx_v1"
  }
}

resource "aws_instance" "ec2_3t_nginx_v2" {
  ami           		= "ami-08b09b6acd8d62254"
  instance_type 		= "t2.micro"
  iam_instance_profile 	= aws_iam_instance_profile.nginx_instance_profile.name
  subnet_id              	= aws_subnet.SEC-PRD-VPC-NGINX-PUB-2A.id
  vpc_security_group_ids 	= [aws_security_group.SEC-PRD-VPC-NGINX-PUB-SG-2A.id]
  key_name      		= aws_key_pair.aws-ssh-keypair.key_name

  tags = {
    Name = "ec2_3t_nginx_v2"
  }
}
