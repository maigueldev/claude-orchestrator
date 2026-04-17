---
name: hacksoft-layered-architecture
description: Reglas detalladas y ejemplos del estilo HackSoft Nivel 2 para Django — qué va en models/services/selectors/api/validators/exceptions, qué NO va, y anti-patrones a rechazar en revisión. Invocar al escribir o revisar código de cualquier app Django.
---

# HackSoft Layered Architecture (Nivel 2)

Una app por bounded context. Cada archivo tiene una responsabilidad única. Sin excepciones.

## `models.py` — ORM + invariantes

- Solo definición de modelos y sus invariantes (`clean()`, `Meta.constraints`, `Meta.indexes`).
- **Sin métodos de negocio gordos.** `publish()` va en `services.py`.
- **Sin queries complejas.** `get_published()` va en `selectors.py`.

```python
class Property(models.Model):
    title = models.CharField(max_length=200)
    price = models.DecimalField(max_digits=12, decimal_places=2)
    is_published = models.BooleanField(default=False)

    class Meta:
        constraints = [
            models.CheckConstraint(check=models.Q(price__gt=0), name="property_price_positive"),
        ]
        indexes = [models.Index(fields=["is_published"])]
```

## `services.py` — escritura

- Funciones **kwargs-only** (`def foo(*, x: int)`).
- **`@transaction.atomic` siempre** en funciones que mutan.
- Reciben datos, devuelven el modelo resultante.
- Lanzan excepciones de `exceptions.py`, no `ValueError` crudos.
- `select_for_update()` en concurrencia sobre un registro.
- `save(update_fields=[...])` al actualizar un subconjunto.

```python
@transaction.atomic
def publish_property(*, property_id: int) -> Property:
    property_ = Property.objects.select_for_update().get(pk=property_id)
    if property_.price <= 0:
        raise PropertyNotPublishable("Price must be positive")
    property_.is_published = True
    property_.save(update_fields=["is_published"])
    return property_
```

## `selectors.py` — lectura

- Funciones **kwargs-only**.
- Devuelven `QuerySet[Model]` o un modelo.
- `select_related`/`prefetch_related` **siempre** al tocar relaciones.
- `only`/`defer` en payloads grandes.

```python
def get_published_properties(*, city: str | None = None) -> QuerySet[Property]:
    qs = Property.objects.filter(is_published=True).select_related("location")
    if city:
        qs = qs.filter(location__city=city)
    return qs
```

## `exceptions.py` — excepciones de dominio

```python
class PropertyError(Exception): ...
class PropertyNotPublishable(PropertyError): ...
class PropertyNotFound(PropertyError): ...
```

## `api/` — capa DRF

- `serializers.py` — uno por acción.
- `views.py` — ViewSets que llaman a `services`/`selectors`. **Nunca ORM directo.**
- `permissions.py` — permission classes custom.
- `urls.py` — router y `@action` endpoints.

## Regla de oro — ¿dónde va esto?

| ¿Qué hace el código? | Archivo |
|---|---|
| Cambia estado en BD | `services.py` |
| Lee datos | `selectors.py` |
| Integridad básica del modelo | `models.py` (`clean`, `constraints`) |
| Traduce HTTP → lógica | `api/views.py` |
| Valida/serializa entrada/salida | `api/serializers.py` |
| Permiso de acceso | `api/permissions.py` |
| Excepción de dominio | `exceptions.py` |
| Validación reutilizable | `validators.py` |

## Anti-patrones (rechazar en revisión)

- ORM en `views.py`.
- `services.py` mutando sin `@transaction.atomic`.
- Serializer con lógica de negocio en `.create()`/`.update()`.
- Modelo de app A importado desde app B.
- Query repetida en varios sitios en vez de extraerla a un selector.
- Métodos de negocio gordos en `models.py`.
