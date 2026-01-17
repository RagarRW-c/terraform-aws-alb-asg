resource "aws_security_group" "ec2" {
  name = "asg-ec2-sg"
  description = "EC2 instances behind ALB"
  vpc_id = var.vpc_id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "asg-ec2-tg"
  })
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_launch_template" "version_1" {
  name_prefix = "portfolio-lt-"
  image_id = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.ec2.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    dnf install -y nginx
    systemctl enable nginx
    echo "<h1>Hello from $(hostname)</h1>" > /usr/share/nginx/html/index.html
    systemctl start nginx
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
  name = "portfolio-asg"
  min_size = 2
  desired_capacity = 2
  max_size = 4
  vpc_zone_identifier =var.private_subnet_ids
  target_group_arns = [var.target_group_arn]
  health_check_type = "ELB"

  launch_template {
    id = aws_launch_template.version_1.id
    version = "$Latest"
  }

  tag {
    key = "Name"
    value = "portfolio-asg"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}