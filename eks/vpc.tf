variable "region" {
  default     = "us-east-1"
  description = "AWS region"
}

provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "cluster-dev-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.66.0"

  name                 = "cluster-dev-eks-vpc"
  cidr                 = "10.51.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.51.1.0/24", "10.51.2.0/24", "10.51.3.0/24"]
  public_subnets       = ["10.51.4.0/24", "10.51.5.0/24", "10.51.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}