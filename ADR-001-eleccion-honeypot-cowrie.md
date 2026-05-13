# ADR-001: Elección de Cowrie como Honeypot

**Estado:** Aceptado  
**Fecha:** 2025  
**Autores:** Victor Benitez, Tamara Schnaas, Tania Hernández

---

## Contexto

El proyecto requiere capturar telemetría de intentos de acceso no autorizado para demostrar un flujo completo de datos: captura → ingesta → almacenamiento → visualización. Para ello necesitamos un **honeypot** que simule servicios reales (SSH/Telnet), registre las interacciones de atacantes o bots, y emita los eventos en un formato estructurado que pueda ser procesado automáticamente.

Las opciones evaluadas fueron:

| Opción | Descripción |
|---|---|
| **Cowrie** | Honeypot de interacción media para SSH y Telnet, escrito en Python |
| **Dionaea** | Honeypot multiprotocolo (FTP, SMB, HTTP, etc.) orientado a malware |
| **Honeyd** | Honeypot de baja interacción, simula hosts virtuales a nivel de red |
| **OpenSSH real** | Servidor SSH legítimo con logging extendido (no es un honeypot) |

---

## Decisión

Usamos **Cowrie** como componente de captura del honeypot.

---

## Justificación

1. **Formato de log JSON nativo.**  
   Cowrie escribe cada evento (intento de login, comando ejecutado, sesión iniciada/cerrada) en `cowrie.json` como objetos JSON línea a línea. Esto permite que el shipper los lea directamente con `readline()` sin necesidad de parsear formatos propietarios o configurar agentes externos.

2. **Interacción media.**  
   A diferencia de honeypots de baja interacción (que solo registran conexiones), Cowrie simula un shell SSH funcional. Esto genera eventos más ricos: `cowrie.login.failed`, `cowrie.command.input`, `cowrie.session.connect`, etc., que son más interesantes como fuente de datos para el análisis.

3. **Imagen Docker oficial.**  
   `cowrie/cowrie:latest` está disponible en Docker Hub y funciona dentro de Compose sin configuración adicional, lo que simplifica la orquestación del stack completo.

4. **Comunidad activa y documentación.**  
   Cowrie tiene documentación extensa, es ampliamente usado en entornos académicos y de investigación en ciberseguridad, y su código es auditable (Python puro).

5. **Alcance académico adecuado.**  
   Para el objetivo del curso (demostrar un pipeline de datos desde una fuente no convencional), Cowrie ofrece suficiente riqueza de eventos sin la complejidad operativa de herramientas como un SIEM completo.

---

## Consecuencias

**Positivas:**
- El shipper puede leer `cowrie.json` con lógica mínima (tail + JSON parse).
- Los eventos tienen campos bien definidos (`eventid`, `src_ip`, `username`, `password`, `input`, `timestamp`) que mapean directamente al esquema de `cowrie_events` en PostgreSQL.
- La imagen Docker no requiere build propio; reduce tiempo de setup.

**Negativas / limitaciones:**
- Cowrie escribe `cowrie.json` solo después del **primer contacto SSH** al puerto 2222. Hasta ese momento el shipper espera activamente, lo que puede sorprender en una demo si no se advierte.
- Cowrie simula SSH/Telnet únicamente; no cubre otros protocolos (HTTP, FTP, SMB). Para ampliar la superficie de captura se necesitaría un honeypot adicional o complementario.
- En redes institucionales el puerto 2222 puede estar bloqueado por firewall, limitando la posibilidad de demo con tráfico real externo.

---

## Referencias

- [Cowrie GitHub](https://github.com/cowrie/cowrie)
- [Cowrie Documentation](https://cowrie.readthedocs.io/)
- [Cowrie Docker Hub](https://hub.docker.com/r/cowrie/cowrie)
