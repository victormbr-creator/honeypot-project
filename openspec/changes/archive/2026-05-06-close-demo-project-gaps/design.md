## Context

La plataforma ya incluye Compose con Postgres, Cowrie (2222), API FastAPI, shipper sobre `cowrie.json`, volumen para offset del shipper y Streamlit que consume `/events` + `/stats`. El README tiene guía corta de demo y `db/init.sql` inserta filas de muestra en la **primera** inicialización del volumen. Ante el jurado debe existir un **rito claro**: qué comprobar, en qué orden y qué se considera tolerancia esperada (caché de Streamlit ~5 s, creación tardía del log JSON hasta primer contacto SSH).

Stakeholders principales del diseño aquí son el equipo (qué implementar antes de la fecha) y el docente/host (quién asume los riesgos de exponer un honeypot en redes de laboratorio vs domésticas).

## Goals / Non-Goals

**Goals:**

- Cerrar el **circuito perceptible**: “algo se ve en pantalla muy pronto”, “un ataque sintético (SSH falto) aumenta evidencia dentro de tiempo razonable”.
- Formalizar evidencia repeatable o casi repeatable (lista de comandos + criterios, humo automatizado opcional).
- Explicitar trabajo remaniente de **documentación/export** como parte de la entrega, no sólo código.

**Non-Goals:**

- Producto hardened production en internet público extendido sin controles organizacionales.
- Integraciones IA (p. ej. Hermes Agent) como requisito de cierre si no están en el alcance aprobado de la materia.
- Alta disponibilidad, colas de mensajes industriales u observabilidad nivel SRE más allá de healthchecks Compose.

## Decisions

1. **Dos capas de “listo”: demo ≠ hardening.**  
   *Rationale:* El curso típicamente puntúa flujo datos + narrativa técnica; el endurecimiento profundo tiene coste alto y debe ser decidido conscientemente como extra.

2. **Paridad README/OpenAPI vía proceso humano más que generación mágica en CI** (opcional futuro: regenerar desde OpenAPI desde FastAPI en build).  
   *Rationale:* El repo YA documenta rutas (`/stats`, `/events/{id}`); export estático debe alinearse antes de llamar cerrada la parte “informe/evidencias” sin imponer hoy infra compleja.

3. **Script de smoke opcional (shell/Makefile)** usando `curl` contra `localhost` después de `up`.  
   *Rationale:* Aumenta confianza en salas donde no pueden abrir todas las GUIs síncronamente; alternativa menos preferida ante ausencia total de cliente HTTP: sólo checklist manual.

## Risks / Trade-offs

[Riesgo Puertos honeypot exuestos accidentalmente sobre red abierta sin consentimiento institucional] → Mitigar con advertencia README, puertos sólo donde el docente lo permita, y narrativa demo “solo laboratorio aisladas”.

[Riesgo Volumen Postgres antiguo sin seed y dashboard “vacío dramático”] → Mitigar con `docker compose down -v` en ensayo previo documentado para la presentación; no auto-seeded en volumen vivo.

[Riesgo Demora perceptible primera línea de log Cowrie hasta evento SSH] → Mitigar con filas muestra locales + texto en presentación aclaratorio.

## Migration Plan

1. Ejecutar ensayo íntegra en equipo con volumen fresco.
2. Ajustar documentación/smoke donde falle repetibilidad observada real.
3. Archivar cambio cuando `tasks.md` marcado cerrado tras implementación opcional pendiente decidida como in-scope para el equipo.

## Open Questions

¿El jurado permitirá tráfico real al honeypot o demo totalmente sintético + seed? ¿Se exige **documentación en PDF/memoria aparte del repo `README`** definida como fuera de estos specs?
