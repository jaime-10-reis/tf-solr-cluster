terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">=3.25.0"
    }
  }
  backend "s3" {
    bucket = "jreis-spotsolr-tfstate"
    key = "prod/vpc/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "jreis-spotsolr-tfstate-lock"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}
