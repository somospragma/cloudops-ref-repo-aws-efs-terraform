# Reporte de Seguridad KICS

## Resumen del Escaneo

- **Fecha:** 22/04/2025
- **Hora:** 11:34:27
- **Rutas escaneadas:** /home/farciniegas/Documents/Felipe/Work/Pragma/Chapter-CloudOps/repositorios/somospragma/modulos/cloudops-ref-repo-aws-efs-terraform
- **Plataformas:** Terraform

## Resultados

### Estadísticas

| Severidad | Cantidad |
|-----------|----------|
| CRÍTICO   | 0        |
| ALTO      | 0        |
| MEDIO     | 0        |
| BAJO      | 1        |
| INFO      | 0        |
| **TOTAL** | **1**    |

### Hallazgos Detallados

#### IAM Access Analyzer Not Enabled (Severidad: BAJO)

- **Descripción:** IAM Access Analyzer debería estar habilitado y configurado para monitorear continuamente los permisos de recursos
- **Plataforma:** Terraform
- **CWE:** 710
- **Archivo:** main.tf (línea 1)
- **Código afectado:**
  ```terraform
  resource "aws_efs_file_system" "efs" {
    provider = aws.project
    for_each = var.efs_config
  ```
- **Solución recomendada:** Considerar la implementación de IAM Access Analyzer en un módulo separado dedicado a la seguridad y cumplimiento.

## Conclusión

El módulo EFS muestra un excelente nivel de seguridad con solo un hallazgo de baja severidad que está fuera del alcance del módulo. No se detectaron problemas críticos, altos o medios que requieran atención inmediata.

Para ver el reporte completo en formato HTML, descargue el archivo [results.html](./results.html) y ábralo en su navegador.
