###########################################
# Data Sources
# PC-IAC-011: Data Sources deben estar en el Root
###########################################

# Data source para obtener la región actual
data "aws_region" "current" {
  provider = aws.project
}

# NOTA: Los Data Sources para VPC, Subnets, Security Groups y KMS Keys
# deben declararse en el Módulo Raíz (IaC Root) y pasarse como variables
# de entrada al módulo (PC-IAC-011, PC-IAC-023)
