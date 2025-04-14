terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.94.1"
    }
  }


backend "s3" {
    bucket = "sivaram-practice-terraform-dev"
    key    = "app-alb"
    region = "us-east-1"
    dynamodb_table = "sivaram-practice-terraform-locking-dev"
  }

}

provider "aws" {
  region = "us-east-1"
}