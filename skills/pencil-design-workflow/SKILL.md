---
name: pencil-design-workflow
description: Flujo de trabajo con el plugin Pencil — cuándo usar cada herramienta, naming de nodos, flujo ideación→wireframe→hi-fi, snapshots, variables/tokens, handoff al frontend. Invocar al usar el agente designer.
---

# Pencil Design Workflow

## Herramientas disponibles y cuándo usarlas

| Herramienta | Cuándo usarla |
|---|---|
| `get_active_editor` | Inicio de sesión — verificar qué canvas está activo |
| `get_variables` | Antes de diseñar — inspeccionar tokens existentes |
| `get_guidelines` | Antes de diseñar — ver guías y grillas del canvas |
| `list_design_nodes` | Explorar estructura del canvas sin leer detalles |
| `read_design_nodes` | Leer propiedades de nodos específicos (ids obtenidos de list) |
| `find_empty_space_around_node` | Antes de insertar — encontrar espacio libre |
| `insert_design_nodes` | Crear nuevos elementos en el canvas |
| `update_design_nodes_properties` | Modificar propiedades de nodos existentes |
| `replace_design_node` | Reemplazar un nodo por completo (cambio de tipo o estructura) |
| `copy_design_nodes` | Duplicar elementos para crear variantes |
| `delete_design_nodes` | Eliminar nodos (confirmar antes si son componentes base) |
| `move_design_nodes` | Reubicar elementos en el canvas |
| `search_design_nodes` | Encontrar nodos por nombre o propiedad |
| `search_all_unique_properties` | Auditar valores únicos (detectar inconsistencias de tokens) |
| `replace_all_matching_properties` | Actualizar un token en masa (ej: cambiar un color en todo el sistema) |
| `get_variables` / `set_variables` | Leer y escribir tokens del design system |
| `snapshot_layout` | Capturar estado antes de modificaciones grandes |
| `get_screenshot` | Verificar visualmente el resultado |
| `generate_image` | Generar imágenes de placeholder o assets |
| `get_selection` | Ver qué tiene seleccionado el usuario en este momento |

## Flujo estándar de diseño

### 1. Orientación (siempre primero)

```
get_active_editor       → confirmar canvas activo
get_variables           → entender tokens disponibles
get_guidelines          → ver grilla y guías
list_design_nodes       → entender estructura existente
```

No diseñes sin este paso — podés pisarte con trabajo existente o ignorar el sistema de tokens.

### 2. Exploración / Ideación

Para propuestas rápidas o wireframes:
- `find_empty_space_around_node` → encontrar zona libre.
- `insert_design_nodes` con nodos simples (rectángulos, texto placeholder).
- Naming temporal aceptado en esta fase: `[WIP] LoginForm/Draft`.

### 3. Diseño Hi-Fi

Para diseño de alta fidelidad:
1. `snapshot_layout` → guardar estado previo.
2. `set_variables` → definir o aplicar tokens correctos.
3. `insert_design_nodes` / `update_design_nodes_properties` → construir componentes.
4. Naming definitivo: `LoginForm/Default`, `LoginForm/Error`.
5. `get_screenshot` → verificar resultado visual.

### 4. Iteración sobre diseño existente

1. `search_design_nodes` → localizar el nodo a modificar.
2. `read_design_nodes` → leer propiedades actuales.
3. `snapshot_layout` → guardar estado antes del cambio.
4. `update_design_nodes_properties` o `replace_design_node`.
5. `get_screenshot` → confirmar cambio.

### 5. Actualización masiva de tokens

Cuando un token primitivo cambia (ej: `--color-blue-500` → nuevo valor):
1. `search_all_unique_properties` → auditar todos los valores que usan ese color.
2. `replace_all_matching_properties` → actualizar en masa.
3. `get_screenshot` → verificar consistencia visual.

## Naming de nodos — convención obligatoria

```
<Componente>/<Variante>/<Estado>
```

Ejemplos correctos:
```
Button/Primary/Default
Button/Primary/Hover
Button/Primary/Disabled
Button/Ghost/Loading
Card/Product/Default
Card/Product/Featured
Input/Default
Input/Error
Input/Disabled
Modal/Confirm/Default
```

Ejemplos incorrectos (rechazar):
```
Frame1
Rectangle2
Group3
button copy
nuevo btn
```

Regla: si el nombre no describe la función y el estado, renombrarlo antes de continuar.

## Variables / Tokens en Pencil

- **Siempre** usar variables para color, spacing, radius, typography — nunca valores hardcodeados.
- Jerarquía: primitivos → semánticos → componente (ver `design-system-conventions`).
- Al crear un nuevo componente: `get_variables` primero, verificar si el token ya existe.
- Si el token no existe, proponerlo al usuario antes de crearlo.

```
// Correcto: referencia a variable
fill: var(--color-action-primary)

// Incorrecto: valor hardcodeado
fill: #3B82F6
```

## Snapshots — cuándo usarlos

Usá `snapshot_layout` antes de:
- Modificar un componente base del sistema (riesgo de rotura en cascada).
- Aplicar `replace_all_matching_properties` (cambio masivo).
- Eliminar un grupo de nodos.
- Cualquier cambio que afecte más de 5 nodos simultáneamente.

No es necesario para: insertar nodos nuevos en espacio vacío, renombrar nodos.

## Handoff al Frontend Engineer

Al terminar el diseño, proveer:
1. **Screenshot** del componente con todos sus estados.
2. **Tokens usados**: listar variables de Pencil aplicadas.
3. **Medidas exactas**: padding, gap, border-radius, font-size, line-height.
4. **Comportamiento**: animaciones, transiciones, interacciones.
5. **Variantes**: cuándo usar cada una.
6. **Accesibilidad**: notas sobre contraste, ARIA esperado, orden de foco.

## Reglas de corte

- No creés un token nuevo sin confirmación del usuario.
- No eliminés nodos sin verificar que no son componentes base referenciados.
- Si el canvas está vacío o sin guidelines, consultá al usuario antes de diseñar — puede que el proyecto no tenga Design System aún.
- Snapshot obligatorio antes de cambios masivos.
