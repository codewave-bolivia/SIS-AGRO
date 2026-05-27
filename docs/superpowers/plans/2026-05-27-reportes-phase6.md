# Phase 6 — Reportes y Estadísticas: Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Corregir 5 bugs conocidos en el módulo de reportes (stock_bajo, resumen financiero, top productos, comparativo sucursales, FiltrosAvanzados) y agregar soporte de parámetros en el servicio + selector de sucursal en VistaGanancias.

**Architecture:** 3 capas: controller Node/Express con MariaDB → `reporte.service.js` Axios → vistas React con Recharts, FiltrosAvanzados genérico, TablaReporte y BotonesExportar.

**Tech Stack:** Node/Express, MariaDB, React 19, Recharts 3, jsPDF 4 + autotable 5, xlsx 0.18, Tailwind CSS 4.

> ⚠️ **Sin commits** — El usuario realizará todos los commits manualmente. Ninguna tarea incluye `git commit`.

---

## Archivos a modificar

| Archivo | Cambio |
|---------|--------|
| `backend/controllers/reportes.Controller.js` | Fix 1, 2, 3, 4 — SQL bugs |
| `frontend/src/services/reporte.service.js` | Fix 6 — params + catálogo sucursales |
| `frontend/src/pages/reportes/components/FiltrosAvanzados.jsx` | Fix 5 — selector sucursal |
| `frontend/src/pages/reportes/vistas/VistaGanancias.jsx` | Selector sucursal + fechas + toggle top |
| `frontend/src/pages/reportes/vistas/VistaInventario.jsx` | Columna stock_minimo |
| `frontend/src/pages/reportes/vistas/VistaSucursales.jsx` | Columna ganancia_bruta |

---

## Task 1: Fix `stock_bajo` — usar `p.stock_minimo` del producto

**Archivo:** `backend/controllers/reportes.Controller.js` líneas 216–228

**Problema actual:** `HAVING stock_total_unidades <= 10` hardcodeado ignora el campo `stock_minimo` de la tabla `producto`.

**Fix:** Incluir `p.stock_minimo` en el SELECT y GROUP BY, y en el HAVING comparar contra `p.stock_minimo`.

- [ ] **Step 1: Abrir `backend/controllers/reportes.Controller.js`** y localizar el case `'stock_bajo'` (aprox. línea 216). El código actual es:

```js
case 'stock_bajo':
  // Definiremos stock bajo arbitrario si no existe en BD, ej. <= 10
  query = `
    SELECT p.id_producto, p.nombre, p.codigo_barras, SUM(l.stock_unidades) as stock_total_unidades
    FROM lote l
    JOIN producto p ON l.id_producto = p.id_producto
    WHERE l.id_sucursal = ? AND l.activo = 1
    GROUP BY p.id_producto, p.nombre, p.codigo_barras
    HAVING stock_total_unidades <= 10
    ORDER BY stock_total_unidades ASC
  `;
  params.push(sucursalId);
  break;
```

- [ ] **Step 2: Reemplazar ese case completo con el siguiente código:**

```js
case 'stock_bajo':
  query = `
    SELECT p.id_producto, p.nombre, p.codigo_barras, p.stock_minimo,
           SUM(l.stock_unidades) as stock_total_unidades
    FROM lote l
    JOIN producto p ON l.id_producto = p.id_producto
    WHERE l.id_sucursal = ? AND l.activo = 1
    GROUP BY p.id_producto, p.nombre, p.codigo_barras, p.stock_minimo
    HAVING stock_total_unidades <= p.stock_minimo
    ORDER BY stock_total_unidades ASC
  `;
  params.push(sucursalId);
  break;
```

- [ ] **Step 3: Verificar manualmente.** Guardar el archivo y confirmar que no hay errores de sintaxis JS (no hay comas sueltas antes del siguiente `case`, la template literal cierra correctamente).

---

## Task 2: Fix `obtenerResumenFinanciero` — filtro por sucursal + fechas parametrizadas

**Archivo:** `backend/controllers/reportes.Controller.js` líneas 279–306

**Problema actual:**
- No filtra por `id_sucursal` — muestra datos de todas las sucursales.
- No acepta `fechaInicio`/`fechaFin` del query.
- Las queries de ventas filtran por `estado != 'ANULADA'` pero el estándar del proyecto es `estado != 'CANCELADO'`.

**Fix:** Reemplazar `obtenerResumenFinanciero` completo con la versión que lee `id_sucursal` del query param (para admins) o del token (`req.user.id_sucursal`), y usa queries parametrizadas para el rango de fechas.

- [ ] **Step 1: Localizar la función `obtenerResumenFinanciero`** (aprox. línea 279). El bloque completo va desde `const obtenerResumenFinanciero = async (req, res) => {` hasta el `};` de cierre antes de `const obtenerTopProductos`.

- [ ] **Step 2: Reemplazar toda la función con:**

```js
const obtenerResumenFinanciero = async (req, res) => {
  const { fechaInicio, fechaFin } = req.query;
  const sucursalId = req.query.id_sucursal || req.user?.id_sucursal;

  try {
    let ventaFechaClause = '';
    let ventaFechaParams = [];
    let compraFechaClause = '';
    let compraFechaParams = [];

    if (fechaInicio && fechaFin) {
      ventaFechaClause  = 'AND DATE(fecha_venta)  BETWEEN ? AND ?';
      ventaFechaParams  = [fechaInicio, fechaFin];
      compraFechaClause = 'AND DATE(fecha_compra) BETWEEN ? AND ?';
      compraFechaParams = [fechaInicio, fechaFin];
    } else {
      ventaFechaClause  = 'AND MONTH(fecha_venta)  = MONTH(CURDATE()) AND YEAR(fecha_venta)  = YEAR(CURDATE())';
      compraFechaClause = 'AND MONTH(fecha_compra) = MONTH(CURDATE()) AND YEAR(fecha_compra) = YEAR(CURDATE())';
    }

    const [ventasRows] = await db.promise().query(
      `SELECT COALESCE(SUM(total), 0) as total_ventas
       FROM venta WHERE estado = 'COMPLETADA' AND id_sucursal = ? ${ventaFechaClause}`,
      [sucursalId, ...ventaFechaParams]
    );

    const [comprasRows] = await db.promise().query(
      `SELECT COALESCE(SUM(total), 0) as total_compras
       FROM compra WHERE estado != 'CANCELADO' AND id_sucursal = ? ${compraFechaClause}`,
      [sucursalId, ...compraFechaParams]
    );

    const [ventasHoyRows] = await db.promise().query(
      `SELECT COUNT(*) as cantidad_ventas_hoy, COALESCE(SUM(total), 0) as ingresos_hoy
       FROM venta WHERE estado = 'COMPLETADA' AND id_sucursal = ? AND DATE(fecha_venta) = CURDATE()`,
      [sucursalId]
    );

    return res.json({
      ingresos_mes:        ventasRows[0].total_ventas,
      egresos_mes:         comprasRows[0].total_compras,
      utilidad_bruta_mes:  ventasRows[0].total_ventas - comprasRows[0].total_compras,
      ventas_hoy_cantidad: ventasHoyRows[0].cantidad_ventas_hoy,
      ingresos_hoy:        ventasHoyRows[0].ingresos_hoy
    });
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
};
```

- [ ] **Step 3: Verificar.** Revisar que la función está completa, que `db` sigue siendo el mismo `require('../config/db')` al tope del archivo, y que no hay doble declaración de `obtenerResumenFinanciero` en el mismo archivo.

---

## Task 3: Fix `obtenerTopProductos` — sucursal + `ordenar_por` + LIMIT 10

**Archivo:** `backend/controllers/reportes.Controller.js` líneas 308–326

**Problemas actuales:**
- No filtra por `id_sucursal`.
- No acepta `ordenar_por` — siempre ordena por `unidades_vendidas`.
- `LIMIT 5` — debe ser 10.

- [ ] **Step 1: Localizar la función `obtenerTopProductos`** (aprox. línea 308).

- [ ] **Step 2: Reemplazar toda la función con:**

```js
const obtenerTopProductos = async (req, res) => {
  const { id_sucursal, ordenar_por } = req.query;
  const sucursalId = id_sucursal || req.user?.id_sucursal;
  const orderColumn = ordenar_por === 'ingresos' ? 'ingresos_generados' : 'unidades_vendidas';

  try {
    const [rows] = await db.promise().query(`
      SELECT p.id_producto, p.nombre, p.codigo_barras,
        SUM(CASE WHEN d.tipo_cantidad = 'CAJA' THEN d.cantidad * l.unidades_por_caja ELSE d.cantidad END) as unidades_vendidas,
        SUM(d.subtotal) as ingresos_generados
      FROM detalle_venta d
      JOIN venta v ON d.id_venta = v.id_venta
      JOIN producto p ON d.id_producto = p.id_producto
      JOIN lote l ON d.id_lote = l.id_lote
      WHERE v.estado = 'COMPLETADA' AND v.id_sucursal = ?
      GROUP BY p.id_producto, p.nombre, p.codigo_barras
      ORDER BY ${orderColumn} DESC LIMIT 10
    `, [sucursalId]);

    return res.json(rows);
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
};
```

> **Nota de seguridad:** `orderColumn` sólo puede tomar dos valores literales definidos en el código (`ingresos_generados` o `unidades_vendidas`) — no proviene directamente del query param, por lo que no hay riesgo de SQL injection.

- [ ] **Step 3: Verificar** que la función cierra con `};` y no queda código huérfano.

---

## Task 4: Fix `obtenerReporteComparativoSucursales` — agregar `ganancia_bruta`

**Archivo:** `backend/controllers/reportes.Controller.js` líneas 441–476

**Problema:** La query no calcula `ganancia_bruta`. La columna falta en la respuesta.

**Fix:** Agregar `LEFT JOIN detalle_venta dv` y `LEFT JOIN lote l` para calcular el costo, y añadir la columna `ganancia_bruta` al SELECT.

- [ ] **Step 1: Localizar la función `obtenerReporteComparativoSucursales`** (aprox. línea 441).

- [ ] **Step 2: Reemplazar la const `query` dentro del bloque `try` (la que empieza con `SELECT s.id_sucursal...`).** El bloque query actual es:

```js
const query = `
  SELECT s.id_sucursal, s.nombre as sucursal, s.ciudad,
    COUNT(DISTINCT v.id_venta) as total_ventas,
    COALESCE(SUM(v.total), 0) as total_ingresos,
    COALESCE(SUM(v.descuento_total), 0) as total_descuentos
  FROM sucursal s
  LEFT JOIN venta v ON s.id_sucursal = v.id_sucursal AND ${ventaJoinWhere}
  WHERE s.activo = 1
  GROUP BY s.id_sucursal, s.nombre, s.ciudad
  ORDER BY total_ingresos DESC
`;
```

Reemplazarlo con:

```js
const query = `
  SELECT s.id_sucursal, s.nombre as sucursal, s.ciudad,
    COUNT(DISTINCT v.id_venta) as total_ventas,
    COALESCE(SUM(v.total), 0) as total_ingresos,
    COALESCE(SUM(v.descuento_total), 0) as total_descuentos,
    COALESCE(SUM(v.total), 0) - COALESCE(SUM(
      CASE WHEN dv.tipo_cantidad = 'CAJA'
        THEN dv.cantidad * l.precio_por_caja
        ELSE dv.cantidad * (l.precio_por_caja / l.unidades_por_caja)
      END
    ), 0) as ganancia_bruta
  FROM sucursal s
  LEFT JOIN venta v ON s.id_sucursal = v.id_sucursal AND ${ventaJoinWhere}
  LEFT JOIN detalle_venta dv ON v.id_venta = dv.id_venta
  LEFT JOIN lote l ON dv.id_lote = l.id_lote
  WHERE s.activo = 1
  GROUP BY s.id_sucursal, s.nombre, s.ciudad
  ORDER BY total_ingresos DESC
`;
```

- [ ] **Step 3: Verificar** que los JOINs adicionales son `LEFT JOIN` (para preservar sucursales sin ventas en el período).

---

## Task 5: Fix `reporte.service.js` — params en financiero/topProductos + catálogo sucursales

**Archivo:** `frontend/src/services/reporte.service.js`

**Problemas:**
- `financiero: () => ...` y `topProductos: () => ...` no aceptan `params`.
- Falta `sucursales` en `catalogos`.

- [ ] **Step 1: Abrir `frontend/src/services/reporte.service.js`.** El archivo completo actual es:

```js
import api from '../api/axios';

const reporteService = {
  financiero:   () => api.get('/reportes/financiero'),
  topProductos: () => api.get('/reportes/top-productos'),
  vencimientos: () => api.get('/reportes/vencimientos'),
  ventas: (tipo, params) => api.get(`/reportes/ventas/${tipo}`, { params }),
  compras: (tipo, params) => api.get(`/reportes/compras/${tipo}`, { params }),
  inventario: (tipo, params) => api.get(`/reportes/inventario/${tipo}`, { params }),
  gananciasProducto: (params) => api.get('/reportes/ganancias/producto', { params }),
  traslados:          (params) => api.get('/reportes/sucursales/traslados', { params }),
  comparativoSucursales: (params) => api.get('/reportes/sucursales/comparativo', { params }),
  caja: (params) => api.get('/reportes/caja', { params }),
  catalogos: {
    clientes:    () => api.get('/clientes'),
    proveedores: () => api.get('/proveedores'),
    usuarios:    () => api.get('/usuarios'),
    productos:   () => api.get('/productos')
  }
};

export default reporteService;
```

- [ ] **Step 2: Reemplazar el archivo completo con:**

```js
import api from '../api/axios';

const reporteService = {
  financiero:   (params) => api.get('/reportes/financiero', { params }),
  topProductos: (params) => api.get('/reportes/top-productos', { params }),
  vencimientos: () => api.get('/reportes/vencimientos'),
  ventas: (tipo, params) => api.get(`/reportes/ventas/${tipo}`, { params }),
  compras: (tipo, params) => api.get(`/reportes/compras/${tipo}`, { params }),
  inventario: (tipo, params) => api.get(`/reportes/inventario/${tipo}`, { params }),
  gananciasProducto: (params) => api.get('/reportes/ganancias/producto', { params }),
  traslados:             (params) => api.get('/reportes/sucursales/traslados', { params }),
  comparativoSucursales: (params) => api.get('/reportes/sucursales/comparativo', { params }),
  caja: (params) => api.get('/reportes/caja', { params }),
  catalogos: {
    clientes:    () => api.get('/clientes'),
    proveedores: () => api.get('/proveedores'),
    usuarios:    () => api.get('/usuarios'),
    productos:   () => api.get('/productos'),
    sucursales:  () => api.get('/sucursales')
  }
};

export default reporteService;
```

- [ ] **Step 3: Verificar** los dos cambios: (a) `financiero` y `topProductos` ahora aceptan `params`; (b) `catalogos.sucursales` existe.

---

## Task 6: Fix `FiltrosAvanzados.jsx` — agregar selector de sucursal

**Archivo:** `frontend/src/pages/reportes/components/FiltrosAvanzados.jsx`

**Problema:** El componente no tiene opción `sucursales` — no puede mostrar un selector de sucursal aunque el padre lo necesite.

- [ ] **Step 1: Abrir `FiltrosAvanzados.jsx`.** Actualmente la firma de props es:

```jsx
export default function FiltrosAvanzados({ 
  filtros, 
  setFiltros, 
  onBuscar, 
  cargando,
  opciones = { fechas: true, clientes: false, productos: false, vendedores: false, proveedores: false },
  catalogos = { clientes: [], productos: [], usuarios: [], proveedores: [] }
})
```

- [ ] **Step 2: Actualizar la firma de props** para incluir `sucursales` en `opciones` y `catalogos`:

```jsx
export default function FiltrosAvanzados({ 
  filtros, 
  setFiltros, 
  onBuscar, 
  cargando,
  opciones = { fechas: true, clientes: false, productos: false, vendedores: false, proveedores: false, sucursales: false },
  catalogos = { clientes: [], productos: [], usuarios: [], proveedores: [], sucursales: [] }
})
```

- [ ] **Step 3: Añadir el bloque del selector de sucursal** justo después del bloque `{opciones.proveedores && ...}` y antes del `{/* Botones de acción ... */}`. El bloque a insertar:

```jsx
{opciones.sucursales && (
  <div>
    <label className="block text-xs text-zinc-500 mb-1">Sucursal</label>
    <select 
      name="id_sucursal" 
      value={filtros.id_sucursal || ''} 
      onChange={handleChange}
      className="w-full px-3 py-1.5 text-sm bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded-lg outline-none focus:ring-2 focus:ring-emerald-500"
    >
      <option value="">Todas las sucursales</option>
      {catalogos.sucursales?.map(s => <option key={s.id_sucursal} value={s.id_sucursal}>{s.nombre}</option>)}
    </select>
  </div>
)}
```

- [ ] **Step 4: Verificar** que el nuevo bloque está dentro del `<div className="grid ...">` y antes del `<div className="flex items-end gap-2 ...">` (botones Aplicar/Limpiar).

---

## Task 7: Fix `VistaGanancias.jsx` — selector sucursal + fechas en "generales" + toggle en "top_productos"

**Archivo:** `frontend/src/pages/reportes/vistas/VistaGanancias.jsx`

**Cambios requeridos:**
1. Cargar catálogo de sucursales al montar (solo si el usuario tiene el permiso `ventas.ver_todas_sucursales`).
2. Tab `generales`: mostrar `FiltrosAvanzados` con `opciones={{ fechas: true, sucursales: puedeVerTodasSucursales }}` y disparar `reporteService.financiero(filtros)` al aplicar.
3. Tab `top_productos`: toggle Unidades/Ingresos, pasar `ordenar_por` al servicio, actualizar label de "Top 5" a "Top 10".

- [ ] **Step 1: Reemplazar el archivo completo con el siguiente código:**

```jsx
import { useState, useEffect } from 'react';
import { usePermission } from '../../../hooks/usePermission';
import reporteService from '../../../services/reporte.service';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Cell } from 'recharts';
import BotonesExportar from '../components/BotonesExportar';
import TablaReporte from '../components/TablaReporte';
import FiltrosAvanzados from '../components/FiltrosAvanzados';

export default function VistaGanancias() {
  const { puede } = usePermission();
  const puedeVerTodasSucursales = puede('ver_todas_sucursales', 'ventas');

  const SUB_TABS = [
    { id: 'generales',          label: 'Resumen Financiero', permiso: 'ganancias' },
    { id: 'top_productos',      label: 'Top Productos',      permiso: 'top_productos' },
    { id: 'ganancias_producto', label: 'Por Producto',       permiso: 'ganancias_producto' }
  ];

  const tabsPermitidos = SUB_TABS.filter(t => puede(t.permiso, 'reportes'));
  const [activeTab, setActiveTab]       = useState(tabsPermitidos.length > 0 ? tabsPermitidos[0].id : null);

  // Resumen financiero
  const [financiero, setFinanciero]     = useState(null);
  const [filtrosFinanciero, setFiltrosFinanciero] = useState({});

  // Top productos
  const [topProductos, setTopProductos] = useState([]);
  const [filtrosTop, setFiltrosTop]     = useState({});
  const [ordenarPor, setOrdenarPor]     = useState('unidades'); // 'unidades' | 'ingresos'

  // Ganancias por producto
  const [datosGanancia, setDatosGanancia]   = useState([]);
  const [resumenGanancia, setResumenGanancia] = useState(null);
  const [filtros, setFiltros]               = useState({});

  // Estado general
  const [cargando, setCargando]             = useState(false);
  const [sucursales, setSucursales]         = useState([]);

  // Cargar catálogo de sucursales solo si tiene permiso
  useEffect(() => {
    if (puedeVerTodasSucursales) {
      reporteService.catalogos.sucursales()
        .then(res => setSucursales(res.data))
        .catch(() => {});
    }
  }, [puedeVerTodasSucursales]);

  // Cargar datos al cambiar de tab
  useEffect(() => {
    if (!activeTab) return;
    setCargando(true);
    if (activeTab === 'generales') {
      reporteService.financiero(filtrosFinanciero)
        .then(res => setFinanciero(res.data))
        .finally(() => setCargando(false));
    } else if (activeTab === 'top_productos') {
      reporteService.topProductos({ ...filtrosTop, ordenar_por: ordenarPor === 'ingresos' ? 'ingresos' : undefined })
        .then(res => setTopProductos(res.data))
        .finally(() => setCargando(false));
    } else {
      setCargando(false);
    }
  }, [activeTab]);

  // Buscar resumen financiero con filtros
  const buscarFinanciero = async () => {
    setCargando(true);
    try {
      const res = await reporteService.financiero(filtrosFinanciero);
      setFinanciero(res.data);
    } catch (err) {
      console.error(err);
    } finally {
      setCargando(false);
    }
  };

  // Buscar top productos con filtros y ordenamiento
  const buscarTopProductos = async (nuevoOrden) => {
    const orden = nuevoOrden || ordenarPor;
    setCargando(true);
    try {
      const params = { ...filtrosTop };
      if (orden === 'ingresos') params.ordenar_por = 'ingresos';
      const res = await reporteService.topProductos(params);
      setTopProductos(res.data);
    } catch (err) {
      console.error(err);
    } finally {
      setCargando(false);
    }
  };

  const handleToggleOrden = (nuevoOrden) => {
    setOrdenarPor(nuevoOrden);
    buscarTopProductos(nuevoOrden);
  };

  // Buscar ganancias por producto
  const buscarGananciasProducto = async () => {
    setCargando(true);
    try {
      const res = await reporteService.gananciasProducto(filtros);
      setDatosGanancia(res.data.data || []);
      setResumenGanancia(res.data.resumen || {});
    } catch (err) {
      console.error(err);
    } finally {
      setCargando(false);
    }
  };

  const COLORS = ['#10b981', '#3b82f6', '#f59e0b', '#ef4444', '#8b5cf6'];

  if (!activeTab) {
    return <div className="p-8 text-center text-zinc-500">No tienes permisos para ver reportes financieros.</div>;
  }

  return (
    <div className="space-y-6">
      {/* Sub-tabs */}
      <div className="flex flex-wrap gap-2">
        {tabsPermitidos.map(tab => (
          <button
            key={tab.id}
            onClick={() => setActiveTab(tab.id)}
            className={`px-3 py-1.5 text-xs font-semibold rounded-lg transition-all ${
              activeTab === tab.id
                ? 'bg-zinc-800 text-white dark:bg-white dark:text-zinc-900 shadow-md'
                : 'bg-white dark:bg-zinc-800 text-zinc-600 dark:text-zinc-300 border border-zinc-200 dark:border-zinc-700 hover:bg-zinc-50 dark:hover:bg-zinc-700'
            }`}
          >
            {tab.label}
          </button>
        ))}
      </div>

      {cargando ? (
        <div className="p-12 text-center text-zinc-500">Cargando métricas...</div>
      ) : (
        <>
          {/* ── RESUMEN FINANCIERO ── */}
          {activeTab === 'generales' && (
            <div className="space-y-4 animate-fade-in">
              <FiltrosAvanzados
                filtros={filtrosFinanciero}
                setFiltros={setFiltrosFinanciero}
                onBuscar={buscarFinanciero}
                cargando={cargando}
                opciones={{ fechas: true, sucursales: puedeVerTodasSucursales }}
                catalogos={{ sucursales }}
              />
              {financiero && (
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div className="bg-white dark:bg-zinc-900 rounded-2xl p-6 border border-zinc-200 dark:border-zinc-800 shadow-sm relative overflow-hidden">
                    <div className="absolute top-0 right-0 p-4 opacity-10">
                      <svg className="w-16 h-16 text-emerald-500" fill="currentColor" viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z"/></svg>
                    </div>
                    <p className="text-sm font-semibold text-zinc-500 uppercase tracking-wider mb-2">Ventas (Ingresos)</p>
                    <h3 className="text-3xl font-black text-emerald-600 dark:text-emerald-400">Bs {parseFloat(financiero.ingresos_mes).toLocaleString('en-US', {minimumFractionDigits: 2})}</h3>
                    <p className="text-xs text-zinc-400 mt-2">Acumulado del período</p>
                  </div>

                  <div className="bg-white dark:bg-zinc-900 rounded-2xl p-6 border border-zinc-200 dark:border-zinc-800 shadow-sm relative overflow-hidden">
                    <div className="absolute top-0 right-0 p-4 opacity-10">
                      <svg className="w-16 h-16 text-red-500" fill="currentColor" viewBox="0 0 24 24"><path d="M19 13H5v-2h14v2z"/></svg>
                    </div>
                    <p className="text-sm font-semibold text-zinc-500 uppercase tracking-wider mb-2">Compras (Egresos)</p>
                    <h3 className="text-3xl font-black text-red-600 dark:text-red-400">Bs {parseFloat(financiero.egresos_mes).toLocaleString('en-US', {minimumFractionDigits: 2})}</h3>
                    <p className="text-xs text-zinc-400 mt-2">Pagos a proveedores</p>
                  </div>

                  <div className="bg-white dark:bg-zinc-900 rounded-2xl p-6 border border-zinc-200 dark:border-zinc-800 shadow-sm relative overflow-hidden">
                    <div className="absolute top-0 right-0 p-4 opacity-10">
                      <svg className="w-16 h-16 text-blue-500" fill="currentColor" viewBox="0 0 24 24"><path d="M3 13h2v-2H3v2zm0 4h2v-2H3v2zm0-8h2V7H3v2zm4 4h14v-2H7v2zm0 4h14v-2H7v2zM7 7v2h14V7H7z"/></svg>
                    </div>
                    <p className="text-sm font-semibold text-zinc-500 uppercase tracking-wider mb-2">Utilidad Bruta</p>
                    <h3 className={`text-3xl font-black ${financiero.utilidad_bruta_mes >= 0 ? 'text-blue-600 dark:text-blue-400' : 'text-orange-600 dark:text-orange-400'}`}>
                      Bs {parseFloat(financiero.utilidad_bruta_mes).toLocaleString('en-US', {minimumFractionDigits: 2})}
                    </h3>
                    <p className="text-xs text-zinc-400 mt-2">Diferencia neta del período</p>
                  </div>

                  {/* KPIs de hoy */}
                  <div className="bg-white dark:bg-zinc-900 rounded-xl p-4 border border-zinc-200 dark:border-zinc-800 shadow-sm flex items-center gap-4">
                    <span className="text-3xl">📦</span>
                    <div>
                      <p className="text-xs text-zinc-500 uppercase font-bold">Ventas Hoy</p>
                      <p className="text-xl font-black text-zinc-900 dark:text-white">{financiero.ventas_hoy_cantidad}</p>
                    </div>
                  </div>
                  <div className="bg-white dark:bg-zinc-900 rounded-xl p-4 border border-zinc-200 dark:border-zinc-800 shadow-sm flex items-center gap-4">
                    <span className="text-3xl">💰</span>
                    <div>
                      <p className="text-xs text-zinc-500 uppercase font-bold">Ingresos Hoy</p>
                      <p className="text-xl font-black text-emerald-600">Bs {parseFloat(financiero.ingresos_hoy).toLocaleString('en-US', {minimumFractionDigits: 2})}</p>
                    </div>
                  </div>
                </div>
              )}
            </div>
          )}

          {/* ── TOP PRODUCTOS ── */}
          {activeTab === 'top_productos' && (
            <div className="space-y-4 animate-fade-in">
              {/* Filtros + toggle */}
              <div className="flex flex-wrap items-end gap-3">
                <div className="flex-1 min-w-[200px]">
                  <FiltrosAvanzados
                    filtros={filtrosTop}
                    setFiltros={setFiltrosTop}
                    onBuscar={() => buscarTopProductos()}
                    cargando={cargando}
                    opciones={{ fechas: false, sucursales: puedeVerTodasSucursales }}
                    catalogos={{ sucursales }}
                  />
                </div>
                {/* Toggle Unidades / Ingresos */}
                <div className="flex rounded-lg overflow-hidden border border-zinc-200 dark:border-zinc-700 mb-4">
                  <button
                    onClick={() => handleToggleOrden('unidades')}
                    className={`px-3 py-1.5 text-xs font-semibold transition-colors ${
                      ordenarPor === 'unidades'
                        ? 'bg-zinc-800 text-white dark:bg-white dark:text-zinc-900'
                        : 'bg-white dark:bg-zinc-800 text-zinc-500 hover:bg-zinc-50 dark:hover:bg-zinc-700'
                    }`}
                  >
                    Unidades
                  </button>
                  <button
                    onClick={() => handleToggleOrden('ingresos')}
                    className={`px-3 py-1.5 text-xs font-semibold transition-colors ${
                      ordenarPor === 'ingresos'
                        ? 'bg-zinc-800 text-white dark:bg-white dark:text-zinc-900'
                        : 'bg-white dark:bg-zinc-800 text-zinc-500 hover:bg-zinc-50 dark:hover:bg-zinc-700'
                    }`}
                  >
                    Ingresos
                  </button>
                </div>
              </div>

              <div className="bg-white dark:bg-zinc-900 rounded-2xl border border-zinc-200 dark:border-zinc-800 shadow-sm p-6">
                <div className="flex justify-between items-center mb-6">
                  <h3 className="font-bold text-lg text-zinc-900 dark:text-white flex items-center gap-2">
                    🏆 Top 10 Productos — {ordenarPor === 'ingresos' ? 'Por Ingresos (Bs)' : 'Por Unidades Vendidas'}
                  </h3>
                  <BotonesExportar
                    datos={topProductos}
                    columnas={[
                      { key: 'codigo_barras',    header: 'Código',       excelValue: r => r.codigo_barras },
                      { key: 'nombre',           header: 'Producto',     excelValue: r => r.nombre },
                      { key: 'unidades_vendidas',header: 'Unidades',     excelValue: r => r.unidades_vendidas },
                      { key: 'ingresos_generados',header: 'Ingresos (Bs)', excelValue: r => parseFloat(r.ingresos_generados) }
                    ]}
                    titulo="Ranking_Top_Productos"
                  />
                </div>

                {topProductos.length === 0 ? (
                  <div className="h-64 flex items-center justify-center text-zinc-400">No hay datos de ventas suficientes</div>
                ) : (
                  <div className="h-72">
                    <ResponsiveContainer width="100%" height="100%">
                      <BarChart data={topProductos} layout="vertical" margin={{ top: 5, right: 30, left: 20, bottom: 5 }}>
                        <CartesianGrid strokeDasharray="3 3" horizontal={false} stroke="#3f3f46" opacity={0.2} />
                        <XAxis type="number" tick={{ fill: '#71717a', fontSize: 12 }} />
                        <YAxis dataKey="nombre" type="category" width={120} tick={{ fill: '#71717a', fontSize: 12 }} />
                        <Tooltip
                          cursor={{ fill: 'rgba(16, 185, 129, 0.1)' }}
                          contentStyle={{ backgroundColor: '#18181b', border: 'none', borderRadius: '8px', color: '#fff' }}
                          formatter={(value) => [
                            ordenarPor === 'ingresos' ? `Bs ${parseFloat(value).toFixed(2)}` : `${value} unidades`,
                            ordenarPor === 'ingresos' ? 'Ingresos' : 'Vendido'
                          ]}
                        />
                        <Bar dataKey={ordenarPor === 'ingresos' ? 'ingresos_generados' : 'unidades_vendidas'} radius={[0, 4, 4, 0]}>
                          {topProductos.map((_, index) => (
                            <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                          ))}
                        </Bar>
                      </BarChart>
                    </ResponsiveContainer>
                  </div>
                )}
              </div>
            </div>
          )}

          {/* ── GANANCIAS POR PRODUCTO ── */}
          {activeTab === 'ganancias_producto' && (
            <div className="space-y-4 animate-fade-in">
              <FiltrosAvanzados
                filtros={filtros}
                setFiltros={setFiltros}
                onBuscar={buscarGananciasProducto}
                cargando={cargando}
                opciones={{ fechas: true }}
                catalogos={{}}
              />
              <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 bg-white dark:bg-zinc-900 p-4 rounded-xl border border-zinc-200 dark:border-zinc-800 shadow-sm">
                <div className="flex gap-6 flex-wrap">
                  <div>
                    <p className="text-[10px] uppercase tracking-wider text-zinc-500 font-bold mb-1">Productos</p>
                    <p className="text-xl font-black text-zinc-900 dark:text-white">{resumenGanancia?.total_registros || 0}</p>
                  </div>
                  {resumenGanancia?.total_ingresos !== undefined && (
                    <div>
                      <p className="text-[10px] uppercase tracking-wider text-zinc-500 font-bold mb-1">Ingresos Totales</p>
                      <p className="text-xl font-black text-emerald-600">Bs {parseFloat(resumenGanancia.total_ingresos).toLocaleString('en-US', {minimumFractionDigits: 2})}</p>
                    </div>
                  )}
                  {resumenGanancia?.ganancia_total !== undefined && (
                    <div>
                      <p className="text-[10px] uppercase tracking-wider text-zinc-500 font-bold mb-1">Ganancia Bruta</p>
                      <p className={`text-xl font-black ${resumenGanancia.ganancia_total >= 0 ? 'text-blue-600' : 'text-red-600'}`}>
                        Bs {parseFloat(resumenGanancia.ganancia_total).toLocaleString('en-US', {minimumFractionDigits: 2})}
                      </p>
                    </div>
                  )}
                </div>
                <BotonesExportar
                  datos={datosGanancia}
                  columnas={[
                    { key: 'codigo_barras',  header: 'Código',       excelValue: r => r.codigo_barras || 'N/A' },
                    { key: 'nombre',         header: 'Producto',     excelValue: r => r.nombre },
                    { key: 'unidades_vendidas', header: 'Unidades',  excelValue: r => r.unidades_vendidas },
                    { key: 'total_ingresos', header: 'Ingresos (Bs)', excelValue: r => parseFloat(r.total_ingresos) },
                    { key: 'costo_total',    header: 'Costo (Bs)',   excelValue: r => parseFloat(r.costo_total) },
                    { key: 'ganancia_bruta', header: 'Ganancia (Bs)', excelValue: r => parseFloat(r.ganancia_bruta) }
                  ]}
                  titulo="Reporte_Ganancias_Por_Producto"
                />
              </div>
              <div className="bg-white dark:bg-zinc-900 rounded-xl border border-zinc-200 dark:border-zinc-800 shadow-sm">
                <TablaReporte
                  cargando={cargando}
                  datos={datosGanancia}
                  columnas={[
                    { key: 'codigo_barras', header: 'Código', render: v => v || 'N/A' },
                    { key: 'nombre', header: 'Producto' },
                    { key: 'unidades_vendidas', header: 'Unidades', align: 'center' },
                    { key: 'total_ingresos', header: 'Ingresos (Bs)', align: 'right', render: v => parseFloat(v).toFixed(2) },
                    { key: 'costo_total', header: 'Costo (Bs)', align: 'right', render: v => parseFloat(v).toFixed(2) },
                    { key: 'ganancia_bruta', header: 'Ganancia Bruta (Bs)', align: 'right', render: (v) => (
                      <span className={`font-bold ${parseFloat(v) >= 0 ? 'text-emerald-600' : 'text-red-600'}`}>
                        {parseFloat(v).toFixed(2)}
                      </span>
                    ), excelValue: r => parseFloat(r.ganancia_bruta) },
                    { key: 'margen', header: 'Margen %', align: 'right', render: (_, r) => {
                      const ing = parseFloat(r.total_ingresos);
                      const gan = parseFloat(r.ganancia_bruta);
                      const margen = ing > 0 ? ((gan / ing) * 100).toFixed(1) : '0.0';
                      return <span className={parseFloat(margen) >= 0 ? 'text-blue-600 font-semibold' : 'text-red-600 font-semibold'}>{margen}%</span>;
                    }, excelValue: r => parseFloat(r.total_ingresos) > 0 ? ((parseFloat(r.ganancia_bruta)/parseFloat(r.total_ingresos))*100).toFixed(1) : 0 }
                  ]}
                />
              </div>
            </div>
          )}
        </>
      )}
    </div>
  );
}
```

- [ ] **Step 2: Verificar** que los imports en la parte superior son correctos (todos los mismos que el archivo original: `useState`, `useEffect`, `usePermission`, `reporteService`, `BarChart`, `Bar`, `XAxis`, `YAxis`, `CartesianGrid`, `Tooltip`, `ResponsiveContainer`, `Cell`, `BotonesExportar`, `TablaReporte`, `FiltrosAvanzados`).

---

## Task 8: Fix `VistaInventario.jsx` — agregar columna `stock_minimo` en stock_bajo

**Archivo:** `frontend/src/pages/reportes/vistas/VistaInventario.jsx`

**Problema:** El case `'stock_bajo'` en `getColumnas()` no incluye la columna `stock_minimo` que ahora devuelve el backend.

- [ ] **Step 1: Abrir `VistaInventario.jsx`** y localizar el case `'stock_bajo'` dentro de `getColumnas()` (aprox. línea 83). El código actual es:

```js
case 'stock_bajo':
  return [
    { key: 'codigo_barras', header: 'Código' },
    { key: 'nombre', header: 'Producto' },
    { key: 'stock_total_unidades', header: 'Stock Actual', align: 'center', render: v => <span className="font-bold text-red-600">{v} u</span>, excelValue: r => r.stock_total_unidades }
  ];
```

- [ ] **Step 2: Reemplazar ese case con:**

```js
case 'stock_bajo':
  return [
    { key: 'codigo_barras', header: 'Código' },
    { key: 'nombre', header: 'Producto' },
    { key: 'stock_minimo', header: 'Mínimo', align: 'center', excelValue: r => r.stock_minimo },
    { key: 'stock_total_unidades', header: 'Stock Actual', align: 'center', render: v => <span className="font-bold text-red-600">{v} u</span>, excelValue: r => r.stock_total_unidades }
  ];
```

- [ ] **Step 3: Verificar** que el array cierra correctamente con `];` y que el siguiente `case 'vencimientos'` sigue intacto.

---

## Task 9: Fix `VistaSucursales.jsx` — agregar columna `ganancia_bruta` en comparativo

**Archivo:** `frontend/src/pages/reportes/vistas/VistaSucursales.jsx`

**Problema:** `columnasComparativo` no incluye la columna `ganancia_bruta` que ahora devuelve el backend.

- [ ] **Step 1: Abrir `VistaSucursales.jsx`** y localizar `columnasComparativo` (aprox. línea 70). El código actual es:

```js
const columnasComparativo = [
  { key: 'sucursal', header: 'Sucursal' },
  { key: 'ciudad', header: 'Ciudad', render: v => v || 'N/A' },
  { key: 'total_ventas', header: 'Nro Ventas', align: 'center' },
  { key: 'total_ingresos', header: 'Ingresos (Bs)', align: 'right', render: v => parseFloat(v).toFixed(2), excelValue: r => parseFloat(r.total_ingresos) },
  { key: 'total_descuentos', header: 'Descuentos (Bs)', align: 'right', render: v => parseFloat(v).toFixed(2), excelValue: r => parseFloat(r.total_descuentos) }
];
```

- [ ] **Step 2: Reemplazar con:**

```js
const columnasComparativo = [
  { key: 'sucursal', header: 'Sucursal' },
  { key: 'ciudad', header: 'Ciudad', render: v => v || 'N/A' },
  { key: 'total_ventas', header: 'Nro Ventas', align: 'center' },
  { key: 'total_ingresos', header: 'Ingresos (Bs)', align: 'right', render: v => parseFloat(v).toFixed(2), excelValue: r => parseFloat(r.total_ingresos) },
  { key: 'total_descuentos', header: 'Descuentos (Bs)', align: 'right', render: v => parseFloat(v).toFixed(2), excelValue: r => parseFloat(r.total_descuentos) },
  { key: 'ganancia_bruta', header: 'Ganancia Bruta (Bs)', align: 'right',
    render: v => <span className={parseFloat(v) >= 0 ? 'text-emerald-600 font-bold' : 'text-red-600 font-bold'}>{parseFloat(v).toFixed(2)}</span>,
    excelValue: r => parseFloat(r.ganancia_bruta) }
];
```

- [ ] **Step 3: Verificar** que el array cierra con `];` y que `columnas` en `const columnas = activeTab === 'traslados' ? columnasTraslados : columnasComparativo;` sigue sin cambios.

---

## Verificación Final

Una vez aplicados todos los cambios, hacer una revisión manual en el navegador:

- [ ] **Backend iniciado:** `cd backend && node app.js` — sin errores de sintaxis en consola.
- [ ] **Frontend iniciado:** `cd frontend && npm run dev` — sin errores de compilación.
- [ ] **Reporte Stock Bajo:** `/reportes` → Inventario → Stock Bajo → Aplicar. La tabla debe mostrar columna "Mínimo" y sólo productos cuyo stock sea ≤ a su `stock_minimo`.
- [ ] **Resumen Financiero sin selector (usuario normal):** `/reportes` → Ganancias → Resumen Financiero. El selector de sucursal NO aparece (usuario sin permiso 80). Las cards muestran datos del mes actual.
- [ ] **Resumen Financiero con selector (admin):** Como admin, el selector "Todas las sucursales / Sucursal X" aparece. Aplicar con fechas diferentes — las cifras cambian.
- [ ] **Top Productos:** Toggle Unidades/Ingresos cambia las barras del gráfico. El título dice "Top 10".
- [ ] **Comparativo Sucursales:** La tabla muestra columna "Ganancia Bruta (Bs)" con color verde/rojo según valor.
