# Phase 6 — Reportes y Estadísticas: Design Spec

**Fecha:** 2026-05-27  
**Rama de trabajo:** main (sin commits hasta que el usuario lo haga)

---

## Objetivo

Completar e integrar el módulo de reportes del ERP SIS-AGRO. La mayoría del código ya existe en el working tree como código no commiteado. Esta fase consiste en **corregir 5 bugs conocidos** y **añadir el selector de sucursal** en los reportes de resumen financiero y top productos.

## Arquitectura

El módulo usa arquitectura de 3 capas:
1. **Backend:** `reportes.Controller.js` → SQL con MariaDB, retorna `{ data: [], resumen: {} }`
2. **Servicio:** `reporte.service.js` → Axios calls a `/api/reportes/*`
3. **Frontend:** `LayoutReportes.jsx` (tabs) → 6 vistas → `FiltrosAvanzados` + `TablaReporte` + `BotonesExportar`

**Tech Stack:** Node/Express, MariaDB, React 19, Recharts 3, jsPDF 4 + autotable, xlsx 0.18, Tailwind CSS 4.

---

## Estructura del módulo (existente, sin cambios)

```
frontend/src/pages/reportes/
  LayoutReportes.jsx             — tabs: Ganancias, Ventas, Compras, Inventario, Sucursales, Caja
  vistas/
    VistaGanancias.jsx           — Resumen financiero, Top productos, Ganancias por producto
    VistaVentas.jsx              — Diarias, Rango, Vendedor, Producto, Cliente
    VistaCompras.jsx             — Generales, Por proveedor
    VistaInventario.jsx          — Actual, Valorizado, Stock bajo, Vencimientos, Kardex
    VistaSucursales.jsx          — Traslados, Comparativo sucursales
    VistaCaja.jsx                — Arqueos de caja
  components/
    FiltrosAvanzados.jsx         — Filtros: fechas, cliente, producto, vendedor, proveedor, sucursal (nuevo)
    TablaReporte.jsx             — Tabla genérica con render/align
    BotonesExportar.jsx          — PDF (jsPDF) + Excel (xlsx)
backend/
  controllers/reportes.Controller.js
  routes/reportes.Routes.js
frontend/src/services/reporte.service.js
```

---

## Cambios requeridos (5 fixes + 1 nueva feature)

### Fix 1: stock_bajo — usar stock_minimo del producto

**Archivo:** `backend/controllers/reportes.Controller.js`  
**Función:** `obtenerReporteInventario`, case `'stock_bajo'`

**Problema:** Usa `HAVING stock_total_unidades <= 10` hardcodeado.  
**Fix:** Usar `p.stock_minimo` de la tabla `producto`.

```sql
-- ANTES:
SELECT p.id_producto, p.nombre, p.codigo_barras, SUM(l.stock_unidades) as stock_total_unidades
FROM lote l
JOIN producto p ON l.id_producto = p.id_producto
WHERE l.id_sucursal = ? AND l.activo = 1
GROUP BY p.id_producto, p.nombre, p.codigo_barras
HAVING stock_total_unidades <= 10
ORDER BY stock_total_unidades ASC

-- DESPUÉS:
SELECT p.id_producto, p.nombre, p.codigo_barras, p.stock_minimo,
       SUM(l.stock_unidades) as stock_total_unidades
FROM lote l
JOIN producto p ON l.id_producto = p.id_producto
WHERE l.id_sucursal = ? AND l.activo = 1
GROUP BY p.id_producto, p.nombre, p.codigo_barras, p.stock_minimo
HAVING stock_total_unidades <= p.stock_minimo
ORDER BY stock_total_unidades ASC
```

La columna `stock_minimo` también se devuelve al frontend para mostrarla en la tabla.

**Frontend:** `VistaInventario.jsx` — añadir columna `stock_minimo` en las columnas del case `'stock_bajo'`:
```jsx
{ key: 'stock_minimo', header: 'Mínimo', align: 'center' }
```

---

### Fix 2: obtenerResumenFinanciero — filtro por sucursal + fechas

**Archivo:** `backend/controllers/reportes.Controller.js`  
**Función:** `obtenerResumenFinanciero`

**Problema:** No filtra por `id_sucursal`. Muestra datos globales de todas las sucursales.  
**Fix:** Leer `id_sucursal` del query param (selector) o usar `req.user.id_sucursal` como fallback.

```js
const obtenerResumenFinanciero = async (req, res) => {
  const { fechaInicio, fechaFin } = req.query;
  // id_sucursal del query param (selector admin) o del usuario autenticado
  const sucursalId = req.query.id_sucursal || req.user?.id_sucursal;

  try {
    // Usar queries parametrizadas para evitar SQL injection
    let ventaFechaClause = '';
    let ventaFechaParams = [];
    let compraFechaClause = '';
    let compraFechaParams = [];

    if (fechaInicio && fechaFin) {
      ventaFechaClause = 'AND DATE(fecha_venta) BETWEEN ? AND ?';
      ventaFechaParams = [fechaInicio, fechaFin];
      compraFechaClause = 'AND DATE(fecha_compra) BETWEEN ? AND ?';
      compraFechaParams = [fechaInicio, fechaFin];
    } else {
      ventaFechaClause = 'AND MONTH(fecha_venta) = MONTH(CURDATE()) AND YEAR(fecha_venta) = YEAR(CURDATE())';
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
      ingresos_mes: ventasRows[0].total_ventas,
      egresos_mes: comprasRows[0].total_compras,
      utilidad_bruta_mes: ventasRows[0].total_ventas - comprasRows[0].total_compras,
      ventas_hoy_cantidad: ventasHoyRows[0].cantidad_ventas_hoy,
      ingresos_hoy: ventasHoyRows[0].ingresos_hoy
    });
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
};
```

**Nota de seguridad:** Si el usuario NO tiene permiso `ventas.ver_todas_sucursales`, el backend ignora el `id_sucursal` del query y siempre usa `req.user.id_sucursal`. La verificación de este permiso se delega al middleware (el endpoint ya tiene `checkPermission`); para el selector en frontend, solo se muestra si el usuario tiene dicho permiso.

---

### Fix 3: obtenerTopProductos — filtro por sucursal + ordenar por ingresos

**Archivo:** `backend/controllers/reportes.Controller.js`  
**Función:** `obtenerTopProductos`

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

Cambios vs original: filtra por sucursal, mantiene límite en 10 (frontend actualiza label de "Top 5" a "Top 10"), soporta `ordenar_por=ingresos`.

**Frontend:** `VistaGanancias.jsx` — en el tab `top_productos`, pasar `ordenar_por` como parámetro y agregar un toggle Unidades/Ingresos.

---

### Fix 4: obtenerReporteComparativoSucursales — agregar ganancia bruta

**Archivo:** `backend/controllers/reportes.Controller.js`  
**Función:** `obtenerReporteComparativoSucursales`

Agregar columna `ganancia_bruta` calculada como `total_ingresos - SUM(costo)`:

```sql
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
```

**Frontend:** `VistaSucursales.jsx` — añadir columna `ganancia_bruta` a `columnasComparativo`:
```jsx
{ key: 'ganancia_bruta', header: 'Ganancia Bruta (Bs)', align: 'right',
  render: v => <span className={parseFloat(v) >= 0 ? 'text-emerald-600 font-bold' : 'text-red-600 font-bold'}>{parseFloat(v).toFixed(2)}</span>,
  excelValue: r => parseFloat(r.ganancia_bruta) }
```

---

### Fix 5: FiltrosAvanzados — añadir selector de sucursal

**Archivo:** `frontend/src/pages/reportes/components/FiltrosAvanzados.jsx`

Añadir opción `sucursales` al componente (igual que `clientes`, `productos`, etc.):
- Nuevo prop en `opciones`: `sucursales: false`  
- Nuevo array en `catalogos`: `sucursales: []`
- El select se muestra solo cuando `opciones.sucursales === true`
- Label: "Sucursal", name: `id_sucursal`, option text: `s.nombre`

**Quién carga el catálogo:** El componente padre (`VistaGanancias`) carga las sucursales al montar con `reporteService.catalogos.sucursales()`.

**Nuevo endpoint en servicio:**
```js
// reporte.service.js
catalogos: {
  ...existing,
  sucursales: () => api.get('/sucursales')   // ya existe este endpoint
}
```

**Quién muestra el selector:** Solo `VistaGanancias.jsx` — para los sub-tabs "Resumen Financiero" y "Top Productos". Controlado por el permiso `ventas.ver_todas_sucursales` del usuario actual usando `usePermission`.

---

### Fix 6: reporte.service.js — pasar params a financiero y topProductos

```js
financiero: (params) => api.get('/reportes/financiero', { params }),
topProductos: (params) => api.get('/reportes/top-productos', { params }),
```

---

## Permisos y seguridad

- El selector de sucursal en frontend se muestra solo si `puede('ver_todas_sucursales', 'ventas')`.
- En backend, si un usuario no tiene ese permiso pero intenta pasar `id_sucursal` diferente a la suya, el sistema usa `req.user.id_sucursal` de todas formas (el middleware ya valida la sesión).
- No se necesita un permiso nuevo — se reutiliza `ventas.ver_todas_sucursales` (permiso 80).

---

## Responsividad

Todos los componentes usan Tailwind con breakpoints:
- `FiltrosAvanzados`: grid responsive `grid-cols-1 sm:grid-cols-2 md:grid-cols-4 lg:grid-cols-5`
- `TablaReporte`: `overflow-x-auto` para scroll horizontal en móvil
- Gráficos Recharts: `ResponsiveContainer width="100%"`
- Cards KPI: `grid-cols-1 md:grid-cols-3`

No se requieren cambios de responsividad — ya está implementado.

---

## Exportación PDF y Excel

Ya implementado en `BotonesExportar.jsx`:
- **Excel**: `xlsx` → columnas mapeadas con `col.excelValue`
- **PDF**: `jsPDF` + `autoTable` → tabla estilizada en A4

Cada vista pasa sus propias columnas y título al componente.

---

## Archivos a modificar (resumen)

| Archivo | Tipo de cambio |
|---------|---------------|
| `backend/controllers/reportes.Controller.js` | Fixes #1, #2, #3, #4 |
| `frontend/src/services/reporte.service.js` | Fix #6 (params) + sucursales catalog |
| `frontend/src/pages/reportes/components/FiltrosAvanzados.jsx` | Fix #5 (selector sucursal) |
| `frontend/src/pages/reportes/vistas/VistaGanancias.jsx` | Selector sucursal + fechas en financiero + toggle ingresos/unidades en top |
| `frontend/src/pages/reportes/vistas/VistaInventario.jsx` | Columna stock_minimo en stock_bajo |
| `frontend/src/pages/reportes/vistas/VistaSucursales.jsx` | Columna ganancia_bruta en comparativo |

**Sin cambios:** LayoutReportes, VistaVentas, VistaCompras, VistaCaja, TablaReporte, BotonesExportar, app.js, sidebar, App.jsx.
