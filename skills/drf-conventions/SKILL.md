---
name: drf-conventions
description: Convenciones DRF — serializer por acción (List/Detail/Create/Update), permission_classes explícitos, versionado URL /api/v1/, paginación global. Invocar al escribir o revisar serializers, views, permissions o urls.
---

# DRF Conventions

## Serializers por acción

Un serializer por acción, no uno genérico por modelo.

```python
class PropertyListSerializer(serializers.ModelSerializer):
    class Meta:
        model = Property
        fields = ("id", "title", "price", "is_published")

class PropertyDetailSerializer(serializers.ModelSerializer):
    class Meta:
        model = Property
        fields = ("id", "title", "price", "is_published", "location", "created_at")

class PropertyCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Property
        fields = ("title", "price", "location")

    def validate_price(self, value):
        if value <= 0:
            raise serializers.ValidationError("Price must be positive")
        return value

class PropertyUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Property
        fields = ("title", "price")
```

**Reglas:**
- `create`/`update` de los serializers **NO mutan la BD directamente**. El ViewSet extrae `validated_data` y llama a un service.
- Nombres: `<Modelo><Acción>Serializer`.

## Permission classes

**Siempre explícitos.** Sin heredar defaults implícitos.

```python
class PropertyViewSet(ViewSet):
    permission_classes = [IsAuthenticated, IsOwner]
```

- `AllowAny` solo con justificación explícita.
- Permisos a nivel objeto → `has_object_permission`.

## Versionado por URL

Prefijo obligatorio `/api/v1/`.

```python
# config/urls.py
urlpatterns = [
    path("api/v1/", include("apps.properties.api.urls")),
]
```

Cuando haya un breaking change, se monta `/api/v2/` en paralelo — no se rompe v1.

## Paginación global

Clase por confirmar (default provisional `CursorPagination`):

```python
REST_FRAMEWORK = {
    "DEFAULT_PAGINATION_CLASS": "rest_framework.pagination.CursorPagination",
    "PAGE_SIZE": 20,
}
```

## Throttling / rate limit

Pendiente de definir.
