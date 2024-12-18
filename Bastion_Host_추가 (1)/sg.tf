# Bastion Host 보안 그룹 (SSH 허용)

resource "aws_security_group" "SEC-PRD-VPC-bastion-PUB-SG-2A" {
  name        = "SEC-PRD-VPC-bastion-PUB-SG-2A"
  vpc_id      = aws_vpc.SEC-PRD-VPC.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # SSH 접속 허용
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Nginx 보안 그룹 (HTTP, HTTPS 허용)

resource "aws_security_group" "SEC-PRD-VPC-NGINX-PUB-SG-2A" {
  vpc_id = aws_vpc.SEC-PRD-VPC.id

  name        = "SEC-PRD-VPC-NGINX-PUB-SG-2A"
  description = "Allow HTTP and HTTPS traffic to Nginx"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH from anywhere"
  }
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from anywhere"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS from anywhere"
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
	description = "Allow ICMP from anywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "SEC-PRD-VPC-NGINX-PUB-SG-2A"
  }
}

resource "aws_security_group" "SEC-PRD-VPC-NGINX-PUB-SG-2C" {
  vpc_id = aws_vpc.SEC-PRD-VPC.id

  name        = "SEC-PRD-VPC-NGINX-PUB-SG-2C"
  description = "Allow HTTP and HTTPS traffic to Nginx"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH from anywhere"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from anywhere"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS from anywhere"
  }
  
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
	description = "Allow ICMP from anywhere"
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "SEC-PRD-VPC-NGINX-PUB-SG-2C"
  }
}


# Tomcat 보안 그룹 (TCP 허용)

resource "aws_security_group" "VEC-PRD-VPC-TOMCAT-PRI-SG-2A" {
  vpc_id = aws_vpc.SEC-PRD-VPC.id
  name        = "VEC-PRD-VPC-TOMCAT-PRI-SG-2A"
  description = "Allow HTTP traffic to Tomcat"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "192.168.20.0/24"  # Bastion Host에서만 Tomcat 접근 가능
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "VEC-PRD-VPC-TOMCAT-PRI-SG-2A"
  }
}

resource "aws_security_group" "VEC-PRD-VPC-TOMCAT-PRI-SG-2C" {
  vpc_id = aws_vpc.SEC-PRD-VPC.id
  name        = "VEC-PRD-VPC-TOMCAT-PRI-SG-2C"
  description = "Allow HTTP traffic to Tomcat"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "192.168.20.0/24"  # Bastion Host에서만 Tomcat 접근 가능
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "VEC-PRD-VPC-TOMCAT-PRI-SG-2C"
  }
}
