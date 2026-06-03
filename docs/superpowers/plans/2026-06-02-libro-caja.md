# Libro de Caja Completo — Plan de Implementación

> **Para workers agénticos:** REQUIRED SUB-SKILL: Usar `superpowers:subagent-driven-development` (recomendado) o `superpowers:executing-plans` para implementar este plan tarea por tarea. Los pasos usan sintaxis checkbox (`- [ ]`) para seguimiento.
>
> **IMPORTANTE:** No hacer commits — el usuario los hace manualmente.

**Goal:** Módulo de Libro de Caja que centraliza ventas, compras y movimientos manuales (gastos/ingresos) en una vista unificada con filtros, resumen de balance y CRUD de movimientos y categorías.

**Architecture:** Dos tablas nuevas (`categoria_movimiento`, `movimiento`); endpoint UNION `/api/movimientos/libro-caja` que agrega ventas + compras + movimientos; frontend con página principal, tabla unificada y dos modales (movimiento y categorías).

**Tech Stack:** Node.js + Express + MariaDB, React + Tailwind CSS

---

## Archivos a crear/modificar

| Archivo | Acción |
|---------|--------|
| `bd/migracion_libro_caja.sql` | Crear — script SQL para ejecutar en MariaDB |
| `backend/controllers/categoriasMovimiento.Controller.js` | Crear |
| `backend/controllers/movimientos.Controller.js` | Crear |
| `backend/routes/categoriasMovimiento.Routes.js` | Crear |
| `backend/routes/movimientos.Routes.js` | Crear |
| `backend/app.js` | Modificar — registrar 2 rutas |
| `frontend/src/services/movimientos.service.js` | Crear |
| `frontend/src/services/categoriasMovimiento.service.js` | Crear |
| `frontend/src/pages/libroCaja/LibroCaja.jsx` | Crear |
| `frontend/src/pages/libroCaja/components/TablaLibroCaja.jsx` | Crear |
| `frontend/src/pages/libroCaja/components/MovimientoModal.jsx` | Crear |
| `frontend/src/pages/libroCaja/components/CategoriasModal.jsx` | Crear |
| `frontend/src/App.jsx` | Modificar — agregar ruta `/libro-caja` |
| `frontend/src/components/sidebar.jsx` | Modificar — agregar entrada al menú |

---

## Task 1: Script SQL — tablas, semilla y permisos

**Files:**
- Create: `bd/migracion_libro_caja.sql`

- [ ] **Step 1: Crear el archivo de migración**

Crear `bd/migracion_libro_caja.sql` con el siguiente contenido completo:

```sql
-- ================================================================
-- Migración: Módulo Libro de Caja
-- Ejecutar en la base de datos: bd_agropecuaria
-- ================================================================

-- Tabla de categorías de movimientos
CREATE TABLE IF NOT EXISTS categoria_movimiento (
  id_categoria  INT          NOT NULL AUTO_INCREMENT,
  nombre        VARCHAR(100) NOT NULL,
  tipo          ENUM('INGRESO','EGRESO','AMBOS') NOT NULL DEFAULT 'AMBOS',
  activo        TINYINT(1)   NOT NULL DEFAULT 1,
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_categoria),
  UNIQUE KEY uq_nombre (nombre)
);

-- Tabla de movimientos manuales
CREATE TABLE IF NOT EXISTS movimiento (
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

-- Categorías iniciales
INSERT IGNORE INTO categoria_movimiento (nombre, tipo) VALUES
  ('Servicios básicos',   'EGRESO'),
  ('Sueldos y salarios',  'EGRESO'),
  ('Alquiler',            'EGRESO'),
  ('Transporte',          'EGRESO'),
  ('Mantenimiento',       'EGRESO'),
  ('Otros gastos',        'EGRESO'),
  ('Ingresos varios',     'INGRESO'),
  ('Préstamos recibidos', 'INGRESO');

-- Permisos nuevos
INSERT IGNORE INTO permiso (nombre_clave, descripcion, modulo) VALUES
  ('movimientos.ver',                'Ver libro de caja y movimientos',         'movimientos'),
  ('movimientos.crear',              'Registrar gasto/ingreso manual',          'movimientos'),
  ('movimientos.editar',             'Editar un movimiento manual',             'movimientos'),
  ('movimientos.eliminar',           'Eliminar un movimiento manual',           'movimientos'),
  ('movimientos.ver_todas',          'Ver movimientos de todas las sucursales', 'movimientos'),
  ('categorias_movimiento.ver',      'Ver categorías de movimientos',           'categorias_movimiento'),
  ('categorias_movimiento.gestionar','Crear/editar/eliminar categorías',        'categorias_movimiento');

-- Asignar todos los permisos al Administrador (id_rol = 1)
INSERT IGNORE INTO rol_permiso (id_rol, id_permiso)
SELECT 1, id_permiso FROM permiso
WHERE modulo IN ('movimientos', 'categorias_movimiento');

-- Verificar:
-- SELECT * FROM categoria_movimiento;
-- SELECT p.nombre_clave FROM permiso p JOIN rol_permiso rp ON rp.id_permiso = p.id_permiso WHERE rp.id_rol = 1 AND p.modulo IN ('movimientos','categorias_movimiento');
```

---

## Task 2: Backend — `categoriasMovimiento.Controller.js`

**Files:**
- Create: `backend/controllers/categoriasMovimiento.Controller.js`

- [ ] **Step 1: Crear el archivo del controller**

Crear `backend/controllers/categoriasMovimiento.Controller.js`:

```js
const db = require('../config/db');

const listar = async (req, res) => {
  const { incluirInactivas } = req.query;
  const sql = incluirInactivas === '1'
    ? 'SELECT * FROM categoria_movimiento ORDER BY activo DESC, nombre ASC'
    : 'SELECT * FROM categoria_movimiento WHERE activo = 1 ORDER BY nombre ASC';
  try {
    const [rows] = await db.promise().query(sql);
    return res.json(rows);
  } catch (err) {
    console.error('[listar categoriasMovimiento]', err);
    return res.status(500).json({ error: 'Error al obtener las categorías' });
  }
};

const crear = async (req, res) => {
  const { nombre, tipo } = req.body;
  const nombreTxt = String(nombre ?? '').trim();
  if (!nombreTxt) {
    return res.status(400).json({ error: 'El nombre es obligatorio' });
  }
  if (!['INGRESO', 'EGRESO', 'AMBOS'].includes(tipo)) {
    return res.status(400).json({ error: 'Tipo inválido' });
  }
  try {
    const [result] = await db.promise().query(
      'INSERT INTO categoria_movimiento (nombre, tipo) VALUES (?, ?)',
      [nombreTxt, tipo]
    );
    const [rows] = await db.promise().query(
      'SELECT * FROM categoria_movimiento WHERE id_categoria = ?',
      [result.insertId]
    );
    return res.status(201).json(rows[0]);
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') {
      return res.status(400).json({ error: 'Ya existe una categoría con ese nombre' });
    }
    console.error('[crear categoriasMovimiento]', err);
    return res.status(500).json({ error: 'Error al crear la categoría' });
  }
};

const actualizar = async (req, res) => {
  const { id } = req.params;
  const { nombre, tipo, activo } = req.body;
  const nombreTxt = String(nombre ?? '').trim();
  if (!nombreTxt) {
    return res.status(400).json({ error: 'El nombre es obligatorio' });
  }
  if (!['INGRESO', 'EGRESO', 'AMBOS'].includes(tipo)) {
    return res.status(400).json({ error: 'Tipo inválido' });
  }
  try {
    const [existing] = await db.promise().query(
      'SELECT id_categoria FROM categoria_movimiento WHERE id_categoria = ?', [id]
    );
    if (existing.length === 0) {
      return res.status(404).json({ error: 'Categoría no encontrada' });
    }
    await db.promise().query(
      'UPDATE categoria_movimiento SET nombre = ?, tipo = ?, activo = ? WHERE id_categoria = ?',
      [nombreTxt, tipo, activo !== undefined ? (activo ? 1 : 0) : 1, id]
    );
    const [rows] = await db.promise().query(
      'SELECT * FROM categoria_movimiento WHERE id_categoria = ?', [id]
    );
    return res.json(rows[0]);
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') {
      return res.status(400).json({ error: 'Ya existe una categoría con ese nombre' });
    }
    console.error('[actualizar categoriasMovimiento]', err);
    return res.status(500).json({ error: 'Error al actualizar la categoría' });
  }
};

const eliminar = async (req, res) => {
  const { id } = req.params;
  try {
    const [movs] = await db.promise().query(
      'SELECT COUNT(*) AS total FROM movimiento WHERE id_categoria = ?', [id]
    );
    if (movs[0].total > 0) {
      return res.status(400).json({ error: 'No se puede desactivar: tiene movimientos asociados' });
    }
    await db.promise().query(
      'UPDATE categoria_movimiento SET activo = 0 WHERE id_categoria = ?', [id]
    );
    return res.json({ mensaje: 'Categoría desactivada' });
  } catch (err) {
    console.error('[eliminar categoriasMovimiento]', err);
    return res.status(500).json({ error: 'Error al desactivar la categoría' });
  }
};

module.exports = { listar, crear, actualizar, eliminar };
```

- [ ] **Step 2: Verificar sintaxis**

Desde la raíz del proyecto:
```bash
node -e "require('./backend/controllers/categoriasMovimiento.Controller.js'); console.log('OK')"
```
Resultado esperado: `OK`

---

## Task 3: Backend — `movimientos.Controller.js`

**Files:**
- Create: `backend/controllers/movimientos.Controller.js`

- [ ] **Step 1: Crear el archivo del controller**

Crear `backend/controllers/movimientos.Controller.js`:

```js
const db = require('../config/db');

const listar = async (req, res) => {
  const puedeVerTodas = req.user.permisos.includes('movimientos.ver_todas');
  const { desde, hasta, tipo } = req.query;

  const where = [];
  const params = [];

  if (!puedeVerTodas) {
    where.push('m.id_sucursal = ?');
    params.push(req.user.id_sucursal);
  }
  if (desde && hasta) {
    where.push('m.fecha BETWEEN ? AND ?');
    params.push(desde, hasta);
  }
  if (tipo && ['INGRESO', 'EGRESO'].includes(tipo)) {
    where.push('m.tipo = ?');
    params.push(tipo);
  }

  const whereClause = where.length ? `WHERE ${where.join(' AND ')}` : '';

  try {
    const [rows] = await db.promise().query(
      `SELECT m.*, cm.nombre AS categoria_nombre,
              COALESCE(s.nombre, 'General') AS sucursal_nombre
       FROM movimiento m
       LEFT JOIN categoria_movimiento cm ON cm.id_categoria = m.id_categoria
       LEFT JOIN sucursal s ON s.id_sucursal = m.id_sucursal
       ${whereClause}
       ORDER BY m.fecha DESC, m.created_at DESC`,
      params
    );
    return res.json(rows);
  } catch (err) {
    console.error('[listar movimientos]', err);
    return res.status(500).json({ error: 'Error al obtener los movimientos' });
  }
};

const crear = async (req, res) => {
  const { tipo, id_categoria, descripcion, monto, fecha, id_sucursal, observaciones } = req.body;
  const puedeVerTodas = req.user.permisos.includes('movimientos.ver_todas');

  if (!['INGRESO', 'EGRESO'].includes(tipo)) {
    return res.status(400).json({ error: 'Tipo inválido' });
  }
  const descTxt = String(descripcion ?? '').trim();
  if (!descTxt) {
    return res.status(400).json({ error: 'La descripción es obligatoria' });
  }
  if (!monto || parseFloat(monto) <= 0) {
    return res.status(400).json({ error: 'El monto debe ser mayor a 0' });
  }
  if (!fecha) {
    return res.status(400).json({ error: 'La fecha es obligatoria' });
  }
  if (!id_categoria) {
    return res.status(400).json({ error: 'La categoría es obligatoria' });
  }

  try {
    const [cats] = await db.promise().query(
      'SELECT id_categoria FROM categoria_movimiento WHERE id_categoria = ? AND activo = 1',
      [id_categoria]
    );
    if (cats.length === 0) {
      return res.status(400).json({ error: 'Categoría no válida' });
    }

    const sucursalFinal = puedeVerTodas ? (id_sucursal || null) : req.user.id_sucursal;

    const [result] = await db.promise().query(
      `INSERT INTO movimiento (tipo, id_categoria, descripcion, monto, fecha, id_sucursal, id_usuario, observaciones)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [tipo, id_categoria, descTxt, monto, fecha, sucursalFinal, req.user.id_usuario, observaciones || null]
    );

    const [rows] = await db.promise().query(
      `SELECT m.*, cm.nombre AS categoria_nombre,
              COALESCE(s.nombre, 'General') AS sucursal_nombre
       FROM movimiento m
       LEFT JOIN categoria_movimiento cm ON cm.id_categoria = m.id_categoria
       LEFT JOIN sucursal s ON s.id_sucursal = m.id_sucursal
       WHERE m.id_movimiento = ?`,
      [result.insertId]
    );
    return res.status(201).json(rows[0]);
  } catch (err) {
    console.error('[crear movimiento]', err);
    return res.status(500).json({ error: 'Error al crear el movimiento' });
  }
};

const actualizar = async (req, res) => {
  const { id } = req.params;
  const { tipo, id_categoria, descripcion, monto, fecha, id_sucursal, observaciones } = req.body;
  const puedeVerTodas = req.user.permisos.includes('movimientos.ver_todas');

  if (!['INGRESO', 'EGRESO'].includes(tipo)) {
    return res.status(400).json({ error: 'Tipo inválido' });
  }
  const descTxt = String(descripcion ?? '').trim();
  if (!descTxt) {
    return res.status(400).json({ error: 'La descripción es obligatoria' });
  }
  if (!monto || parseFloat(monto) <= 0) {
    return res.status(400).json({ error: 'El monto debe ser mayor a 0' });
  }
  if (!fecha) {
    return res.status(400).json({ error: 'La fecha es obligatoria' });
  }

  try {
    const [existing] = await db.promise().query(
      'SELECT id_movimiento, id_sucursal FROM movimiento WHERE id_movimiento = ?', [id]
    );
    if (existing.length === 0) {
      return res.status(404).json({ error: 'Movimiento no encontrado' });
    }
    if (!puedeVerTodas && existing[0].id_sucursal !== req.user.id_sucursal) {
      return res.status(403).json({ error: 'Sin permiso para editar este movimiento' });
    }

    const sucursalFinal = puedeVerTodas ? (id_sucursal || null) : req.user.id_sucursal;

    await db.promise().query(
      `UPDATE movimiento
       SET tipo=?, id_categoria=?, descripcion=?, monto=?, fecha=?, id_sucursal=?, observaciones=?
       WHERE id_movimiento=?`,
      [tipo, id_categoria, descTxt, monto, fecha, sucursalFinal, observaciones || null, id]
    );

    const [rows] = await db.promise().query(
      `SELECT m.*, cm.nombre AS categoria_nombre,
              COALESCE(s.nombre, 'General') AS sucursal_nombre
       FROM movimiento m
       LEFT JOIN categoria_movimiento cm ON cm.id_categoria = m.id_categoria
       LEFT JOIN sucursal s ON s.id_sucursal = m.id_sucursal
       WHERE m.id_movimiento = ?`,
      [id]
    );
    return res.json(rows[0]);
  } catch (err) {
    console.error('[actualizar movimiento]', err);
    return res.status(500).json({ error: 'Error al actualizar el movimiento' });
  }
};

const eliminar = async (req, res) => {
  const { id } = req.params;
  const puedeVerTodas = req.user.permisos.includes('movimientos.ver_todas');

  try {
    const [existing] = await db.promise().query(
      'SELECT id_movimiento, id_sucursal FROM movimiento WHERE id_movimiento = ?', [id]
    );
    if (existing.length === 0) {
      return res.status(404).json({ error: 'Movimiento no encontrado' });
    }
    if (!puedeVerTodas && existing[0].id_sucursal !== req.user.id_sucursal) {
      return res.status(403).json({ error: 'Sin permiso para eliminar este movimiento' });
    }

    await db.promise().query('DELETE FROM movimiento WHERE id_movimiento = ?', [id]);
    return res.json({ mensaje: 'Movimiento eliminado' });
  } catch (err) {
    console.error('[eliminar movimiento]', err);
    return res.status(500).json({ error: 'Error al eliminar el movimiento' });
  }
};

const libroCaja = async (req, res) => {
  const { desde, hasta, id_sucursal, tipo } = req.query;
  const puedeVerTodas = req.user.permisos.includes('movimientos.ver_todas');
  const sucursalId = !puedeVerTodas ? req.user.id_sucursal : (id_sucursal || null);

  const ventasConds  = ['v.estado = ?'];
  const ventasParams = ['COMPLETADA'];
  const comprasConds  = ['c.estado != ?'];
  const comprasParams = ['CANCELADO'];
  const movConds  = [];
  const movParams = [];

  if (desde && hasta) {
    ventasConds.push('DATE(v.fecha_venta) BETWEEN ? AND ?');
    ventasParams.push(desde, hasta);
    comprasConds.push('c.fecha_compra BETWEEN ? AND ?');
    comprasParams.push(desde, hasta);
    movConds.push('m.fecha BETWEEN ? AND ?');
    movParams.push(desde, hasta);
  }

  if (sucursalId) {
    ventasConds.push('v.id_sucursal = ?');
    ventasParams.push(sucursalId);
    comprasConds.push('c.id_sucursal = ?');
    comprasParams.push(sucursalId);
    movConds.push('m.id_sucursal = ?');
    movParams.push(sucursalId);
  }

  const vWhere = `WHERE ${ventasConds.join(' AND ')}`;
  const cWhere = `WHERE ${comprasConds.join(' AND ')}`;
  const mWhere = movConds.length ? `WHERE ${movConds.join(' AND ')}` : '';

  const tipoValido = tipo && ['INGRESO', 'EGRESO'].includes(tipo);
  const tipoFilter = tipoValido ? 'WHERE tipo = ?' : '';
  const tipoParam  = tipoValido ? [tipo] : [];

  const sql = `
    SELECT fecha, tipo, categoria, descripcion, monto, origen, id_origen, sucursal
    FROM (
      SELECT
        DATE(v.fecha_venta)  AS fecha,
        'INGRESO'            AS tipo,
        'Venta'              AS categoria,
        CONCAT('Venta #', v.id_venta,
          IF(c.nombre IS NOT NULL, CONCAT(' - ', c.nombre), '')) AS descripcion,
        v.total              AS monto,
        'venta'              AS origen,
        v.id_venta           AS id_origen,
        COALESCE(s.nombre, 'General') AS sucursal
      FROM venta v
      LEFT JOIN cliente  c ON c.id_cliente  = v.id_cliente
      LEFT JOIN sucursal s ON s.id_sucursal = v.id_sucursal
      ${vWhere}

      UNION ALL

      SELECT
        c.fecha_compra       AS fecha,
        'EGRESO'             AS tipo,
        'Compra'             AS categoria,
        CONCAT('Compra #', c.id_compra, ' - ', p.nombre) AS descripcion,
        c.total              AS monto,
        'compra'             AS origen,
        c.id_compra          AS id_origen,
        COALESCE(s.nombre, 'General') AS sucursal
      FROM compra c
      LEFT JOIN proveedor p ON p.id_proveedor = c.id_proveedor
      LEFT JOIN sucursal  s ON s.id_sucursal  = c.id_sucursal
      ${cWhere}

      UNION ALL

      SELECT
        m.fecha              AS fecha,
        m.tipo               AS tipo,
        COALESCE(cm.nombre, 'Sin categoría') AS categoria,
        m.descripcion        AS descripcion,
        m.monto              AS monto,
        'movimiento'         AS origen,
        m.id_movimiento      AS id_origen,
        COALESCE(s.nombre, 'General') AS sucursal
      FROM movimiento m
      LEFT JOIN categoria_movimiento cm ON cm.id_categoria = m.id_categoria
      LEFT JOIN sucursal             s  ON s.id_sucursal   = m.id_sucursal
      ${mWhere}
    ) AS todos
    ${tipoFilter}
    ORDER BY fecha DESC, origen ASC
  `;

  const allParams = [...ventasParams, ...comprasParams, ...movParams, ...tipoParam];

  try {
    const [rows] = await db.promise().query(sql, allParams);

    let total_ingresos = 0;
    let total_egresos  = 0;
    for (const row of rows) {
      const monto = parseFloat(row.monto) || 0;
      if (row.tipo === 'INGRESO') total_ingresos += monto;
      else total_egresos += monto;
    }

    return res.json({
      movimientos: rows,
      resumen: {
        total_ingresos: total_ingresos.toFixed(2),
        total_egresos:  total_egresos.toFixed(2),
        balance:        (total_ingresos - total_egresos).toFixed(2),
      },
    });
  } catch (err) {
    console.error('[libroCaja]', err);
    return res.status(500).json({ error: 'Error al obtener el libro de caja' });
  }
};

module.exports = { listar, crear, actualizar, eliminar, libroCaja };
```

- [ ] **Step 2: Verificar sintaxis**

```bash
node -e "require('./backend/controllers/movimientos.Controller.js'); console.log('OK')"
```
Resultado esperado: `OK`

---

## Task 4: Backend — Routes y registro en `app.js`

**Files:**
- Create: `backend/routes/categoriasMovimiento.Routes.js`
- Create: `backend/routes/movimientos.Routes.js`
- Modify: `backend/app.js`

- [ ] **Step 1: Crear `backend/routes/categoriasMovimiento.Routes.js`**

```js
const router = require('express').Router();
const { authMiddleware, checkPermission } = require('../middlewares/authMiddleware');
const ctrl = require('../controllers/categoriasMovimiento.Controller');

router.use(authMiddleware);

router.get('/',      checkPermission('ver',        'movimientos'),            ctrl.listar);
router.post('/',     checkPermission('gestionar',  'categorias_movimiento'),  ctrl.crear);
router.put('/:id',   checkPermission('gestionar',  'categorias_movimiento'),  ctrl.actualizar);
router.delete('/:id',checkPermission('gestionar',  'categorias_movimiento'),  ctrl.eliminar);

module.exports = router;
```

- [ ] **Step 2: Crear `backend/routes/movimientos.Routes.js`**

```js
const router = require('express').Router();
const { authMiddleware, checkPermission } = require('../middlewares/authMiddleware');
const ctrl = require('../controllers/movimientos.Controller');

router.use(authMiddleware);

// /libro-caja debe ir ANTES de /:id para evitar conflictos de ruta
router.get('/libro-caja', checkPermission('ver',      'movimientos'), ctrl.libroCaja);
router.get('/',           checkPermission('ver',      'movimientos'), ctrl.listar);
router.post('/',          checkPermission('crear',    'movimientos'), ctrl.crear);
router.put('/:id',        checkPermission('editar',   'movimientos'), ctrl.actualizar);
router.delete('/:id',     checkPermission('eliminar', 'movimientos'), ctrl.eliminar);

module.exports = router;
```

- [ ] **Step 3: Registrar las rutas en `backend/app.js`**

Después de `const backupRoutes = require('./routes/backup.Routes');` (línea ~21), agregar:

```js
const movimientosRoutes          = require('./routes/movimientos.Routes');
const categoriasMovimientoRoutes = require('./routes/categoriasMovimiento.Routes');
```

Después de `app.use('/api/configuracion', configuracionRoutes);` (línea ~60), agregar:

```js
app.use('/api/movimientos',           movimientosRoutes);
app.use('/api/categorias-movimiento', categoriasMovimientoRoutes);
```

- [ ] **Step 4: Verificar sintaxis de las rutas**

```bash
node -e "require('./backend/routes/movimientos.Routes.js'); console.log('OK')"
node -e "require('./backend/routes/categoriasMovimiento.Routes.js'); console.log('OK')"
```
Resultado esperado: `OK` en ambas.

---

## Task 5: Frontend — Servicios

**Files:**
- Create: `frontend/src/services/movimientos.service.js`
- Create: `frontend/src/services/categoriasMovimiento.service.js`

- [ ] **Step 1: Crear `frontend/src/services/movimientos.service.js`**

```js
import api from '../api/axios';

const movimientosService = {
  libroCaja:  (params)     => api.get('/movimientos/libro-caja', { params }),
  listar:     (params)     => api.get('/movimientos', { params }),
  crear:      (data)       => api.post('/movimientos', data),
  actualizar: (id, data)   => api.put(`/movimientos/${id}`, data),
  eliminar:   (id)         => api.delete(`/movimientos/${id}`),
};

export default movimientosService;
```

- [ ] **Step 2: Crear `frontend/src/services/categoriasMovimiento.service.js`**

```js
import api from '../api/axios';

const categoriasMovimientoService = {
  listar:     (params)     => api.get('/categorias-movimiento', { params }),
  crear:      (data)       => api.post('/categorias-movimiento', data),
  actualizar: (id, data)   => api.put(`/categorias-movimiento/${id}`, data),
  eliminar:   (id)         => api.delete(`/categorias-movimiento/${id}`),
};

export default categoriasMovimientoService;
```

---

## Task 6: Frontend — `CategoriasModal.jsx`

**Files:**
- Create: `frontend/src/pages/libroCaja/components/CategoriasModal.jsx`

- [ ] **Step 1: Crear el directorio y el archivo**

Crear `frontend/src/pages/libroCaja/components/CategoriasModal.jsx`:

```jsx
import { useState, useEffect, useCallback } from 'react';
import categoriasMovimientoService from '../../../services/categoriasMovimiento.service';

const TIPOS = ['INGRESO', 'EGRESO', 'AMBOS'];
const FORM_VACIO = { nombre: '', tipo: 'EGRESO' };

export default function CategoriasModal({ abierto, onClose, onActualizado }) {
  const [categorias, setCategorias]   = useState([]);
  const [cargando, setCargando]       = useState(true);
  const [guardando, setGuardando]     = useState(false);
  const [form, setForm]               = useState(FORM_VACIO);
  const [editando, setEditando]       = useState(null);
  const [error, setError]             = useState('');

  const cargar = useCallback(async () => {
    setCargando(true);
    try {
      const res = await categoriasMovimientoService.listar({ incluirInactivas: '1' });
      setCategorias(res.data);
    } finally {
      setCargando(false);
    }
  }, []);

  useEffect(() => { if (abierto) cargar(); }, [abierto, cargar]);

  const handleCampo = (e) => {
    const { name, value } = e.target;
    setForm(f => ({ ...f, [name]: value }));
    setError('');
  };

  const iniciarEdicion = (cat) => {
    setEditando(cat.id_categoria);
    setForm({ nombre: cat.nombre, tipo: cat.tipo });
    setError('');
  };

  const cancelarEdicion = () => {
    setEditando(null);
    setForm(FORM_VACIO);
    setError('');
  };

  const handleGuardar = async () => {
    if (!form.nombre.trim()) { setError('El nombre es obligatorio'); return; }
    setGuardando(true);
    try {
      if (editando) {
        await categoriasMovimientoService.actualizar(editando, form);
      } else {
        await categoriasMovimientoService.crear(form);
      }
      setEditando(null);
      setForm(FORM_VACIO);
      await cargar();
      if (onActualizado) onActualizado();
    } catch (err) {
      setError(err.response?.data?.error || 'Error al guardar');
    } finally {
      setGuardando(false);
    }
  };

  const handleDesactivar = async (id) => {
    try {
      await categoriasMovimientoService.eliminar(id);
      await cargar();
      if (onActualizado) onActualizado();
    } catch (err) {
      setError(err.response?.data?.error || 'Error al desactivar');
    }
  };

  if (!abierto) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50">
      <div className="w-full max-w-lg bg-white dark:bg-zinc-900 rounded-2xl shadow-2xl border border-zinc-200 dark:border-zinc-800 flex flex-col max-h-[90vh]">

        {/* Header */}
        <div className="flex items-center justify-between px-5 py-4 border-b border-zinc-200 dark:border-zinc-800 shrink-0">
          <h2 className="text-base font-bold text-zinc-900 dark:text-white">Categorías de Movimientos</h2>
          <button onClick={onClose} className="text-zinc-400 hover:text-zinc-600 dark:hover:text-zinc-200 text-xl leading-none">✕</button>
        </div>

        {/* Formulario crear/editar */}
        <div className="px-5 py-4 border-b border-zinc-100 dark:border-zinc-800 shrink-0">
          <p className="text-xs font-semibold text-zinc-500 dark:text-zinc-400 uppercase mb-3">
            {editando ? 'Editar categoría' : 'Nueva categoría'}
          </p>
          <div className="flex gap-2">
            <input
              type="text"
              name="nombre"
              value={form.nombre}
              onChange={handleCampo}
              placeholder="Nombre de la categoría"
              className="flex-1 px-3 py-2 rounded-lg text-sm border border-zinc-200 dark:border-zinc-700
                         bg-white dark:bg-zinc-800 text-zinc-900 dark:text-white
                         focus:ring-2 focus:ring-emerald-500 focus:border-transparent outline-none"
            />
            <select
              name="tipo"
              value={form.tipo}
              onChange={handleCampo}
              className="px-3 py-2 rounded-lg text-sm border border-zinc-200 dark:border-zinc-700
                         bg-white dark:bg-zinc-800 text-zinc-900 dark:text-white
                         focus:ring-2 focus:ring-emerald-500 outline-none"
            >
              {TIPOS.map(t => <option key={t} value={t}>{t}</option>)}
            </select>
          </div>
          {error && <p className="text-xs text-red-500 mt-1">{error}</p>}
          <div className="flex gap-2 mt-2">
            <button
              onClick={handleGuardar}
              disabled={guardando}
              className="px-4 py-1.5 text-sm font-bold bg-emerald-600 hover:bg-emerald-500 text-white rounded-lg disabled:opacity-50 transition-colors"
            >
              {guardando ? 'Guardando...' : editando ? 'Actualizar' : 'Agregar'}
            </button>
            {editando && (
              <button
                onClick={cancelarEdicion}
                className="px-4 py-1.5 text-sm text-zinc-600 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-700 rounded-lg transition-colors"
              >
                Cancelar
              </button>
            )}
          </div>
        </div>

        {/* Lista */}
        <div className="flex-1 overflow-y-auto px-5 py-3">
          {cargando ? (
            <div className="flex justify-center py-8">
              <span className="w-6 h-6 rounded-full border-2 border-zinc-300 dark:border-zinc-600 border-t-emerald-500 animate-spin" />
            </div>
          ) : categorias.length === 0 ? (
            <p className="text-sm text-center text-zinc-400 py-6">Sin categorías</p>
          ) : (
            <ul className="space-y-1">
              {categorias.map(cat => (
                <li key={cat.id_categoria}
                    className="flex items-center justify-between px-3 py-2 rounded-lg hover:bg-zinc-50 dark:hover:bg-zinc-800/50">
                  <div className="flex items-center gap-2">
                    <span className={`w-2 h-2 rounded-full ${cat.activo ? 'bg-emerald-500' : 'bg-zinc-300'}`} />
                    <span className={`text-sm ${cat.activo ? 'text-zinc-900 dark:text-white' : 'text-zinc-400 line-through'}`}>
                      {cat.nombre}
                    </span>
                    <span className="text-xs text-zinc-400 dark:text-zinc-500">{cat.tipo}</span>
                  </div>
                  {cat.activo && (
                    <div className="flex gap-1">
                      <button
                        onClick={() => iniciarEdicion(cat)}
                        className="px-2 py-0.5 text-xs text-zinc-500 hover:text-zinc-700 dark:hover:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-700 rounded transition-colors"
                      >
                        Editar
                      </button>
                      <button
                        onClick={() => handleDesactivar(cat.id_categoria)}
                        className="px-2 py-0.5 text-xs text-red-500 hover:text-red-700 hover:bg-red-50 dark:hover:bg-red-500/10 rounded transition-colors"
                      >
                        Desactivar
                      </button>
                    </div>
                  )}
                </li>
              ))}
            </ul>
          )}
        </div>

        {/* Footer */}
        <div className="px-5 py-3 border-t border-zinc-100 dark:border-zinc-800 shrink-0">
          <button
            onClick={onClose}
            className="w-full py-2 text-sm text-zinc-600 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-700 rounded-lg transition-colors"
          >
            Cerrar
          </button>
        </div>
      </div>
    </div>
  );
}
```

---

## Task 7: Frontend — `MovimientoModal.jsx`

**Files:**
- Create: `frontend/src/pages/libroCaja/components/MovimientoModal.jsx`

- [ ] **Step 1: Crear el archivo**

Crear `frontend/src/pages/libroCaja/components/MovimientoModal.jsx`:

```jsx
import { useState, useEffect } from 'react';
import movimientosService from '../../../services/movimientos.service';

const hoy = () => new Date().toISOString().split('T')[0];

const FORM_VACIO = {
  tipo:          'EGRESO',
  id_categoria:  '',
  descripcion:   '',
  monto:         '',
  fecha:         hoy(),
  id_sucursal:   '',
  observaciones: '',
};

export default function MovimientoModal({ modal, categorias, sucursales, puedeVerTodas, onClose, onGuardado }) {
  const [form, setForm]         = useState(FORM_VACIO);
  const [guardando, setGuardando] = useState(false);
  const [error, setError]       = useState('');

  useEffect(() => {
    if (!modal.abierto) return;
    if (modal.modo === 'editar' && modal.datos) {
      setForm({
        tipo:          modal.datos.tipo,
        id_categoria:  String(modal.datos.id_categoria),
        descripcion:   modal.datos.descripcion,
        monto:         String(modal.datos.monto),
        fecha:         modal.datos.fecha?.split('T')[0] ?? hoy(),
        id_sucursal:   modal.datos.id_sucursal ? String(modal.datos.id_sucursal) : '',
        observaciones: modal.datos.observaciones ?? '',
      });
    } else {
      setForm(FORM_VACIO);
    }
    setError('');
  }, [modal]);

  const handleCampo = (e) => {
    const { name, value } = e.target;
    setForm(f => ({
      ...f,
      [name]: value,
      ...(name === 'tipo' ? { id_categoria: '' } : {}),
    }));
    setError('');
  };

  const categsFiltradas = categorias.filter(c =>
    c.tipo === form.tipo || c.tipo === 'AMBOS'
  );

  const handleGuardar = async () => {
    if (!form.descripcion.trim()) { setError('La descripción es obligatoria'); return; }
    if (!form.monto || parseFloat(form.monto) <= 0) { setError('El monto debe ser mayor a 0'); return; }
    if (!form.id_categoria) { setError('Selecciona una categoría'); return; }
    if (!form.fecha) { setError('La fecha es obligatoria'); return; }

    setGuardando(true);
    try {
      const payload = {
        ...form,
        monto:        parseFloat(form.monto),
        id_categoria: parseInt(form.id_categoria),
        id_sucursal:  form.id_sucursal ? parseInt(form.id_sucursal) : null,
      };
      if (modal.modo === 'editar') {
        await movimientosService.actualizar(modal.datos.id_movimiento, payload);
      } else {
        await movimientosService.crear(payload);
      }
      onGuardado();
    } catch (err) {
      setError(err.response?.data?.error || 'Error al guardar');
    } finally {
      setGuardando(false);
    }
  };

  if (!modal.abierto) return null;

  const inputClass = 'w-full px-3 py-2 rounded-lg text-sm border border-zinc-200 dark:border-zinc-700 bg-white dark:bg-zinc-800 text-zinc-900 dark:text-white focus:ring-2 focus:ring-emerald-500 focus:border-transparent outline-none';

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50">
      <div className="w-full max-w-md bg-white dark:bg-zinc-900 rounded-2xl shadow-2xl border border-zinc-200 dark:border-zinc-800">

        {/* Header */}
        <div className="flex items-center justify-between px-5 py-4 border-b border-zinc-200 dark:border-zinc-800">
          <h2 className="text-base font-bold text-zinc-900 dark:text-white">
            {modal.modo === 'editar' ? 'Editar movimiento' : 'Nuevo movimiento'}
          </h2>
          <button onClick={onClose} className="text-zinc-400 hover:text-zinc-600 dark:hover:text-zinc-200 text-xl leading-none">✕</button>
        </div>

        {/* Body */}
        <div className="px-5 py-4 space-y-4">

          {/* Tipo toggle */}
          <div>
            <label className="block text-sm font-medium text-zinc-700 dark:text-zinc-300 mb-1">Tipo</label>
            <div className="flex gap-2">
              {['INGRESO', 'EGRESO'].map(t => (
                <button
                  key={t}
                  onClick={() => handleCampo({ target: { name: 'tipo', value: t } })}
                  className={`flex-1 py-2 rounded-lg text-sm font-bold transition-colors ${
                    form.tipo === t
                      ? t === 'INGRESO'
                        ? 'bg-emerald-600 text-white'
                        : 'bg-red-600 text-white'
                      : 'bg-zinc-100 dark:bg-zinc-700 text-zinc-600 dark:text-zinc-300 hover:bg-zinc-200 dark:hover:bg-zinc-600'
                  }`}
                >
                  {t === 'INGRESO' ? '↑ INGRESO' : '↓ EGRESO'}
                </button>
              ))}
            </div>
          </div>

          {/* Categoría */}
          <div>
            <label className="block text-sm font-medium text-zinc-700 dark:text-zinc-300 mb-1">
              Categoría <span className="text-red-500">*</span>
            </label>
            <select name="id_categoria" value={form.id_categoria} onChange={handleCampo} className={inputClass}>
              <option value="">Seleccionar categoría</option>
              {categsFiltradas.map(c => (
                <option key={c.id_categoria} value={c.id_categoria}>{c.nombre}</option>
              ))}
            </select>
          </div>

          {/* Descripción */}
          <div>
            <label className="block text-sm font-medium text-zinc-700 dark:text-zinc-300 mb-1">
              Descripción <span className="text-red-500">*</span>
            </label>
            <input type="text" name="descripcion" value={form.descripcion} onChange={handleCampo}
                   placeholder="Ej: Pago servicio de luz — Junio" className={inputClass} />
          </div>

          {/* Monto + Fecha */}
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-sm font-medium text-zinc-700 dark:text-zinc-300 mb-1">
                Monto <span className="text-red-500">*</span>
              </label>
              <input type="number" name="monto" value={form.monto} onChange={handleCampo}
                     step="0.01" min="0.01" placeholder="0.00" className={inputClass} />
            </div>
            <div>
              <label className="block text-sm font-medium text-zinc-700 dark:text-zinc-300 mb-1">
                Fecha <span className="text-red-500">*</span>
              </label>
              <input type="date" name="fecha" value={form.fecha} onChange={handleCampo} className={inputClass} />
            </div>
          </div>

          {/* Sucursal — solo si puedeVerTodas */}
          {puedeVerTodas && (
            <div>
              <label className="block text-sm font-medium text-zinc-700 dark:text-zinc-300 mb-1">Sucursal</label>
              <select name="id_sucursal" value={form.id_sucursal} onChange={handleCampo} className={inputClass}>
                <option value="">General (sin sucursal)</option>
                {sucursales.map(s => (
                  <option key={s.id_sucursal} value={s.id_sucursal}>{s.nombre}</option>
                ))}
              </select>
            </div>
          )}

          {/* Observaciones */}
          <div>
            <label className="block text-sm font-medium text-zinc-700 dark:text-zinc-300 mb-1">Observaciones</label>
            <textarea name="observaciones" value={form.observaciones} onChange={handleCampo}
                      rows={2} placeholder="Opcional..."
                      className={`${inputClass} resize-none`} />
          </div>

          {error && (
            <p className="text-sm text-red-500 bg-red-50 dark:bg-red-500/10 px-3 py-2 rounded-lg">{error}</p>
          )}
        </div>

        {/* Footer */}
        <div className="flex gap-3 px-5 py-4 border-t border-zinc-200 dark:border-zinc-800">
          <button onClick={onClose}
                  className="flex-1 py-2.5 text-sm text-zinc-600 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-700 rounded-xl transition-colors">
            Cancelar
          </button>
          <button onClick={handleGuardar} disabled={guardando}
                  className="flex-1 py-2.5 text-sm font-bold bg-emerald-600 hover:bg-emerald-500 text-white rounded-xl disabled:opacity-50 transition-colors">
            {guardando ? 'Guardando...' : modal.modo === 'editar' ? 'Actualizar' : 'Registrar'}
          </button>
        </div>
      </div>
    </div>
  );
}
```

---

## Task 8: Frontend — `TablaLibroCaja.jsx`

**Files:**
- Create: `frontend/src/pages/libroCaja/components/TablaLibroCaja.jsx`

- [ ] **Step 1: Crear el archivo**

Crear `frontend/src/pages/libroCaja/components/TablaLibroCaja.jsx`:

```jsx
function fmt(n) { return parseFloat(n || 0).toLocaleString('es-BO', { minimumFractionDigits: 2 }); }

function BadgeTipo({ tipo }) {
  return tipo === 'INGRESO'
    ? <span className="px-2 py-0.5 rounded-full text-xs font-bold bg-emerald-100 dark:bg-emerald-900/40 text-emerald-700 dark:text-emerald-400">↑ INGRESO</span>
    : <span className="px-2 py-0.5 rounded-full text-xs font-bold bg-red-100 dark:bg-red-900/40 text-red-700 dark:text-red-400">↓ EGRESO</span>;
}

function BadgeOrigen({ origen }) {
  const map = {
    venta:      { label: 'Venta',   cls: 'bg-blue-100 dark:bg-blue-900/40 text-blue-700 dark:text-blue-400' },
    compra:     { label: 'Compra',  cls: 'bg-orange-100 dark:bg-orange-900/40 text-orange-700 dark:text-orange-400' },
    movimiento: { label: 'Manual',  cls: 'bg-zinc-100 dark:bg-zinc-700 text-zinc-600 dark:text-zinc-300' },
  };
  const { label, cls } = map[origen] ?? map.movimiento;
  return <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${cls}`}>{label}</span>;
}

export default function TablaLibroCaja({ movimientos, cargando, onEditar, onEliminar, puedeEditar, puedeEliminar }) {
  if (cargando) {
    return (
      <div className="flex justify-center py-20">
        <span className="w-7 h-7 rounded-full border-2 border-zinc-300 dark:border-zinc-600 border-t-emerald-500 animate-spin" />
      </div>
    );
  }

  if (movimientos.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-16 text-zinc-400 dark:text-zinc-500">
        <span className="text-4xl mb-3">📒</span>
        <p className="text-sm">Sin movimientos en el período seleccionado</p>
      </div>
    );
  }

  return (
    <div className="overflow-x-auto rounded-xl border border-zinc-200 dark:border-zinc-800">
      <table className="w-full text-sm">
        <thead className="bg-zinc-50 dark:bg-zinc-800/50">
          <tr>
            <th className="text-left px-4 py-3 text-xs font-semibold text-zinc-500 dark:text-zinc-400 uppercase">Fecha</th>
            <th className="text-left px-4 py-3 text-xs font-semibold text-zinc-500 dark:text-zinc-400 uppercase">Tipo</th>
            <th className="text-left px-4 py-3 text-xs font-semibold text-zinc-500 dark:text-zinc-400 uppercase">Categoría</th>
            <th className="text-left px-4 py-3 text-xs font-semibold text-zinc-500 dark:text-zinc-400 uppercase">Descripción</th>
            <th className="text-left px-4 py-3 text-xs font-semibold text-zinc-500 dark:text-zinc-400 uppercase hidden sm:table-cell">Sucursal</th>
            <th className="text-right px-4 py-3 text-xs font-semibold text-zinc-500 dark:text-zinc-400 uppercase">Monto</th>
            <th className="text-center px-4 py-3 text-xs font-semibold text-zinc-500 dark:text-zinc-400 uppercase">Origen</th>
            <th className="text-center px-4 py-3 text-xs font-semibold text-zinc-500 dark:text-zinc-400 uppercase">Acciones</th>
          </tr>
        </thead>
        <tbody className="divide-y divide-zinc-100 dark:divide-zinc-800">
          {movimientos.map((mov, i) => (
            <tr key={`${mov.origen}-${mov.id_origen}-${i}`}
                className="hover:bg-zinc-50 dark:hover:bg-zinc-800/30 transition-colors">
              <td className="px-4 py-3 text-zinc-600 dark:text-zinc-400 whitespace-nowrap">
                {mov.fecha ? String(mov.fecha).split('T')[0] : '—'}
              </td>
              <td className="px-4 py-3"><BadgeTipo tipo={mov.tipo} /></td>
              <td className="px-4 py-3 text-zinc-700 dark:text-zinc-300">{mov.categoria}</td>
              <td className="px-4 py-3 text-zinc-900 dark:text-white max-w-xs truncate">{mov.descripcion}</td>
              <td className="px-4 py-3 text-zinc-500 dark:text-zinc-400 hidden sm:table-cell">{mov.sucursal}</td>
              <td className={`px-4 py-3 text-right font-semibold whitespace-nowrap ${
                mov.tipo === 'INGRESO' ? 'text-emerald-600 dark:text-emerald-400' : 'text-red-600 dark:text-red-400'
              }`}>
                {mov.tipo === 'INGRESO' ? '+' : '-'} Bs. {fmt(mov.monto)}
              </td>
              <td className="px-4 py-3 text-center"><BadgeOrigen origen={mov.origen} /></td>
              <td className="px-4 py-3 text-center">
                {mov.origen === 'movimiento' ? (
                  <div className="flex items-center justify-center gap-1">
                    {puedeEditar && (
                      <button onClick={() => onEditar(mov)}
                              className="px-2 py-1 text-xs text-zinc-500 hover:text-zinc-700 dark:hover:text-zinc-200 hover:bg-zinc-100 dark:hover:bg-zinc-700 rounded transition-colors">
                        ✏️
                      </button>
                    )}
                    {puedeEliminar && (
                      <button onClick={() => onEliminar(mov.id_origen)}
                              className="px-2 py-1 text-xs text-red-500 hover:text-red-700 hover:bg-red-50 dark:hover:bg-red-500/10 rounded transition-colors">
                        🗑
                      </button>
                    )}
                  </div>
                ) : (
                  <span className="text-zinc-300 dark:text-zinc-600 text-xs">—</span>
                )}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
```

---

## Task 9: Frontend — `LibroCaja.jsx`

**Files:**
- Create: `frontend/src/pages/libroCaja/LibroCaja.jsx`

- [ ] **Step 1: Crear el archivo**

Crear `frontend/src/pages/libroCaja/LibroCaja.jsx`:

```jsx
import { useState, useEffect, useCallback } from 'react';
import PageWrapper from '../../components/PageWrapper';
import movimientosService from '../../services/movimientos.service';
import categoriasMovimientoService from '../../services/categoriasMovimiento.service';
import sucursalService from '../../services/sucursal.service';
import { usePermission } from '../../hooks/usePermission';
import TablaLibroCaja from './components/TablaLibroCaja';
import MovimientoModal from './components/MovimientoModal';
import CategoriasModal from './components/CategoriasModal';

function Toast({ toast }) {
  if (!toast) return null;
  return (
    <div className={`fixed bottom-5 right-5 z-50 flex items-center gap-3 px-4 py-3 rounded-xl shadow-xl border text-sm font-medium transition-all max-w-xs sm:max-w-sm ${
      toast.tipo === 'ok'
        ? 'bg-green-50 dark:bg-green-900/40 border-green-200 dark:border-green-700 text-green-800 dark:text-green-300'
        : 'bg-red-50 dark:bg-red-900/40 border-red-200 dark:border-red-700 text-red-800 dark:text-red-300'
    }`}>
      <span className="shrink-0">{toast.tipo === 'ok' ? '✅' : '⚠️'}</span>
      <span className="break-words">{toast.msg}</span>
    </div>
  );
}

function fmtMonto(n) {
  return parseFloat(n || 0).toLocaleString('es-BO', { minimumFractionDigits: 2 });
}

function fechaDefecto() {
  const hoy = new Date();
  const desde = new Date(hoy.getFullYear(), hoy.getMonth(), 1).toISOString().split('T')[0];
  const hasta = hoy.toISOString().split('T')[0];
  return { desde, hasta };
}

export default function LibroCaja() {
  const { puede } = usePermission();
  const puedeCrear    = puede('crear',    'movimientos');
  const puedeEditar   = puede('editar',   'movimientos');
  const puedeEliminar = puede('eliminar', 'movimientos');
  const puedeVerTodas = puede('ver_todas','movimientos');
  const puedeGestCats = puede('gestionar','categorias_movimiento');

  const [datos, setDatos]       = useState({ movimientos: [], resumen: { total_ingresos: '0.00', total_egresos: '0.00', balance: '0.00' } });
  const [categorias, setCategorias] = useState([]);
  const [sucursales, setSucursales] = useState([]);
  const [cargando, setCargando]   = useState(true);
  const [toast, setToast]         = useState(null);
  const [filtros, setFiltros]     = useState({ ...fechaDefecto(), id_sucursal: '', tipo: '' });
  const [modalMov, setModalMov]   = useState({ abierto: false, modo: 'crear', datos: null });
  const [modalCats, setModalCats] = useState(false);

  const mostrarToast = (tipo, msg) => {
    setToast({ tipo, msg });
    setTimeout(() => setToast(null), 3500);
  };

  const cargarDatos = useCallback(async (f) => {
    setCargando(true);
    try {
      const params = {};
      if (f.desde)       params.desde        = f.desde;
      if (f.hasta)       params.hasta        = f.hasta;
      if (f.id_sucursal) params.id_sucursal  = f.id_sucursal;
      if (f.tipo)        params.tipo         = f.tipo;
      const res = await movimientosService.libroCaja(params);
      setDatos(res.data);
    } catch {
      mostrarToast('error', 'Error al cargar el libro de caja');
    } finally {
      setCargando(false);
    }
  }, []);

  const cargarCategorias = useCallback(async () => {
    try {
      const res = await categoriasMovimientoService.listar();
      setCategorias(res.data);
    } catch { /* silencioso */ }
  }, []);

  const cargarSucursales = useCallback(async () => {
    if (!puedeVerTodas) return;
    try {
      const res = await sucursalService.listar();
      setSucursales(res.data);
    } catch { /* silencioso */ }
  }, [puedeVerTodas]);

  useEffect(() => {
    cargarDatos(filtros);
    cargarCategorias();
    cargarSucursales();
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  const handleFiltro = (e) => {
    const { name, value } = e.target;
    setFiltros(f => ({ ...f, [name]: value }));
  };

  const aplicarFiltros = () => cargarDatos(filtros);

  const handleEliminar = async (id) => {
    if (!window.confirm('¿Eliminar este movimiento?')) return;
    try {
      await movimientosService.eliminar(id);
      mostrarToast('ok', 'Movimiento eliminado');
      cargarDatos(filtros);
    } catch (err) {
      mostrarToast('error', err.response?.data?.error || 'Error al eliminar');
    }
  };

  const handleGuardado = () => {
    setModalMov({ abierto: false, modo: 'crear', datos: null });
    mostrarToast('ok', 'Movimiento guardado correctamente');
    cargarDatos(filtros);
    cargarCategorias();
  };

  const handleCatsActualizado = () => cargarCategorias();

  const { total_ingresos, total_egresos, balance } = datos.resumen;
  const balanceNum = parseFloat(balance);

  const inputClass = 'px-3 py-2 rounded-lg text-sm border border-zinc-200 dark:border-zinc-700 bg-white dark:bg-zinc-800 text-zinc-900 dark:text-white focus:ring-2 focus:ring-emerald-500 outline-none';

  return (
    <PageWrapper>
      <Toast toast={toast} />

      {/* Header */}
      <div className="mb-6">
        <h1 className="text-xl font-bold text-zinc-900 dark:text-white flex items-center gap-2">
          📒 Libro de Caja
        </h1>
        <p className="text-sm text-zinc-500 dark:text-zinc-400 mt-1">
          Flujo completo: ventas, compras y movimientos manuales.
        </p>
      </div>

      {/* Filtros */}
      <div className="flex flex-wrap gap-2 mb-5 items-end">
        <div className="flex flex-col gap-1">
          <label className="text-xs text-zinc-500 dark:text-zinc-400">Desde</label>
          <input type="date" name="desde" value={filtros.desde} onChange={handleFiltro} className={inputClass} />
        </div>
        <div className="flex flex-col gap-1">
          <label className="text-xs text-zinc-500 dark:text-zinc-400">Hasta</label>
          <input type="date" name="hasta" value={filtros.hasta} onChange={handleFiltro} className={inputClass} />
        </div>
        {puedeVerTodas && (
          <div className="flex flex-col gap-1">
            <label className="text-xs text-zinc-500 dark:text-zinc-400">Sucursal</label>
            <select name="id_sucursal" value={filtros.id_sucursal} onChange={handleFiltro} className={inputClass}>
              <option value="">Todas</option>
              {sucursales.map(s => (
                <option key={s.id_sucursal} value={s.id_sucursal}>{s.nombre}</option>
              ))}
            </select>
          </div>
        )}
        <div className="flex flex-col gap-1">
          <label className="text-xs text-zinc-500 dark:text-zinc-400">Tipo</label>
          <select name="tipo" value={filtros.tipo} onChange={handleFiltro} className={inputClass}>
            <option value="">Todos</option>
            <option value="INGRESO">Ingresos</option>
            <option value="EGRESO">Egresos</option>
          </select>
        </div>
        <button onClick={aplicarFiltros}
                className="px-4 py-2 bg-emerald-600 hover:bg-emerald-500 text-white text-sm font-bold rounded-lg transition-colors">
          Aplicar
        </button>
      </div>

      {/* Tarjetas de resumen */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
        <div className="bg-emerald-50 dark:bg-emerald-900/20 border border-emerald-200 dark:border-emerald-800 rounded-xl p-4">
          <p className="text-xs font-semibold text-emerald-600 dark:text-emerald-400 uppercase mb-1">Total Ingresos</p>
          <p className="text-2xl font-bold text-emerald-700 dark:text-emerald-300">Bs. {fmtMonto(total_ingresos)}</p>
        </div>
        <div className="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-xl p-4">
          <p className="text-xs font-semibold text-red-600 dark:text-red-400 uppercase mb-1">Total Egresos</p>
          <p className="text-2xl font-bold text-red-700 dark:text-red-300">Bs. {fmtMonto(total_egresos)}</p>
        </div>
        <div className={`border rounded-xl p-4 ${
          balanceNum >= 0
            ? 'bg-blue-50 dark:bg-blue-900/20 border-blue-200 dark:border-blue-800'
            : 'bg-red-50 dark:bg-red-900/20 border-red-200 dark:border-red-800'
        }`}>
          <p className={`text-xs font-semibold uppercase mb-1 ${balanceNum >= 0 ? 'text-blue-600 dark:text-blue-400' : 'text-red-600 dark:text-red-400'}`}>Balance</p>
          <p className={`text-2xl font-bold ${balanceNum >= 0 ? 'text-blue-700 dark:text-blue-300' : 'text-red-700 dark:text-red-300'}`}>
            Bs. {fmtMonto(balance)}
          </p>
        </div>
      </div>

      {/* Botones de acción */}
      <div className="flex gap-2 mb-4">
        {puedeCrear && (
          <button
            onClick={() => setModalMov({ abierto: true, modo: 'crear', datos: null })}
            className="flex items-center gap-2 px-4 py-2 bg-emerald-600 hover:bg-emerald-500 text-white text-sm font-bold rounded-lg transition-colors"
          >
            + Nuevo movimiento
          </button>
        )}
        {puedeGestCats && (
          <button
            onClick={() => setModalCats(true)}
            className="flex items-center gap-2 px-4 py-2 bg-zinc-100 dark:bg-zinc-700 hover:bg-zinc-200 dark:hover:bg-zinc-600 text-zinc-700 dark:text-zinc-300 text-sm font-medium rounded-lg transition-colors"
          >
            ⚙ Categorías
          </button>
        )}
      </div>

      {/* Tabla */}
      <TablaLibroCaja
        movimientos={datos.movimientos}
        cargando={cargando}
        onEditar={(mov) => setModalMov({ abierto: true, modo: 'editar', datos: mov })}
        onEliminar={handleEliminar}
        puedeEditar={puedeEditar}
        puedeEliminar={puedeEliminar}
      />

      {/* Modales */}
      <MovimientoModal
        modal={modalMov}
        categorias={categorias}
        sucursales={sucursales}
        puedeVerTodas={puedeVerTodas}
        onClose={() => setModalMov({ abierto: false, modo: 'crear', datos: null })}
        onGuardado={handleGuardado}
      />
      <CategoriasModal
        abierto={modalCats}
        onClose={() => setModalCats(false)}
        onActualizado={handleCatsActualizado}
      />
    </PageWrapper>
  );
}
```

- [ ] **Step 2: Verificar que el frontend compila sin errores**

```bash
cd frontend && npm run build
```

Resultado esperado: `✓ built in X.XXs` sin errores.

---

## Task 10: Frontend — Ruta en `App.jsx` y entrada en `sidebar.jsx`

**Files:**
- Modify: `frontend/src/App.jsx`
- Modify: `frontend/src/components/sidebar.jsx`

- [ ] **Step 1: Agregar el import en `frontend/src/App.jsx`**

Después de `import Configuracion from './pages/configuracion/Configuracion';` (línea ~29), agregar:

```js
import LibroCaja from './pages/libroCaja/LibroCaja';
```

- [ ] **Step 2: Agregar la ruta en `frontend/src/App.jsx`**

Después del bloque de Configuración (antes del bloque de Dashboard), agregar:

```jsx
            {/* ── Libro de Caja ──────────────────────────────────────────── */}
            <Route path="/libro-caja" element={
              <PageRoute action="ver" subject="movimientos">
                <LibroCaja />
              </PageRoute>
            }/>
```

- [ ] **Step 3: Agregar entrada al menú en `frontend/src/components/sidebar.jsx`**

En el array `MENU_ITEMS`, agregar **antes** de la entrada de `'Reportes'` (que tiene `path: '/reportes'`):

```js
{ label: 'Libro de Caja',  path: '/libro-caja',   icono: '📒', action: 'ver', subject: 'movimientos' },
```

- [ ] **Step 4: Verificar build**

```bash
cd frontend && npm run build
```

Resultado esperado: `✓ built in X.XXs` sin errores.

---

## Task 11: Prueba funcional completa

- [ ] **Step 1: Ejecutar el script SQL**

En tu cliente MariaDB, ejecutar el script `bd/migracion_libro_caja.sql` contra la BD `bd_agropecuaria`.

Verificar:
```sql
SELECT * FROM categoria_movimiento;
-- Debe devolver 8 filas

SELECT p.nombre_clave FROM permiso p
JOIN rol_permiso rp ON rp.id_permiso = p.id_permiso
WHERE rp.id_rol = 1 AND p.modulo IN ('movimientos','categorias_movimiento');
-- Debe devolver 7 filas
```

- [ ] **Step 2: Levantar backend y frontend**

```bash
# Terminal 1
cd backend && npm run dev

# Terminal 2
cd frontend && npm run dev
```

- [ ] **Step 3: Probar la página principal**

1. Iniciar sesión como Administrador
2. Verificar que aparece "📒 Libro de Caja" en el sidebar
3. Navegar a `/libro-caja` — debe cargar con los datos del mes actual
4. Verificar que las tarjetas muestran total ingresos, egresos y balance
5. Verificar que la tabla muestra ventas (azul), compras (naranja) en origen

- [ ] **Step 4: Probar crear movimiento**

1. Clic en "+ Nuevo movimiento"
2. Seleccionar EGRESO, categoría "Servicios básicos", descripción "Pago de luz", monto 250, fecha hoy
3. Clic en "Registrar" — toast verde "Movimiento guardado correctamente"
4. Verificar que aparece en la tabla con origen "Manual" y badge rojo "↓ EGRESO"
5. Verificar que el balance y total egresos se actualizan en las tarjetas

- [ ] **Step 5: Probar editar y eliminar**

1. Clic en ✏️ del movimiento recién creado — debe abrir modal con datos precargados
2. Cambiar el monto a 300, guardar — toast verde
3. Clic en 🗑 — confirmar — toast verde "Movimiento eliminado"
4. Verificar que el movimiento desaparece de la tabla

- [ ] **Step 6: Probar gestión de categorías**

1. Clic en "⚙ Categorías"
2. Crear nueva categoría "Combustible" de tipo EGRESO — aparece en la lista
3. Editar "Combustible" → cambiar nombre a "Combustible/Gas"
4. Intentar desactivar una categoría que ya tenga movimientos — debe mostrar error

- [ ] **Step 7: Probar filtros**

1. Cambiar el rango de fechas a un período sin movimientos — tabla muestra "Sin movimientos"
2. Filtrar por tipo INGRESO — solo aparecen ventas e ingresos manuales
3. Filtrar por tipo EGRESO — solo aparecen compras y egresos manuales
