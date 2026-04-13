###########################################
# Variables de Entrada del Módulo
# PC-IAC-002: Variables obligatorias y buenas prácticas
# PC-IAC-009: Tipos de datos con map(object)
###########################################

###########################################
# Variables de Gobernanza (Obligatorias)
###########################################

variable "client" {
  description = "Nombre del cliente asociado al EFS"
  type        = string

  validation {
    condition     = length(var.client) > 0
    error_message = "El valor de client no puede estar vacío."
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

variable "environment" {
  description = "Entorno en el que se desplegará el EFS (dev, qa, pdn, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "qa", "pdn", "prod"], var.environment)
    error_message = "El entorno debe ser uno de: dev, qa, pdn, prod."
  }
}

###########################################
# Variable de Configuración Principal
# PC-IAC-002: Uso de map(object) para estabilidad con for_each
###########################################

variable "efs_config" {
  description = "Configuración de sistemas de archivos EFS"
  type = map(object({
    # Configuración básica
    kms_key_arn = optional(string, "")

    # Configuraciones de rendimiento
    performance_mode                = optional(string, "generalPurpose")
    throughput_mode                 = optional(string, "bursting")
    provisioned_throughput_in_mibps = optional(number, null)

    # Configuración de red (PC-IAC-023: recibidos como inputs, no creados)
    subnet_ids      = list(string)
    security_groups = list(string)

    # Políticas de ciclo de vida
    lifecycle_policy = optional(list(object({
      transition_to_ia                    = optional(string)
      transition_to_archive               = optional(string)
      transition_to_primary_storage_class = optional(string)
    })), [])

    # Protección de replicación
    replication_overwrite_protection = optional(string, "ENABLED")

    # Puntos de acceso
    access_points = optional(list(object({
      name        = string
      path        = string
      owner_gid   = number
      owner_uid   = number
      permissions = string
      posix_user = optional(object({
        gid            = number
        uid            = number
        secondary_gids = optional(list(number), [])
      }))
    })), [])

    # Tags adicionales específicos del EFS
    additional_tags = optional(map(string), {})
  }))
  default = {}

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
      contains(["bursting", "provisioned", "elastic"], v.throughput_mode)
    ])
    error_message = "El modo de throughput debe ser 'bursting', 'provisioned' o 'elastic'."
  }

  validation {
    condition = alltrue([
      for k, v in var.efs_config :
      v.throughput_mode != "provisioned" || v.provisioned_throughput_in_mibps != null
    ])
    error_message = "Si el modo de throughput es 'provisioned', debe especificar 'provisioned_throughput_in_mibps'."
  }
}
