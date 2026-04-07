###########################################
# Variables del Ejemplo
# PC-IAC-002: Variables con tipos explícitos
###########################################

###########################################
# Variables de Gobernanza
###########################################

variable "client" {
  description = "Nombre del cliente"
  type        = string
}

variable "project" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Entorno (dev, qa, pdn)"
  type        = string
}

###########################################
# Variables de Configuración AWS
###########################################

variable "aws_region" {
  description = "Región de AWS"
  type        = string
}

variable "profile" {
  description = "Perfil de AWS CLI"
  type        = string
}

variable "common_tags" {
  description = "Tags comunes aplicados a todos los recursos"
  type        = map(string)
}

###########################################
# Variable de Configuración EFS
###########################################

variable "efs_config" {
  description = "Configuración de sistemas de archivos EFS"
  type = map(object({
    kms_key_arn                      = optional(string, "")
    performance_mode                 = optional(string, "generalPurpose")
    throughput_mode                  = optional(string, "bursting")
    provisioned_throughput_in_mibps  = optional(number, null)
    subnet_ids                       = optional(list(string), [])
    security_groups                  = optional(list(string), [])
    replication_overwrite_protection = optional(string, "ENABLED")

    lifecycle_policy = optional(list(object({
      transition_to_ia                    = optional(string)
      transition_to_archive               = optional(string)
      transition_to_primary_storage_class = optional(string)
    })), [])

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

    additional_tags = optional(map(string), {})
  }))
  default = {}
}
