###########################################
# Invocación del Módulo Padre (EFS)
# PC-IAC-026: main.tf solo invoca el módulo, sin bloques locals
# PC-IAC-013: Orden de atributos en bloque module
###########################################

module "efs" {
  # A. Fuente del Módulo
  source = "../"

  # B. Providers (PC-IAC-005)
  providers = {
    aws.project = aws.principal
  }

  # C. Variables de Gobernanza (PC-IAC-003)
  client      = var.client
  project     = var.project
  environment = var.environment

  # E. Variables de Configuración (PC-IAC-026)
  # ✅ Consumir configuración transformada desde locals (nunca var.* directo)
  efs_config = local.efs_config_transformed
}
