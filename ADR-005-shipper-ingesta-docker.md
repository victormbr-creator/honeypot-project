# ADR-005: Elección de Shipper Python como Componente de Ingesta en Docker Compose

**Estado:** Aceptado  
**Fecha:** 2025  
**Autores:** Victor Benitez, Tamara Schnaas, Tania Hernández

---

## Contexto

Cowrie escribe sus eventos en `cowrie.json` como un archivo de log rotativo en un volumen Docker. Necesitamos un componente que **lea ese archivo continuamente** y envíe cada línea nueva como evento a la API FastAPI. Este componente es el puente entre la capa de captura (Cowrie) y la capa de procesamiento (FastAPI + PostgreSQL).

El componente debe funcionar dentro de Docker Compose, compartir el volumen de Cowrie en modo lectura, tolerar que el archivo no exista al arrancar (Cowrie lo crea solo tras el primer contacto SSH), y reanudar desde donde quedó si se reinicia.

Las opciones evaluadas fueron:

| Opción | Tipo | Descripción |
|---|---|---|
| **Shipper Python custom** | Script stdlib Python | Lee `cowrie.json` con lógica tipo `tail -f` y hace POST a la API |
| **Filebeat** | Agente de logs (Elastic) | Agente de producción para envío de logs a destinos configurables |
| **Logstash** | Pipeline ETL (Elastic) | Ingesta, transformación y envío de logs con plugins |
| **Vector** | Agente de observabilidad moderno | Pipeline de datos de alta performance (Rust) |
| **Lectura directa a BD** | Sin intermediario | Cowrie escribe directo a PostgreSQL via plugin |

---

## Decisión

Usamos un **shipper Python custom** (`shipper/shipper.py`) que corre como servicio independiente en Docker Compose, comparte el volumen `cowrie_var` con Cowrie en modo solo lectura, y persiste su offset en un volumen separado `shipper_state`.

---

## Justificación

1. **Sin dependencias externas — solo stdlib Python.**  
   `shipper.py` usa únicamente módulos de la biblioteca estándar (`json`, `os`, `sys`, `time`, `urllib.request`, `pathlib`). El Dockerfile del shipper es de 3 líneas: imagen base Python slim, copia del script, y CMD. No requiere instalar ningún paquete adicional, lo que elimina riesgos de compatibilidad y reduce el tamaño de la imagen.

2. **Lógica de offset para resiliencia.**  
   El shipper persiste la posición de lectura (`byte offset`) en `shipper_state:/data/cowrie_shipper.offset` después de cada línea enviada exitosamente. Si el contenedor se reinicia (`restart: on-failure:5` en Compose), retoma desde la última línea confirmada sin reenviar eventos duplicados ni perder eventos nuevos.

3. **Espera activa ante archivo ausente.**  
   `wait_for_logfile()` espera hasta 3600 segundos con polling cada 5 segundos antes de salir con error. Esto cubre el caso conocido donde Cowrie no crea `cowrie.json` hasta el primer contacto SSH, evitando que el shipper falle inmediatamente al arrancar.

4. **Backoff exponencial ante errores de red.**  
   Si el `POST /events` falla (API no disponible, error HTTP), el shipper retrocede al `pos_before` de la línea fallida y reintenta con backoff exponencial (1s → 2s → ... → 60s máximo). Esto garantiza que ningún evento se pierda por un fallo transitorio de la API.

5. **Separación de responsabilidades clara.**  
   El shipper hace exactamente una cosa: leer líneas de `cowrie.json` y enviarlas a `POST /events`. La transformación del formato Cowrie al modelo `EventIn` de la API ocurre en `cowrie_line_to_payload()`, una función pura y testeable. La validación final es responsabilidad de la API.

6. **Alternativas descartadas por complejidad innecesaria.**  
   Filebeat, Logstash y Vector son herramientas de producción diseñadas para infraestructuras con múltiples fuentes y destinos. Introducirlas añadiría configuración YAML adicional, dependencias de imágenes pesadas, y conocimiento específico de cada herramienta, sin beneficio real para el alcance académico del proyecto.

---

## Consecuencias

**Positivas:**
- El shipper es completamente auditable en ~200 líneas de Python legible, lo que facilita su explicación ante el jurado.
- El volumen `cowrie_var` se monta como `:ro` (solo lectura) en el shipper, lo que garantiza que nunca puede modificar los logs originales de Cowrie.
- Los logs del shipper (`docker logs honeypot-shipper`) son informativos: reportan el offset de inicio, cada espera por el archivo, y errores de red con detalle.

**Negativas / limitaciones:**
- El shipper no maneja rotación de logs de Cowrie. Si `cowrie.json` es rotado (renombrado y recreado), el offset guardado podría apuntar a una posición inválida. El código detecta esto comparando el offset con el tamaño actual del archivo y lo resetea a 0, pero podría perder eventos del archivo rotado.
- No hay deduplicación en la API; si el shipper reenvía una línea por un error de red justo después de un POST exitoso, se insertará un evento duplicado en la BD. Para el volumen de una demo académica esto es aceptable.
- El polling con `SHIPPER_BATCH_SLEEP=0.1s` consume CPU mínimamente de forma continua. Para un entorno de producción sería preferible `inotify` o un mecanismo de notificación de sistema de archivos.

---

## Referencias

- [Cowrie log format](https://cowrie.readthedocs.io/en/latest/json/README.html)
- [Python urllib.request](https://docs.python.org/3/library/urllib.request.html)
- [Docker Compose volumes (read-only)](https://docs.docker.com/compose/compose-file/07-volumes/)
- [Filebeat (referencia descartada)](https://www.elastic.co/beats/filebeat)
