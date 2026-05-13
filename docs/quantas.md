# Architecture Quantas — Plataforma de Telemetría para Honeypot

## ¿Qué es un Architecture Quantum?

Un *architecture quantum* es una unidad desplegable de forma independiente 
con alta cohesión funcional. Define los límites naturales del sistema: 
qué partes pueden cambiar, escalar o reemplazarse sin afectar a las demás.

---

## Quantum 1: Captura

**Servicios:** Cowrie + **shipper** (contenedor `shipper/` en Docker Compose)

**Responsabilidad:**  
Simular servicios vulnerables (SSH/Telnet) y transformar las interacciones 
de los atacantes en eventos estructurados que el resto del sistema pueda consumir.

**Características:**
- Cowrie es el único servicio expuesto hacia el exterior para interacción de atacantes (puerto **2222**)
- Cowrie genera logs en formato JSON de forma nativa (`var/log/cowrie/cowrie.json` dentro de su volumen)
- El **shipper** lee ese archivo (mismo volumen montado en solo lectura), avanza con offset persistente y realiza `POST /events` al quantum de procesamiento
- Alta disponibilidad deseable: si cae Cowrie o el shipper, se pierden o retrasan eventos hasta recuperación

**Independencia:**  
Cowrie puede reemplazarse por cualquier otro honeypot (Dionaea, HoneyD) 
sin modificar los quantas de procesamiento ni visualización, siempre que 
el componente de ingesta mantenga el **contrato del payload** documentado hacia la API (hoy modelado como `EventIn` en FastAPI).

---

## Quantum 2: Procesamiento

**Servicios:** FastAPI + PostgreSQL

**Responsabilidad:**  
Recibir, validar y persistir los eventos capturados. Exponer los datos 
almacenados mediante una API REST para su consumo por otros servicios.

**Características:**
- FastAPI y PostgreSQL están intencionalmente acoplados: la API no tiene 
  sentido sin la base de datos y viceversa
- Validación de esquema mediante modelos Pydantic antes de cualquier 
  escritura en base de datos
- Expone documentación OpenAPI automática en `/docs`
- Es el único quantum que escribe en la base de datos

**Independencia:**  
La base de datos puede migrarse a otro motor relacional (MySQL, SQLite 
para desarrollo) modificando únicamente la cadena de conexión. 
El dashboard consume este quantum exclusivamente a través de la API, 
nunca conectándose directamente a PostgreSQL.

---

## Quantum 3: Visualización

**Servicios:** Streamlit

**Responsabilidad:**  
Consultar los datos almacenados y presentarlos como métricas e indicadores 
visuales para el análisis humano.

**Características:**
- Consumo de datos exclusivamente a través de la API REST (Quantum 2)
- Solo lectura: no escribe ni modifica datos
- Completamente intercambiable: puede reemplazarse por Grafana, Metabase 
  o cualquier herramienta de BI sin afectar los otros quantas
- Accesible únicamente dentro de la red interna del proyecto

---

## Diagrama de relación entre quantas
