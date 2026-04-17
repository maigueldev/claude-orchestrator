---
name: factory-boy-patterns
description: Patrones de factory_boy para tests de Django — base factories, Sequence, SubFactory, Trait, post_generation. Invocar al crear o modificar factories para modelos Django.
---

# factory_boy Patterns

## Factory base

```python
# apps/properties/tests/factories.py
class PropertyFactory(DjangoModelFactory):
    class Meta:
        model = Property

    title = factory.Sequence(lambda n: f"Property {n}")
    price = factory.Faker("pydecimal", left_digits=6, right_digits=2, positive=True)
    is_published = False
    location = factory.SubFactory("apps.locations.tests.factories.LocationFactory")
```

**Reglas:**
- Una factory por modelo.
- `factory.Sequence` para campos únicos (`email`, `slug`, `title`).
- `factory.SubFactory` con **path string** (evita imports circulares).

## Traits

```python
class PropertyFactory(DjangoModelFactory):
    class Meta:
        model = Property
    title = factory.Sequence(lambda n: f"Property {n}")
    price = 100_000
    is_published = False

    class Params:
        published = factory.Trait(is_published=True)
        premium = factory.Trait(price=1_000_000, is_published=True)

# uso
PropertyFactory(published=True)
PropertyFactory(premium=True)
```

## `post_generation` (M2M)

```python
class PropertyFactory(DjangoModelFactory):
    @factory.post_generation
    def amenities(self, create, extracted, **kwargs):
        if not create:
            return
        if extracted:
            self.amenities.set(extracted)
```

## Como fixture de pytest

```python
@pytest.fixture
def property_factory():
    return PropertyFactory
```

## Reglas

- **Factories viven en `tests/factories.py`**, nunca en código de producción.
- **Usá `build()`** si necesitás una instancia sin persistir.
- **Batch:** `PropertyFactory.create_batch(10)` para colecciones.
- **No abuses de `Faker`** en campos que las aserciones necesitan conocer.
