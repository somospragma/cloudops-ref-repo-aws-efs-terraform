resource "aws_efs_file_system" "efs" {
  provider = aws.project
  for_each = var.efs_config
  
  creation_token = join("-", [var.client, var.project, var.environment, "efs", each.key])
  encrypted      = true
  kms_key_id     = each.value.kms_key_id != "" ? each.value.kms_key_id : null
  
  # Configuraciones de rendimiento y almacenamiento
  performance_mode                = each.value.performance_mode
  throughput_mode                 = each.value.throughput_mode
  provisioned_throughput_in_mibps = each.value.throughput_mode == "provisioned" ? each.value.provisioned_throughput_in_mibps : null
  
  # Políticas de ciclo de vida
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
      if policy.transition_to_primary_storage_class != null
    ]
    
    content {
      transition_to_primary_storage_class = lifecycle_policy.value.transition_to_primary_storage_class
    }
  }
  
  tags = merge(
    {
      Name = join("-", [var.client, var.project, var.environment, "efs", each.key])
    },
    var.additional_tags,
    each.value.additional_tags
  )
}

resource "aws_efs_mount_target" "efs" {
  provider = aws.project
  for_each = {
    for item in flatten([
      for efs_key, efs in var.efs_config : [
        for subnet_id in efs.subnet_ids : {
          efs_key      = efs_key
          subnet_id    = subnet_id
          unique_key   = "${efs_key}-${subnet_id}"
          security_groups = efs.security_groups
        }
      ]
    ]) : item.unique_key => item
  }
  
  file_system_id  = aws_efs_file_system.efs[each.value.efs_key].id
  subnet_id       = each.value.subnet_id
  security_groups = each.value.security_groups
}

resource "aws_efs_access_point" "efs" {
  provider = aws.project
  for_each = {
    for item in flatten([
      for efs_key, efs in var.efs_config : [
        for ap_index, access_point in efs.access_points : {
          efs_key        = efs_key
          access_point   = access_point
          unique_key     = "${efs_key}-${access_point.name}"
        }
      ]
    ]) : item.unique_key => item
  }
  
  file_system_id = aws_efs_file_system.efs[each.value.efs_key].id
  
  posix_user {
    gid = each.value.access_point.posix_user != null ? each.value.access_point.posix_user.gid : each.value.access_point.owner_gid
    uid = each.value.access_point.posix_user != null ? each.value.access_point.posix_user.uid : each.value.access_point.owner_uid
  }
  
  root_directory {
    path = each.value.access_point.path
    creation_info {
      owner_gid   = each.value.access_point.owner_gid
      owner_uid   = each.value.access_point.owner_uid
      permissions = each.value.access_point.permissions
    }
  }
  
  tags = merge(
    {
      Name = join("-", [var.client, var.project, var.environment, "efs-ap", each.value.efs_key, each.value.access_point.name])
    },
    var.additional_tags
  )
}

# Política de recursos para EFS
resource "aws_efs_file_system_policy" "policy" {
  provider = aws.project
  for_each = {
    for k, v in var.efs_config : k => v
    if v.resource_policy != null
  }
  
  file_system_id = aws_efs_file_system.efs[each.key].id
  policy         = each.value.resource_policy
}

# Configuración de backup para EFS
resource "aws_backup_selection" "efs_backup" {
  provider = aws.project
  for_each = {
    for k, v in var.efs_config : k => v
    if v.enable_backup && v.backup_policy != null
  }
  
  name         = join("-", [var.client, var.project, var.environment, "backup", "efs", each.key])
  iam_role_arn = aws_iam_role.backup_role[0].arn
  plan_id      = aws_backup_plan.efs_backup_plan[each.key].id
  
  resources = [
    aws_efs_file_system.efs[each.key].arn
  ]
}

# Plan de backup para EFS
resource "aws_backup_plan" "efs_backup_plan" {
  provider = aws.project
  for_each = {
    for k, v in var.efs_config : k => v
    if v.enable_backup && v.backup_policy != null
  }
  
  name = join("-", [var.client, var.project, var.environment, "backup-plan", "efs", each.key])
  
  rule {
    rule_name         = join("-", [var.client, var.project, var.environment, "backup-rule", "efs", each.key])
    target_vault_name = aws_backup_vault.efs_backup_vault[0].name
    schedule          = each.value.backup_policy.schedule
    
    lifecycle {
      delete_after = each.value.backup_policy.retention_in_days
    }
  }
  
  tags = merge(
    {
      Name = join("-", [var.client, var.project, var.environment, "backup-plan", "efs", each.key])
    },
    var.additional_tags
  )
}

# Vault de backup para EFS
resource "aws_backup_vault" "efs_backup_vault" {
  provider = aws.project
  count    = length([for k, v in var.efs_config : v if v.enable_backup && v.backup_policy != null]) > 0 ? 1 : 0
  
  name = join("-", [var.client, var.project, var.environment, "backup-vault", "efs"])
  
  tags = merge(
    {
      Name = join("-", [var.client, var.project, var.environment, "backup-vault", "efs"])
    },
    var.additional_tags
  )
}

# Rol IAM para backup
resource "aws_iam_role" "backup_role" {
  provider = aws.project
  count    = length([for k, v in var.efs_config : v if v.enable_backup && v.backup_policy != null]) > 0 ? 1 : 0
  
  name = join("-", [var.client, var.project, var.environment, "backup-role", "efs"])
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
      }
    ]
  })
  
  tags = merge(
    {
      Name = join("-", [var.client, var.project, var.environment, "backup-role", "efs"])
    },
    var.additional_tags
  )
}

# Política para el rol de backup
resource "aws_iam_role_policy_attachment" "backup_policy" {
  provider   = aws.project
  count      = length([for k, v in var.efs_config : v if v.enable_backup && v.backup_policy != null]) > 0 ? 1 : 0
  
  role       = aws_iam_role.backup_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}
