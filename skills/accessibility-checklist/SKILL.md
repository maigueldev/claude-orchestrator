---
name: accessibility-checklist
description: Checklist WCAG 2.2 AA para componentes web — semántica HTML5, ARIA, contraste, foco, teclado, motion, formularios, imágenes. Invocar al escribir o revisar componentes con interacción o contenido visual.
---

# Accessibility Checklist — WCAG 2.2 AA

## Semántica HTML5

- Usá el elemento HTML correcto para cada propósito — el navegador y los lectores de pantalla dependen de esto.
- `<button>` para acciones que no navegan. `<a href>` para navegación.
- Landmarks obligatorios: `<main>`, `<nav>`, `<header>`, `<footer>`, `<aside>`.
- Si usás múltiples `<nav>`, dales `aria-label` para distinguirlos.
- Headings en orden jerárquico (`h1` → `h2` → `h3`) — nunca saltés niveles por estilo.
- Listas de ítems → `<ul>` / `<ol>` / `<dl>`. No uses `<div>` para simular listas.

```html
<!-- MAL -->
<div onclick="submitForm()">Enviar</div>

<!-- BIEN -->
<button type="submit">Enviar</button>
```

## Contraste de color

| Tipo | Ratio mínimo |
|---|---|
| Texto normal (< 18px o < 14px bold) | 4.5:1 |
| Texto grande (≥ 18px o ≥ 14px bold) | 3:1 |
| Componentes UI (bordes de input, iconos informativos) | 3:1 |
| Texto decorativo / logotipos | Sin requisito |

- Verificá con herramienta: [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/).
- El contraste aplica tanto en modo claro como oscuro.
- No uses color como único diferenciador de información (ej: error en rojo sin texto ni icono).

## Navegación por teclado

- Todo elemento interactivo debe ser alcanzable con `Tab` en orden lógico.
- Orden del DOM = orden visual (no reordenés visualmente con CSS sin considerar el DOM).
- Sin `tabindex` positivos — rompen el orden natural.
- `tabindex="0"` solo para elementos custom interactivos que no son natively focusable.
- `tabindex="-1"` para elementos que reciben foco programáticamente (ej: modales).

## Foco visible

- Nunca `outline: none` o `outline: 0` sin un reemplazo visual equivalente.
- Usá `:focus-visible` para mostrar foco solo con teclado (no en click con mouse).
- El indicador de foco debe tener contraste 3:1 contra el fondo adyacente.

```css
/* MAL */
:focus { outline: none; }

/* BIEN */
:focus-visible {
  outline: 2px solid var(--color-focus);
  outline-offset: 2px;
}
```

## Imágenes

- `<img>` siempre con atributo `alt`.
- Imagen informativa: `alt` describe el contenido o función.
- Imagen decorativa: `alt=""` (string vacío — no `alt="decorativa"`).
- Iconos SVG inline informativos: `role="img"` + `<title>` o `aria-label`.
- Iconos SVG decorativos: `aria-hidden="true"`.

```html
<!-- Informativa -->
<img src="avatar.jpg" alt="Foto de perfil de Juan García" />

<!-- Decorativa -->
<img src="background.jpg" alt="" />

<!-- Icono SVG informativo -->
<svg role="img" aria-label="Buscar">...</svg>

<!-- Icono SVG decorativo junto a texto -->
<svg aria-hidden="true">...</svg>
<span>Buscar</span>
```

## Formularios

- Cada `<input>`, `<select>`, `<textarea>` tiene un `<label>` asociado (`for`/`id` o anidado).
- Alternativas a `<label>` visible: `aria-label` o `aria-labelledby`.
- Mensajes de error:
  - Identificados por texto, no solo por color.
  - Asociados al campo con `aria-describedby`.
  - Anunciados con `role="alert"` o `aria-live="polite"`.
- Campos requeridos: `required` en el HTML (no solo asterisco visual).
- Agrupaciones relacionadas: `<fieldset>` + `<legend>`.

```html
<div>
  <label for="email">Email</label>
  <input
    id="email"
    type="email"
    required
    aria-describedby="email-error"
    aria-invalid="true"
  />
  <p id="email-error" role="alert">El email no es válido.</p>
</div>
```

## Estados dinámicos y regiones live

- Mensajes de éxito/error que aparecen dinámicamente: `aria-live="polite"` o `role="alert"`.
- `aria-live="assertive"` solo para errores críticos que interrumpen la tarea.
- Contadores, notificaciones de carga: `aria-live="polite"`.
- Estado de carga de un botón: `aria-busy="true"` en el contenedor o `aria-disabled`.

## Modales y diálogos

- Usá `role="dialog"` + `aria-modal="true"` + `aria-labelledby` apuntando al título.
- Al abrir: mover el foco al primer elemento interactivo del modal.
- Al cerrar: restaurar el foco al elemento que lo abrió.
- Trampa de foco: `Tab` y `Shift+Tab` deben ciclar dentro del modal.
- Cerrar con `Escape`.

## Motion y animaciones

- Respetá `prefers-reduced-motion: reduce`.
- Envolvé animaciones en media query:

```css
@media (prefers-reduced-motion: no-preference) {
  .card {
    transition: transform 0.3s ease;
  }
}
```

- Nunca parpadeo entre 2–55 Hz (riesgo de convulsiones — criterio WCAG 2.3.1 nivel A).

## Mobile / táctil

- Áreas táctiles mínimas: 44×44px (WCAG 2.5.8 nivel AA).
- Sin gestos de un solo camino que no tengan alternativa (ej: solo swipe sin botón).
- Texto legible sin zoom: mínimo 16px en body, nunca menos de 14px.

## Herramientas de testing

```bash
# axe-core en Vitest/Jest
npm install --save-dev @axe-core/vue

# Vue axe (dev overlay)
npm install --save-dev vue-axe

# Lighthouse CLI
npx lighthouse http://localhost:3000 --only-categories=accessibility
```

Checklist manual:
- [ ] Navegar solo con teclado (Tab, Shift+Tab, Enter, Escape, flechas en widgets).
- [ ] Probar con lector de pantalla (VoiceOver en Mac, NVDA en Windows).
- [ ] Simular `prefers-reduced-motion: reduce` en DevTools.
- [ ] Simular alto contraste en DevTools.
- [ ] Verificar contraste con DevTools o extensión.
