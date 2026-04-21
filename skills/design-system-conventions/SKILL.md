---
name: design-system-conventions
description: Convenciones de Design System — tokens (color/spacing/typo/radii), atomic design (átomos→moléculas→organismos), naming, dark mode con CSS custom properties, variantes, estados de componentes. Invocar al diseñar o implementar componentes del sistema.
---

# Design System Conventions

## Tokens — jerarquía de tres niveles

Los tokens son la única fuente de verdad para decisiones visuales. Sin valores hardcodeados en componentes.

### Nivel 1 — Primitivos

Valores concretos. No se usan directamente en componentes.

```css
--color-blue-50: #EFF6FF;
--color-blue-500: #3B82F6;
--color-blue-900: #1E3A5F;

--space-1: 4px;
--space-2: 8px;
--space-4: 16px;
--space-8: 32px;

--radius-sm: 4px;
--radius-md: 8px;
--radius-full: 9999px;

--font-size-sm: 14px;
--font-size-base: 16px;
--font-size-lg: 18px;
--font-size-xl: 20px;

--font-weight-regular: 400;
--font-weight-medium: 500;
--font-weight-bold: 700;

--shadow-sm: 0 1px 2px rgba(0,0,0,0.05);
--shadow-md: 0 4px 6px rgba(0,0,0,0.10);
```

### Nivel 2 — Semánticos

Propósito, no valor. Se usan en los tokens de componente y en algunos estilos base.

```css
--color-action-primary: var(--color-blue-500);
--color-action-primary-hover: var(--color-blue-600);
--color-surface-default: var(--color-white);
--color-surface-subtle: var(--color-gray-50);
--color-text-primary: var(--color-gray-900);
--color-text-secondary: var(--color-gray-600);
--color-text-disabled: var(--color-gray-400);
--color-border-default: var(--color-gray-200);
--color-feedback-error: var(--color-red-600);
--color-feedback-success: var(--color-green-600);
```

### Nivel 3 — Componente

Tokens específicos de un componente. Facilitan theming por componente sin romper el sistema.

```css
--button-bg-primary: var(--color-action-primary);
--button-bg-primary-hover: var(--color-action-primary-hover);
--button-text-primary: var(--color-white);
--button-radius: var(--radius-md);
--button-padding-y: var(--space-2);
--button-padding-x: var(--space-4);

--input-border: var(--color-border-default);
--input-border-focus: var(--color-action-primary);
--input-border-error: var(--color-feedback-error);
--input-radius: var(--radius-md);
```

## Dark Mode

No invertir colores — redefinir los tokens semánticos en el selector de dark.

```css
:root {
  --color-surface-default: #FFFFFF;
  --color-text-primary: #111827;
  --color-border-default: #E5E7EB;
}

[data-theme="dark"],
@media (prefers-color-scheme: dark) {
  :root {
    --color-surface-default: #111827;
    --color-text-primary: #F9FAFB;
    --color-border-default: #374151;
  }
}
```

**Regla**: los tokens primitivos nunca cambian. Solo cambian los semánticos en dark mode.

## Atomic Design

### Átomos
Elementos indivisibles del UI. Sin dependencias entre sí.

- `BaseButton` — variantes: primary, secondary, ghost, danger; estados: default, hover, focus, active, disabled, loading.
- `BaseInput` — estados: default, focus, error, disabled, readonly.
- `BaseLabel`, `BaseIcon`, `BaseBadge`, `BaseAvatar`, `BaseSkeleton`.

### Moléculas
Combinación de átomos con una función específica.

- `SearchBar` = `BaseInput` + `BaseButton` (icono lupa).
- `FormField` = `BaseLabel` + `BaseInput` + mensaje de error.
- `Pagination` = múltiples `BaseButton` + conteo de páginas.

Regla: una molécula no usa otra molécula.

### Organismos
Secciones de UI complejas, potencialmente con datos reales.

- `ProductCard` = `BaseAvatar` + `BaseBadge` + `BaseButton` + texto.
- `AppHeader` = `TheNav` + `SearchBar` + `UserMenu`.
- `DataTable` = `BaseInput` (filtros) + filas + `Pagination`.

Regla: un organismo no usa otro organismo directamente.

### Templates
Layouts de página sin datos reales — solo estructura y placeholders.

### Pages
Templates con datos reales. En Nuxt, corresponden a `pages/`.

## Naming de componentes y variantes

```
<Componente>           → BaseButton, ProductCard
<Componente>/<Variante>    → BaseButton/Primary, BaseButton/Ghost
<Componente>/<Variante>/<Estado> → BaseButton/Primary/Disabled
```

En Pencil (nodos): misma jerarquía con `/` como separador.

## Estados obligatorios por componente

Todo componente interactivo debe tener diseño para:

| Estado | Cuándo |
|---|---|
| `default` | Estado base |
| `hover` | Mouse sobre el elemento |
| `focus` | Foco por teclado |
| `active` | Durante el click/press |
| `disabled` | Elemento no interactuable |
| `loading` | Acción en progreso |
| `error` | Validación fallida |
| `empty` | Sin contenido que mostrar |

## Tipografía — escala

Define una escala modular. Ejemplo con escala de 1.25 (Major Third):

```
xs:   12px / 16px line-height — captions, labels secundarios
sm:   14px / 20px              — texto secundario, helpers
base: 16px / 24px              — cuerpo principal
lg:   20px / 28px              — subtítulos, énfasis
xl:   24px / 32px              — títulos de sección
2xl:  30px / 36px              — headings de página
3xl:  36px / 40px              — hero headings
```

## Espaciado — escala 4px

Múltiplos de 4px. No usés valores arbitrarios.

```
4px   → gap mínimo entre elementos inline
8px   → padding interno de componentes pequeños
12px  → gap entre elementos relacionados
16px  → padding de sección, gap estándar
24px  → separación entre grupos
32px  → separación entre secciones
48px  → separación entre bloques mayores
64px+ → secciones de página
```

## Checklist de consistencia

- [ ] Todos los valores de color vienen de tokens semánticos.
- [ ] Todos los espaciados son múltiplos de 4px.
- [ ] Todos los radii vienen de tokens.
- [ ] Todos los estados del componente están diseñados.
- [ ] El componente funciona en modo claro y oscuro.
- [ ] El contraste cumple WCAG 2.2 AA en ambos modos.
- [ ] El componente tiene documentación de uso (cuándo usar cada variante).
