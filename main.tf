provider "aws" {
  region = var.vpc_region
}

data "aws_key_pair" "deployer" {
  key_name = var.key_pair_name
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
      Name = "web-app-infra-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr_block
  availability_zone       = var.public_subnet_availability_zone

  tags = {
      Name = "web-app-infra-public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr_block
  availability_zone       = var.private_subnet_availability_zone
  map_public_ip_on_launch = false

  tags = {
      Name = "web-app-infra-private-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  tags = {
    Name = "web-app-internet-gateway"
  }
}

resource "aws_internet_gateway_attachment" "ig_vpc" {
  internet_gateway_id = aws_internet_gateway.igw.id
  vpc_id              = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
}

resource "aws_eip" "nat" {}

resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = aws_nat_gateway.main.id
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "public" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}

resource "aws_security_group" "private" {
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "private_allow_tcp" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = [var.public_subnet_cidr_block]
  security_group_id = aws_security_group.private.id
}

resource "aws_security_group_rule" "private_allow_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1" 
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.private.id
}

resource "aws_security_group_rule" "private_allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.public_subnet_cidr_block]
  security_group_id = aws_security_group.private.id
}

resource "aws_instance" "public" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.public.id]
  key_name      = data.aws_key_pair.deployer.key_name
  associate_public_ip_address = true
  
  tags = {
    Name = "web-app-infra-public-instance"
  }
}

resource "aws_instance" "private" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private.id]
  key_name      = data.aws_key_pair.deployer.key_name

  user_data = templatefile("./docker-image-setup.sh", {})

  tags = {
    Name = "web-app-infra-private-instance"
  }
}

output "public_instance_ip" {
  value = aws_instance.public.public_ip
}