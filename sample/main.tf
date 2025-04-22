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
      application   = "efs"
      description   = "Security group for EFS"
      vpc_id        = data.aws_vpc.vpc.id
      service       = "efs"
      functionality = "storage"

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
  source = "../"
  
  providers = {
    aws.project = aws.pra_idp_dev
  }

  client      = var.client
  project     = var.project
  environment = var.environment
  additional_tags = var.additional_tags

  efs_config = {
    "app1" = {
      description     = "EFS para la aplicación 1"
      kms_key_id      = ""  # Usar la clave predeterminada
      subnet_ids      = [data.aws_subnet.private_subnet.id]
      security_groups = [module.security_groups.sg_info["efs-efs-storage"].sg_id]
      
      # Configuraciones de rendimiento y almacenamiento
      performance_mode = "generalPurpose"
      throughput_mode  = "bursting"
      
      # Políticas de ciclo de vida
      lifecycle_policy = [
        {
          transition_to_ia = "AFTER_30_DAYS"
        }
      ]
      
      # Configuración de backup
      enable_backup = true
      backup_policy = {
        schedule           = "cron(0 1 * * ? *)"
        retention_in_days  = 30
      }
      
      access_points = [
        {
          name        = "ap1"
          path        = "/path1"
          owner_gid   = 1001
          owner_uid   = 1001
          permissions = 755
          posix_user = {
            gid = 1001
            uid = 1001
          }
        }
      ]
      additional_tags = {
        application = "app1"
        data-classification = "internal"
      }
    }
  }
}
