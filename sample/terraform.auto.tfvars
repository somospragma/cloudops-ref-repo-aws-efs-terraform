###############################################################
# Variables Globales
###############################################################


aws_region        = "us-east-1"
profile           = "pra_idp_dev"
environment       = "dev"
client            = "pragma"
project           = "hefesto"
service           = "efs"
functionality     = "sample"  


common_tags = {
  environment   = "dev"
  project-name  = "Modulos Referencia"
  cost-center   = "-"
  owner         = "cristian.noguera@pragma.com.co"
  area          = "KCCC"
  provisioned   = "terraform"
  datatype      = "interno"
}


###############################################################
# Variables EFS
###############################################################

name         = "sample"
path         = "/path"
owner_gid    = 1001
owner_uid    = 1001
permissions  = 755
gid          = 1001
uid          = 1001
