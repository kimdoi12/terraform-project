output "module_path" {
  value = path.module
}

# Bastion Host 생성 (Public Subnet)
resource "aws_instance" "Bastion-Host" {
  ami           = "ami-08b09b6acd8d62254"
  instance_type = "t2.micro"
  subnet_id         = aws_subnet.SEC-PRD-VPC-NGINX-PUB-2A.id
  key_name      = "aws-ssh-keypair" # 사용자 키 페어
  source_dest_check      = false

  user_data = templatefile("${path.module}/user_data_bastion.sh", {
    private_key = local.encoded_private_key
  })

  vpc_security_group_ids   = [aws_security_group.SEC-PRD-VPC-Bastion-PUB-SG.id]

  tags = {
    Name = "Bastion-Host"
  }
}

resource "aws_instance" "EC2_3T_Tomcat" {
  ami           		= "ami-08b09b6acd8d62254" 
  instance_type 		= "t2.micro"
  subnet_id          		= aws_subnet.SEC-PRD-VPC-TOMCAT-PRI-2A.id
  key_name      		= aws_key_pair.aws-ssh-keypair.key_name
  vpc_security_group_ids 	= [aws_security_group.VEC-PRD-VPC-TOMCAT-PRI-SG-2A.id]
  user_data 		= file("${path.module}/user_data_tomcat.sh")

  tags = {
    Name 		= "EC2_3T_Tomcat"
  }
}

resource "aws_instance" "EC2_3T_Nginx" {
  ami           		= "ami-08b09b6acd8d62254"
  instance_type 		= "t2.micro"
  iam_instance_profile 	= aws_iam_instance_profile.nginx_instance_profile.name
  subnet_id              	= aws_subnet.SEC-PRD-VPC-NGINX-PUB-2A.id
  vpc_security_group_ids 	= [aws_security_group.SEC-PRD-VPC-NGINX-PUB-SG-2A.id]
  key_name      		= aws_key_pair.aws-ssh-keypair.key_name
  user_data 		= file("${path.module}/user_data_nginx.sh")

  tags = {
    Name 		= "EC2_3T_Nginx"
  }
}
