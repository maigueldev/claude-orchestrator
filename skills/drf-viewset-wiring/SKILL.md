---
name: drf-viewset-wiring
description: Plantillas para conectar ViewSets DRF a services/selectors con get_serializer_class por acción, permission_classes explícitos, @action para endpoints custom, registro en router. Invocar al crear o modificar vistas DRF.
---

# DRF ViewSet Wiring

## Principio

El ViewSet **solo** traduce HTTP a llamadas de `services`/`selectors`. No contiene lógica de negocio ni accede al ORM directamente.

## Plantilla completa

```python
class PropertyViewSet(ViewSet):
    permission_classes = [IsAuthenticated]

    def get_permissions(self):
        if self.action in {"update", "partial_update", "destroy", "publish"}:
            return [IsAuthenticated(), IsOwner()]
        return super().get_permissions()

    def list(self, request):
        qs = get_published_properties(city=request.query_params.get("city"))
        page = self.paginate_queryset(qs)
        serializer = PropertyListSerializer(page, many=True)
        return self.get_paginated_response(serializer.data)

    def retrieve(self, request, pk: str):
        property_ = get_property(property_id=int(pk))
        return Response(PropertyDetailSerializer(property_).data)

    def create(self, request):
        serializer = PropertyCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        property_ = create_property(owner_id=request.user.id, **serializer.validated_data)
        return Response(PropertyDetailSerializer(property_).data, status=status.HTTP_201_CREATED)

    def partial_update(self, request, pk: str):
        serializer = PropertyUpdateSerializer(data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        property_ = update_property(property_id=int(pk), **serializer.validated_data)
        return Response(PropertyDetailSerializer(property_).data)

    @action(detail=True, methods=["post"])
    def publish(self, request, pk: str):
        try:
            property_ = publish_property(property_id=int(pk))
        except PropertyNotPublishable as exc:
            return Response({"detail": str(exc)}, status=status.HTTP_400_BAD_REQUEST)
        return Response(PropertyDetailSerializer(property_).data)
```

## Registro en el router

```python
# apps/properties/api/urls.py
router = DefaultRouter()
router.register("properties", PropertyViewSet, basename="property")
urlpatterns = router.urls
```

## Reglas

1. `permission_classes` declarados explícitamente en el class body.
2. Override `get_permissions` cuando los permisos varían por acción.
3. **Nunca** accedés al ORM directamente.
4. **Serializer por acción**.
5. **Paginación** vía `self.paginate_queryset` + `self.get_paginated_response`.
6. **`@action`** para endpoints custom. `detail=True` para recursos, `detail=False` para colecciones.

## Exception → HTTP status

| Excepción | HTTP |
|---|---|
| `Model.DoesNotExist` | 404 |
| `DRF ValidationError` | 400 |
| Excepción de dominio | 400 o 409 |
| Permiso denegado | 403 |
| No autenticado | 401 |
