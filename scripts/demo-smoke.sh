#!/usr/bin/env bash
# Humo rápido contra la API local (tras `docker compose up`).
# Uso: API_BASE_URL=http://127.0.0.1:8000 ./scripts/demo-smoke.sh
set -euo pipefail

API_BASE_URL="${API_BASE_URL:-http://127.0.0.1:8000}"
API_BASE_URL="${API_BASE_URL%/}"

echo "== Smoke API en ${API_BASE_URL} =="

echo "GET /health"
curl -sfS "${API_BASE_URL}/health" | python3 -m json.tool 2>/dev/null || curl -sfS "${API_BASE_URL}/health"
echo

echo "GET /events?limit=1"
curl -sfS "${API_BASE_URL}/events?limit=1" | python3 -m json.tool 2>/dev/null || curl -sfS "${API_BASE_URL}/events?limit=1"
echo

echo "GET /stats"
curl -sfS "${API_BASE_URL}/stats" | python3 -m json.tool 2>/dev/null || curl -sfS "${API_BASE_URL}/stats"
echo

echo "OK — humo completado."
echo "Nota: el primer evento en Cowrie puede tardar hasta que alguien se conecte al puerto 2222; entonces aparece cowrie.json y el shipper empieza a enviar líneas."
