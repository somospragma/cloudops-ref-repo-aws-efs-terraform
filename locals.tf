###########################################
# Local Values and Transformations
# PC-IAC-003: Nomenclatura centralizada
# PC-IAC-012: Estructuras de datos reutilizables
###########################################

locals {
  # Prefijo de gobernanza para nomenclatura estándar (PC-IAC-003)
  governance_prefix = "${var.client}-${var.project}-${var.environment}"

  # Construcción de nombres de EFS File Systems con nomenclatura estándar
  # Patrón: {client}-{project}-{environment}-efs-{key}
  efs_names = {
    for key, config in var.efs_config : key => "${local.governance_prefix}-efs-${key}"
  }

  # Construcción de nombres de Access Points
  # Patrón: {client}-{project}-{environment}-efs-ap-{efs_key}-{ap_name}
  access_point_names = {
    for item in local.access_points_flat : item.unique_key => "${local.governance_prefix}-efs-ap-${item.efs_key}-${item.access_point.name}"
  }

  # Aplanamiento de Access Points para for_each (PC-IAC-012)
  access_points_flat = flatten([
    for efs_key, efs in var.efs_config : [
      for ap in efs.access_points : {
        efs_key      = efs_key
        access_point = ap
        unique_key   = "${efs_key}-${ap.name}"
      }
    ]
  ])

  # Aplanamiento de Mount Targets para for_each (PC-IAC-012)
  mount_targets_flat = flatten([
    for efs_key, efs in var.efs_config : [
      for subnet_id in efs.subnet_ids : {
        efs_key         = efs_key
        subnet_id       = subnet_id
        unique_key      = "${efs_key}-${subnet_id}"
        security_groups = efs.security_groups
      }
    ]
  ])
}
