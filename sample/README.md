# Ejemplo de Uso del Módulo EFS

Este directorio contiene un ejemplo funcional de cómo consumir el módulo EFS siguiendo el patrón de transformación PC-IAC-026.

## Flujo de Datos

```
terraform.tfvars → variables.tf → data.tf → locals.tf → main.tf → ../
     (config)        (tipos)     (consulta)  (transform)  (invoca módulo padre)
```

## Requisitos Previos

1. VPC existente con nomenclatura estándar: `{client}-{project}-{environment}-vpc`
2. Subnets privadas con tag `Type = private`
3. Security Group para EFS con nomenclatura: `{client}-{project}-{environment}-sg-efs-*`
4. KMS Key para EFS (opcional): `alias/{client}-{project}-{environment}-kms-efs`

## Ejecución

```bash
# Inicializar Terraform
terraform init

# Revisar el plan
terraform plan -var-file=terraform.tfvars

# Aplicar (solo en ambientes de prueba)
terraform apply -var-file=terraform.tfvars
```

## Patrón de Transformación (PC-IAC-026)

Este ejemplo demuestra cómo:

1. **terraform.tfvars**: Declarar configuración sin IDs hardcodeados
2. **data.tf**: Consultar recursos existentes (VPC, Subnets, SG, KMS)
3. **locals.tf**: Transformar configuración inyectando IDs dinámicos
4. **main.tf**: Invocar el módulo padre con `local.*` (nunca `var.*` directo)

## Notas

- El estado es local (no configurado backend S3) ya que es solo un ejemplo
- Los IDs de VPC, Subnets y Security Groups se obtienen dinámicamente
- Si no existe KMS key, se usa la clave administrada de AWS
