# Módulo de Referencia - AWS EFS (Elastic File System)

Módulo de Terraform para crear y gestionar sistemas de archivos EFS en AWS, siguiendo las 26 reglas de gobernanza PC-IAC.

## Descripción

Este módulo crea:
- **EFS File Systems** con cifrado en reposo obligatorio
- **Mount Targets** en las subnets especificadas
- **Access Points** con configuración POSIX personalizada

## Uso

```hcl
module "efs" {
  source = "git::https://github.com/somospragma/cloudops-ref-repo-aws-efs-terraform.git?ref=v1.0.0"

  providers = {
    aws.project = aws.principal
  }

  # Variables de gobernanza
  client      = var.client
  project     = var.project
  environment = var.environment

  # Configuración transformada desde locals
  efs_config = local.efs_config_transformed
}
```

## Inputs

| Nombre | Descripción | Tipo | Requerido |
|--------|-------------|------|-----------|
| `client` | Nombre del cliente | `string` | Sí |
| `project` | Nombre del proyecto | `string` | Sí |
| `environment` | Entorno (dev, qa, pdn) | `string` | Sí |
| `efs_config` | Configuración de sistemas EFS | `map(object)` | No |

### Estructura de `efs_config`

```hcl
efs_config = {
  "workspace" = {
    kms_key_arn                      = ""  # Se inyecta desde data source
    performance_mode                 = "generalPurpose"
    throughput_mode                  = "bursting"
    provisioned_throughput_in_mibps  = null
    subnet_ids                       = []  # Se inyectan desde data source
    security_groups                  = []  # Se inyectan desde data source
    replication_overwrite_protection = "ENABLED"
    
    lifecycle_policy = [
      { transition_to_ia = "AFTER_30_DAYS" }
    ]
    
    access_points = [
      {
        name        = "tmp"
        path        = "/tmp"
        owner_gid   = 1000
        owner_uid   = 1000
        permissions = "755"
      }
    ]
    
    additional_tags = {
      purpose = "workspace-storage"
    }
  }
}
```

## Outputs

| Nombre | Descripción |
|--------|-------------|
| `efs_info` | Información completa de los EFS creados |
| `efs_ids` | Mapa de IDs de los EFS |
| `efs_arns` | Mapa de ARNs de los EFS |
| `efs_dns_names` | Mapa de DNS names de los EFS |
| `access_points` | Información de los Access Points |
| `access_point_ids` | Mapa de IDs de Access Points |
| `access_point_arns` | Mapa de ARNs de Access Points |
| `mount_targets` | Información de los Mount Targets |

## Requisitos

| Nombre | Versión |
|--------|---------|
| terraform | >= 1.0.0 |
| aws | >= 4.31.0 |

## Cumplimiento PC-IAC

| Regla | Descripción | Implementación |
|-------|-------------|----------------|
| PC-IAC-001 | Estructura de módulo | 10 archivos raíz + 8 archivos sample/ |
| PC-IAC-002 | Variables | `map(object)` con validaciones |
| PC-IAC-003 | Nomenclatura | `{client}-{project}-{environment}-efs-{key}` |
| PC-IAC-004 | Etiquetas | `merge()` con Name y additional_tags |
| PC-IAC-005 | Providers | Alias `aws.project` obligatorio |
| PC-IAC-006 | Versiones | Pinning en versions.tf |
| PC-IAC-007 | Outputs | Granulares (IDs, ARNs) |
| PC-IAC-010 | for_each | Uso de map para estabilidad |
| PC-IAC-014 | Bloques dinámicos | lifecycle_policy con dynamic |
| PC-IAC-020 | Seguridad | Cifrado obligatorio (`encrypted = true`) |
| PC-IAC-023 | Responsabilidad única | NO crea IAM roles ni Security Groups |
| PC-IAC-026 | Patrón sample/ | Transformación en locals.tf |

## Decisiones de Diseño

### Cifrado Obligatorio (PC-IAC-020)
El módulo fuerza `encrypted = true` en todos los EFS. Si no se proporciona `kms_key_arn`, AWS usa la clave administrada `aws/elasticfilesystem`.

### Responsabilidad Única (PC-IAC-023)
El módulo NO crea:
- IAM Roles (deben crearse en el dominio de Seguridad)
- Security Groups (deben crearse en el dominio de Seguridad)
- Recursos de Backup (deben gestionarse en un módulo separado)

Estos recursos se reciben como variables de entrada (`security_groups`, etc.).

### Nomenclatura (PC-IAC-003)
- EFS: `{client}-{project}-{environment}-efs-{key}`
- Access Points: `{client}-{project}-{environment}-efs-ap-{efs_key}-{ap_name}`

## Ejemplo

Ver el directorio `sample/` para un ejemplo funcional completo que demuestra el patrón de transformación PC-IAC-026.

```bash
cd sample/
terraform init
terraform plan -var-file=terraform.tfvars
```

## Licencia

Copyright © 2026 Pragma. Todos los derechos reservados.
