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


module "s3-bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "2.9.0"
  # insert the 5 required variables here
  acceleration_status = "Suspended"
  bucket = "img-mgr-t75675464"
  #policy = 
}


#-----Autoscaling group-----
resource "aws_autoscaling_group" "img-mgr-asg" {
  availability_zones        = [ "us-east-1a", "us-east-1b" ]
  name                      = "img-mgr"
  max_size                  = 4
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true

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
  availability_zones = ["us-east-2a", "us-east-2b"]

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

  instances                   = [aws_autoscaling_group.img-mgr-asg.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "img-mgr-lb"
  }
}