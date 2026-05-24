import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import PageWrapper from '../../components/PageWrapper';
import TablaVentas from './components/TablaVentas';
import DetalleVentaModal from './components/DetalleVentaModal';
import ventaService from '../../services/venta.service';
import { usePermission } from '../../hooks/usePermission';

function Toast({ toast }) {
  if (!toast) return null;
  return (
    <div className={`fixed bottom-5 right-5 z-50 flex items-center gap-3 px-4 py-3 rounded-xl shadow-xl border text-sm font-medium transition-all duration-300 max-w-xs sm:max-w-sm ${
      toast.tipo === 'ok'
        ? 'bg-green-50 dark:bg-green-900/40 border-green-200 dark:border-green-700 text-green-800 dark:text-green-300'
        : 'bg-red-50 dark:bg-red-900/40 border-red-200 dark:border-red-700 text-red-800 dark:text-red-300'
    }`}>
      <span className="shrink-0">{toast.tipo === 'ok' ? '✅' : '⚠️'}</span>
      <span className="break-words">{toast.msg}</span>
    </div>
  );
}

export default function HistorialVentas() {
  const { puede } = usePermission();
  const navigate = useNavigate();

  const [ventas, setVentas] = useState([]);
  const [cargando, setCargando] = useState(true);
  const [toast, setToast] = useState(null);

  const [detalleId, setDetalleId] = useState(null);

  const mostrarToast = (tipo, msg) => {
    setToast({ tipo, msg });
    setTimeout(() => setToast(null), 3500);
  };

  const cargarDatos = useCallback(async () => {
    setCargando(true);
    try {
      const res = await ventaService.listar();
      setVentas(res.data);
    } catch (err) {
      mostrarToast('error', 'Error al cargar el historial de ventas');
    } finally {
      setCargando(false);
    }
  }, []);

  useEffect(() => {
    cargarDatos();
  }, [cargarDatos]);

  const handleVerDetalle = (venta) => {
    setDetalleId(venta.id_venta);
  };

  const handleAnular = async (venta) => {
    if (!window.confirm(`¿Estás seguro de ANULAR la venta #${venta.id_venta}?\nEsta acción devolverá los productos al inventario y no se puede deshacer.`)) {
      return;
    }
    
    try {
      await ventaService.anular(venta.id_venta);
      mostrarToast('ok', 'Venta anulada. Stock retornado al inventario.');
      await cargarDatos();
    } catch (err) {
      mostrarToast('error', err.response?.data?.error || 'Error al anular la venta');
    }
  };

  return (
    <PageWrapper>
      <Toast toast={toast} />

      <div className="mb-6 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-xl font-bold text-zinc-900 dark:text-white flex items-center gap-2">
            🧾 Registro de Ventas
          </h1>
          <p className="text-sm text-zinc-500 dark:text-zinc-400 mt-1">
            Historial de todas las transacciones realizadas.
          </p>
        </div>
        {puede('crear', 'ventas') && (
          <button
            onClick={() => navigate('/ventas/nueva')}
            className="bg-emerald-600 hover:bg-emerald-500 text-white px-4 py-2 rounded-xl text-sm font-medium shadow-sm transition-colors flex items-center gap-2"
          >
            <svg className="w-5 h-5" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" />
            </svg>
            Punto de Venta (POS)
          </button>
        )}
      </div>

      <TablaVentas
        ventas={ventas}
        cargando={cargando}
        onVerDetalle={handleVerDetalle}
        onAnular={handleAnular}
      />

      {detalleId && (
        <DetalleVentaModal
          ventaId={detalleId}
          onClose={() => setDetalleId(null)}
        />
      )}

    </PageWrapper>
  );
}
