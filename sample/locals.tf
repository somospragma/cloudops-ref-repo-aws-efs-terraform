###########################################
# Transformaciones del Ejemplo
# PC-IAC-026: Patrón de transformación en sample/
# PC-IAC-009: Inyección de IDs dinámicos
###########################################

locals {
  # Prefijo de gobernanza (PC-IAC-003)
  governance_prefix = "${var.client}-${var.project}-${var.environment}"

  # PC-IAC-026: Transformar configuración inyectando IDs dinámicos desde data sources
  # Si los campos están vacíos, se llenan automáticamente desde data sources
  efs_config_transformed = {
    for key, config in var.efs_config : key => merge(config, {
      # Inyectar KMS key ARN si está vacío (PC-IAC-009)
      kms_key_arn = length(config.kms_key_arn) > 0 ? config.kms_key_arn : try(data.aws_kms_key.efs.arn, "")

      # Inyectar subnet IDs si están vacíos
      subnet_ids = length(config.subnet_ids) > 0 ? config.subnet_ids : data.aws_subnets.private.ids

      # Inyectar security groups si están vacíos
      security_groups = length(config.security_groups) > 0 ? config.security_groups : [data.aws_security_group.efs.id]
    })
  }
}
