---
description: Generar pruebas para proyecto Flutter
---

OBJETIVO:
Crear pruebas automáticas para aumentar cobertura y permitir refactors seguros.

PASOS:

1) Detectar estructura del proyecto.

2) Si no existe carpeta test/:
    - Crear carpeta test/

3) Generar:

A) Smoke test principal
- Verificar que la app inicia correctamente.

B) Tests para lógica pura (servicios, helpers)

C) Widget tests básicos para pantallas principales

4) Ejecutar:
   flutter test

REGLAS:

- No modificar código de producción.
- Crear mocks si es necesario.
- Priorizar pruebas estables.
- Explicar qué se cubrió y qué no.

ENTREGABLE:

Lista de archivos creados y cobertura aproximada.