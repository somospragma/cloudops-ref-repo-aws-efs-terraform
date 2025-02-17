# **🚀 Módulo Terraform para API Gateway: cloudops-ref-repo-aws-api-terraform**

## Descripción:

Este módulo de Terraform permite la creación y gestión de recursos de Amazon Elastic File System (EFS) en AWS. Proporciona una forma estructurada y reutilizable de implementar sistemas de archivos EFS con configuraciones personalizadas, el cual requiere de los siguientes recursos, los cuales debieron ser previamente creados:

- kms_key_id: ARN del KMS a utilizar (si esta vacio le configura aws/elasticfilesystem).
- subnet_id      : ID de la subnet
- security_groups : ID del security group

Consulta CHANGELOG.md para la lista de cambios de cada versión. *Recomendamos encarecidamente que en tu código fijes la versión exacta que estás utilizando para que tu infraestructura permanezca estable y actualices las versiones de manera sistemática para evitar sorpresas.*

## Estructura del Módulo

El módulo cuenta con la siguiente estructura:

```bash
cloudops-ref-repo-aws-rds-terraform/
└── sample/
    ├── data.tf
    ├── main.tf
    ├── outputs.tf
    ├── providers.tf
    ├── terraform.auto.tfvars
    └── variables.tf
├── CHANGELOG.md
├── README.md
├── main.tf
├── outputs.tf
├── variables.tf
```

- Los archivos principales del módulo (`main.tf`, `outputs.tf` y `variables.tf`) se encuentran en el directorio raíz.
- `CHANGELOG.md` y `README.md` también están en el directorio raíz para fácil acceso.
- La carpeta `sample/` contiene un ejemplo de implementación del módulo.


## Uso del Módulo:

```hcl
module "efs" {
  source = "./module/efs"

  client      = "xxxx"
  service     = "xxxx"
  environment = "xxxx"

efs_config = [
  {
    application_id  = "xxxx"
    kms_key_id      = "xxxx" #si esta vacio le configura aws/elasticfilesystem
    subnet_id       = "xxxx
    security_groups = ["xxxx"]

    access_points = [
      {
        name         = "xxxx"
        path         = "xxxx"
        owner_gid    = "xxxx"
        owner_uid    = "xxxx"
        permissions  = "xxxx"
        posix_user = {
          gid = "xxxx"
          uid = "xxxx"
        }
      }
    ]
  }
  ]
}
```
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.31.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.project"></a> [aws.project](#provider\_aws) | >= 4.31.0 |

## Resources

| Name | Type |
|------|------|
| [aws_efs_file_system.efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_mount_target.efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [aws_efs_access_point.efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point) | resource |

## 📌 Variables

| Variable        | Tipo                                                                 | Descripción                                                                                       |
|-----------------|----------------------------------------------------------------------|---------------------------------------------------------------------------------------------------|
| `service`       | `string`                                                             | Nombre del servicio asociado al EFS.                                                              |
| `client`        | `string`                                                             | Nombre del cliente asociado al EFS.                                                               |
| `environment`   | `string`                                                             | Entorno en el que se desplegará el EFS (por ejemplo, `dev`, `prod`).                             |

## Variable `efs_config`

Esta variable es una lista de objetos que define la configuración de cada sistema de archivos EFS, incluyendo el ID de la aplicación, la clave KMS, el ID de la subred, los grupos de seguridad y los puntos de acceso.

```hcl
variable "efs_config" {
  type = list(object({
    application_id = string
    kms_key_id     = string
    subnet_id      = string
    security_groups = list(string)
    access_points = list(object({
      name        = string
      path        = string
      owner_gid   = number
      owner_uid   = number
      permissions = number
    }))
  }))
}
```

## Descripción de los Atributos de la Variable `efs_config`

| Atributo        | Tipo                                                                 | Descripción                                                                                       |
|-----------------|----------------------------------------------------------------------|---------------------------------------------------------------------------------------------------|
| `application_id` | `string`                                                             | Identificador de la aplicación asociada al sistema de archivos EFS.                              |
| `kms_key_id`     | `string`                                                             | ID de la clave KMS utilizada para cifrado.                                                       |
| `subnet_id`      | `string`                                                             | ID de la subred donde se desplegará el EFS.                                                      |
| `security_groups` | `list(string)`                                                        | Lista de IDs de los grupos de seguridad asociados al EFS.                                         |
| `access_points`   | `list(object({ name = string, path = string, owner_gid = number, owner_uid = number, permissions = number }))` | Lista de objetos que definen los puntos de acceso al EFS, cada uno con: `name`, `path`, `owner_gid`, `owner_uid` y `permissions`. |


### 📤 Outputs

| Output     | Tipo   | Descripción                                                                                       |
|------------|--------|---------------------------------------------------------------------------------------------------|
| `efs_info` | `map`  | Mapa donde la clave es el `application_id` y el valor es un objeto que contiene el ARN y el ID del sistema de archivos EFS correspondiente. |


