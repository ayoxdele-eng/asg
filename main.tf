data "template_file" "user_data_script" {
  template = "${file("${path.module}/server.sh")}"
}

# Create a new VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
}


resource "aws_subnet" "my_subnet_a" {
  cidr_block = "10.0.1.0/24"
  vpc_id     = aws_vpc.my_vpc.id
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "my_subnet_b" {
  cidr_block = "10.0.2.0/24"
  vpc_id     = aws_vpc.my_vpc.id
  availability_zone = "us-east-1b"
}



resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.my_vpc.id
}


# resource "aws_eip" "eip" {
#   vpc = true
# }

# resource "aws_nat_gateway" "nat_gateway_a" {
#   allocation_id = aws_eip.eip.id
#   subnet_id     = aws_subnet.my_subnet_a.id
#     depends_on = [aws_internet_gateway.gateway]
# }

# resource "aws_nat_gateway" "nat_gateway_b" {
#   allocation_id = aws_eip.eip.id
#   subnet_id     = aws_subnet.my_subnet_b.id
# }



resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.my_vpc.id
  

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
    # nat_gateway_id = aws_nat_gateway.nat_gateway_a.id
  }

#   route {
#     cidr_block = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat_gateway_a.id
#   }

#   route {
#     cidr_block = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat_gateway_b.id
#   }
}
# resource "aws_route" "route" {
#   route_table_id = aws_route_table.route_table.id
#  destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id = aws_nat_gateway.nat_gateway_a.id
# }
# resource "aws_route_table" "route_table_a" {
#   vpc_id = aws_vpc.my_vpc.id
  

#   route {
#     cidr_block = "0.0.0.0/0"
    
#     nat_gateway_id = aws_nat_gateway.nat_gateway_a.id
#   }

#   route {
#     cidr_block = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat_gateway_a.id
#   }

#   route {
#     cidr_block = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat_gateway_b.id
#   }
# }

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "my_rta" {
#   subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.route_table.id
  subnet_id = aws_subnet.my_subnet_a.id
}

resource "aws_route_table_association" "my_rtb" {
#   subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.route_table.id
  subnet_id = aws_subnet.my_subnet_b.id 
}


resource "aws_security_group" "my_sg" {
  vpc_id = aws_vpc.my_vpc.id  
   name_prefix = "my_sg_"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    # security_groups = [aws_security_group.lb_sg.id]
     cidr_blocks      = ["0.0.0.0/0"] 
  }

  egress {

    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

  }
  # egress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   security_groups = [aws_security_group.lb_sg.id]
  # }

}

# resource "aws_security_group_rule" "load_balancer_sg_rule" {
#   type = "ingress"
#   from_port = 80
#   to_port = 80
#   protocol = "tcp"
#   source_security_group_id = aws_security_group.lb_sg.id
#   security_group_id = aws_security_group.my_sg.id
# }

resource "aws_security_group" "lb_sg" {
  vpc_id = aws_vpc.my_vpc.id  
  name_prefix = "my_lb_sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
     cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]
    # security_groups = [aws_security_group.my_sg.id]
    
  }
}


# Launch Template
# resource "aws_launch_template" "my_launch_template" {
#   name_prefix      = "my_launch_template_"
#   image_id         = var.ami_id
#   instance_type    = var.instance_type
#   key_name = "demo"
# #   security_group_names  = [aws_security_group.my_sg.name]

#   network_interfaces {
#     device_index = 0

#     # subnet_id = aws_subnet.my_subnet_a.id
#     security_groups = [aws_security_group.my_sg.id]

#     associate_public_ip_address = true

    
#   }
# #   security_group_names = [aws_security_group.my_sg.id]
# #    vpc_security_group_ids = [aws_security_group.my_sg.id]
# #   user_data = filebase64("${path.module}/server.sh")
    
#   user_data = base64encode(data.template_file.user_data_script.rendered)

#   tag_specifications {
#     resource_type = "instance"
#     tags = {
#       Name = "my_instance"
#     }
#   }
# }

resource "aws_launch_configuration" "example" {
  name_prefix = "Launch_config_"  
  image_id = var.ami_id
  instance_type = var.instance_type
  associate_public_ip_address = true
  key_name = "demo"
  security_groups         = ["${aws_security_group.my_sg.id}"]
  user_data               = "${base64encode(file("server.sh"))}"
}


# Autoscaling Group
resource "aws_autoscaling_group" "my_autoscaling_group" {
  name_prefix                  = var.name
#   launch_template       {
#     id      = aws_launch_template.my_launch_template.id
#     version = "$Latest"
#   }
    launch_configuration = aws_launch_configuration.example.id
  #vpc_zone_identifier  = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
#   target_group_arns    = [aws_lb_target_group.my_target_group.arn]
  health_check_type    = var.health_check_type
  health_check_grace_period = var.health_check_grace_period
  termination_policies = var.termination_policies
  min_size             = var.min_size
  max_size             = var.max_size
  desired_capacity     = var.desired_capacity
  vpc_zone_identifier = [aws_subnet.my_subnet_a.id, aws_subnet.my_subnet_b.id]
#   tags = {
#     Terraform   = "true"
#     Environment =  "dev"
#   }

}



# Create a new Load Balancer
resource "aws_lb" "my_lb" {
  name               = "my-lb"
#   internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.my_subnet_a.id, aws_subnet.my_subnet_b.id]
  security_groups    = [aws_security_group.lb_sg.id]
}

# Create a new Target Group
resource "aws_lb_target_group" "lb_target" {
  name        = "example-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.my_vpc.id

  health_check {
    path     = "/"
    interval = 30
    timeout  = 5
  }
}

resource "aws_lb_listener" "example" {
  load_balancer_arn = aws_lb.my_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.lb_target.arn
    type             = "forward"
  }
}
