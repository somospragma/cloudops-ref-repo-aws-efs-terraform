###########################################
# Data Sources del Ejemplo
# PC-IAC-011: Data Sources para obtener IDs dinámicos
# PC-IAC-017: Búsqueda por nomenclatura estándar
###########################################

# Obtener VPC por nomenclatura estándar
data "aws_vpc" "selected" {
  provider = aws.principal

  filter {
    name   = "tag:Name"
    values = ["${var.client}-${var.project}-${var.environment}-vpc"]
  }
}

# Obtener Subnets privadas
data "aws_subnets" "private" {
  provider = aws.principal

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "tag:Type"
    values = ["private"]
  }
}

# Obtener Security Group para EFS
data "aws_security_group" "efs" {
  provider = aws.principal

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "tag:Name"
    values = ["${var.client}-${var.project}-${var.environment}-sg-efs-*"]
  }
}

# Obtener KMS Key para EFS (opcional - puede no existir)
data "aws_kms_key" "efs" {
  provider = aws.principal
  key_id   = "alias/${var.client}-${var.project}-${var.environment}-kms-efs"
}
