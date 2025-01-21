module "security_groups" {
  source = "git::https://github.com/somospragma/cloudops-ref-repo-aws-sg-terraform.git?ref=feature/sg-module-init"
  providers = {
    aws.project = aws.pra_idp_dev
  }

  client      = var.client
  project     = var.project
  environment = var.environment

  sg_config = [
    {
      application   = "sm"
      description   = "Security group for VPC Endpoint"
      vpc_id        = data.aws_vpc.vpc_hefesto.id
      service       = var.service
      functionality = var.functionality

      ingress = [
        {
          from_port       = 2049
          to_port         = 2049
          protocol        = "tcp"
          cidr_blocks     = ["0.0.0.0/0"]
          security_groups = []
          prefix_list_ids = []
          self            = false
          description     = "Allow NFS"
        }
      ]

      egress = [
        {
          from_port       = 0
          to_port         = 0
          protocol        = "-1"
          cidr_blocks     = ["0.0.0.0/0"]
          prefix_list_ids = []
          description     = "Allow all outbound traffic"
        }
      ]
    }
  ]
}


module "efs" {
  source = "./module/efs"

  client      = var.client
  service     = var.service
  environment = var.environment

efs_config = [
  {
    application_id  = var.project
    kms_key_id      = "" #si esta vacio le configura aws/elasticfilesystem
    subnet_id       = data.aws_subnet.private_subnet.id
    security_groups = [module.security_groups.sg_info["${var.service}-sm-${var.functionality}"].sg_id]

    access_points = [
      {
        name         = var.name
        path         = var.path
        owner_gid    = var.owner_gid
        owner_uid    = var.owner_uid
        permissions  = var.permissions
        posix_user = {
          gid = var.gid
          uid = var.uid
        }
      }
    ]
  }
  ]
}