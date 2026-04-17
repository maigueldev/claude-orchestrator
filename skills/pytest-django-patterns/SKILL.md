---
name: pytest-django-patterns
description: Patrones de pytest-django para tests de Django — markers, conftest, --reuse-db, layout por capa (test_services/test_selectors/test_api). Invocar al escribir tests en el proyecto.
---

# pytest-django Patterns

## Setup base

`pyproject.toml`:
```toml
[tool.pytest.ini_options]
DJANGO_SETTINGS_MODULE = "config.settings.test"
python_files = ["test_*.py"]
addopts = "--reuse-db --no-header -ra"
```

- `--reuse-db`: no recrea la BD entre runs. Usar `--create-db` al cambiar migraciones.

## Layout por capa

```
apps/properties/tests/
├── __init__.py
├── conftest.py
├── factories.py
├── test_services.py
├── test_selectors.py
└── test_api.py
```

## Marker obligatorio

```python
@pytest.mark.django_db
def test_publish_property_marks_as_published():
    ...

# Para toda la suite de un archivo:
pytestmark = pytest.mark.django_db
```

## Transacciones

- Por defecto, el test corre en una transacción que se revierte al final.
- Si necesitás transacciones reales: `@pytest.mark.django_db(transaction=True)`.

## Fixtures típicas

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

## Nombres de test

- `test_<acción>_<resultado_esperado>`.
- `test_publish_property_marks_as_published` ✓
- `test_1`, `test_property`, `test_works` ✗

## Correr subsets

```bash
uv run pytest
uv run pytest apps/properties/tests/
uv run pytest apps/properties/tests/test_services.py
uv run pytest -k "publish"
uv run pytest -vv --tb=long
uv run pytest --lf
```

## Checklist

- [ ] Marker `@pytest.mark.django_db` presente cuando se toca BD.
- [ ] Nombre descriptivo (`test_<acción>_<resultado>`).
- [ ] Un test = un comportamiento observable.
- [ ] Fixtures via `factory_boy`.
- [ ] Test falla por la razón esperada (no `ImportError`).
- [ ] Sin dependencia entre tests.
