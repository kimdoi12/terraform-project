# VPC 생성

resource "aws_vpc" "SEC-PRD-VPC" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name = "SEC-PRD-VPC"
  }
}

# 사용 가능한 가용 영역 가져오기

data "aws_availability_zones" "available" {
  state = "available"
}

# 퍼블릭 서브넷 생성 (AZ A)

resource "aws_subnet" "SEC-PRD-VPC-NGINX-PUB-2A" {
  vpc_id                  = aws_vpc.SEC-PRD-VPC.id
  cidr_block              = "192.168.10.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "SEC-PRD-VPC-NGINX-PUB-2A"
  }
}

# 퍼블릭 서브넷 생성 (AZ C)

resource "aws_subnet" "SEC-PRD-VPC-NGINX-PUB-2C" {
  vpc_id                  = aws_vpc.SEC-PRD-VPC.id
  cidr_block              = "192.168.110.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[2]

  tags = {
    Name = "SEC-PRD-VPC-NGINX-PUB-2C"
  }
}

resource "aws_subnet" "SEC-PRD-VPC-TOMCAT-PRI-2A" {
  vpc_id = aws_vpc.SEC-PRD-VPC.id
  cidr_block = "192.168.20.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "SEC-PRD-VPC-TOMCAT-PRI-2A"
  }
}

resource "aws_subnet" "SEC-PRD-VPC-TOMCAT-PRI-2C" {
  vpc_id = aws_vpc.SEC-PRD-VPC.id
  cidr_block = "192.168.120.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]
  tags = {
    Name = "SEC-PRD-VPC-TOMCAT-PRI-2C"
  }
}

resource "aws_subnet" "SEC-PRD-VPC-RDS-PRI-2A" {
  vpc_id = aws_vpc.SEC-PRD-VPC.id
  cidr_block = "192.168.30.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "SEC-PRD-VPC-RDS-PRI-2A"
  }
}

resource "aws_subnet" "SEC-PRD-VPC-RDS-PRI-2C" {
  vpc_id = aws_vpc.SEC-PRD-VPC.id
  cidr_block = "192.168.130.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]
  tags = {
    Name = "SEC-PRD-VPC-RDS-PRI-2C"
  }
}

#인터넷 게이트웨이 설정

resource "aws_internet_gateway" "SEC-PRD-IGW" {
  vpc_id = aws_vpc.SEC-PRD-VPC.id
  tags = {
    Name = "SEC-PRD-IGW"
  }
}

#NAT 게이트웨이 설정

# Elastic IP for NAT Gateway in Availability Zone 2A
resource "aws_eip" "SEC-PRD-NAT-EIP-2A" {
  domain = "vpc"
  tags = {
    Name = "SEC-PRD-NAT-EIP-2A"
  }
}

# Elastic IP for NAT Gateway in Availability Zone 2C
resource "aws_eip" "SEC-PRD-NAT-EIP-2C" {
  domain = "vpc"
  tags = {
    Name = "SEC-PRD-NAT-EIP-2C"
  }
}

resource "aws_nat_gateway" "SEC-PRD-NGW-2A" {
  allocation_id = aws_eip.SEC-PRD-NAT-EIP-2A.id
  subnet_id     = aws_subnet.SEC-PRD-VPC-TOMCAT-PRI-2A.id

  tags = {
    Name = "SEC-PRD-NGW-2A"
  }
}

resource "aws_nat_gateway" "SEC-PRD-NGW-2C" {
  allocation_id = aws_eip.SEC-PRD-NAT-EIP-2C.id
  subnet_id     = aws_subnet.SEC-PRD-VPC-TOMCAT-PRI-2C.id

  tags = {
    Name = "SEC-PRD-NGW-2C"
  }
}

#라우팅 테이블 설정

resource "aws_route_table" "SEC-PRD-RT-PUB" {
  vpc_id = aws_vpc.SEC-PRD-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.SEC-PRD-IGW.id
  }
  tags = {
    Name = "SEC-PRD-RT-PUB"
  }
}

resource "aws_route_table" "SEC-PRD-RT-PRI-2A" {
  vpc_id = aws_vpc.SEC-PRD-VPC.id
  route {
    cidr_block = "192.168.0.0/16"  # VPC 내의 트래픽은 VPC 내에서 라우팅
    gateway_id = "local"
  }
  tags = {
    Name = "SEC-PRD-RT-PRI-2A"
  }
}

resource "aws_route_table" "SEC-PRD-RT-PRI-2C" {
  vpc_id = aws_vpc.SEC-PRD-VPC.id
  route {
    cidr_block = "192.168.0.0/16"  # VPC 내의 트래픽은 VPC 내에서 라우팅
    gateway_id = "local"
  }
  tags = {
    Name = "SEC-PRD-RT-PRI-2C"
  }
}

resource "aws_route_table_association" "SEC-PRD-VPC-NGINX-PUB-2A_association" {
  subnet_id = aws_subnet.SEC-PRD-VPC-NGINX-PUB-2A.id
  route_table_id = aws_route_table.SEC-PRD-RT-PUB.id
}

resource "aws_route_table_association" "SEC-PRD-VPC-NGINX-PUB-2C_association" {
  subnet_id = aws_subnet.SEC-PRD-VPC-NGINX-PUB-2C.id
  route_table_id = aws_route_table.SEC-PRD-RT-PUB.id
}

resource "aws_route_table_association" "SEC-PRD-VPC-TOMCAT-PRI-2A_association" {
  subnet_id = aws_subnet.SEC-PRD-VPC-TOMCAT-PRI-2A.id
  route_table_id = aws_route_table.SEC-PRD-RT-PRI-2A.id
}

resource "aws_route_table_association" "SEC-PRD-VPC-TOMCAT-PRI-2C_association" {
  subnet_id = aws_subnet.SEC-PRD-VPC-TOMCAT-PRI-2C.id
  route_table_id = aws_route_table.SEC-PRD-RT-PRI-2C.id
}
