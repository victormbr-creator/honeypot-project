# ADR-002: Elección de PostgreSQL como Almacenamiento

**Estado:** Aceptado  
**Fecha:** 2025  
**Autores:** Victor Benitez, Tamara Schnaas, Tania Hernández

---

## Contexto

El pipeline necesita un componente de **persistencia** que reciba eventos desde la API FastAPI y los almacene de forma estructurada para consultas posteriores (listado, detalle por ID, agregaciones para estadísticas). Los eventos tienen estructura semi-fija: campos conocidos (`event_time`, `src_ip`, `event_type`, `username`, `password`, `command`) más un campo de payload completo (`raw_json`) que varía según el tipo de evento Cowrie.

Las opciones evaluadas fueron:

| Opción | Tipo | Descripción |
|---|---|---|
| **PostgreSQL 16** | Relacional + JSONB | Base de datos relacional con soporte nativo para JSON binario |
| **MongoDB** | Documental | Base de datos orientada a documentos JSON |
| **SQLite** | Relacional embebida | BD relacional sin servidor, archivo local |
| **Elasticsearch** | Search engine | Motor de búsqueda y análisis de logs |
| **Archivos JSON/CSV** | Flat files | Persistencia directa en disco sin motor de BD |

---

## Decisión

Usamos **PostgreSQL 16** como motor de almacenamiento, con la tabla `cowrie_events` que combina columnas tipadas para los campos conocidos y una columna `JSONB` para el payload completo.

---

## Justificación

1. **Esquema híbrido: relacional + JSONB.**  
   Los eventos de Cowrie tienen campos comunes bien definidos (ideales para columnas tipadas con índices) y un payload variable por tipo de evento (ideal para JSONB). PostgreSQL permite ambos en la misma tabla, sin tener que elegir entre rigidez total o flexibilidad total.

2. **Consultas SQL estándar para agregaciones.**  
   Los endpoints `/stats` requieren `COUNT`, `GROUP BY`, `ORDER BY` y filtros por rango de tiempo (`NOW() - INTERVAL`). SQL es el lenguaje más directo para estas operaciones; no requiere frameworks adicionales de agregación.

3. **Imagen oficial Docker sin configuración extra.**  
   `postgres:16` está disponible en Docker Hub y se inicializa automáticamente con el script `db/init.sql` mediante el mecanismo `docker-entrypoint-initdb.d`. Esto permite crear el esquema y los datos de muestra en el primer arranque sin pasos manuales.

4. **Integración directa con SQLAlchemy.**  
   FastAPI usa SQLAlchemy como ORM/query builder. El driver `psycopg2-binary` conecta PostgreSQL con SQLAlchemy sin configuración adicional, y el tipo `JSONB` es manejado nativamente al hacer `CAST(:raw_json AS JSONB)`.

5. **Familiaridad académica y profesional.**  
   PostgreSQL es una tecnología estándar en cursos de bases de datos y en la industria. Su elección facilita la evaluación por parte del jurado y es transferible a proyectos reales.

6. **Usuario de solo lectura para demos.**  
   PostgreSQL permite crear roles con permisos granulares. El `init.sql` crea `honeypot_readonly` para que el jurado pueda conectarse con TablePlus sin riesgo de modificar datos durante la presentación.

---

## Consecuencias

**Positivas:**
- El campo `raw_json JSONB` permite almacenar el evento Cowrie completo sin pérdida de información, aunque el esquema principal solo exponga los campos más relevantes.
- Las consultas de `/stats` son eficientes y legibles en SQL puro dentro de `main.py`.
- El healthcheck de Compose (`pg_isready`) permite que los servicios dependientes (API, shipper) esperen a que Postgres esté listo antes de arrancar.

**Negativas / limitaciones:**
- PostgreSQL es más pesado que SQLite para un proyecto de demostración con volumen bajo de eventos. Sin embargo, el overhead es aceptable en Docker y la paridad con entornos de producción justifica la elección.
- El seed de datos de muestra (`db/init.sql`) solo se ejecuta en la **primera** inicialización del volumen. Si se reutiliza un volumen antiguo sin el seed, el dashboard aparece vacío; requiere `docker compose down -v` para reinicializar.
- No se implementaron índices adicionales más allá de la llave primaria. Para volúmenes altos de eventos, sería recomendable indexar `src_ip` y `event_time`.

---

## Referencias

- [PostgreSQL 16 Documentation](https://www.postgresql.org/docs/16/)
- [PostgreSQL JSONB](https://www.postgresql.org/docs/current/datatype-json.html)
- [SQLAlchemy + psycopg2](https://docs.sqlalchemy.org/en/20/dialects/postgresql.html)
- [Docker postgres image](https://hub.docker.com/_/postgres)
