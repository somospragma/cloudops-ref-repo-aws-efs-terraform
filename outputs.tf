###########################################
# Outputs del Módulo
# PC-IAC-007: Outputs granulares (IDs, ARNs)
# PC-IAC-014: Splat Expressions para extracción
###########################################

output "efs_info" {
  description = "Información de los sistemas de archivos EFS creados"
  value = {
    for k, v in aws_efs_file_system.this : k => {
      id               = v.id
      arn              = v.arn
      dns_name         = v.dns_name
      performance_mode = v.performance_mode
      throughput_mode  = v.throughput_mode
      encrypted        = v.encrypted
    }
  }
}

output "efs_ids" {
  description = "Mapa de IDs de los sistemas de archivos EFS"
  value = {
    for k, v in aws_efs_file_system.this : k => v.id
  }
}

output "efs_arns" {
  description = "Mapa de ARNs de los sistemas de archivos EFS"
  value = {
    for k, v in aws_efs_file_system.this : k => v.arn
  }
}

output "efs_dns_names" {
  description = "Mapa de DNS names de los sistemas de archivos EFS"
  value = {
    for k, v in aws_efs_file_system.this : k => v.dns_name
  }
}

output "access_points" {
  description = "Información de los puntos de acceso EFS creados"
  value = {
    for k, v in aws_efs_access_point.this : k => {
      id             = v.id
      arn            = v.arn
      file_system_id = v.file_system_id
    }
  }
}

output "access_point_ids" {
  description = "Mapa de IDs de los puntos de acceso EFS"
  value = {
    for k, v in aws_efs_access_point.this : k => v.id
  }
}

output "access_point_arns" {
  description = "Mapa de ARNs de los puntos de acceso EFS"
  value = {
    for k, v in aws_efs_access_point.this : k => v.arn
  }
}

output "mount_targets" {
  description = "Información de los puntos de montaje EFS creados"
  value = {
    for k, v in aws_efs_mount_target.this : k => {
      id                   = v.id
      file_system_id       = v.file_system_id
      subnet_id            = v.subnet_id
      ip_address           = v.ip_address
      network_interface_id = v.network_interface_id
      dns_name             = v.dns_name
    }
  }
}
