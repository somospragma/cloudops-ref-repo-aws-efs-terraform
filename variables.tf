variable "efs_config" {
  description = "Configuración de sistemas de archivos EFS"
  type = map(object({
    description      = string
    kms_key_id       = string  # Si está vacío, se configura aws/elasticfilesystem
    subnet_ids       = list(string)  # Lista de subredes para puntos de montaje
    security_groups  = list(string)
    
    # Configuraciones de rendimiento y almacenamiento
    performance_mode = optional(string, "generalPurpose")  # generalPurpose o maxIO
    throughput_mode  = optional(string, "bursting")        # bursting o provisioned
    provisioned_throughput_in_mibps = optional(number, null) # Requerido si throughput_mode = "provisioned"
    
    # Políticas de ciclo de vida
    lifecycle_policy = optional(list(object({
      transition_to_ia                    = optional(string) # AFTER_7_DAYS, AFTER_14_DAYS, AFTER_30_DAYS, AFTER_60_DAYS, AFTER_90_DAYS
      transition_to_primary_storage_class = optional(string) # AFTER_1_ACCESS
    })), [])
    
    # Configuración de backup
    enable_backup = optional(bool, false)
    backup_policy = optional(object({
      schedule           = optional(string, "cron(0 1 * * ? *)")  # Por defecto, diariamente a la 1 AM
      retention_in_days  = optional(number, 30)                   # Retención por defecto: 30 días
    }), null)
    
    # Política de recursos EFS
    resource_policy = optional(string, null)
    
    # Puntos de acceso
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
  
  validation {
    condition = alltrue([
      for k, v in var.efs_config : 
      length(v.subnet_ids) > 0
    ])
    error_message = "Debe proporcionar al menos una subred para los puntos de montaje."
  }
  
  validation {
    condition = alltrue([
      for k, v in var.efs_config : 
      length(v.security_groups) > 0
    ])
    error_message = "Debe proporcionar al menos un grupo de seguridad."
  }
  
  validation {
    condition = alltrue([
      for k, v in var.efs_config : 
      contains(["generalPurpose", "maxIO"], v.performance_mode)
    ])
    error_message = "El modo de rendimiento debe ser 'generalPurpose' o 'maxIO'."
  }
  
  validation {
    condition = alltrue([
      for k, v in var.efs_config : 
      contains(["bursting", "provisioned"], v.throughput_mode)
    ])
    error_message = "El modo de rendimiento debe ser 'bursting' o 'provisioned'."
  }
  
  validation {
    condition = alltrue([
      for k, v in var.efs_config : 
      v.throughput_mode != "provisioned" || v.provisioned_throughput_in_mibps != null
    ])
    error_message = "Si el modo de rendimiento es 'provisioned', debe especificar 'provisioned_throughput_in_mibps'."
  }
}

variable "project" {
  description = "Nombre del proyecto asociado al EFS"
  type        = string
  
  validation {
    condition     = length(var.project) > 0
    error_message = "El valor de project no puede estar vacío."
  }
}

variable "client" {
  description = "Nombre del cliente asociado al EFS"
  type        = string
  
  validation {
    condition     = length(var.client) > 0
    error_message = "El valor de client no puede estar vacío."
  }
}

variable "environment" {
  description = "Entorno en el que se desplegará el EFS (dev, qa, pdn)"
  type        = string
  
  validation {
    condition     = contains(["dev", "qa", "pdn"], var.environment)
    error_message = "El entorno debe ser uno de: dev, qa, pdn."
  }
}

variable "additional_tags" {
  description = "Etiquetas adicionales para los recursos"
  type        = map(string)
  default     = {}
}
