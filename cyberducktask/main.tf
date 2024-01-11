# main.tf

# Configuring the AWS provider
provider "aws" {
  region = "eu-west-1"  # Replace with clients desired region
}

# Create a VPC - assuming this already exists 
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "2.0.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"
}

# Create a subnet within the VPC - assuming this already exists 
module "subnet" {
  source = "terraform-aws-modules/subnet/aws" #unless we use local module
  version = "2.0.0"

  vpc_id     = module.vpc.vpc_id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-1"  # Replace with the clients desired availability zone
}

# Create a security group for the RDS instance
module "security_group" {
  source = "terraform-aws-modules/security-group/aws" #unless we use local module
  version = "3.0.0"

  name        = "rds-security-group"
  description = "Security group for RDS instance"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "auroraMySQL"
    }
  ]
}

# Creating the RDS instance 
# It will an Aurora cluster due to the requirements
module "aurora" {
  source = "terraform-aws-modules/rds/aws" #unless we use local module
  version = "3.0.0"

  identifier            = "my-aurora-cluster"
  engine                = "aurora-mysql"  # Use "aurora-postgresql" for PostgreSQL-compatible Aurora - as it is higly available
  engine_version        = "8.0.32.mysql_aurora.3.05"
  instance_class        = "db.t3.2xlarge" # This has burstable performance 
  allocated_storage     = 50
  storage_type          = "gp2"
  username              = "admin"
  password              = "admin123"
  vpc_security_group_ids = [module.security_group.this_security_group_id] # the security groups
  subnet_ids            = [module.subnet.this_subnet_id] 
}