# Conectar TablePlus al PostgreSQL del proyecto

[TablePlus](https://tableplus.com/) es opcional: el flujo oficial de la app usa **FastAPI + Streamlit**. TablePlus sirve para **exploración SQL**, depuración y demos donde quieras mostrar datos crudos (`cowrie_events`) sin cambiar código.

## Requisitos

- Servicio `db` activo (`docker compose up -d`).
- El puerto publicado debe coincidir con `POSTGRES_PORT` de tu `.env` (por defecto **5432** en host → 5432 en el contenedor).

## Conexión con el usuario principal (read/write)

Valores típicos al copiar desde [`.env.example`](../.env.example):

| Campo | Valor |
|--------|--------|
| Host | `127.0.0.1` o `localhost` |
| Port | `5432` o el definido en `POSTGRES_PORT` |
| User | Valor de `POSTGRES_USER` (ej. `honeyuser`) |
| Password | Valor de `POSTGRES_PASSWORD` (ej. `honeypass`) |
| Database | Valor de `POSTGRES_DB` (ej. `honeypot`) |

En TablePlus → **Create a new connection** → **PostgreSQL** → rellena y guarda como favorito (“Honeypot dev”).

- **SSL**: en Docker local suele funcionar **desactivado** / “Prefer” según cliente.
- Sin esto aparece **connection refused**: comprueba que el contenedor está arriba y el puerto no está ocupado por otra instancia Postgres.

## Conexión con usuario sólo lectura (recomendado para demos públicas)

Tras inicializar Postgres con el volumen nuevo, `db/init.sql` crea el rol **`honeypot_readonly`** (contraseña por defecto documentada junto al usuario en [`.env.example`](../.env.example)). Úsalo en TablePlus con los mismos host/puerto/base de datos para **consultar sin riesgo de borrar/modificar datos** desde la sala.

Los permisos cubren las tablas del esquema `public` vigentes en el momento del `init`; nuevas tablas futuras pueden requerir un `ALTER DEFAULT PRIVILEGES` adicional si se añaden fuera del mismo proceso de migración.

## Acceso desde otra máquina (tunnel SSH)

Si la base corre en un servidor remoto donde sólo tienes SSH:

```bash
ssh -N -L 5433:127.0.0.1:5432 usuario@servidor-remoto
```

En TablePlus: host `127.0.0.1`, puerto **5433** (u otro libre local), mismas credenciales que en el servidor.

## Qué tabla mirar primero

- `cowrie_events`: columnas de demostración alineadas con la API (`src_ip`, `event_type`, `username`, etc.).

No edites contenido desde TablePlus durante una demo guiada si el jurado debe ver integridad estable; mejor usa la cuenta **`honeypot_readonly`** o limita tus consultas a `SELECT`.
