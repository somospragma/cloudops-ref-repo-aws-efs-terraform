# Changelog

Todos los cambios notables de este módulo serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-04-07

### Added
- Implementación inicial del módulo EFS siguiendo las 26 reglas PC-IAC
- Soporte para múltiples sistemas de archivos EFS con `for_each`
- Cifrado en reposo obligatorio (PC-IAC-020)
- Soporte para KMS keys personalizadas
- Mount targets en múltiples subnets
- Access points con configuración POSIX
- Lifecycle policies (transition_to_ia, transition_to_archive, transition_to_primary_storage_class)
- Protección de replicación configurable
- Nomenclatura estándar: `{client}-{project}-{environment}-efs-{key}`
- Ejemplo funcional en `sample/` con patrón de transformación (PC-IAC-026)

### Removed
- Recursos IAM (backup role) - violaban PC-IAC-023 (responsabilidad única)
- Recursos de backup - deben gestionarse en un módulo separado

### Security
- Cifrado en reposo habilitado por defecto
- Security Groups recibidos como input (no creados internamente)
