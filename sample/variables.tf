variable "client" {
  description = "Nombre del cliente asociado al EFS"
  type        = string
}

variable "environment" {
  description = "Entorno en el que se desplegará el EFS (dev, qa, pdn)"
  type        = string
}

variable "project" {
  description = "Nombre del proyecto asociado al EFS"
  type        = string
}

variable "aws_region" {
  description = "Región de AWS donde se desplegarán los recursos"
  type        = string
}

variable "profile" {
  description = "Perfil de AWS a utilizar para el despliegue"
  type        = string
}

variable "common_tags" {
  description = "Tags comunes aplicadas a los recursos"
  type        = map(string)
}

variable "additional_tags" {
  description = "Etiquetas adicionales para los recursos"
  type        = map(string)
  default     = {}
}

variable "efs_config" {
  description = "Configuración de sistemas de archivos EFS"
  type = map(object({
    description      = string
    kms_key_id       = string
    subnet_ids       = list(string)
    security_groups  = list(string)
    
    # Configuraciones de rendimiento y almacenamiento
    performance_mode = optional(string, "generalPurpose")
    throughput_mode  = optional(string, "bursting")
    provisioned_throughput_in_mibps = optional(number, null)
    
    # Políticas de ciclo de vida
    lifecycle_policy = optional(list(object({
      transition_to_ia                    = optional(string)
      transition_to_primary_storage_class = optional(string)
    })), [])
    
    # Configuración de backup
    enable_backup = optional(bool, false)
    backup_policy = optional(object({
      schedule           = optional(string, "cron(0 1 * * ? *)")
      retention_in_days  = optional(number, 30)
    }), null)
    
    # Política de recursos EFS
    resource_policy = optional(string, null)
    
    access_points = list(object({
      name        = string
      path        = string
      owner_gid   = number
      owner_uid   = number
      permissions = number
      posix_user = optional(object({
        gid = number
        uid = number
      }))
    }))
    additional_tags  = optional(map(string), {})
  }))
}
