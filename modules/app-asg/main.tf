#module "VPC" {
#    source = "./modules/vpc"  
#    private_ips = ["${module.vpc.private_subnets}"]  
#}

#resource "aws_iam_role" "dev-img-mgr-permissions-role" {
#  name = "test_role"
#
#  assume_role_policy = <<EOF
#  {
#    "Version": "2012-10-17",
#    "Statement": [
#        {
#            "Sid": "VisualEditor0",
#            "Effect": "Allow",
#            "Action": [
#                "s3:GetObject",
#                "s3:PutObject",
#                "s3:DeleteObject"
#            ],
#            "Resource": "arn:aws:s3:::img-mgr-t75675464/*"
#        },
#        {
#            "Sid": "VisualEditor1",
#            "Effect": "Allow",
#            "Action": [
#                "s3:ListBucket"
#            ],
#            "Resource": "arn:aws:s3:::img-mgr-t75675464"
#        },
#        {
#            "Sid": "VisualEditor2",
#            "Effect": "Allow",
#            "Action": [
#                "ec2:DescribeTags"
#            ],
#            "Resource": "*"
#        }
#    ]
#}
#  EOF
#}

#-----Autoscaling group-----
resource "aws_autoscaling_group" "img-mgr-asg" {
  name                      = "img-mgr"
  max_size                  = 4
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  vpc_zone_identifier = var.private_subnets

  launch_template {
    id = aws_launch_template.img-mgr.id
  }
  tag {
    key                 = "name"
    value               = "img-mgr-asg"
    propagate_at_launch = false
  }
}
#-----Launch Template-----
resource "aws_launch_template" "img-mgr" {
  name = "img-mgr"

  image_id = "ami-087c17d1fe0178315"
  instance_type = "t2.micro"


  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = false
  }

  #vpc_security_group_ids = ["sg-12345678"]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "test"
    }
  }

  user_data = filebase64("${path.module}/img-mgr.sh")
}

#-----Load Balancer-----
resource "aws_elb" "img-mgr-lb" {
  name               = "img-mgr-lb"
  subnets = var.public_subnets

  #access_logs {
  #  bucket        = "foo"
  #  bucket_prefix = "bar"
  #  interval      = 60
  #}

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "img-mgr-lb"
  }
}

#-----LB Security Group-----
resource "aws_security_group" "allow_http_to_lb" {
  name        = "lb_http"
  description = "Allow HTTP traffic to lb"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http"
  }
}

#-----EC2 Security Group-----

resource "aws_security_group" "allow_http_to_instance" {
  name        = "ec2_http"
  description = "Allow HTTP from load balancer to ec2 instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = []
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.3.0/24", "10.0.4.0/24"]
  }

  tags = {
    Name = "allow_http"
  }
}