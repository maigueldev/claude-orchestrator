---
name: vue-nuxt-architecture
description: Arquitectura por capas para Vue 4 + Nuxt — composables/stores/services/components/pages, reglas de responsabilidad por capa y anti-patrones a rechazar. Invocar al iniciar cualquier tarea frontend.
---

# Vue 4 + Nuxt — Arquitectura por capas

Una responsabilidad por capa. Sin excepciones.

## Mapa de capas

```
composables/    → lógica reactiva reutilizable, sin efecto de red
stores/         → estado global (Pinia)
services/       → acceso a red y efectos externos
components/     → UI pura y declarativa
pages/          → nivel de ruta, orquesta las capas
layouts/        → estructura de página persistente
utils/          → funciones puras sin estado
types/          → definiciones TypeScript compartidas
```

## `composables/` — lógica reactiva

- Funciones con prefijo `use`: `useCart`, `useValidation`, `usePagination`.
- Encapsulan `ref`, `computed`, `watch` y lógica derivada.
- **Sin llamadas de red directas** — si necesitan datos externos, reciben un service como parámetro o delegan a la store.
- Reutilizables entre páginas y componentes.

```ts
// composables/useCounter.ts
export function useCounter(initial = 0) {
  const count = ref(initial)
  const increment = () => count.value++
  const reset = () => (count.value = initial)
  return { count: readonly(count), increment, reset }
}
```

## `stores/` — estado global (Pinia)

- Una store por dominio: `useAuthStore`, `useCartStore`, `useNotificationsStore`.
- **Sin lógica de negocio gorda** — delegá en composables o services.
- Las actions llaman a `services/` para efectos externos.
- El estado es la única fuente de verdad para datos globales.

```ts
// stores/auth.ts
export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const isAuthenticated = computed(() => user.value !== null)

  async function login(credentials: LoginCredentials) {
    user.value = await authService.login(credentials)
  }

  return { user: readonly(user), isAuthenticated, login }
})
```

## `services/` — acceso a red

- Un archivo por dominio: `userService.ts`, `productService.ts`.
- Toda llamada a `$fetch`, `useFetch` o librerías externas vive aquí.
- Tipado estricto de request y response.
- Sin reactividad — devuelven datos planos o Promises.

```ts
// services/userService.ts
export const userService = {
  async getProfile(id: string): Promise<UserProfile> {
    return $fetch(`/api/users/${id}`)
  },
  async updateProfile(id: string, data: UpdateProfileInput): Promise<UserProfile> {
    return $fetch(`/api/users/${id}`, { method: 'PATCH', body: data })
  },
}
```

## `components/` — UI pura

- `<script setup>` (con `lang="ts"` según el proyecto).
- Reciben datos por props, comunican eventos por emits.
- **Sin acceso directo a stores** desde componentes hoja — recibí los datos como prop.
- Excepción: componentes de layout o "container" que orquestan stores explícitamente.
- Nombrados en PascalCase: `ProductCard.vue`, `BaseButton.vue`.

```
components/
├── base/           → átomos del design system (BaseButton, BaseInput)
├── common/         → moléculas compartidas (SearchBar, Pagination)
└── [feature]/      → organismos específicos de feature (ProductCard, CheckoutSummary)
```

## `pages/` — nivel de ruta

- Archivos mapeados a rutas por Nuxt (`pages/products/[id].vue`).
- Orquestan composables, stores y llaman a services vía stores.
- **Thin**: la mayor parte de la lógica vive en composables y stores.
- Sin lógica de negocio directamente en el template.

## `layouts/` — estructura de página

- `layouts/default.vue`, `layouts/auth.vue`, etc.
- Solo estructura visual persistente (header, footer, sidebar).
- Sin lógica de dominio.

## `utils/` — funciones puras

- Sin estado, sin reactividad, sin efectos.
- Testeables de forma aislada.
- `formatDate`, `slugify`, `clamp`, `groupBy`.

## Regla de oro — ¿dónde va esto?

| ¿Qué hace el código? | Archivo |
|---|---|
| Lógica reactiva reutilizable | `composables/` |
| Estado global compartido | `stores/` |
| Llamada a red / API externa | `services/` |
| UI declarativa | `components/` |
| Orquestación nivel ruta | `pages/` |
| Función pura sin estado | `utils/` |
| Tipos compartidos | `types/` |

## Anti-patrones (rechazar en revisión)

- `$fetch` directamente en un `<script setup>` de un componente hoja.
- Store con lógica de negocio gorda en una action de 100 líneas.
- Composable que accede a otra store directamente (crea acoplamiento implícito).
- Página con 300 líneas de template — extraer a componentes.
- `utils/` con funciones con efectos secundarios o estado.
- Importar una store desde un componente hoja que debería recibir la data como prop.
