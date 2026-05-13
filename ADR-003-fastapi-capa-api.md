# ADR-003: Elección de FastAPI como Capa de API

**Estado:** Aceptado  
**Fecha:** 2025  
**Autores:** Victor Benitez, Tamara Schnaas, Tania Hernández

---

## Contexto

El pipeline necesita una **capa de API REST** que actúe como intermediario entre el shipper (productor de eventos) y PostgreSQL (almacenamiento), y entre PostgreSQL y el dashboard Streamlit (consumidor). Esta capa debe recibir eventos vía `POST /events`, validarlos, persistirlos, y exponerlos junto con estadísticas agregadas mediante endpoints `GET`.

Las opciones evaluadas fueron:

| Opción | Tipo | Descripción |
|---|---|---|
| **FastAPI** | Framework async moderno | API REST con validación automática vía Pydantic y docs OpenAPI integradas |
| **Flask** | Microframework sync | Framework minimalista, ampliamente usado en proyectos académicos |
| **Django REST Framework** | Framework full-stack | ORM + API + admin panel incluidos |
| **Conexión directa a BD** | Sin API | Shipper y dashboard conectan directo a PostgreSQL |

---

## Decisión

Usamos **FastAPI** como capa de API REST, con modelos Pydantic para validación de entrada y SQLAlchemy para acceso a la base de datos.

---

## Justificación

1. **Validación automática con Pydantic.**  
   El modelo `EventIn` en `main.py` declara todos los campos como `Optional` con tipos explícitos (`datetime`, `str`, `dict`). FastAPI valida y convierte automáticamente el JSON entrante antes de que llegue al handler, sin código de validación manual. Errores de tipo retornan HTTP 422 con detalle del campo fallido.

2. **Documentación OpenAPI generada automáticamente.**  
   FastAPI expone `/docs` (Swagger UI) y `/redoc` en tiempo de ejecución sin configuración adicional. Esto permite al jurado explorar y probar los endpoints interactivamente durante la presentación, y sirve como fuente canónica para mantener `docs/openapi.json` alineado.

3. **Sintaxis declarativa y legible.**  
   Los 5 endpoints del proyecto (`/`, `/health`, `/events`, `/events/{event_id}`, `/stats`) se expresan como funciones Python estándar con decoradores. El código en `main.py` es directo y auditable por cualquier evaluador sin conocimiento previo del framework.

4. **Healthcheck nativo compatible con Docker Compose.**  
   El endpoint `/health` ejecuta `SELECT 1` contra PostgreSQL y retorna `{"status": "ok"}`. El healthcheck de Compose llama a este endpoint, lo que permite que los servicios dependientes (shipper, dashboard) esperen a que la API esté lista y la BD sea accesible antes de arrancar.

5. **Ecosistema compatible con el stack.**  
   FastAPI + `psycopg2-binary` + SQLAlchemy es una combinación estándar y bien documentada. El `TestClient` de FastAPI (basado en `httpx`) permite las pruebas en `test_main.py` sin levantar un servidor real, facilitando la integración con pytest en CI.

6. **Rendimiento adecuado para el alcance del proyecto.**  
   Aunque el volumen de eventos en una demo académica es bajo, FastAPI es uno de los frameworks Python más rápidos disponibles, lo que evita que la capa de API sea un cuello de botella si el honeypot recibe ráfagas de conexiones.

---

## Consecuencias

**Positivas:**
- El shipper puede hacer `POST /events` con JSON sin autenticación adicional (red interna de Compose), y la API valida el payload antes de insertarlo.
- Streamlit consume `/events` y `/stats` con `httpx` de forma síncrona; la API responde en milisegundos para los volúmenes esperados.
- La documentación interactiva en `/docs` es un activo de presentación que no requiere preparación adicional.

**Negativas / limitaciones:**
- `POST /events` no tiene autenticación. Está diseñado para la red interna de Docker Compose donde solo el shipper tiene acceso; exponer este endpoint en una red pública sin Bearer token sería un riesgo de seguridad (documentado en el backlog del README).
- Las pruebas en `test_main.py` requieren una instancia de PostgreSQL disponible al importar `main.py`, ya que `create_engine` se ejecuta al cargar el módulo. El pipeline de CI debe incluir un servicio Postgres para que los tests pasen.
- No se implementó paginación con cursor en `/events`; el parámetro `limit` es suficiente para la demo pero no escala a millones de eventos.

---

## Referencias

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Pydantic v2](https://docs.pydantic.dev/)
- [SQLAlchemy Core](https://docs.sqlalchemy.org/en/20/core/)
- [FastAPI TestClient](https://fastapi.tiangolo.com/tutorial/testing/)
