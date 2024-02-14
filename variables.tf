variable "vpc_region" {
    description = "The region where the VPC will be created"
    type        = string
    default     = "us-east-1"
}

variable "vpc_cidr_block" {
    description = "The CIDR block for the VPC"
    type        = string
    default     = "10.0.0.0/16"
}

variable "private_subnet_cidr_block" {
    description = "The CIDR blocks for the private subnets"
    type        = string
    default     = "10.0.2.0/24"
}

variable "public_subnet_cidr_block" {
    description = "The CIDR blocks for the public subnets"
    type        = string
    default     = "10.0.1.0/24"
}

variable "private_subnet_availability_zone" {
    description = "The availability zones for the private subnets"
    type        = string
    default     = "us-east-1a"
}

variable "public_subnet_availability_zone" {
    description = "The availability zones for the public subnets"
    type        = string
    default     = "us-east-1a"
}

variable "key_pair_name" {
    description = "The name of the key pair to use for the EC2 instance"
    type        = string
    default     = "devops-projects-key"
}

variable "instance_type" {
    description = "The type of EC2 instance"
    type        = string
    default     = "t2.micro"
}

variable "instance_ami" {
    description = "The AMI ID for the EC2 instance"
    type        = string
    default     = "ami-0c7217cdde317cfec" # ubuntu, us-east-1
}