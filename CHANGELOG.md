# Changelog

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-04-21

### Añadido
- Versión inicial del módulo de AWS Elastic File System (EFS)
- Soporte para creación de múltiples sistemas de archivos EFS usando mapas de objetos
- Soporte para puntos de acceso EFS con configuraciones personalizadas
- Soporte para puntos de montaje en múltiples subredes para alta disponibilidad
- Configuración de modos de rendimiento (generalPurpose/maxIO) y rendimiento (bursting/provisioned)
- Políticas de ciclo de vida para gestión automática del almacenamiento
- Backup automático integrado con AWS Backup
- Políticas de recursos para control de acceso granular
- Cifrado obligatorio mediante AWS KMS (clave predeterminada o personalizada)
- Etiquetado consistente según estándares organizacionales
- Validaciones de entrada para prevenir configuraciones incorrectas
- Documentación completa con ejemplos de uso
- Nomenclatura estandarizada con formato de guiones (-)

### Cambiado
- Estructura de variables mejorada para mayor flexibilidad y validación
- Cambio de variable `service` a `project` para mantener consistencia con otros módulos
- Cambio de `subnet_id` a `subnet_ids` para soportar múltiples puntos de montaje
