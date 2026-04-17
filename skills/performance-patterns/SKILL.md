---
name: performance-patterns
description: Patrones de rendimiento del ORM de Django — N+1, select_related, prefetch_related, update_fields, select_for_update, only/defer. Invocar al escribir selectors/services o revisar el impacto de queries.
---

# Performance Patterns

## N+1 — detectar y evitar

```python
# ❌ N+1
for prop in Property.objects.filter(is_published=True):
    print(prop.location.city)  # 1 query extra por cada propiedad

# ✅ una query
qs = Property.objects.filter(is_published=True).select_related("location")
for prop in qs:
    print(prop.location.city)
```

## `select_related` vs `prefetch_related`

- **`select_related`**: FK y OneToOne. JOIN en SQL. Una sola query.
- **`prefetch_related`**: M2M y reverse FK. Query adicional, une en Python.

```python
Property.objects.select_related("location", "owner")
Property.objects.prefetch_related("amenities", "images")
Property.objects.select_related("location").prefetch_related("images")

# prefetch con queryset custom
from django.db.models import Prefetch
Property.objects.prefetch_related(
    Prefetch("images", queryset=PropertyImage.objects.filter(is_primary=True))
)
```

## `update_fields` en `.save()`

```python
property_.is_published = True
property_.save(update_fields=["is_published"])
```

## `select_for_update` en concurrencia

```python
@transaction.atomic
def reserve_property(*, property_id: int, user_id: int) -> Property:
    property_ = Property.objects.select_for_update().get(pk=property_id)
    if property_.reserved_by_id is not None:
        raise PropertyAlreadyReserved()
    property_.reserved_by_id = user_id
    property_.save(update_fields=["reserved_by_id"])
    return property_
```

## `only` / `defer` en payloads grandes

```python
Property.objects.only("id", "title", "price")
Property.objects.defer("long_description")
```

## `exists()` en lugar de `if qs:`

```python
# ❌ carga filas
if Property.objects.filter(is_published=True):
    ...

# ✅ SELECT 1 LIMIT 1
if Property.objects.filter(is_published=True).exists():
    ...
```

## `bulk_create` y `bulk_update`

```python
Property.objects.bulk_create([Property(title=t) for t in titles], batch_size=500)
```

## Checklist para code-reviewer

- [ ] Todo acceso a FK/M2M en iteración cubierto por `select_related`/`prefetch_related`.
- [ ] `.save()` con `update_fields` cuando aplica.
- [ ] `select_for_update()` en mutaciones concurrentes.
- [ ] `exists()` en lugar de `if qs:`.
- [ ] Índices declarados en campos de filtrado frecuente.
