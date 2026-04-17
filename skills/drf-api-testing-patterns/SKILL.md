---
name: drf-api-testing-patterns
description: Patrones para testear endpoints DRF con APIClient — auth, aserciones de status/body, paginación, errores de validación, permisos. Invocar al escribir test_api.py.
---

# DRF API Testing Patterns

## Setup

```python
# tests/conftest.py
@pytest.fixture
def api_client() -> APIClient:
    return APIClient()

@pytest.fixture
def authenticated_client(api_client, user_factory):
    user = user_factory()
    api_client.force_authenticate(user=user)
    return api_client
```

## Patrón base de test

```python
pytestmark = pytest.mark.django_db

class TestPropertyList:
    def test_returns_published_properties(self, authenticated_client, property_factory):
        property_factory(is_published=True)
        property_factory(is_published=False)
        response = authenticated_client.get("/api/v1/properties/")
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data["results"]) == 1

    def test_unauthenticated_returns_401(self, api_client):
        response = api_client.get("/api/v1/properties/")
        assert response.status_code == status.HTTP_401_UNAUTHORIZED
```

## Aserciones de status

Usá constantes de `rest_framework.status`, nunca códigos literales:
```python
assert response.status_code == status.HTTP_200_OK
assert response.status_code == status.HTTP_201_CREATED
assert response.status_code == status.HTTP_400_BAD_REQUEST
assert response.status_code == status.HTTP_401_UNAUTHORIZED
assert response.status_code == status.HTTP_403_FORBIDDEN
assert response.status_code == status.HTTP_404_NOT_FOUND
```

## Errores de validación

```python
def test_create_rejects_zero_price(authenticated_client):
    response = authenticated_client.post(
        "/api/v1/properties/",
        {"title": "Test", "price": 0, "location": 1},
        format="json",
    )
    assert response.status_code == status.HTTP_400_BAD_REQUEST
    assert "price" in response.data
```

## Endpoints custom (`@action`)

```python
def test_publish_endpoint(authenticated_client, property_factory):
    prop = property_factory(is_published=False, price=100)
    response = authenticated_client.post(f"/api/v1/properties/{prop.id}/publish/")
    assert response.status_code == status.HTTP_200_OK
    prop.refresh_from_db()
    assert prop.is_published is True
```

## Checklist del test-engineer para `test_api.py`

- [ ] Cubre el **camino feliz** (200/201).
- [ ] Cubre **auth fallida** (401).
- [ ] Cubre **permisos** (403).
- [ ] Cubre **validación** (400) con input inválido.
- [ ] Cubre **404** cuando el recurso no existe.
- [ ] Verifica **efecto en BD** con `refresh_from_db()`.
- [ ] Usa `status.HTTP_*` constantes.
- [ ] Usa `format="json"` en payloads.
