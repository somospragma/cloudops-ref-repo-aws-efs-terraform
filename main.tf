###########################################
# EFS Resources
# PC-IAC-010: Uso de for_each
# PC-IAC-020: Hardenizado de seguridad (cifrado obligatorio)
# PC-IAC-023: Responsabilidad única (solo recursos EFS)
###########################################

###########################################
# EFS File System
###########################################

resource "aws_efs_file_system" "this" {
  provider = aws.project
  for_each = var.efs_config

  # PC-IAC-003: Nomenclatura estándar desde locals
  creation_token = local.efs_names[each.key]

  # PC-IAC-020: Cifrado en reposo obligatorio
  encrypted  = true
  kms_key_id = length(each.value.kms_key_arn) > 0 ? each.value.kms_key_arn : null

  # Configuraciones de rendimiento
  performance_mode                = each.value.performance_mode
  throughput_mode                 = each.value.throughput_mode
  provisioned_throughput_in_mibps = each.value.throughput_mode == "provisioned" ? each.value.provisioned_throughput_in_mibps : null

  # PC-IAC-014: Bloques dinámicos para lifecycle policies
  dynamic "lifecycle_policy" {
    for_each = [
      for policy in each.value.lifecycle_policy : policy
      if policy.transition_to_ia != null
    ]
    content {
      transition_to_ia = lifecycle_policy.value.transition_to_ia
    }
  }

  dynamic "lifecycle_policy" {
    for_each = [
      for policy in each.value.lifecycle_policy : policy
      if policy.transition_to_archive != null
    ]
    content {
      transition_to_archive = lifecycle_policy.value.transition_to_archive
    }
  }

  dynamic "lifecycle_policy" {
    for_each = [
      for policy in each.value.lifecycle_policy : policy
      if policy.transition_to_primary_storage_class != null
    ]
    content {
      transition_to_primary_storage_class = lifecycle_policy.value.transition_to_primary_storage_class
    }
  }

  # Protección de replicación
  protection {
    replication_overwrite = each.value.replication_overwrite_protection
  }

  # PC-IAC-004: Tags con merge de Name y additional_tags
  tags = merge(
    { Name = local.efs_names[each.key] },
    each.value.additional_tags
  )
}

###########################################
# EFS Mount Targets
###########################################

resource "aws_efs_mount_target" "this" {
  provider = aws.project
  for_each = {
    for item in local.mount_targets_flat : item.unique_key => item
  }

  file_system_id  = aws_efs_file_system.this[each.value.efs_key].id
  subnet_id       = each.value.subnet_id
  security_groups = each.value.security_groups
}

###########################################
# EFS Access Points
###########################################

resource "aws_efs_access_point" "this" {
  provider = aws.project
  for_each = {
    for item in local.access_points_flat : item.unique_key => item
  }

  file_system_id = aws_efs_file_system.this[each.value.efs_key].id

  # Configuración de usuario POSIX
  posix_user {
    gid            = each.value.access_point.posix_user != null ? each.value.access_point.posix_user.gid : each.value.access_point.owner_gid
    uid            = each.value.access_point.posix_user != null ? each.value.access_point.posix_user.uid : each.value.access_point.owner_uid
    secondary_gids = each.value.access_point.posix_user != null ? each.value.access_point.posix_user.secondary_gids : []
  }

  # Configuración del directorio raíz
  root_directory {
    path = each.value.access_point.path
    creation_info {
      owner_gid   = each.value.access_point.owner_gid
      owner_uid   = each.value.access_point.owner_uid
      permissions = each.value.access_point.permissions
    }
  }

  # PC-IAC-004: Tags con merge de Name y additional_tags
  tags = merge(
    { Name = local.access_point_names[each.key] },
    try(var.efs_config[each.value.efs_key].additional_tags, {})
  )
}
