output "efs_info" {
  description = "Información de los sistemas de archivos EFS creados"
  value = {
    for k, v in aws_efs_file_system.efs : k => {
      efs_id  = v.id
      efs_arn = v.arn
      dns_name = "${v.id}.efs.${data.aws_region.current.name}.amazonaws.com"
      performance_mode = v.performance_mode
      throughput_mode = v.throughput_mode
      encrypted = v.encrypted
    }
  }
}

output "access_points" {
  description = "Información de los puntos de acceso EFS creados"
  value = {
    for k, v in aws_efs_access_point.efs : k => {
      access_point_id  = v.id
      access_point_arn = v.arn
      file_system_id   = v.file_system_id
      posix_user       = v.posix_user
      root_directory   = v.root_directory
    }
  }
}

output "mount_targets" {
  description = "Información de los puntos de montaje EFS creados"
  value = {
    for k, v in aws_efs_mount_target.efs : k => {
      mount_target_id = v.id
      file_system_id  = v.file_system_id
      subnet_id       = v.subnet_id
      ip_address      = v.ip_address
    }
  }
}

output "backup_info" {
  description = "Información de las configuraciones de backup (si están habilitadas)"
  value = {
    backup_vault = length([for k, v in var.efs_config : v if v.enable_backup && v.backup_policy != null]) > 0 ? {
      name = try(aws_backup_vault.efs_backup_vault[0].name, null)
      arn  = try(aws_backup_vault.efs_backup_vault[0].arn, null)
    } : null
    backup_plans = {
      for k, v in aws_backup_plan.efs_backup_plan : k => {
        id   = v.id
        arn  = v.arn
        name = v.name
      }
    }
  }
}

output "resource_policies" {
  description = "Información de las políticas de recursos EFS (si están configuradas)"
  value = {
    for k, v in aws_efs_file_system_policy.policy : k => {
      policy = v.policy
    }
  }
}
