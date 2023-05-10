variable "name" {
  description = "A name prefix to apply to all resources"
  type        = string
}

variable "ami_id" {
  description = "The ID of the AMI to use for the launch template"
  type        = string
}

variable "instance_type" {
  description = "The EC2 instance type to use for the launch template"
  type        = string
}

variable "vpc_cidr" {
  description = "The EC2 instance type to use for the launch template"
  type        = string
}
# variable "vpc_cidr" {
#   description = "The CIDR block to use for the VPC"
#   type        = string
# }

# variable "public_subnet_cidrs" {
#   description = "The CIDR blocks to use for the public subnets"
#   type        = list(string)
# }

# variable "private_subnet_cidrs" {
#   description = "The CIDR blocks to use for the private subnets"
#   type        = list(string)
# }

# variable "ssh_cidr_blocks" {
#   description = "The CIDR blocks to allow SSH access from"
#   type        = list(string)
# }

# variable "http_cidr_blocks" {
#   description = "The CIDR blocks to allow HTTP access from"
#   type        = list(string)
# }



variable "min_size" {
  description = "The minimum size of the autoscaling group"
  type        = number
}

variable "max_size" {
  description = "The maximum size of the autoscaling group"
  type        = number
}

variable "region" {
  description = "Region to create the autoscaling group"
  type        = string
}

variable "desired_capacity" {
  description = "The maximum size of the autoscaling group"
  type        = number
}

variable "termination_policies" {
  description = "The maximum size of the autoscaling group"
  type        = list(string)
}

variable "health_check_grace_period" {
  description = "The maximum size of the autoscaling group"
  type        = number
}

variable "health_check_type" {
  description = "The maximum size of the autoscaling group"
  type        = string
}