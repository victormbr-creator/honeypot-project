## ADDED Requirements

### Requirement: Repetición estable del encendido Compose

Los presentadores MUST poder iniciar todos los servicios del demo con Docker Compose usando la documentación oficial del repositorio y variables de ejemplo.

#### Scenario: Levantamiento en limpio antes de clase

- **WHEN** se ejecuta la secuencia documentada (`cp .env.example .env`, `docker compose up -d` o equivalentes) en una máquina con Docker
- **THEN** Postgres, FastAPI (API), Cowrie, dashboard Streamlit y el shipper DEBEN estar corriendo o en estado conocido reproducible como “esperando log” donde aplique sin error silencioso no documentado

### Requirement: Visibilidad inmediata de datos útiles para la audiencia

El dashboard MUST mostrar suficientes filas métricas o tablas en la primera vista relevante después de cargar Compose en un volúmen fresco de base de datos, sin depender necesariamente de tráfico en vivo inicial.

#### Scenario: Métricas y tabla no vacía en volumen nuevo

- **WHEN** tras el primer bootstrap de Postgres (volumen de datos inicializado mediante `db/init.sql` según proceso documentado del proyecto) el presentador accede al dashboard
- **THEN** DEBEN aparecer indicadores derivados del API que no estén todos en cero inútil cuando `init.sql` define datos de muestra, y DEBE existir al menos información textual que guíe al presentador si aún falta SSH

### Requirement: Amplificación perceptible después de SSH simulado

Un intento sintético al honeypot MUST aumentar dentro de tiempo razonable la evidencia en la capa downstream (lista de eventos vía consumo público configurado Streamlit desde API).

#### Scenario: Nueva fila después de intento falto SSH

- **WHEN** un presentador ejecuta un intento de conexión SSH al honeypot documentado (por ejemplo usuario contraseña falsa suficientes para producir registros Cowrie cuando el servidor esté disponible), y el pipeline shipper/API está saludable
- **THEN** nuevos elementos DEBEN llegar eventualmente reflejados en datos devueltos por la API dentro de margen comunicado públicamente como aceptación (orden de magnitud de menos de sesenta segundos bajo máquinas normales clase, no garantía SLA estricto)
