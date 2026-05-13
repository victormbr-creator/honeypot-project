from fastapi.testclient import TestClient
from main import app

client = TestClient(app)


def test_healthcheck():
    response = client.get("/health")
    assert response.status_code == 200


def test_get_events_returns_shape():
    response = client.get("/events")
    assert response.status_code == 200
    body = response.json()
    assert isinstance(body, dict)
    assert "events" in body
    assert isinstance(body["events"], list)


def test_stats_shape():
    response = client.get("/stats")
    assert response.status_code == 200
    body = response.json()
    assert "total_events" in body
    assert "top_ips" in body
    assert "top_event_types" in body
    assert "recent_24h" in body
