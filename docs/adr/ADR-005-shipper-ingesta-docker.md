# ADR-005: Ingesta con shipper ligero sobre volumen Cowrie en Docker Compose

## Estado
Aceptado

## Contexto
Cowrie produce eventos como líneas JSON en un archivo dentro de su volumen de datos (`cowrie.json`). La API FastAPI debe recibir estos eventos sin acoplar directamente Cowrie al código Python del backend, manteniendo el quantum de captura reemplazable y el contrato REST simple (`POST /events`).

Las alternativas incluyen ejecutar Fluent Bit / Vector dentro de Compose, usar sidecar oficial de Splunk/DataDog configurado en Cowrie, o ejecutar comandos dentro del contenedor Cowrie contra la API. El proyecto académico prioriza reproducibilidad mínima y trazabilidad en el código del repositorio.

## Decisión
Se usa un **contenedor Python mínimo (stdlib)** que comparte volumen solo lectura con Cowrie, hace lectura tipo *tail* con persistencia de offset en un volumen pequeño, y **envía payloads JSON** documentados como `EventIn` a la API sobre la red Compose.

## Consecuencias

### Positivas
- La demo muestra explicitamente **transporte observable** desde logs hasta Postgres (narrativa clara ante el jurado).
- Cambiar Cowrie por otro honeypot sólo exige compatibilizar el **mapeo** de líneas entrantes manteniendo el contrato REST.
- No se añade broker ni dependencias pesadas sólo por la clase.

### Limitaciones
- Robustez menor que un agente oficial de ingestión ante rotación/agresivos volúmenes de log.
- Requiere que el archivo JSON exista; hasta el primer evento puede haber espera perceptible si no hay datos de muestra cargados desde la base.
