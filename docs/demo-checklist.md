# Checklist de ensayo para la presentación final

Ejecuta estos pasos **en la misma máquina** donde presentarás, **antes** del día del jurado.

## 1. Arranque en limpio (volumenes nuevos)

1. Copia entorno si aún no existe: `cp .env.example .env`
2. Apaga y borra volúmenes: `docker compose down -v`
3. Construye y levanta: `docker compose up --build -d`
4. Verifica proceso: `docker compose ps` (cinco servicios `running`; el shipper puede seguir esperando `cowrie.json` hasta que haya tráfico al honeypot)

## 2. Sin SSH: datos visibles en el dashboard

1. Espera ~30–60 s a que la API marque healthy (Compose ya tiene healthchecks).
2. Abre el dashboard en `http://localhost:$DASHBOARD_PORT` (por defecto `8501`).
3. Comprueba que **métricas y tabla no estén vacías** si Postgres se inicializó de cero (`db/init.sql` inserta filas de muestra en el primer bootstrap del volumen).
4. Opcional rápido: `make demo-smoke` (requiere API arriba; ver `Makefile`).

## 3. Con SSH: nueva actividad en ≤60 s

1. Ejecuta: `ssh root@localhost -p 2222` (acepta fingerprint; cualquier intento falto cuenta).
2. Cowrie creará `var/log/cowrie/cowrie.json` dentro de su volumen; el shipper lo leerá y hará POST a `/events`.
3. Tras hasta **unos 60 segundos** (y hasta **~5 s** de caché en Streamlit), refresca el dashboard o revisa `curl -s "http://localhost:8000/stats"`.
4. Deberías ver **aumento** en `total_events` o filas nuevas respecto al paso 2.

## Notas

- Si el dashboard “no cambia” al instante: Streamlit cachea consultas unos segundos; usar **refresco del navegador** o esperar el TTL.
- Si no hay filas de muestra: probablemente reutilizas un volumen Postgres antiguo; usa `docker compose down -v` y vuelve al paso 1.
