output "efs_info" {
  description = "Información de los sistemas de archivos EFS creados"
  value       = module.efs.efs_info
}

output "access_points" {
  description = "Información de los puntos de acceso EFS creados"
  value       = module.efs.access_points
}

output "mount_targets" {
  description = "Información de los puntos de montaje EFS creados"
  value       = module.efs.mount_targets
}

output "backup_info" {
  description = "Información de las configuraciones de backup (si están habilitadas)"
  value       = module.efs.backup_info
}

output "resource_policies" {
  description = "Información de las políticas de recursos EFS (si están configuradas)"
  value       = module.efs.resource_policies
}

output "security_group_id" {
  description = "ID del grupo de seguridad creado para EFS"
  value       = module.security_groups.sg_info["efs-efs-storage"].sg_id
}
