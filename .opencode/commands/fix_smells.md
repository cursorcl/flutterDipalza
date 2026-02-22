---
description: Corregir code smells detectados (Flutter) con cambios mínimos y validación
---

OBJETIVO:
Corregir los code smells detectados en el reporte anterior con cambios mínimos y seguros.

PERMISOS Y SEGURIDAD:
- Se permiten modificaciones SOLO con aprobación (edit/write están en "ask").
- Antes de editar o crear archivos: solicitar aprobación explícita.

REGLAS:
- Cambios pequeños, agrupados por tipo (evitar “refactors masivos”).
- No cambiar comportamiento funcional salvo que sea imprescindible; si lo es, explicarlo.
- Validar al final; si la validación falla, revertir el último cambio y explicar.

PASOS:

1) Preparación
   - flutter pub get

2) Correcciones seguras y mecánicas (prioridad alta)
   - Aplicar correcciones automáticas conservadoras:
      - dart fix --apply
   - Normalizar formato (aplica cambios de formato):
      - dart format .

3) Correcciones guiadas por análisis
   - Ejecutar:
      - flutter analyze
   - Corregir hallazgos (imports, dead code, lints, null-safety, etc.) manteniendo cambios mínimos.

4) Correcciones por métricas (si existe dart_code_metrics)
   - Detectar si está instalado (sin modificar nada):
      - Revisar pubspec.yaml / pubspec.lock (presencia de "dart_code_metrics")
   - Si está instalado:
      - dart run dart_code_metrics:metrics lib
      - (Opcional) dart run dart_code_metrics:check-unused-files lib
      - Si hay violaciones por complejidad/anidamiento/parámetros:
         - Refactorizar con técnicas seguras:
            - extraer métodos/widgets
            - early returns para reducir nesting
            - dividir funciones largas
         - Evitar cambios de arquitectura no solicitados.
   - Si NO está instalado:
      - Omitir este paso y reportar: "dart_code_metrics no está instalado; se ejecutó auditoría basada en flutter analyze."

5) Validación obligatoria (con fallback si no hay tests)
   - Siempre:
      - flutter analyze
   - Detectar si existen tests:
      - Buscar archivos test/**/*_test.dart
   - Si existen tests:
      - flutter test
   - Si NO existen tests:
      - Ejecutar una validación alternativa de compilación (según plataforma disponible):
         - flutter build apk  (si Android está configurado)
         - o flutter build ios (si iOS está configurado)
      - Reportar explícitamente que no hay cobertura de pruebas y recomendar verificación manual (smoke test).

6) Entregables
   - Resumen de cambios por archivo (qué se cambió y por qué)
   - Lista de smells corregidos y cuáles quedaron pendientes (con motivo)
   - Recomendaciones de siguientes pasos (si algunos requieren decisiones de arquitectura)

IMPORTANTE:
- No crear PR automáticamente.
- No hacer commits automáticamente (a menos que yo lo pida explícitamente).
- Solicitar confirmación antes de cualquier cambio grande (p. ej. mover carpetas, renombrar APIs públicas, cambios de arquitectura).
