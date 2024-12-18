# AMI 생성

resource "aws_ami_from_instance" "nginx_web_image" {
  count                  = 1
  name                   = "nginx_web_image"
  source_instance_id     = aws_instance.EC2_3T_Nginx.id
  snapshot_without_reboot = false

  depends_on = [
    aws_instance.EC2_3T_Nginx  # 인스턴스가 생성된 후 AMI 생성
  ]
  description = "App Tier"
}

resource "aws_ami_from_instance" "tomcat_web_image" {
  count                   = 1
  name                    = "tomcat_web_image"
  source_instance_id      = aws_instance.EC2_3T_Tomcat.id
  snapshot_without_reboot  = false

  depends_on = [
    aws_instance.EC2_3T_Tomcat  # 인스턴스가 생성된 후 AMI 생성
  ]
  description = "App Tier"
}

# 런치 템플릿 생성 (Nginx)
resource "aws_launch_template" "nginx_template" {
  name          = "nginx-template"
  image_id     = aws_ami_from_instance.nginx_web_image[0].id
  instance_type = "t2.micro"

  iam_instance_profile {
    arn = aws_iam_instance_profile.nginx_instance_profile.arn  # 참조 수정
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.SEC-PRD-VPC-NGINX-PUB-SG-2A.id]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# 런치 템플릿 생성 (Tomcat)
resource "aws_launch_template" "tomcat_template" {
  name          = "tomcat-template"
  image_id     = aws_ami_from_instance.tomcat_web_image[0].id
  instance_type = "t2.micro"
  key_name      = "aws-ssh-keypair"

  iam_instance_profile {
    arn = aws_iam_instance_profile.nginx_instance_profile.arn  # 참조 수정
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.VEC-PRD-VPC-TOMCAT-PRI-SG-2A.id]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Target Group 생성
resource "aws_lb_target_group" "nginx_target_group" {
  name     = "nginx-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.SEC-PRD-VPC.id

  health_check {
    path = "/health"
  }
}

resource "aws_lb_target_group" "tomcat_target_group" {
  name     = "tomcat-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.SEC-PRD-VPC.id

  health_check {
    path                 = "/"
    protocol             = "HTTP"
    matcher              = "200"
    interval             = 30
    timeout              = 5
    healthy_threshold    = 2
    unhealthy_threshold  = 2
  }

  tags = {
    Name = "tomcat-target-group"
  }
}

# 오토 스케일링 그룹 생성 (Nginx)
resource "aws_autoscaling_group" "nginx_autoscaling_group" {
  name                = "nginx-autoscaling-group"
  desired_capacity    = 2
  min_size            = 2
  max_size            = 4
  vpc_zone_identifier = [aws_subnet.SEC-PRD-VPC-NGINX-PUB-2A.id, aws_subnet.SEC-PRD-VPC-NGINX-PUB-2C.id]
  target_group_arns   = [aws_lb_target_group.nginx_target_group.arn]

  launch_template {
    id      = aws_launch_template.nginx_template.id
    version = "$Latest"
  }

  tag {
    key                 = "aws-ssh-keypair"
    value               = "ec2_3t_nginx_v2"
    propagate_at_launch = true
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300
}

# 오토 스케일링 그룹 생성 (Tomcat)
resource "aws_autoscaling_group" "tomcat_autoscaling_group" {
  name                = "tomcat-autoscaling-group"
  desired_capacity    = 2
  min_size            = 2
  max_size            = 4
  vpc_zone_identifier = [aws_subnet.SEC-PRD-VPC-TOMCAT-PRI-2A.id, aws_subnet.SEC-PRD-VPC-TOMCAT-PRI-2C.id]
  target_group_arns    = [aws_lb_target_group.tomcat_target_group.arn]

  launch_template {
    id      = aws_launch_template.tomcat_template.id
    version = "$Latest"
  }

  tag {
    key                 = "aws-ssh-keypair"
    value               = "ec2_3t_tomcat"
    propagate_at_launch = true
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300
}

# Auto Scaling Policy
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up-policy"
  scaling_adjustment      = 1
  adjustment_type         = "ChangeInCapacity"
  autoscaling_group_name  = aws_autoscaling_group.tomcat_autoscaling_group.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down-policy"
  scaling_adjustment      = -1
  adjustment_type         = "ChangeInCapacity"
  autoscaling_group_name  = aws_autoscaling_group.tomcat_autoscaling_group.name
}

# ALB 생성 (Nginx)
resource "aws_lb" "nginx_autoscaling_alb" {
  name               = "nginx-autoscaling-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.SEC-PRD-VPC-NGINX-PUB-SG-2A.id]
  subnets            = [
    aws_subnet.SEC-PRD-VPC-NGINX-PUB-2A.id,
    aws_subnet.SEC-PRD-VPC-NGINX-PUB-2C.id  # 서로 다른 가용 영역의 서브넷
  ]
  enable_deletion_protection = false

  tags = {
    Name = "nginx-autoscaling-alb"
  }
}

# ALB 생성 (Tomcat)
resource "aws_lb" "tomcat_autoscaling_alb" {
  name               = "tomcat-autoscaling-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.VEC-PRD-VPC-TOMCAT-PRI-SG-2A.id]
  subnets            = [
    aws_subnet.SEC-PRD-VPC-TOMCAT-PRI-2A.id,
    aws_subnet.SEC-PRD-VPC-TOMCAT-PRI-2C.id  # 서로 다른 가용 영역의 서브넷
  ]
  enable_deletion_protection = false

  tags = {
    Name = "tomcat-autoscaling-alb"
  }
}

# ALB 리스너 생성 (Nginx)
resource "aws_lb_listener" "nginx_listener" {
  load_balancer_arn = aws_lb.nginx_autoscaling_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_target_group.arn
  }
}

# ALB 리스너 생성 (Tomcat)
resource "aws_lb_listener" "tomcat_listener" {
  load_balancer_arn = aws_lb.tomcat_autoscaling_alb.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tomcat_target_group.arn
  }
}
