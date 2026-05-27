# Venta Ticket Page – Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reemplazar el `DetalleVentaModal` (portal + CSS inyectado) por una página dedicada `/ventas/:id/ticket` que muestra el comprobante con inline styles, previsualización 80mm en pantalla y CSS de impresión simple.

**Architecture:** Nueva página `VentaTicket.jsx` montada en ruta `/ventas/:id/ticket` sin sidebar (solo `ProtectedRoute`). Usa inline styles para el ticket y `@media print` con `visibility: hidden / visible` en lugar de portal+CSS inyectado. `NuevaVenta` y `HistorialVentas` navegan a esta ruta en vez de abrir el modal. `DetalleVentaModal.jsx` se elimina.

**Tech Stack:** React 18, React Router v6, Tailwind CSS (solo en barra de botones, no en el ticket), `ventaService.obtener(id)` (sin cambios en backend).

---

## File Map

| Acción | Archivo |
|---|---|
| **Crear** | `frontend/src/pages/ventas/VentaTicket.jsx` |
| **Modificar** | `frontend/src/App.jsx` — agregar ruta `/ventas/:id/ticket` |
| **Modificar** | `frontend/src/pages/ventas/NuevaVenta.jsx` — navegar a ticket en vez de modal |
| **Modificar** | `frontend/src/pages/ventas/HistorialVentas.jsx` — navegar a ticket en vez de modal |
| **Eliminar** | `frontend/src/pages/ventas/components/DetalleVentaModal.jsx` |

---

## Task 1: Crear `VentaTicket.jsx`

**Files:**
- Create: `frontend/src/pages/ventas/VentaTicket.jsx`

- [ ] **Step 1: Crear el archivo con el componente completo**

```jsx
import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import ventaService from '../../services/venta.service';

const fmt = (n) => Number(n ?? 0).toFixed(2);
const fmtFecha = (s) =>
  s
    ? new Date(s).toLocaleString('es-BO', {
        day: '2-digit', month: '2-digit', year: 'numeric',
        hour: '2-digit', minute: '2-digit',
      })
    : '—';

export default function VentaTicket() {
  const { id }               = useParams();
  const navigate             = useNavigate();
  const [venta, setVenta]    = useState(null);
  const [cargando, setCargando] = useState(true);

  useEffect(() => {
    ventaService
      .obtener(id)
      .then((r) => setVenta(r.data))
      .catch(() => navigate('/ventas'))
      .finally(() => setCargando(false));
  }, [id]); // eslint-disable-line

  if (cargando)
    return (
      <div className="flex items-center justify-center py-32 text-zinc-400">
        Cargando…
      </div>
    );
  if (!venta) return null;

  const clienteNombre = venta.cliente_nombre
    ? `${venta.cliente_nombre} ${venta.cliente_apellido || ''}`.trim()
    : 'Consumidor Final';

  /* ── estilos reutilizables ── */
  const row = {
    display: 'flex',
    justifyContent: 'space-between',
    marginBottom: '2px',
  };
  const sep = {
    borderTop: '1px dashed #000',
    margin: '4px 0',
  };

  return (
    <>
      {/* ── Barra de botones (se oculta al imprimir) ── */}
      <div className="no-print flex gap-3 p-4 border-b border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-900">
        <button
          onClick={() => window.print()}
          className="px-5 py-2 rounded-xl bg-green-600 hover:bg-green-700 text-white font-semibold text-sm transition-colors flex items-center gap-2"
        >
          🖨️ Imprimir (80mm)
        </button>
        <button
          onClick={() => navigate(-1)}
          className="px-5 py-2 rounded-xl border border-zinc-300 dark:border-zinc-600 text-zinc-700 dark:text-zinc-300 hover:bg-zinc-50 dark:hover:bg-zinc-800 font-semibold text-sm transition-colors"
        >
          ← Volver
        </button>
      </div>

      {/* ── Preview en pantalla ── */}
      <div className="flex justify-center p-6 bg-zinc-100 dark:bg-zinc-950 min-h-screen">
        <div
          id="ticket"
          style={{
            width: '80mm',
            fontFamily: "'Courier New', Courier, monospace",
            fontSize: '11px',
            lineHeight: '1.4',
            background: 'white',
            color: '#000',
            padding: '4mm',
          }}
        >
          {/* Cabecera empresa */}
          <div style={{ textAlign: 'center', marginBottom: '4px' }}>
            <img
              src="/logo.png"
              alt="Logo SIS-AGRO"
              style={{
                maxHeight: '60px',
                maxWidth: '100%',
                margin: '0 auto 4px',
                display: 'block',
                objectFit: 'contain',
              }}
              onError={(e) => { e.target.style.display = 'none'; }}
            />
            <div style={{ fontSize: '14px', fontWeight: 'bold' }}>SIS-AGRO</div>
            {venta.sucursal_nombre && <div>{venta.sucursal_nombre}</div>}
            {venta.sucursal_direccion && (
              <div style={{ fontSize: '10px' }}>
                {venta.sucursal_direccion}
                {venta.sucursal_ciudad ? `, ${venta.sucursal_ciudad}` : ''}
              </div>
            )}
            {venta.sucursal_telefono && <div>Tel: {venta.sucursal_telefono}</div>}
          </div>

          <div style={sep} />

          {/* Número y datos generales */}
          <div style={{ marginBottom: '4px' }}>
            <div style={{ ...row, fontWeight: 'bold' }}>
              <span>COMPROBANTE DE VENTA</span>
              <span>Nº {venta.id_venta.toString().padStart(6, '0')}</span>
            </div>
            <div style={row}>
              <span>Fecha:</span>
              <span>{fmtFecha(venta.fecha_venta)}</span>
            </div>
            <div style={row}>
              <span>Cajero:</span>
              <span>{venta.usuario_nombre} {venta.usuario_apellido}</span>
            </div>
            <div style={row}>
              <span>Tipo:</span>
              <span>{venta.tipo_venta === 'MAYOR' ? 'Por Mayor' : 'Por Menor'}</span>
            </div>
            {venta.nro_factura && (
              <div style={row}>
                <span>N° Factura:</span>
                <span>{venta.nro_factura}</span>
              </div>
            )}
          </div>

          <div style={sep} />

          {/* Cliente */}
          <div style={{ marginBottom: '4px' }}>
            <div style={{ fontWeight: 'bold' }}>CLIENTE</div>
            <div>{clienteNombre}</div>
            {venta.ci_nit && <div>CI/NIT: {venta.ci_nit}</div>}
          </div>

          <div style={sep} />

          {/* Detalle de productos */}
          <div style={{ marginBottom: '4px' }}>
            <div style={{ fontWeight: 'bold', marginBottom: '2px' }}>DETALLE</div>
            {(venta.detalles || []).map((d) => (
              <div key={d.id_detalle_venta} style={{ marginBottom: '4px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                  <span style={{ maxWidth: '55mm', wordBreak: 'break-word' }}>
                    {d.cantidad} {d.tipo_cantidad === 'CAJA' ? 'cj' : 'un'} — {d.producto_nombre}
                  </span>
                  <span style={{ fontWeight: 'bold', whiteSpace: 'nowrap' }}>
                    Bs {fmt(d.subtotal)}
                  </span>
                </div>
                <div style={{ fontSize: '10px', color: '#444', paddingLeft: '4px' }}>
                  P.U.: Bs {fmt(d.precio_unitario)}
                  {parseFloat(d.descuento_pct) > 0 && ` (-${d.descuento_pct}%)`}
                  {' · Lote: '}{d.numero_lote || 'S/N'}
                </div>
              </div>
            ))}
          </div>

          <div style={{ borderTop: '1.5px solid #000', margin: '4px 0' }} />

          {/* Totales */}
          <div style={{ marginBottom: '4px' }}>
            <div style={row}>
              <span>Subtotal Bs:</span>
              <span>{fmt(venta.subtotal)}</span>
            </div>
            {parseFloat(venta.descuento_total) > 0 && (
              <div style={row}>
                <span>Descuento Bs:</span>
                <span>- {fmt(venta.descuento_total)}</span>
              </div>
            )}
            <div style={{ ...row, fontWeight: 'bold', fontSize: '13px', marginTop: '2px' }}>
              <span>TOTAL Bs:</span>
              <span>{fmt(venta.total)}</span>
            </div>
          </div>

          <div style={sep} />

          {/* Pago */}
          <div style={{ marginBottom: '4px' }}>
            <div style={row}>
              <span>Método:</span>
              <span>{venta.metodo_pago}</span>
            </div>
            <div style={row}>
              <span>Pagado Bs:</span>
              <span>{fmt(venta.monto_pagado)}</span>
            </div>
            <div style={row}>
              <span>Cambio Bs:</span>
              <span>{fmt(venta.cambio)}</span>
            </div>
          </div>

          {/* Sello ANULADA */}
          {venta.estado === 'ANULADA' && (
            <>
              <div style={sep} />
              <div
                style={{
                  textAlign: 'center',
                  fontWeight: 'bold',
                  fontSize: '14px',
                  letterSpacing: '0.2em',
                  border: '3px dashed #000',
                  padding: '3mm',
                  marginTop: '4px',
                }}
              >
                *** ANULADA ***
              </div>
            </>
          )}

          <div style={sep} />

          {/* Pie */}
          <div style={{ textAlign: 'center', fontSize: '10px', marginTop: '4px' }}>
            <div>¡Gracias por su compra!</div>
            <div style={{ marginTop: '2px' }}>SIS-AGRO · Sistema Agropecuario</div>
          </div>
        </div>
      </div>

      {/* CSS de impresión */}
      <style>{`
        @media print {
          .no-print { display: none !important; }
          body * { visibility: hidden !important; }
          #ticket, #ticket * { visibility: visible !important; }
          #ticket {
            position: fixed !important;
            top: 0 !important;
            left: 0 !important;
            width: 72mm !important;
            margin: 0 !important;
            padding: 2mm !important;
            font-size: 11px !important;
            background: white !important;
            color: #000 !important;
          }
          @page { size: 80mm auto; margin: 0; }
        }
      `}</style>
    </>
  );
}
```

- [ ] **Step 2: Verificar que el archivo se creó correctamente**

Abrir `frontend/src/pages/ventas/VentaTicket.jsx` y confirmar que no hay errores de sintaxis visibles.

---

## Task 2: Registrar la ruta en `App.jsx`

**Files:**
- Modify: `frontend/src/App.jsx`

- [ ] **Step 1: Agregar el import de `VentaTicket`**

En `frontend/src/App.jsx`, después de la línea:
```js
import NuevaVenta     from './pages/ventas/NuevaVenta';
```
agregar:
```js
import VentaTicket    from './pages/ventas/VentaTicket';
```

- [ ] **Step 2: Agregar la ruta `/ventas/:id/ticket`**

Dentro del bloque `<Routes>`, inmediatamente después de la ruta `/ventas/nueva`, agregar:

```jsx
<Route path="/ventas/:id/ticket" element={
  <ProtectedRoute action="ver" subject="ventas">
    <VentaTicket />
  </ProtectedRoute>
}/>
```

> ⚠️ Esta ruta va **sin** `<AppLayout>` (sin sidebar) para que la impresión no se vea afectada por el layout.

- [ ] **Step 3: Verificar orden de rutas**

Confirmar que en el bloque de ventas el orden queda así (React Router hace match de arriba a abajo):
```
/ventas             → HistorialVentas
/ventas/nueva       → NuevaVenta
/ventas/:id/ticket  → VentaTicket   ← nueva
```

- [ ] **Step 4: Commit parcial**

```bash
git add frontend/src/pages/ventas/VentaTicket.jsx frontend/src/App.jsx
git commit -m "feat(ventas): agregar página dedicada /ventas/:id/ticket"
```

---

## Task 3: Actualizar `HistorialVentas.jsx`

**Files:**
- Modify: `frontend/src/pages/ventas/HistorialVentas.jsx`

- [ ] **Step 1: Eliminar el import del modal**

Quitar la línea:
```js
import DetalleVentaModal from './components/DetalleVentaModal';
```

- [ ] **Step 2: Eliminar el estado `detalleId`**

Quitar la declaración:
```js
const [detalleId, setDetalleId] = useState(null);
```

(Si hay otros estados en la misma línea, quitar solo `detalleId`.)

- [ ] **Step 3: Cambiar el handler `onVerDetalle`**

Localizar:
```jsx
onVerDetalle={(v) => setDetalleId(v.id_venta)}
```
Reemplazar con:
```jsx
onVerDetalle={(v) => navigate(`/ventas/${v.id_venta}/ticket`)}
```

- [ ] **Step 4: Eliminar el bloque del modal**

Quitar el bloque completo:
```jsx
{detalleId && (
  <DetalleVentaModal
    ventaId={detalleId}
    onClose={() => setDetalleId(null)}
  />
)}
```

- [ ] **Step 5: Confirmar que `useNavigate` ya está importado**

En la línea de imports, verificar que existe:
```js
import { useNavigate } from 'react-router-dom';
```
Y que `navigate` está declarado en el cuerpo del componente:
```js
const navigate = useNavigate();
```
Ambas líneas ya existen — solo verificar, no duplicar.

- [ ] **Step 6: Commit**

```bash
git add frontend/src/pages/ventas/HistorialVentas.jsx
git commit -m "feat(ventas): historial navega a página ticket en vez de modal"
```

---

## Task 4: Actualizar `NuevaVenta.jsx`

**Files:**
- Modify: `frontend/src/pages/ventas/NuevaVenta.jsx`

- [ ] **Step 1: Eliminar el import del modal**

Quitar la línea:
```js
import DetalleVentaModal from './components/DetalleVentaModal';
```

- [ ] **Step 2: Localizar el estado `ventaCompletadaId`**

Identificar la línea que declara `ventaCompletadaId` (algo como):
```js
const [ventaCompletadaId, setVentaCompletadaId] = useState(null);
```
**No la elimines** — se sigue usando para saber que hay una venta completada; solo cambia lo que hace con ese valor.

- [ ] **Step 3: Reemplazar el bloque del modal por navegación**

Quitar el bloque:
```jsx
{ventaCompletadaId && (
  <DetalleVentaModal
    ventaId={ventaCompletadaId}
    onClose={() => {
      setVentaCompletadaId(null);
      navigate('/ventas');
    }}
  />
)}
```

Y en su lugar agregar un `useEffect` que navegue automáticamente cuando `ventaCompletadaId` cambia (colocar con los otros `useEffect` del componente):
```js
useEffect(() => {
  if (ventaCompletadaId) {
    navigate(`/ventas/${ventaCompletadaId}/ticket`);
  }
}, [ventaCompletadaId]); // eslint-disable-line
```

> Esto navega a la página ticket en cuanto la venta es completada, sin interrumpir el flujo con un modal.

- [ ] **Step 4: Confirmar que `useNavigate` ya está importado**

Verificar que en los imports ya existe `useNavigate` y que `navigate` está declarado. Ya existe — solo confirmar.

- [ ] **Step 5: Commit**

```bash
git add frontend/src/pages/ventas/NuevaVenta.jsx
git commit -m "feat(ventas): nueva venta navega a página ticket al completar"
```

---

## Task 5: Eliminar `DetalleVentaModal.jsx`

**Files:**
- Delete: `frontend/src/pages/ventas/components/DetalleVentaModal.jsx`

- [ ] **Step 1: Verificar que ya no hay ningún import del archivo**

```bash
grep -r "DetalleVentaModal" frontend/src/
```

Resultado esperado: sin resultados (vacío). Si aparece algún archivo, corregirlo antes de continuar.

- [ ] **Step 2: Eliminar el archivo**

```bash
rm frontend/src/pages/ventas/components/DetalleVentaModal.jsx
```

- [ ] **Step 3: Commit final**

```bash
git add -A
git commit -m "chore(ventas): eliminar DetalleVentaModal (reemplazado por VentaTicket)"
```

---

## Task 6: Verificación manual

- [ ] **Step 1: Arrancar el proyecto**

```bash
# Desde la raíz del proyecto
cd backend && node app.js &
cd frontend && npm run dev
```

- [ ] **Step 2: Verificar flujo desde HistorialVentas**

1. Ir a `/ventas`
2. Hacer clic en "Ver detalle" de cualquier venta
3. Esperado: navega a `/ventas/000001/ticket` (número padded)
4. El ticket se muestra en preview 80mm sobre fondo gris
5. La barra "Imprimir / Volver" está visible arriba
6. Clic en "Volver" regresa a `/ventas`

- [ ] **Step 3: Verificar flujo desde NuevaVenta**

1. Ir a `/ventas/nueva`
2. Completar y confirmar una venta
3. Esperado: navega automáticamente a `/ventas/:id/ticket`
4. El ticket muestra los datos correctos de la venta recién creada

- [ ] **Step 4: Verificar impresión**

1. En la página ticket, abrir diálogo de impresión (`Ctrl+P` o botón)
2. Esperado:
   - La barra de botones desaparece
   - Solo el ticket es visible
   - El ticket ocupa 80mm de ancho
   - `@page size: 80mm auto` aplica

- [ ] **Step 5: Verificar venta ANULADA**

1. Buscar una venta con `estado = 'ANULADA'` en historial
2. Ir a su ticket
3. Esperado: aparece el sello `*** ANULADA ***` al final del ticket

- [ ] **Step 6: Verificar logo**

1. Si existe `/logo.png` en `frontend/public/`, debe aparecer en el ticket
2. Si no existe, el `onError` lo oculta sin romper el layout
