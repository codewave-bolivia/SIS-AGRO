import { useState, useEffect } from 'react';
import ventaService from '../../../services/venta.service';

export default function DetalleVentaModal({ ventaId, onClose }) {
  const [venta, setVenta] = useState(null);
  const [cargando, setCargando] = useState(true);

  useEffect(() => {
    if (ventaId) {
      cargarDetalle();
    }
  }, [ventaId]);

  const cargarDetalle = async () => {
    setCargando(true);
    try {
      const res = await ventaService.obtener(ventaId);
      setVenta(res.data);
    } catch (err) {
      console.error(err);
    } finally {
      setCargando(false);
    }
  };

  if (cargando) {
    return (
      <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm">
        <div className="bg-white dark:bg-zinc-900 rounded-2xl p-8 flex items-center justify-center">
          <p className="text-zinc-500">Generando comprobante...</p>
        </div>
      </div>
    );
  }

  if (!venta) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm">
      <div className="bg-white dark:bg-zinc-900 rounded-2xl shadow-xl border border-zinc-200 dark:border-zinc-800 w-full max-w-2xl overflow-hidden flex flex-col max-h-[90vh]">
        
        {/* Recibo Header */}
        <div className="px-6 py-6 border-b border-zinc-200 dark:border-zinc-800 text-center relative shrink-0">
          <button onClick={onClose} className="absolute right-4 top-4 text-zinc-400 hover:text-zinc-600 dark:hover:text-zinc-300">
            <svg className="w-6 h-6" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
          <h2 className="text-xl font-bold text-zinc-900 dark:text-white uppercase tracking-widest">SIS-AGRO</h2>
          <p className="text-sm text-zinc-500 dark:text-zinc-400">Comprobante de Venta</p>
          <p className="text-sm font-mono mt-2 bg-zinc-100 dark:bg-zinc-800 inline-block px-3 py-1 rounded">
            Nº {venta.id_venta.toString().padStart(5, '0')}
          </p>
        </div>

        {/* Recibo Body */}
        <div className="p-6 overflow-y-auto font-mono text-sm">
          <div className="flex justify-between mb-2">
            <span className="text-zinc-500">Fecha:</span>
            <span className="text-zinc-900 dark:text-zinc-100">{new Date(venta.fecha_venta).toLocaleString()}</span>
          </div>
          <div className="flex justify-between mb-2">
            <span className="text-zinc-500">Cajero:</span>
            <span className="text-zinc-900 dark:text-zinc-100">{venta.usuario_nombre} {venta.usuario_apellido}</span>
          </div>
          <div className="flex justify-between mb-2">
            <span className="text-zinc-500">Cliente:</span>
            <span className="text-zinc-900 dark:text-zinc-100">{venta.cliente_nombre ? `${venta.cliente_nombre} ${venta.cliente_apellido || ''}` : 'Consumidor Final'}</span>
          </div>
          {venta.ci_nit && (
            <div className="flex justify-between mb-2">
              <span className="text-zinc-500">CI/NIT:</span>
              <span className="text-zinc-900 dark:text-zinc-100">{venta.ci_nit}</span>
            </div>
          )}
          <div className="flex justify-between mb-6">
            <span className="text-zinc-500">Tipo Venta:</span>
            <span className="text-zinc-900 dark:text-zinc-100">{venta.tipo_venta === 'MAYOR' ? 'Por Mayor' : 'Por Menor'}</span>
          </div>

          <div className="border-t border-b border-dashed border-zinc-300 dark:border-zinc-700 py-4 mb-4">
            <table className="w-full">
              <thead>
                <tr className="text-zinc-500 text-left">
                  <th className="font-normal pb-2 w-1/2">Cant / Prod</th>
                  <th className="font-normal pb-2 text-right">P.U.</th>
                  <th className="font-normal pb-2 text-right">SubT</th>
                </tr>
              </thead>
              <tbody>
                {venta.detalles && venta.detalles.map((d) => (
                  <tr key={d.id_detalle_venta}>
                    <td className="py-2 pr-2 text-zinc-900 dark:text-zinc-100 break-words">
                      {d.cantidad} {d.tipo_cantidad === 'CAJA' ? 'cj' : 'un'} x {d.producto_nombre}
                      <br/>
                      <span className="text-[10px] text-zinc-400">Lote: {d.numero_lote || 'S/N'}</span>
                    </td>
                    <td className="py-2 text-right align-top text-zinc-900 dark:text-zinc-100">{parseFloat(d.precio_unitario).toFixed(2)}</td>
                    <td className="py-2 text-right align-top text-zinc-900 dark:text-zinc-100">{parseFloat(d.subtotal).toFixed(2)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div className="flex justify-end mb-1">
            <div className="w-1/2 flex justify-between text-zinc-500">
              <span>Subtotal:</span>
              <span>{parseFloat(venta.subtotal).toFixed(2)}</span>
            </div>
          </div>
          <div className="flex justify-end mb-2">
            <div className="w-1/2 flex justify-between text-zinc-500">
              <span>Descuento:</span>
              <span>- {parseFloat(venta.descuento_total).toFixed(2)}</span>
            </div>
          </div>
          <div className="flex justify-end mb-4">
            <div className="w-1/2 flex justify-between text-lg font-bold text-zinc-900 dark:text-white border-t border-zinc-200 dark:border-zinc-800 pt-2">
              <span>TOTAL Bs:</span>
              <span>{parseFloat(venta.total).toFixed(2)}</span>
            </div>
          </div>

          <div className="text-xs text-zinc-500 flex justify-between mt-6">
            <span>Método: {venta.metodo_pago}</span>
            <div className="text-right">
              <p>Pagado: {parseFloat(venta.monto_pagado).toFixed(2)}</p>
              <p>Cambio: {parseFloat(venta.cambio).toFixed(2)}</p>
            </div>
          </div>

          {venta.estado === 'ANULADA' && (
            <div className="mt-6 p-2 bg-red-100 text-red-700 text-center font-bold tracking-widest border-2 border-red-500 border-dashed transform -rotate-2">
              *** ANULADA ***
            </div>
          )}

        </div>

        {/* Footer */}
        <div className="px-6 py-4 bg-zinc-50 dark:bg-zinc-800/50 border-t border-zinc-200 dark:border-zinc-800 flex justify-center gap-4 shrink-0">
          <button
            onClick={() => window.print()}
            className="px-4 py-2 text-sm font-medium text-zinc-700 bg-white border border-zinc-300 hover:bg-zinc-50 dark:bg-zinc-800 dark:border-zinc-700 dark:text-zinc-300 dark:hover:bg-zinc-700 rounded-xl transition-colors flex items-center gap-2"
          >
            <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z" />
            </svg>
            Imprimir
          </button>
          <button
            onClick={onClose}
            className="px-4 py-2 text-sm font-medium text-white bg-zinc-800 hover:bg-zinc-700 rounded-xl transition-colors"
          >
            Cerrar
          </button>
        </div>
      </div>
    </div>
  );
}
