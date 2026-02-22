---
description: Corregir code smells detectados (Flutter) con cambios mínimos y validación
---

OBJETIVO:
Corregir los code smells detectados en el reporte anterior con cambios mínimos y seguros.
Se permiten modificaciones SOLO con aprobación (edit/write están en "ask").

REGLAS:
- Antes de editar archivos: solicitar aprobación.
- Cambios pequeños, agrupados por tipo.
- No cambiar comportamiento funcional salvo que sea imprescindible; si lo es, explicarlo.
- Ejecutar flutter analyze y flutter test al final (y si falla, revertir el último cambio y explicar).

PASOS:

1) Preparación
    - flutter pub get

2) Correcciones seguras y mecánicas (prioridad alta)
    - Aplicar "Optimize Imports" equivalente usando herramientas de CLI:
        - dart fix --apply
    - Normalizar formato:
        - dart format .

3) Correcciones guiadas por análisis
    - Ejecutar:
        - flutter analyze
    - Corregir hallazgos (imports, dead code, lints, null-safety, etc.) manteniendo cambios mínimos.

4) Correcciones por métricas (si existe dart_code_metrics)
    - Intentar:
        - dart run dart_code_metrics:metrics lib
    - Si hay violaciones por complejidad/anidamiento/parámetros:
        - Refactorizar con técnicas seguras:
            - extraer métodos/widgets
            - early returns para reducir nesting
            - dividir funciones largas
        - Evitar “refactors masivos” en una sola pasada.

5) Validación obligatoria
    - flutter analyze
    - flutter test

6) Entregables
    - Resumen de cambios por archivo
    - Lista de smells corregidos y cuáles quedaron pendientes (con motivo)
    - Sugerencias de siguientes pasos (si algunos requieren decisiones de arquitectura)

IMPORTANTE:
- No crear PR automáticamente.
- No hacer commits automáticamente (a menos que yo lo pida explícitamente).
- Solicitar confirmación antes de cualquier cambio grande (p. ej. mover carpetas, renombrar APIs públicas, cambios de arquitectura).