---
description: Auditoría de code smells en proyecto Flutter (reporte priorizado + CSV)
---

OBJETIVO:
Detectar deuda técnica, problemas de mantenibilidad, rendimiento y arquitectura en el proyecto Flutter SIN modificar archivos.

PASOS A EJECUTAR:

1) Preparación del entorno
    - flutter pub get

2) Verificación de formato (no aplicar cambios)
    - dart format --output=none --set-exit-if-changed .

3) Análisis estático
    - flutter analyze

4) Pruebas automatizadas
    - flutter test

5) Métricas de complejidad y smells
    - dart run dart_code_metrics:metrics lib

6) (Opcional si existe)
    - dart run dart_code_metrics:check-unused-files lib

ANÁLISIS REQUERIDO:

Identificar y priorizar especialmente:

- Widgets demasiado grandes o complejos
- Métodos con alta complejidad ciclomática
- Anidamiento excesivo
- Lógica de negocio dentro de UI
- Uso incorrecto de setState
- Falta de const en widgets inmutables
- Código duplicado
- Imports innecesarios o archivos no usados
- Violaciones de lints importantes
- Problemas potenciales de rendimiento

REPORTE A GENERAR:

1) Resumen con todos los hallazgos

2) Tabla detallada con:

- Archivo
- Línea aproximada
- Tipo de smell
- Severidad (Alta / Media / Baja)
- Descripción
- Causa probable
- Refactor sugerido
- Riesgo del cambio

3) Generar archivo:

reporte_smells.csv

Columnas del CSV:

Archivo,Línea,Tipo,Severidad,Descripción,Causa probable,Refactor sugerido,Riesgo

4) Priorizar por severidad e impacto.

REGLAS IMPORTANTES:

- NO modificar archivos del proyecto
- NO aplicar refactors automáticamente
- NO ejecutar comandos destructivos
- Solicitar aprobación antes de cualquier intento de edición

Al finalizar, indicar:

- Ubicación del CSV generado
- Número total de smells detectados
- Módulos más afectados