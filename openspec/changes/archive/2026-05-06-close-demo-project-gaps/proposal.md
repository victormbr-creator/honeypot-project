## Why

Antes del cierre del curso necesitamos criterios explícitos y trabajo remanente alineados: parte del flujo técnico (shipper → API → dashboard) ya existe en código, pero siguen apareciendo **huecos opcionales** (validación repeatable de la demo, paridad docs/API, seguridad docente/host) que impiden llamar **“terminado”** al entregable sin acordarlos como alcance del proyecto vs “nice-to-have.”

## What Changes

- Definir y documentar qué cuenta como **demo presentable** vs **alcance total del proyecto** (entrega académica).
- Añadir criterios de aceptación y tareas reproducibles donde hoy sólo hay intenciones (p. ej. humo automatizado opcional).
- Opcional (**no bloqueante de demo**) marcar trabajo de endurecimiento, OpenAPI/export y ampliaciones (autenticación de ingesta, retención de datos).

## Capabilities

### New Capabilities

- **`demo-validation`**: Criterios y verificaciones que demuestran que el stack Docker funciona como narrativa para la audiencia en vivo (URLs, comandos SSH, tiempo de reflujo hasta el dashboard, datos de muestra).
- **`project-delivery-completion`**: Criterios de entrega más allá de la demo: paridad README/OpenAPI/`docs/` con el código, evidencia automatizada continua en CI y decisiones conscientes sobre riesgos (datos sensibles, exposición de puertos).

### Modified Capabilities

- *(Sin capacidades especificadas previas en `openspec/specs/`; no aplicable.)*

## Impact

- **Documentación**: `README.md`, `docs/quantas.md`, ADRs opcionales, `docs/openapi.json`.
- **Código/DevOps**: Scripts de humo opcionales, mejoras CI, posibles ajustes mínimos de API/dashboard si la validación lo exige.
- **Operación demo**: Ritual reproducible ante el jurado (`docker compose` + pasos declarados por spec).
