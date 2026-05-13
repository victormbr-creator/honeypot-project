# ADR-004: Elección de Streamlit como Dashboard de Visualización

**Estado:** Aceptado  
**Fecha:** 2025  
**Autores:** Victor Benitez, Tamara Schnaas, Tania Hernández

---

## Contexto

El pipeline necesita una capa de **visualización** que consuma los datos expuestos por la API FastAPI y los presente de forma interactiva a una audiencia no técnica (jurado, docente). El dashboard debe mostrar métricas agregadas (`total_events`, `recent_24h`), una tabla de eventos recientes y gráficas de distribución por IP y tipo de evento. El equipo trabaja principalmente en Python y el tiempo de desarrollo disponible es limitado.

Las opciones evaluadas fueron:

| Opción | Tipo | Descripción |
|---|---|---|
| **Streamlit** | Framework Python para dashboards | Convierte scripts Python en aplicaciones web interactivas |
| **Grafana** | Plataforma de observabilidad | Dashboard profesional con datasources configurables |
| **Dash (Plotly)** | Framework Python para apps analíticas | Componentes React bajo Python callbacks |
| **Aplicación web custom** | HTML + JS + CSS | Frontend hecho a medida consumiendo la API |
| **Jupyter Notebook** | Entorno interactivo de análisis | Visualización en celdas, no orientado a presentación en vivo |

---

## Decisión

Usamos **Streamlit** como capa de visualización, desplegado como contenedor Docker que consume los endpoints `/events` y `/stats` de la API.

---

## Justificación

1. **Desarrollo en Python puro sin frontend.**  
   `app.py` tiene 50 líneas de Python estándar. No requiere conocimientos de HTML, CSS, JavaScript ni configuración de bundlers. El equipo puede iterar sobre el dashboard con las mismas habilidades que usa para el resto del stack.

2. **Caché integrada con `@st.cache_data`.**  
   Streamlit ofrece el decorador `@st.cache_data(ttl=5)` que evita llamadas repetidas a la API en cada re-render. Con un TTL de 5 segundos, el dashboard se actualiza con frecuencia suficiente para mostrar nuevos eventos durante la demo sin saturar la API.

3. **Componentes listos para usar.**  
   `st.metric`, `st.dataframe` y `st.bar_chart` cubren todos los requisitos de visualización del proyecto sin configuración adicional. La tabla de eventos usa `use_container_width=True` para adaptarse al ancho de la pantalla del presentador.

4. **Despliegue trivial en Docker.**  
   El Dockerfile del dashboard es de 5 líneas: instala dependencias y ejecuta `streamlit run app.py --server.address=0.0.0.0 --server.port=8501`. No requiere servidor web adicional (nginx, gunicorn) ni configuración de rutas.

5. **Consumo desacoplado vía API.**  
   El dashboard no conecta directamente a PostgreSQL; consume `http://api:8000` mediante `httpx`. Esto respeta la separación de capas de la arquitectura y permite que el dashboard sea reemplazado o actualizado sin tocar la BD ni la API.

6. **Mensaje de estado ante fallo de conexión.**  
   Si la API no está disponible, `app.py` captura la excepción y muestra `st.error(...)` con la URL fallida antes de llamar a `st.stop()`. Esto evita un crash silencioso y da información útil durante la demo si algún servicio no levantó correctamente.

---

## Consecuencias

**Positivas:**
- El tiempo de desarrollo del dashboard fue mínimo; la mayor parte del esfuerzo del proyecto se concentró en el pipeline de datos (shipper, API, BD).
- La interfaz es funcional y suficiente para demostrar el flujo completo ante el jurado.
- El refresco automático por TTL de caché muestra nuevos eventos SSH sin intervención manual más allá de refrescar el navegador.

**Negativas / limitaciones:**
- Streamlit no está diseñado para dashboards de producción de alta concurrencia; cada usuario abre una sesión Python independiente. Para el alcance académico esto no es un problema.
- El estado de la aplicación se reinicia en cada sesión; no hay persistencia de filtros o selecciones entre recargas.
- Las opciones de personalización visual (temas, layouts complejos) son más limitadas que en Grafana o Dash. El dashboard tiene apariencia estándar de Streamlit.
- El caché de ~5 segundos puede dar la impresión de que el dashboard "no responde" inmediatamente tras un evento SSH; esto debe advertirse durante la presentación.

---

## Referencias

- [Streamlit Documentation](https://docs.streamlit.io/)
- [st.cache_data](https://docs.streamlit.io/develop/api-reference/caching-and-state/st.cache_data)
- [Streamlit Docker deployment](https://docs.streamlit.io/deploy/tutorials/docker)
