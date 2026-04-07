###########################################
# Version Requirements - Terraform & Providers
# PC-IAC-005: Alias consumidor aws.project
# PC-IAC-006: Pinning de versiones
###########################################

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.31.0"
      configuration_aliases = [aws.project]
    }
  }
}
