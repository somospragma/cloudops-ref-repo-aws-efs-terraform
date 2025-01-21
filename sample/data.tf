data "aws_caller_identity" "current" {}

data "aws_vpc" "vpc_hefesto" {
  filter {
    name   = "tag:Name"
    values = ["${var.client}-${var.project}-${var.environment}-vpc"]
  }
}

data "aws_subnet" "private_subnet" {
  filter {
    name   = "tag:Name"
    values = ["${var.client}-${var.project}-${var.environment}-subnet-private-subnet-1"] 
  }
}