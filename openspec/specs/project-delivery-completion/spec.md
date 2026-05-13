# project-delivery-completion Specification

## Purpose
TBD - created by archiving change close-demo-project-gaps. Update Purpose after archive.
## Requirements
### Requirement: Cobertura mínima de verificación automatizada sobre la API

La integridad continua básica de la superficie REST expuesta MUST ejecutarse mediante pruebas automatizadas reproducibles donde el equipo haya decidido ejecutar CI (pipeline existente definido GitHub Actions en el proyecto).

#### Scenario: Health y colección estadística válida

- **WHEN** el pipeline ejecuta suites sobre la aplicación tras provisionar Postgres de prueba aplicando mismo esquema que producción inicial
- **THEN** al menos DEBEN ejecutarse llamadas automatizadas verificaciones de rotas críticas de lectura establecidas equipo (por ejemplo estado salud `/health`, listado `/events`, resumen estadístico `/stats`) sin errores esperados conocidos código regresivos

### Requirement: Paridad declarada entre navegabilidad desarrolladora y comportamiento ejecutable exportado donde exista archivo OpenAPI versionado estático separado vida documentación rápida

Si el repositorio mantiene un fichero especificación OpenAPI estático versionado paralelo Swagger live, el equipo MUST alinearlo con rutas actuales FastAPI antes de cerrar entrega formal entregable académico publicado.

#### Scenario: Coincidencia rutas documentadas persistidas

- **WHEN** un revisor compara enumeración endpoints prometidos README y snapshot `docs/openapi.json` (si presente) frente implementación corriente `main`
- **THEN** no DEBEN existir discrepancias mayores no explicadas (rutas listadas como existentes que no existen o contrario sin nota de depósito intencional)

### Requirement: Consistencia descriptiva arquitectura interna crítica al flujo ingestión/visualización donde documento quantas todavía establece contratos de dependencia

Documentos que declaran límites entre quantum captura proceso visualización MUST reflejar el acoplamiento actual real del código desplegable Docker Compose (por ejemplo navegador Streamlit hacia REST frente cualquier mención contradictoria texto antiguo todavía versionado en el repositorio).

#### Scenario: Narrativa ingestión menciona pipeline activo observable

- **WHEN** se audita archivo `docs/quantas.md` y README ante servicios efectivos Compose
- **THEN** DEBE aparecer mención coherentemente servicios ingesta automatizada (nombre shipper o sinónimo aprobado) y consumo datos dashboard vía rutas públicas establecidas `API_*` donde contrato oficial actual lo exija

