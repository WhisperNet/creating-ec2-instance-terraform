terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.21.0"
    }
    jenkins = {
      source = "taiidani/jenkins"
      version = "0.11.0"
    }
  }
}