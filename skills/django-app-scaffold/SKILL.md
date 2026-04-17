---
name: django-app-scaffold
description: Checklist y plantillas para crear una app Django nueva con la estructura Nivel 2 HackSoft completa — todos los archivos necesarios, registro en INSTALLED_APPS, routing global, admin. Invocar al crear un nuevo bounded context.
---

# Django App Scaffold

## Cuándo crear una app nueva

Una app = un bounded context del dominio. Si tiene su propio agregado raíz, sus propias reglas de negocio, y potencial de evolucionar independientemente → **merece una app propia**.

## Estructura completa a crear

```
apps/<nombre>/
├── __init__.py
├── apps.py
├── models.py
├── services.py
├── selectors.py
├── validators.py
├── exceptions.py
├── admin.py
├── api/
│   ├── __init__.py
│   ├── serializers.py
│   ├── views.py
│   ├── permissions.py
│   └── urls.py
├── migrations/
│   └── __init__.py
└── tests/
    ├── __init__.py
    ├── conftest.py
    ├── factories.py
    ├── test_services.py
    ├── test_selectors.py
    └── test_api.py
```

## Plantillas mínimas

### `apps.py`
```python
from django.apps import AppConfig

class PropertiesConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "apps.properties"
    label = "properties"
```

### `exceptions.py`
```python
class <Nombre>Error(Exception):
    """Base exception for the <nombre> domain."""
```

### `api/urls.py`
```python
from rest_framework.routers import DefaultRouter
router = DefaultRouter()
urlpatterns = router.urls
```

### `tests/test_services.py`, `test_selectors.py`, `test_api.py`
```python
import pytest
pytestmark = pytest.mark.django_db
```

## Registro en el proyecto

### 1. `INSTALLED_APPS`
```python
INSTALLED_APPS = [
    "rest_framework",
    "apps.core",
    "apps.properties",
]
```

### 2. URLs globales
```python
urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/v1/", include("apps.properties.api.urls")),
]
```

### 3. Migraciones
El **desarrollador** corre — el agente no:
```bash
uv run python manage.py makemigrations <nombre>
uv run python manage.py migrate
```

## Checklist

- [ ] Directorio `apps/<nombre>/` creado con todos los archivos.
- [ ] `apps.py` con `name = "apps.<nombre>"` y `default_auto_field = BigAutoField`.
- [ ] App registrada en `INSTALLED_APPS`.
- [ ] URLs incluidas en `config/urls.py` bajo `/api/v1/`.
- [ ] `tests/__init__.py` y `migrations/__init__.py` presentes.
- [ ] Migración **declarada como pendiente** para que el desarrollador la ejecute.
