variable "efs_config" {
    type = list(object({
      application_id = string
      kms_key_id = string 
      subnet_id = string
      security_groups = list(string)
      access_points = list(object({
        name = string
        path = string
        owner_gid = number
        owner_uid = number
        permissions = number
      }))   
    }))
  
}


variable "service" {
  type = string
}

variable "client" {
  type = string
}

variable "environment" {
  type = string
}
