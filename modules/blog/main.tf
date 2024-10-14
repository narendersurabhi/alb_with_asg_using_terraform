data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_filter.name]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [var.ami_filter.owner] # Bitnami
}


module "blog_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.environment.name
  cidr = "${var.environment.network_prefix}.0.0/16"

  azs             = ["us-east-2a", "us-east-2b", "us-east-2c"]
  public_subnets  = ["${var.environment.network_prefix}.101.0/24", "${var.environment.network_prefix}.102.0/24", "${var.environment.network_prefix}.103.0/24"]

  tags = {
    Terraform = "true"
    Environment = var.environment.name
  }
}

resource "aws_launch_template" "blog_template" {
  name_prefix   = "${var.environment.name}-"
  image_id      = data.aws_ami.app_ami.id
  instance_type = var.instance_type

  //user_data       = file("user-data.sh")


  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.sg_web.id]
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on         = [aws_security_group.sg_web]  
}

resource "aws_autoscaling_group" "blog_asg" {
  //availability_zones = ["us-east-2a", "us-east-2b"]
  desired_capacity   = var.asg_desired_capacity
  max_size           = var.asg_max_size
  min_size           = var.asg_min_size

  name = "${var.environment.name}-blog"

  vpc_zone_identifier   = module.blog_vpc.public_subnets
  //security_groups = [aws_security_group.sg_web.id]   
  //launch_configuration = aws_launch_configuration.blog_template.name
  
  launch_template {
    id      = aws_launch_template.blog_template.id
    version = aws_launch_template.blog_template.latest_version
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }  

  tag {
    key                 = "Environment"
    value               = var.environment.name
    propagate_at_launch = true
  }

  depends_on         = [aws_launch_template.blog_template, module.blog_vpc]  

}



resource "aws_lb" "blog_alb" {
  name               = "${var.environment.name}-blog-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_lb.id]
  subnets            = module.blog_vpc.public_subnets
  depends_on         = [aws_security_group.sg_lb, module.blog_vpc]  
}

resource "aws_lb_target_group" "blog_tg" {
  name     = "${var.environment.name}-blog-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.blog_vpc.vpc_id

  depends_on         = [module.blog_vpc]
}

resource "aws_autoscaling_attachment" "auto_to_targ" {
  autoscaling_group_name = aws_autoscaling_group.blog_asg.id
  //alb_target_group_arn   = aws_lb_target_group.blog_tg.arn
  lb_target_group_arn    = aws_lb_target_group.blog_tg.arn

  depends_on         = [aws_autoscaling_group.blog_asg, aws_lb_target_group.blog_tg]
}

resource "aws_security_group" "sg_lb" {
  name = "${var.environment.name}_blog_sg_lb"
  ingress {
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

  vpc_id = module.blog_vpc.vpc_id

  depends_on         = [module.blog_vpc]
}

resource "aws_security_group" "sg_web" {
  name = "${var.environment.name}-blog-web-sg"
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_lb.id]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  vpc_id = module.blog_vpc.vpc_id

  depends_on         = [module.blog_vpc]
}


resource "aws_lb_listener" "blog_lb_lstnr" {
  load_balancer_arn = aws_lb.blog_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blog_tg.arn
  }

  depends_on         = [aws_lb.blog_alb, aws_lb_target_group.blog_tg]
}