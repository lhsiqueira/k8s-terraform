terraform {
  backend "s3" {
    bucket = "eks-terraform-dev"
    key    = "devops-eks-1.21"
    region = "us-east-1"
  }
}

