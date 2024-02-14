# Project Infrastructure Architecture

This project implements a web application infrastructure on AWS. The architecture consists of the following components:

## VPC (Virtual Private Cloud)

The project utilizes a single VPC to isolate the resources. The VPC is divided into two subnets:

- Public Subnet: This subnet is accessible from the internet and hosts a single EC2 instance.
- Private Subnet: This subnet is not directly accessible from the internet and hosts another EC2 instance.

## EC2 Instances

### Public EC2 Instance

The public subnet contains an EC2 instance that serves as the web server. It is accessible from the internet and hosts the web application. This instance has an associated Internet Gateway to allow inbound and outbound traffic.

### Private EC2 Instance

The private subnet contains an EC2 instance that serves as the backend server. It is not directly accessible from the internet. To enable outbound internet access for this instance, a NAT Gateway is used. The private EC2 instance has Docker installed and runs a containerized REST API. The API responds with a "Hello World" object when accessed on port 8080: `https://github.com/thomaspoignant/hello-world-rest-json`.

For this project, it is possible to make the GET request to this api only after accessing the public EC2 instance, using `curl`, for example. The main purpose of this project is to create a simple project that provides a basic infrastructure in AWS using terraform.

## SSH Access

To access the private EC2 instance, you can SSH into the public EC2 instance and then access the private instance from there (also via SSH).

Both instances are connected using the key specified using the key_pair_name variable inside the `variables.tf` file.

# Diagram
![image](https://github.com/viniciusvianadp/simple-private-ec2-project/assets/86125479/c0635244-f4f2-41c7-a369-e82f1680b1f6)
