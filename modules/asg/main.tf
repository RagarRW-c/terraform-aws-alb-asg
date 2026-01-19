resource "aws_security_group" "ec2" {
  name        = "asg-ec2-sg"
  description = "EC2 instances behind ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "asg-ec2-tg"
  })
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_launch_template" "version_1" {
  name_prefix   = "portfolio-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.ec2.id]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2.name
  }

  user_data = base64encode(<<-EOF
#!/bin/bash
#!/bin/bash
set -xe

dnf update -y
dnf install -y docker awscli

systemctl enable docker
systemctl start docker

aws ecr get-login-password --region eu-central-1 \
| docker login --username AWS --password-stdin 242046727288.dkr.ecr.eu-central-1.amazonaws.com

docker pull 242046727288.dkr.ecr.eu-central-1.amazonaws.com/portfolio-app:latest

docker run -d -p 80:80 \
  --name portfolio-app \
  242046727288.dkr.ecr.eu-central-1.amazonaws.com/portfolio-app:latest
EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = merge(var.tags, {
      Name = "portfolio-asg-instance"
    })
  }

}


resource "aws_autoscaling_group" "asg_version_1" {
  name                = "portfolio-asg"
  min_size            = 2
  desired_capacity    = 2
  max_size            = 4
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [var.target_group_arn]
  health_check_type   = "ELB"

  launch_template {
    id      = aws_launch_template.version_1.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "portfolio-asg"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "cpu-scale-out"
  autoscaling_group_name = aws_autoscaling_group.asg_version_1.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "cpu-scale-in"
  autoscaling_group_name = aws_autoscaling_group.asg_version_1.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}


resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = var.scale_out_cpu_threshold

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_version_1.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_out.arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = var.scale_in_cpu_threshold

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_version_1.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_in.arn]

  tags = var.tags
}
