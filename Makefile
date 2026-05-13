.PHONY: demo-smoke

# Requiere `docker compose up` y puerto API por defecto 8000.
demo-smoke:
	bash scripts/demo-smoke.sh
