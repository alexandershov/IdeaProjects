# Terraform configurations are written in HCL (Hashicorp Configuration Language)
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "app_server" {
  # you can set count = 2 and terraform will create an additional ec2 instance
  # after `terraform apply`
  count         = 2
  ami           = "ami-830c94e3"
  instance_type = "t2.micro"

  tags = {
    Name = "TestingTerraform"
  }
}
