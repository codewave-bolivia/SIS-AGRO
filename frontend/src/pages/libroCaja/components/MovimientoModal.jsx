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
        fecha:         modal.datos.fecha ? String(modal.datos.fecha).split('T')[0] : hoy(),
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
