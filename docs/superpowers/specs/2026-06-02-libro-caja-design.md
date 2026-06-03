# Libro de Caja Completo — Diseño

> **Para workers agénticos:** Usar `superpowers:subagent-driven-development` (recomendado) o `superpowers:executing-plans` para implementar este spec tarea por tarea.

**Goal:** Módulo de Libro de Caja que centraliza todos los flujos de dinero: ventas (ingresos automáticos), compras (egresos automáticos) y movimientos manuales (gastos operativos e ingresos misceláneos), con categorías configurables por el administrador.

**Architecture:** Dos tablas nuevas (`categoria_movimiento`, `movimiento`); un endpoint UNION que agrega ventas + compras + movimientos en un solo flujo; frontend con página principal de libro de caja + modal de movimiento + modal de categorías.

**Tech Stack:** Node.js + Express + MariaDB, React + Tailwind CSS, jsPDF (ya instalado)

---

## 1. Base de Datos

### Tabla `categoria_movimiento`

```sql
CREATE TABLE categoria_movimiento (
  id_categoria  INT          NOT NULL AUTO_INCREMENT,
  nombre        VARCHAR(100) NOT NULL,
  tipo          ENUM('INGRESO','EGRESO','AMBOS') NOT NULL DEFAULT 'AMBOS',
  activo        TINYINT(1)   NOT NULL DEFAULT 1,
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_categoria),
  UNIQUE KEY uq_nombre (nombre)
);
```

### Tabla `movimiento`

```sql
CREATE TABLE movimiento (
  id_movimiento  INT            NOT NULL AUTO_INCREMENT,
  tipo           ENUM('INGRESO','EGRESO') NOT NULL,
  id_categoria   INT            NOT NULL,
  descripcion    VARCHAR(255)   NOT NULL,
  monto          DECIMAL(12,2)  NOT NULL,
  fecha          DATE           NOT NULL,
  id_sucursal    INT            DEFAULT NULL,
  id_usuario     INT            NOT NULL,
  observaciones  TEXT           DEFAULT NULL,
  created_at     DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_movimiento),
  FOREIGN KEY (id_categoria) REFERENCES categoria_movimiento(id_categoria),
  FOREIGN KEY (id_sucursal)  REFERENCES sucursal(id_sucursal),
  FOREIGN KEY (id_usuario)   REFERENCES usuario(id_usuario)
);
```

### Datos semilla — Categorías iniciales

```sql
INSERT INTO categoria_movimiento (nombre, tipo) VALUES
  ('Servicios básicos',  'EGRESO'),
  ('Sueldos y salarios', 'EGRESO'),
  ('Alquiler',           'EGRESO'),
  ('Transporte',         'EGRESO'),
  ('Mantenimiento',      'EGRESO'),
  ('Otros gastos',       'EGRESO'),
  ('Ingresos varios',    'INGRESO'),
  ('Préstamos recibidos','INGRESO');
```

### Permisos nuevos

```sql
INSERT INTO permiso (nombre_clave, descripcion, modulo) VALUES
  ('movimientos.ver',               'Ver libro de caja y movimientos',          'movimientos'),
  ('movimientos.crear',             'Registrar gasto/ingreso manual',           'movimientos'),
  ('movimientos.editar',            'Editar un movimiento manual',              'movimientos'),
  ('movimientos.eliminar',          'Eliminar un movimiento manual',            'movimientos'),
  ('movimientos.ver_todas',         'Ver movimientos de todas las sucursales',  'movimientos'),
  ('categorias_movimiento.ver',     'Ver categorías de movimientos',            'categorias_movimiento'),
  ('categorias_movimiento.gestionar','Crear/editar/eliminar categorías',        'categorias_movimiento');

-- Asignar todos al rol Administrador (id_rol = 1)
INSERT IGNORE INTO rol_permiso (id_rol, id_permiso)
SELECT 1, id_permiso FROM permiso
WHERE modulo IN ('movimientos', 'categorias_movimiento');
```

**Invariante del filtro por sucursal:** si el usuario NO tiene `movimientos.ver_todas`, el backend filtra por `id_sucursal = req.user.id_sucursal` en los tres orígenes (ventas, compras, movimientos). Si tiene `ver_todas`, muestra todo.

---

## 2. Backend

### Archivos

| Archivo | Acción |
|---------|--------|
| `backend/controllers/movimientos.Controller.js` | Crear |
| `backend/routes/movimientos.Routes.js` | Crear |
| `backend/controllers/categoriasMovimiento.Controller.js` | Crear |
| `backend/routes/categoriasMovimiento.Routes.js` | Crear |
| `backend/app.js` | Modificar — registrar 2 rutas |

---

### `GET /api/movimientos/libro-caja`

Permiso: `movimientos.ver`

Query params: `?desde=YYYY-MM-DD&hasta=YYYY-MM-DD&id_sucursal=N&tipo=INGRESO|EGRESO`

Respuesta:
```json
{
  "movimientos": [
    {
      "fecha": "2026-06-01",
      "tipo": "INGRESO",
      "categoria": "Venta",
      "descripcion": "Venta #142 - Juan Pérez",
      "monto": "1500.00",
      "origen": "venta",
      "id_origen": 142,
      "sucursal": "Sucursal Central"
    }
  ],
  "resumen": {
    "total_ingresos": "12450.00",
    "total_egresos": "8320.00",
    "balance": "4130.00"
  }
}
```

**Query UNION:**
```sql
SELECT
  DATE(v.fecha_venta)  AS fecha,
  'INGRESO'            AS tipo,
  'Venta'              AS categoria,
  CONCAT('Venta #', v.id_venta, IF(c.nombre IS NOT NULL, CONCAT(' - ', c.nombre), '')) AS descripcion,
  v.total              AS monto,
  'venta'              AS origen,
  v.id_venta           AS id_origen,
  s.nombre             AS sucursal
FROM venta v
LEFT JOIN cliente  c ON c.id_cliente  = v.id_cliente
LEFT JOIN sucursal s ON s.id_sucursal = v.id_sucursal
WHERE v.estado = 'COMPLETADA'
  [AND DATE(v.fecha_venta) BETWEEN ? AND ?]
  [AND v.id_sucursal = ?]

UNION ALL

SELECT
  c.fecha_compra       AS fecha,
  'EGRESO'             AS tipo,
  'Compra'             AS categoria,
  CONCAT('Compra #', c.id_compra, ' - ', p.nombre) AS descripcion,
  c.total              AS monto,
  'compra'             AS origen,
  c.id_compra          AS id_origen,
  s.nombre             AS sucursal
FROM compra c
LEFT JOIN proveedor p ON p.id_proveedor = c.id_proveedor
LEFT JOIN sucursal  s ON s.id_sucursal  = c.id_sucursal
WHERE c.estado != 'CANCELADO'
  [AND c.fecha_compra BETWEEN ? AND ?]
  [AND c.id_sucursal = ?]

UNION ALL

SELECT
  m.fecha              AS fecha,
  m.tipo               AS tipo,
  cm.nombre            AS categoria,
  m.descripcion        AS descripcion,
  m.monto              AS monto,
  'movimiento'         AS origen,
  m.id_movimiento      AS id_origen,
  COALESCE(s.nombre, 'General') AS sucursal
FROM movimiento m
LEFT JOIN categoria_movimiento cm ON cm.id_categoria = m.id_categoria
LEFT JOIN sucursal              s  ON s.id_sucursal   = m.id_sucursal
  [WHERE m.fecha BETWEEN ? AND ?]
  [AND m.id_sucursal = ?]

ORDER BY fecha DESC
```

Los filtros opcionales (`[AND ...]`) se añaden dinámicamente según los query params recibidos.

---

### `GET /api/movimientos`

Permiso: `movimientos.ver`

Devuelve solo los movimientos manuales (tabla `movimiento`) con datos de categoría y sucursal. Filtra por sucursal si no tiene `ver_todas`.

### `POST /api/movimientos`

Permiso: `movimientos.crear`

Body: `{ tipo, id_categoria, descripcion, monto, fecha, id_sucursal, observaciones }`

Validaciones: `tipo` válido, `id_categoria` existe y está activo, `descripcion` no vacío, `monto > 0`, `fecha` válida.

### `PUT /api/movimientos/:id`

Permiso: `movimientos.editar`

Mismas validaciones que POST. Solo puede editar si el movimiento pertenece a la sucursal del usuario (a menos que tenga `ver_todas`).

### `DELETE /api/movimientos/:id`

Permiso: `movimientos.eliminar`

Hard delete. Misma restricción de sucursal.

---

### `GET /api/categorias-movimiento`

Permiso: `movimientos.ver`

Devuelve categorías con `activo = 1`. Ordenadas por nombre.

### `POST /api/categorias-movimiento`

Permiso: `categorias_movimiento.gestionar`

Body: `{ nombre, tipo }`. Valida nombre no vacío y único.

### `PUT /api/categorias-movimiento/:id`

Permiso: `categorias_movimiento.gestionar`

Body: `{ nombre, tipo, activo }`.

### `DELETE /api/categorias-movimiento/:id`

Permiso: `categorias_movimiento.gestionar`

Soft delete: `UPDATE categoria_movimiento SET activo = 0 WHERE id_categoria = ?`

No se puede desactivar una categoría que tenga movimientos activos asociados (devuelve error 400).

---

## 3. Frontend

### Archivos

| Archivo | Acción |
|---------|--------|
| `frontend/src/services/movimientos.service.js` | Crear |
| `frontend/src/services/categoriasMovimiento.service.js` | Crear |
| `frontend/src/pages/libroCaja/LibroCaja.jsx` | Crear |
| `frontend/src/pages/libroCaja/components/TablaLibroCaja.jsx` | Crear |
| `frontend/src/pages/libroCaja/components/MovimientoModal.jsx` | Crear |
| `frontend/src/pages/libroCaja/components/CategoriasModal.jsx` | Crear |
| `frontend/src/App.jsx` | Modificar — ruta `/libro-caja` |
| `frontend/src/components/sidebar.jsx` | Modificar — entrada al menú |

---

### Servicios

```js
// movimientos.service.js
import api from '../api/axios';
const movimientosService = {
  libroCaja:  (params) => api.get('/movimientos/libro-caja', { params }),
  listar:     (params) => api.get('/movimientos', { params }),
  crear:      (data)   => api.post('/movimientos', data),
  actualizar: (id, data) => api.put(`/movimientos/${id}`, data),
  eliminar:   (id)     => api.delete(`/movimientos/${id}`),
};
export default movimientosService;
```

```js
// categoriasMovimiento.service.js
import api from '../api/axios';
const categoriasMovimientoService = {
  listar:     () => api.get('/categorias-movimiento'),
  crear:      (data) => api.post('/categorias-movimiento', data),
  actualizar: (id, data) => api.put(`/categorias-movimiento/${id}`, data),
  eliminar:   (id) => api.delete(`/categorias-movimiento/${id}`),
};
export default categoriasMovimientoService;
```

---

### Página `LibroCaja.jsx`

**Estados:**
- `movimientos[]` — array del libro de caja (ventas + compras + manuales)
- `resumen` — `{ total_ingresos, total_egresos, balance }`
- `filtros` — `{ desde, hasta, id_sucursal, tipo }`
- `cargando`, `toast`
- `modalMovimiento` — `{ abierto, modo: 'crear'|'editar', datos }`
- `modalCategorias` — `{ abierto }`

**Layout:**
```
┌─ Libro de Caja ──────────────────────────────────────────────┐
│  Filtros: [Desde] [Hasta] [Sucursal▼] [Tipo▼]  [Aplicar]     │
├──────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │ + Ingresos   │  │ - Egresos    │  │  = Balance   │        │
│  │ Bs. 12,450   │  │ Bs.  8,320   │  │  Bs.  4,130  │        │
│  └──────────────┘  └──────────────┘  └──────────────┘        │
├──────────────────────────────────────────────────────────────┤
│  [+ Nuevo movimiento]                    [⚙ Categorías]       │
├──────────────────────────────────────────────────────────────┤
│  Fecha │ Tipo │ Categoría │ Descripción │ Sucursal │ Monto    │
│        │      │           │             │          │ Origen   │
│  ...   │      │           │             │          │ Acciones │
└──────────────────────────────────────────────────────────────┘
```

**Tarjetas de resumen:**
- Ingresos: fondo verde suave, monto en verde
- Egresos: fondo rojo suave, monto en rojo
- Balance: fondo azul/esmeralda si positivo, rojo si negativo

**Tabla `TablaLibroCaja.jsx`:**
- Columnas: Fecha · Tipo (badge `INGRESO`=verde / `EGRESO`=rojo) · Categoría · Descripción · Sucursal · Monto · Origen (chip `Venta` / `Compra` / `Manual`) · Acciones
- Acciones de editar/eliminar solo visibles para filas con `origen = 'movimiento'`
- Sin acciones para ventas/compras (son de solo lectura en este módulo)

**Filtros por defecto al cargar:** desde = primer día del mes actual, hasta = hoy.

---

### Modal `MovimientoModal.jsx`

Campos:
- Tipo: selector INGRESO / EGRESO (botones toggle)
- Categoría: `<select>` filtrado por tipo seleccionado
- Descripción: `<input text>` obligatorio
- Monto: `<input number>` obligatorio, > 0
- Fecha: `<input date>` obligatorio, default = hoy
- Sucursal: `<select>` (visible solo si tiene `ver_todas`)
- Observaciones: `<textarea>` opcional

---

### Modal `CategoriasModal.jsx`

- Lista todas las categorías (activas e inactivas)
- Columnas: Nombre · Tipo · Estado · Acciones (editar / desactivar)
- Formulario inline o sub-modal para crear/editar
- Botón "Desactivar" en lugar de eliminar si la categoría tiene movimientos

---

### Sidebar

Agregar antes de "Reportes":
```js
{ label: 'Libro de Caja', path: '/libro-caja', icono: '📒', action: 'ver', subject: 'movimientos' },
```

### Ruta en App.jsx

```jsx
<Route path="/libro-caja" element={
  <PageRoute action="ver" subject="movimientos">
    <LibroCaja />
  </PageRoute>
}/>
```

---

## 4. Flujo completo

```
Usuario abre /libro-caja
  → GET /api/movimientos/libro-caja?desde=2026-06-01&hasta=2026-06-30
  → Muestra tabla con ventas + compras + movimientos del mes
  → Tarjetas muestran totales y balance

Usuario registra un gasto:
  → Clic "+ Nuevo movimiento"
  → Selecciona EGRESO → categoría "Servicios básicos" → descripción → monto → fecha
  → POST /api/movimientos → toast "Movimiento registrado"
  → Tabla se recarga con el nuevo movimiento

Admin gestiona categorías:
  → Clic "⚙ Categorías"
  → Modal muestra categorías existentes
  → Puede crear "Combustible" de tipo EGRESO
  → PUT/DELETE para editar o desactivar
```

---

## 5. Lo que NO incluye este módulo

- Conciliación bancaria
- Presupuestos o proyecciones
- Integración con apertura/cierre de caja (turno) — los movimientos son independientes del turno
- Exportación a PDF (puede añadirse después como mejora)
- Paginación del lado del servidor (el filtro de fechas actúa como paginación natural)
