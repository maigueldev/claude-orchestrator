---
name: frontend-testing-patterns
description: Patrones de testing para Vue 4 + Nuxt — Vitest + Vue Test Utils, testing de composables, stores Pinia, componentes (comportamiento no implementación), mocks de API y servicios. Invocar al escribir tests frontend.
---

# Frontend Testing Patterns

## Setup base

```ts
// vitest.config.ts
import { defineConfig } from 'vitest/config'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./tests/setup.ts'],
  },
})
```

```ts
// tests/setup.ts
import { config } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import { beforeEach } from 'vitest'

beforeEach(() => {
  setActivePinia(createPinia())
})
```

## Layout por capa

```
tests/
├── setup.ts
├── composables/
│   └── useCounter.test.ts
├── stores/
│   └── auth.test.ts
├── services/
│   └── userService.test.ts
└── components/
    └── BaseButton.test.ts
```

O co-localizados junto al archivo:

```
composables/useCounter.ts
composables/useCounter.test.ts
```

Elegí el layout según la convención del proyecto — no mezclés los dos.

## Nombres de test

```
test('<acción>_<resultado esperado>')
```

- `test('increment_increases_count_by_one')` ✓
- `test('login_redirects_to_dashboard_on_success')` ✓
- `test('works')` ✗
- `test('test1')` ✗

## Testing de Composables

Los composables son funciones — se testean de forma aislada sin montar un componente.

```ts
// composables/useCounter.test.ts
import { useCounter } from './useCounter'

describe('useCounter', () => {
  test('initializes with given value', () => {
    const { count } = useCounter(5)
    expect(count.value).toBe(5)
  })

  test('increment_increases_count_by_one', () => {
    const { count, increment } = useCounter()
    increment()
    expect(count.value).toBe(1)
  })

  test('reset_restores_initial_value', () => {
    const { count, increment, reset } = useCounter(3)
    increment()
    reset()
    expect(count.value).toBe(3)
  })
})
```

Si el composable usa Pinia internamente, asegurate de que `setActivePinia(createPinia())` corre en `beforeEach` (el setup global lo cubre).

## Testing de Stores Pinia

```ts
// stores/auth.test.ts
import { useAuthStore } from './auth'
import { authService } from '@/services/authService'
import { vi } from 'vitest'

vi.mock('@/services/authService')

describe('useAuthStore', () => {
  test('isAuthenticated_is_false_initially', () => {
    const store = useAuthStore()
    expect(store.isAuthenticated).toBe(false)
  })

  test('login_sets_user_on_success', async () => {
    const mockUser = { id: '1', name: 'Ana' }
    vi.mocked(authService.login).mockResolvedValue(mockUser)

    const store = useAuthStore()
    await store.login({ email: 'ana@test.com', password: '1234' })

    expect(store.user).toEqual(mockUser)
    expect(store.isAuthenticated).toBe(true)
  })

  test('login_does_not_set_user_on_failure', async () => {
    vi.mocked(authService.login).mockRejectedValue(new Error('Unauthorized'))

    const store = useAuthStore()
    await expect(store.login({ email: 'x', password: 'y' })).rejects.toThrow()
    expect(store.user).toBeNull()
  })
})
```

## Testing de Services

Testeá el service mockeando `$fetch` o la librería HTTP. Verificá que construye la request correctamente y maneja respuestas/errores.

```ts
// services/userService.test.ts
import { userService } from './userService'
import { vi } from 'vitest'

const mockFetch = vi.fn()
vi.stubGlobal('$fetch', mockFetch)

describe('userService.getProfile', () => {
  test('calls_correct_endpoint_with_id', async () => {
    mockFetch.mockResolvedValue({ id: '42', name: 'Carlos' })
    await userService.getProfile('42')
    expect(mockFetch).toHaveBeenCalledWith('/api/users/42')
  })

  test('returns_user_data_from_response', async () => {
    const mockUser = { id: '42', name: 'Carlos' }
    mockFetch.mockResolvedValue(mockUser)
    const result = await userService.getProfile('42')
    expect(result).toEqual(mockUser)
  })
})
```

## Testing de Componentes Vue

Testeá comportamiento observable — lo que el usuario ve e interactúa — no la implementación interna.

```ts
// components/BaseButton.test.ts
import { mount } from '@vue/test-utils'
import BaseButton from './BaseButton.vue'

describe('BaseButton', () => {
  test('renders_slot_content', () => {
    const wrapper = mount(BaseButton, {
      slots: { default: 'Enviar' },
    })
    expect(wrapper.text()).toBe('Enviar')
  })

  test('emits_click_event_when_clicked', async () => {
    const wrapper = mount(BaseButton)
    await wrapper.trigger('click')
    expect(wrapper.emitted('click')).toBeTruthy()
  })

  test('does_not_emit_click_when_disabled', async () => {
    const wrapper = mount(BaseButton, {
      props: { disabled: true },
    })
    await wrapper.trigger('click')
    expect(wrapper.emitted('click')).toBeFalsy()
  })

  test('applies_correct_class_for_variant', () => {
    const wrapper = mount(BaseButton, {
      props: { variant: 'ghost' },
    })
    expect(wrapper.classes()).toContain('btn--ghost')
  })
})
```

## Mocking de módulos y stores

```ts
// Mock de un service completo
vi.mock('@/services/productService', () => ({
  productService: {
    getAll: vi.fn().mockResolvedValue([]),
    getById: vi.fn(),
  },
}))

// Mock de una store en un componente
import { useAuthStore } from '@/stores/auth'
vi.mock('@/stores/auth')
vi.mocked(useAuthStore).mockReturnValue({
  user: { id: '1', name: 'Ana' },
  isAuthenticated: true,
  login: vi.fn(),
} as any)
```

## Testing de accesibilidad con axe

```ts
import { mount } from '@vue/test-utils'
import { axe, toHaveNoViolations } from 'jest-axe'
expect.extend(toHaveNoViolations)

test('has_no_accessibility_violations', async () => {
  const wrapper = mount(BaseButton, {
    slots: { default: 'Enviar formulario' },
  })
  const results = await axe(wrapper.element)
  expect(results).toHaveNoViolations()
})
```

## Correr tests

```bash
npx vitest run                  # una vez
npx vitest                      # modo watch
npx vitest run --coverage       # con reporte de cobertura
npx vitest run tests/components # solo un directorio
npx vitest run -t "login"       # solo tests que matcheen "login"
```

## Checklist

- [ ] Nombre descriptivo: `test('<acción>_<resultado>')`.
- [ ] Un test = un comportamiento observable.
- [ ] Sin dependencia entre tests.
- [ ] Services mockeados — no se hacen llamadas de red reales.
- [ ] Pinia reiniciada en cada test (setupFiles lo cubre).
- [ ] Se testea comportamiento, no implementación (no se accede a `wrapper.vm.internalState`).
- [ ] Test de accesibilidad con axe en componentes interactivos críticos.
- [ ] Test falla por la razón esperada, no por error de setup.
