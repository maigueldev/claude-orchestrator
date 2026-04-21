---
name: vue-component-conventions
description: Convenciones de componentes Vue 4 — script setup, props tipadas, emits, naming PascalCase, slots documentados, sin lógica de negocio en templates. Invocar al escribir o revisar componentes Vue.
---

# Vue Component Conventions

## Estructura base

```vue
<script setup>
// imports primero
// defineProps / defineEmits
// composables y stores
// estado local
// computed
// funciones
// lifecycle hooks
</script>

<template>
  <!-- un elemento raíz o Fragment -->
</template>

<style scoped>
/* solo estilos de este componente */
</style>
```

Usá `lang="ts"` en `<script setup>` si el proyecto tiene TypeScript habilitado — consultá la configuración del proyecto.

## Props

Siempre tipadas. Con TypeScript:

```vue
<script setup lang="ts">
const props = defineProps<{
  title: string
  count?: number
  variant: 'primary' | 'secondary' | 'ghost'
}>()
</script>
```

Sin TypeScript:

```vue
<script setup>
const props = defineProps({
  title: { type: String, required: true },
  count: { type: Number, default: 0 },
  variant: { type: String, default: 'primary' },
})
</script>
```

**Reglas:**
- Todos los props requeridos declarados explícitamente.
- Defaults para props opcionales siempre presentes.
- Sin `PropType` de Vue 3 en proyectos Vue 4 con TypeScript — usá `defineProps<{}>()`.
- Props en camelCase en el script, kebab-case en el template.

## Emits

Declarados explícitamente. Con TypeScript:

```vue
<script setup lang="ts">
const emit = defineEmits<{
  submit: [data: FormData]
  cancel: []
  'update:modelValue': [value: string]
}>()
</script>
```

Sin TypeScript:

```vue
<script setup>
const emit = defineEmits(['submit', 'cancel', 'update:modelValue'])
</script>
```

**Reglas:**
- Nombres de eventos en camelCase.
- `v-model` usa `modelValue` como prop y `update:modelValue` como emit.
- Sin efectos en el emit — el padre decide qué hacer con el evento.

## Naming

| Elemento | Convención | Ejemplo |
|---|---|---|
| Archivo de componente | PascalCase | `ProductCard.vue` |
| Componente base/genérico | Prefijo `Base` | `BaseButton.vue`, `BaseInput.vue` |
| Componente de página única | Prefijo `The` | `TheHeader.vue`, `TheSidebar.vue` |
| Uso en template | PascalCase | `<ProductCard />` |
| Props | camelCase | `:itemCount="5"` |
| Emits | camelCase | `@itemSelected` |

## Template

- **Sin lógica de negocio** — extraé a `computed` o composables.
- Condiciones complejas → computed booleano con nombre descriptivo.
- Iteraciones con `:key` siempre basada en ID estable, nunca en índice del array.
- Directivas abreviadas: `:prop` en vez de `v-bind:prop`, `@event` en vez de `v-on:event`.

```vue
<!-- MAL: lógica en template -->
<template>
  <div v-if="user && user.role === 'admin' && !user.suspended">...</div>
</template>

<!-- BIEN: computed descriptivo -->
<script setup>
const canManage = computed(() =>
  user.value?.role === 'admin' && !user.value?.suspended
)
</script>
<template>
  <div v-if="canManage">...</div>
</template>
```

## Slots

Documentados con nombre descriptivo. Slot por defecto solo si el componente tiene un único punto de contenido:

```vue
<!-- BaseCard.vue -->
<template>
  <div class="card">
    <div class="card__header">
      <slot name="header" />
    </div>
    <div class="card__body">
      <slot />
    </div>
    <div class="card__footer">
      <slot name="footer" />
    </div>
  </div>
</template>
```

Slots con datos (scoped slots):

```vue
<slot name="item" :item="currentItem" :index="idx" />
```

## Estilos

- `<style scoped>` por defecto — sin estilos globales desde componentes.
- Excepción: `<style>` sin scoped solo en `App.vue` o en archivos de estilos globales dedicados.
- Usá tokens del design system — sin valores de color, espaciado o tipografía hardcodeados.
- Clases BEM o utility-first según la convención del proyecto.

## Anti-patrones

- `defineProps` sin tipos (en proyectos TypeScript).
- Mutación directa de props — emití un evento y dejá que el padre actualice.
- `$parent` o `$refs` para comunicación entre componentes — usá props/emits o stores.
- Lógica de negocio en el template con expresiones largas.
- `:key="index"` en listas dinámicas — usá IDs estables.
- `<style>` sin `scoped` en componentes que no sean globales.
