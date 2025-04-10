terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.86.1"
    }
  }


backend "s3" {
    bucket = "sivaram-practice-terraform-dev"
    key    = "vpc"
    region = "us-east-1"
    dynamodb_table = "sivaram-practice-terraform-locking-dev"
  }

}

provider "aws" {
  region = "us-east-1"
}