###########################################
# Configuración de Ejemplo para Módulo EFS
# PC-IAC-026: Configuración declarativa sin IDs hardcodeados
###########################################

# Variables de gobernanza
client      = "pragma"
project     = "sopp"
environment = "dev"

# Configuración AWS
aws_region = "us-east-1"
profile    = "pra_chaptercloudops_lab"

# Tags comunes (PC-IAC-004)
common_tags = {
  client      = "pragma"
  project     = "sopp"
  environment = "dev"
  provisioned = "terraform"
  area        = "infrastructure"
  application = "sopp"
}

# Configuración de EFS
# NOTA: Los campos vacíos ("", []) se llenarán automáticamente desde data sources en locals.tf
efs_config = {
  "workspace" = {
    # KMS key ARN - vacío para inyección dinámica desde data source
    kms_key_arn = ""

    # Configuración de rendimiento
    performance_mode = "generalPurpose"
    throughput_mode  = "bursting"

    # Red - vacíos para inyección dinámica desde data sources
    subnet_ids      = [] # Se llenarán desde data.aws_subnets.private
    security_groups = [] # Se llenarán desde data.aws_security_group.efs

    # Protección de replicación
    replication_overwrite_protection = "ENABLED"

    # Políticas de ciclo de vida
    lifecycle_policy = [
      {
        transition_to_ia = "AFTER_30_DAYS"
      }
    ]

    # Puntos de acceso
    access_points = [
      {
        name        = "tmp"
        path        = "/tmp"
        owner_gid   = 1000
        owner_uid   = 1000
        permissions = "755"
        posix_user = {
          gid            = 1000
          uid            = 1000
          secondary_gids = []
        }
      }
    ]

    # Tags adicionales específicos
    additional_tags = {
      purpose = "workspace-storage"
      owner   = "cloudops-team"
    }
  }
}
