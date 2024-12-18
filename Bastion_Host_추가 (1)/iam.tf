# IAM 역할 선언

resource "aws_iam_role" "nginx_role" {
  name = "nginx-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "nginx-role"
    Environment = "production"
  }
}

# IAM 역할에 대한 ECR 정책 추가

resource "aws_iam_role_policy" "nginx_ecr_policy" {
  name   = "ECRPolicy"
  role   = aws_iam_role.nginx_role.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:BatchCheckLayerAvailability",
          "ecr:DescribeRepositories",
          "ecr:CreateRepository",
          "ecr:GetAuthorizationToken" # ECR 로그인에 필요
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM 인스턴스 프로파일 선언

resource "aws_iam_instance_profile" "nginx_instance_profile" {
  name = "nginx-instance-profile"
  role = aws_iam_role.nginx_role.name

  tags = {
    Name        = "nginx-instance-profile"
    Environment = "production"
  }
}
