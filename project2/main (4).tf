# Provider configuration
provider "aws" {
  region = "ap-south-1"
}

# VPC Module
module "vpc" {
  source     = "./vpc"
  cidr_block = "10.0.0.0/16"
}

# Subnet Module
module "subnet" {
  source                            = "./subnet"
  vpc_id                            = module.vpc.vpc_id
  public_subnet_cidr                = "10.0.1.0/24"
  private_subnet_cidr               = "10.0.2.0/24"
  public_subnet_availability_zone   = "ap-south-1a"
  private_subnet_availability_zone  = "ap-south-1b"
}

# Internet Gateway Module
module "internet_gateway" {
  source = "./igw"
  vpc_id = module.vpc.vpc_id
}

# NAT Gateway Module
module "nat_gateway" {
  source           = "./nat"
  public_subnet_id = module.subnet.public_subnet_id
}

# Route Table Module
module "route_table" {
  source              = "./route_table"
  vpc_id              = module.vpc.vpc_id
  internet_gateway_id = module.internet_gateway.internet_gateway_id
  nat_gateway_id      = module.nat_gateway.nat_gateway_id
  public_subnet_id    = module.subnet.public_subnet_id
  private_subnet_id   = module.subnet.private_subnet_id
}

# EC2 Instance Module
module "ec2_instance" {
  source            = "./ec2"
  ami_id            = "ami-0dee22c13ea7a9a67" # Amazon Linux 2 AMI for ap-south-1, verify this is current before use
  instance_type     = "t2.micro"
  private_subnet_id = module.subnet.private_subnet_id
}

# Load Balancer Module
module "load_balancer" {
  source          = "./load_balancer"
  vpc_id          = module.vpc.vpc_id
  subnets         = [module.subnet.public_subnet_id, module.subnet.private_subnet_id]
  security_groups = [] # Provide at least one security group ID - most AWS accounts require this for an ALB
  ec2_instance_id = module.ec2_instance.instance_id
}

output "load_balancer_dns_name" {
  value = module.load_balancer.load_balancer_dns_name
}

output "ec2_instance_id" {
  value = module.ec2_instance.instance_id
}
