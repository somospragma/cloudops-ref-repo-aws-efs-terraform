###########################################
# Outputs del Ejemplo
# PC-IAC-007: Outputs granulares
###########################################

output "efs_info" {
  description = "Información de los sistemas de archivos EFS creados"
  value       = module.efs.efs_info
}

output "efs_ids" {
  description = "IDs de los sistemas de archivos EFS"
  value       = module.efs.efs_ids
}

output "efs_dns_names" {
  description = "DNS names de los sistemas de archivos EFS"
  value       = module.efs.efs_dns_names
}

output "access_point_ids" {
  description = "IDs de los Access Points"
  value       = module.efs.access_point_ids
}

output "mount_targets" {
  description = "Información de los Mount Targets"
  value       = module.efs.mount_targets
}
