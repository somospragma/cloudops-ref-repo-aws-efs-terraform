variable "client" {
  type = string
}
variable "environment" {
  type = string
}
variable "service"{
  type = string  
}
variable "aws_region" {
  type = string
}
variable "profile" {
  type = string
}
variable "common_tags" {
    type = map(string)
    description = "Tags comunes aplicadas a los recursos"
}
variable "project" {
  type = string  
}
variable "functionality" {
  type = string  
}


########### Varibales EFS
variable "name" {
  type = string  
}
variable "path" {
  type = string  
}
variable "owner_gid" {
  type = number  
}
variable "owner_uid" {
  type = number  
}
variable "permissions" {
  type = number  
}
variable "gid" {
  type = number  
}
variable "uid" {
  type = number  
}
