# Ejemplo de implementación del módulo AWS EFS

Este directorio contiene un ejemplo completo de cómo implementar el módulo de AWS Elastic File System (EFS). El ejemplo muestra cómo crear sistemas de archivos EFS con puntos de acceso personalizados y grupos de seguridad.

## Estructura de archivos

```
sample/
├── data.tf              # Data sources utilizados en el ejemplo
├── main.tf              # Implementación del módulo
├── outputs.tf           # Outputs del ejemplo
├── providers.tf         # Configuración del proveedor AWS
├── README.md            # Este archivo
├── terraform.auto.tfvars.sample # Variables de ejemplo (renombrar a terraform.auto.tfvars para usar)
└── variables.tf         # Definición de variables
```

## Requisitos previos

1. [Terraform](https://www.terraform.io/downloads.html) (versión >= 1.0.0)
2. [AWS CLI](https://aws.amazon.com/cli/) configurado con las credenciales adecuadas
3. Permisos IAM para crear y gestionar recursos de AWS EFS
4. Una VPC con al menos una subred privada donde desplegar el EFS

## Cómo usar este ejemplo

1. **Preparar las variables**:
   - Copie el archivo `terraform.auto.tfvars.sample` a `terraform.auto.tfvars`
   - Revise y modifique el archivo `terraform.auto.tfvars` según sus necesidades
   - Asegúrese de actualizar los valores de `profile`, `aws_region`, `client`, `project`, `environment` y `common_tags`
   - Actualice los IDs de subredes y grupos de seguridad según su entorno

2. **Inicializar Terraform**:
   ```bash
   terraform init
   ```

3. **Verificar el plan de ejecución**:
   ```bash
   terraform plan
   ```

4. **Aplicar la configuración**:
   ```bash
   terraform apply
   ```

5. **Verificar los recursos creados**:
   - Compruebe los sistemas de archivos EFS creados en la consola de AWS
   - Revise los outputs de Terraform para obtener los ARNs, IDs y puntos de acceso

## Ejemplo incluido

Este ejemplo crea:

1. Un grupo de seguridad específico para EFS que permite el tráfico NFS (puerto 2049)
2. Un sistema de archivos EFS con cifrado habilitado
3. Un punto de montaje en una subred privada
4. Un punto de acceso con configuración POSIX personalizada

```hcl
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
      subnet_id       = data.aws_subnet.private_subnet.id
      security_groups = [module.security_groups.sg_info["efs-efs-storage"].sg_id]
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
```

## Montaje del sistema de archivos EFS

Una vez creado el sistema de archivos EFS, puede montarlo en instancias EC2 o contenedores:

### En una instancia EC2 (Amazon Linux 2):

1. Instale el cliente NFS:
   ```bash
   sudo yum install -y amazon-efs-utils
   ```

2. Cree un directorio para el punto de montaje:
   ```bash
   sudo mkdir -p /mnt/efs
   ```

3. Monte el sistema de archivos EFS:
   ```bash
   # Usando el ID del sistema de archivos
   sudo mount -t efs fs-12345678:/ /mnt/efs
   
   # O usando un punto de acceso
   sudo mount -t efs -o tls,accesspoint=fsap-12345678 fs-12345678:/ /mnt/efs
   ```

4. Para montar automáticamente al iniciar, añada a `/etc/fstab`:
   ```
   fs-12345678:/ /mnt/efs efs defaults,tls,_netdev 0 0
   ```

### En contenedores (Amazon ECS):

```json
{
  "containerDefinitions": [
    {
      "name": "app",
      "image": "app-image",
      "mountPoints": [
        {
          "sourceVolume": "efs-volume",
          "containerPath": "/data"
        }
      ]
    }
  ],
  "volumes": [
    {
      "name": "efs-volume",
      "efsVolumeConfiguration": {
        "fileSystemId": "fs-12345678",
        "rootDirectory": "/",
        "transitEncryption": "ENABLED",
        "authorizationConfig": {
          "accessPointId": "fsap-12345678"
        }
      }
    }
  ]
}
```

## Limpieza

Para eliminar todos los recursos creados:

```bash
terraform destroy
```

## Consideraciones de seguridad

- Este ejemplo utiliza la clave KMS predeterminada de AWS para el cifrado. En entornos de producción, considere usar una clave KMS personalizada.
- El grupo de seguridad creado permite el acceso desde cualquier dirección IP (0.0.0.0/0) al puerto NFS. En entornos de producción, restrinja el acceso solo a las subredes o grupos de seguridad necesarios.
- Considere implementar políticas de IAM adicionales para restringir aún más el acceso al sistema de archivos EFS.
