## 1. Demo lista para presentación (spec: `demo-validation`)

- [x] 1.1 Ensayar en máquina del presentador: `docker compose down -v`, copiar `.env` desde `.env.example`, `docker compose up --build -d`, verificar `docker compose ps`.
- [x] 1.2 Confirmar datos visibles sin SSH: dashboard en `localhost:${DASHBOARD_PORT}` muestra tabla/métricas no vacías con volumen DB nuevo (filas muestra desde `db/init.sql`).
- [x] 1.3 Simular `ssh … -p 2222` desde red permitida por el docente; tras ≤60 s (y refresco Streamlit o espera TTL caché) verificar aumento perceptible eventos tabla o contadores desde API `/stats`.

## 2. Documentación y paridad ejecutable versus código (spec: `project-delivery-completion`)

- [x] 2.1 Comparar rutas mencionadas `README.md` con `api/main.py` y listar deltas (si aparece `/events/{id}` en docs, verificar comportamiento esperado contra respuesta ejemplo).
- [x] 2.2 Actualizar `docs/openapi.json` contra implementación vigente FastAPI OU documentar en README decisión deprecación snapshot estático hasta próxima generación automatizada si se elige ese camino temporal.
- [x] 2.3 Re-leer `docs/quantas.md`; alinear párrafos que describan ingestión/visualización consumo datos con comportamiento efectivo Compose (shipper Streamlit usando API donde siga texto antiguo incoherente tras merges previos revisión humana rápida).
- [x] 2.4 Añadir o actualizar un ADR opcional nuevo “shipper-ingesta-docker” sólo motivación decisiones alto nivel si equipo lo exige formato curso .

## 3. Observabilidad mínima y humo repeatable (opcional pero recomendado)

- [x] 3.1 Crear script `scripts/demo-smoke.sh` (o comando `make demo-smoke`) que llame `/health`, `/stats`, quizá lista `/events?limit=1` contra `localhost` tras arranque; documentar tiempo esperado primer log Cowrie aparece después primer SSH.
- [x] 3.2 Extender README sección Troubleshooting errores conocidos clase (Cowrie tardío mostrar archivo log, Postgres sin seed tras volumen antiguo, bloque firewall universidad contra puerto SSH).

## 4. Alcance proyecto “bonus” conscientemente decidido después demo (explicitamente extra)

- [x] 4.1 Si la rúbrica exige seguridad adicional definir historia mínimo viable: token ingestión `/events`, rate limiting texto documentado riesgos credenciales almacenadas sin cifrado sólo sandbox académico.
- [x] 4.2 Si la rúbrica exige análisis avanzados planear segunda iteración (GeoIP comandos etiquetados) como backlog SEPARADO no bloque demo core.
