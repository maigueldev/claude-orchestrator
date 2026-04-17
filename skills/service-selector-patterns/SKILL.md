---
name: service-selector-patterns
description: Plantillas y reglas para escribir services.py (escritura, @transaction.atomic, kwargs-only, excepciones de dominio) y selectors.py (lectura, QuerySet, queries optimizadas). Invocar al escribir lógica de escritura o lectura de una app.
---

# Service & Selector Patterns

## `services.py` — escritura

```python
@transaction.atomic
def publish_property(*, property_id: int) -> Property:
    property_ = Property.objects.select_for_update().get(pk=property_id)
    if property_.price <= 0:
        raise PropertyNotPublishable("Price must be positive")
    property_.is_published = True
    property_.save(update_fields=["is_published"])
    return property_

@transaction.atomic
def create_property(*, owner_id: int, title: str, price: Decimal, location_id: int) -> Property:
    return Property.objects.create(
        owner_id=owner_id, title=title, price=price, location_id=location_id,
    )

@transaction.atomic
def update_property(*, property_id: int, **fields) -> Property:
    allowed = {"title", "price"}
    if invalid := set(fields) - allowed:
        raise ValueError(f"Invalid fields: {invalid}")
    property_ = Property.objects.select_for_update().get(pk=property_id)
    for key, value in fields.items():
        setattr(property_, key, value)
    property_.save(update_fields=list(fields.keys()))
    return property_

@transaction.atomic
def delete_property(*, property_id: int) -> None:
    Property.objects.filter(pk=property_id).delete()
```

### Reglas
1. **kwargs-only**: `def foo(*, x: int)`.
2. **`@transaction.atomic`** en toda función que mute.
3. **`select_for_update`** si hay concurrencia sobre el mismo registro.
4. **`save(update_fields=[...])`** cuando actualizás un subconjunto.
5. **Excepciones de dominio** (`exceptions.py`), no `ValueError` crudos.
6. **Devolver el modelo**. No devuelvas dicts ni tuplas.
7. **No importés modelos de otra app.**

## `selectors.py` — lectura

```python
def get_published_properties(*, city: str | None = None, min_price: int | None = None) -> QuerySet[Property]:
    qs = Property.objects.filter(is_published=True).select_related("location")
    if city:
        qs = qs.filter(location__city=city)
    if min_price is not None:
        qs = qs.filter(price__gte=min_price)
    return qs

def get_property(*, property_id: int) -> Property:
    return (
        Property.objects
        .select_related("location", "owner")
        .prefetch_related("images")
        .get(pk=property_id)
    )
```

### Reglas
1. **kwargs-only**.
2. **Devolver `QuerySet[Model]`** para 0..N resultados.
3. **`select_related` / `prefetch_related` siempre** al acceder a FKs/M2M.
4. **No mutés** desde un selector.

## Anti-patrones

- Service sin `@transaction.atomic`.
- Selector que muta.
- `Model.objects.filter(...)` en `views.py`.
- `from apps.<otra_app>.models import ...` desde services/selectors.
