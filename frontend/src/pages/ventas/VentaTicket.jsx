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
                maxHeight: '140px',
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
