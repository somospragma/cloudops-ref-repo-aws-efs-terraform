###########################################
# Provider Configuration for Sample
# PC-IAC-005: Provider con alias y default_tags
###########################################

provider "aws" {
  alias   = "principal"
  region  = var.aws_region
  profile = var.profile

  default_tags {
    tags = var.common_tags
  }
}
