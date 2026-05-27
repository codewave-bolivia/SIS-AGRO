import { useState, useEffect, useCallback } from 'react';
import PageWrapper from '../../components/PageWrapper';
import cajaService from '../../services/caja.service';
import { usePermission } from '../../hooks/usePermission';
import { ModalCaja, ModalAbrirTurno, ModalCerrarTurno } from './components/CajaModals';

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

const TABS = ['cajas', 'turnos'];
const TAB_LABELS = { cajas: 'Cajas', turnos: 'Historial de Turnos' };

function BadgeEstado({ activo }) {
  return activo
    ? <span className="px-2 py-0.5 rounded-full text-xs font-bold bg-emerald-100 dark:bg-emerald-900/40 text-emerald-700 dark:text-emerald-400">Activa</span>
    : <span className="px-2 py-0.5 rounded-full text-xs font-bold bg-zinc-100 dark:bg-zinc-800 text-zinc-500">Inactiva</span>;
}

function BadgeTurno({ estado }) {
  return estado === 'ABIERTA'
    ? <span className="px-2 py-0.5 rounded-full text-xs font-bold bg-green-100 dark:bg-green-900/40 text-green-700 dark:text-green-400">Abierta</span>
    : <span className="px-2 py-0.5 rounded-full text-xs font-bold bg-zinc-100 dark:bg-zinc-800 text-zinc-500">Cerrada</span>;
}

function fmt(n) { return parseFloat(n || 0).toFixed(2); }
function fmtFecha(d) { return d ? new Date(d).toLocaleString('es-BO') : '—'; }

export default function Caja() {
  const { puede } = usePermission();

  const [tab, setTab] = useState('cajas');
  const [cajas, setCajas] = useState([]);
  const [turnos, setTurnos] = useState([]);
  const [turnoActivo, setTurnoActivo] = useState(null);
  const [cargandoCajas, setCargandoCajas] = useState(true);
  const [cargandoTurnos, setCargandoTurnos] = useState(false);
  const [guardando, setGuardando] = useState(false);
  const [toast, setToast] = useState(null);
  const [modal, setModal] = useState(null); // 'nuevaCaja' | 'editarCaja' | 'abrirTurno' | 'cerrarTurno'
  const [cajaActiva, setCajaActiva] = useState(null);

  const mostrarToast = (tipo, msg) => {
    setToast({ tipo, msg });
    setTimeout(() => setToast(null), 3500);
  };

  const cargarCajas = useCallback(async () => {
    setCargandoCajas(true);
    try {
      const res = await cajaService.listarCajas();
      setCajas(res.data);
    } catch {
      mostrarToast('error', 'Error al cargar cajas');
    } finally {
      setCargandoCajas(false);
    }
  }, []);

  const cargarTurnoActivo = useCallback(async () => {
    try {
      const res = await cajaService.obtenerTurnoActivo();
      setTurnoActivo(res.data);
    } catch {
      setTurnoActivo(null);
    }
  }, []);

  const cargarTurnos = useCallback(async () => {
    setCargandoTurnos(true);
    try {
      const res = await cajaService.listarTurnos();
      setTurnos(res.data);
    } catch {
      mostrarToast('error', 'Error al cargar historial de turnos');
    } finally {
      setCargandoTurnos(false);
    }
  }, []);

  useEffect(() => {
    cargarCajas();
    cargarTurnoActivo();
  }, [cargarCajas, cargarTurnoActivo]);

  useEffect(() => {
    if (tab === 'turnos') cargarTurnos();
  }, [tab, cargarTurnos]);

  // ── Handlers cajas ──────────────────────────────────────────────────────────
  const handleGuardarCaja = async (form) => {
    setGuardando(true);
    try {
      if (cajaActiva) {
        await cajaService.editarCaja(cajaActiva.id_caja, form);
        mostrarToast('ok', 'Caja actualizada');
      } else {
        await cajaService.crearCaja(form);
        mostrarToast('ok', 'Caja creada');
      }
      setModal(null);
      await cargarCajas();
    } catch (err) {
      mostrarToast('error', err.response?.data?.error || 'Error al guardar caja');
    } finally {
      setGuardando(false);
    }
  };

  const handleToggleCaja = async (caja) => {
    try {
      await cajaService.toggleCaja(caja.id_caja);
      mostrarToast('ok', `Caja ${caja.activo ? 'desactivada' : 'activada'}`);
      await cargarCajas();
    } catch (err) {
      mostrarToast('error', err.response?.data?.error || 'Error al cambiar estado');
    }
  };

  // ── Handlers turnos ─────────────────────────────────────────────────────────
  const handleAbrirTurno = async (form) => {
    setGuardando(true);
    try {
      await cajaService.abrirCaja(form);
      mostrarToast('ok', 'Turno abierto correctamente');
      setModal(null);
      await cargarTurnoActivo();
    } catch (err) {
      mostrarToast('error', err.response?.data?.error || 'Error al abrir turno');
    } finally {
      setGuardando(false);
    }
  };

  const handleCerrarTurno = async (id, form) => {
    setGuardando(true);
    try {
      const res = await cajaService.cerrarCaja(id, form);
      const d = res.data;
      mostrarToast('ok', `Turno cerrado. Esperado: Bs ${fmt(d.monto_esperado)} | Contado: Bs ${fmt(d.monto_final)} | Dif: Bs ${fmt(d.diferencia)}`);
      setModal(null);
      await Promise.all([cargarTurnoActivo(), tab === 'turnos' ? cargarTurnos() : Promise.resolve()]);
    } catch (err) {
      mostrarToast('error', err.response?.data?.error || 'Error al cerrar turno');
    } finally {
      setGuardando(false);
    }
  };

  const diferenciaBadge = (dif) => {
    const n = parseFloat(dif || 0);
    if (n === 0) return <span className="text-zinc-500">Bs 0.00</span>;
    if (n > 0) return <span className="text-green-600 font-bold">+Bs {fmt(n)}</span>;
    return <span className="text-red-500 font-bold">-Bs {fmt(Math.abs(n))}</span>;
  };

  return (
    <PageWrapper>
      <Toast toast={toast} />

      {/* Header */}
      <div className="mb-6 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-xl font-bold text-zinc-900 dark:text-white flex items-center gap-2">
            🏧 Módulo de Caja
          </h1>
          <p className="text-sm text-zinc-500 dark:text-zinc-400 mt-1">
            Gestión de cajas físicas, apertura y cierre de turnos.
          </p>
        </div>
      </div>

      {/* Turno activo banner */}
      {turnoActivo ? (
        <div className="mb-6 p-4 bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-2xl flex flex-col sm:flex-row sm:items-center justify-between gap-3">
          <div>
            <div className="flex items-center gap-2 mb-1">
              <span className="w-2 h-2 rounded-full bg-green-500 animate-pulse inline-block" />
              <span className="font-bold text-green-800 dark:text-green-300">Turno ABIERTO — {turnoActivo.caja_nombre}</span>
            </div>
            <p className="text-sm text-green-700 dark:text-green-400">
              Cajero: {turnoActivo.usuario_nombre} {turnoActivo.usuario_apellido} &nbsp;|&nbsp;
              Apertura: {fmtFecha(turnoActivo.fecha_apertura)} &nbsp;|&nbsp;
              Monto inicial: Bs {fmt(turnoActivo.monto_inicial)}
            </p>
          </div>
          {puede('cerrar', 'caja') && (
            <button
              onClick={() => setModal('cerrarTurno')}
              className="px-4 py-2 bg-red-600 hover:bg-red-500 text-white rounded-xl text-sm font-medium shrink-0"
            >
              Cerrar Turno
            </button>
          )}
        </div>
      ) : (
        <div className="mb-6 p-4 bg-zinc-50 dark:bg-zinc-800/50 border border-zinc-200 dark:border-zinc-700 rounded-2xl flex flex-col sm:flex-row sm:items-center justify-between gap-3">
          <div>
            <p className="font-medium text-zinc-700 dark:text-zinc-300">Sin turno activo</p>
            <p className="text-sm text-zinc-500">Abra un turno de caja para registrar ventas en esta sucursal.</p>
          </div>
          {puede('abrir', 'caja') && (
            <button
              onClick={() => setModal('abrirTurno')}
              className="px-4 py-2 bg-emerald-600 hover:bg-emerald-500 text-white rounded-xl text-sm font-medium shrink-0"
            >
              Abrir Turno
            </button>
          )}
        </div>
      )}

      {/* Tabs */}
      <div className="flex gap-1 mb-6 p-1 bg-zinc-100 dark:bg-zinc-800 rounded-xl w-fit">
        {TABS.map(t => (
          <button
            key={t}
            onClick={() => setTab(t)}
            className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
              tab === t
                ? 'bg-white dark:bg-zinc-900 text-zinc-900 dark:text-white shadow-sm'
                : 'text-zinc-500 dark:text-zinc-400 hover:text-zinc-700 dark:hover:text-zinc-200'
            }`}
          >
            {TAB_LABELS[t]}
          </button>
        ))}
      </div>

      {/* Tab: Cajas */}
      {tab === 'cajas' && (
        <div>
          <div className="flex justify-end mb-4">
            {puede('crear', 'caja') && (
              <button
                onClick={() => { setCajaActiva(null); setModal('nuevaCaja'); }}
                className="bg-emerald-600 hover:bg-emerald-500 text-white px-4 py-2 rounded-xl text-sm font-medium shadow-sm flex items-center gap-2"
              >
                <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M12 4v16m8-8H4"/></svg>
                Nueva Caja
              </button>
            )}
          </div>

          {cargandoCajas ? (
            <div className="text-center py-12 text-zinc-400">Cargando cajas...</div>
          ) : cajas.length === 0 ? (
            <div className="text-center py-12 text-zinc-400">No hay cajas registradas.</div>
          ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
              {cajas.map(c => (
                <div key={c.id_caja} className="bg-white dark:bg-zinc-900 rounded-2xl border border-zinc-200 dark:border-zinc-800 p-4 shadow-sm">
                  <div className="flex items-start justify-between mb-2">
                    <div>
                      <h3 className="font-bold text-zinc-900 dark:text-white">{c.nombre}</h3>
                      <p className="text-xs text-zinc-500">{c.sucursal_nombre}</p>
                    </div>
                    <BadgeEstado activo={c.activo} />
                  </div>
                  {c.descripcion && (
                    <p className="text-sm text-zinc-500 mb-3">{c.descripcion}</p>
                  )}
                  <div className="flex gap-2 mt-3 pt-3 border-t border-zinc-100 dark:border-zinc-800">
                    {puede('editar', 'caja') && (
                      <button
                        onClick={() => { setCajaActiva(c); setModal('nuevaCaja'); }}
                        className="flex-1 py-1.5 text-xs border border-zinc-200 dark:border-zinc-700 rounded-lg hover:bg-zinc-50 dark:hover:bg-zinc-800 transition-colors"
                      >
                        Editar
                      </button>
                    )}
                    {puede('activar', 'caja') && (
                      <button
                        onClick={() => handleToggleCaja(c)}
                        className={`flex-1 py-1.5 text-xs rounded-lg transition-colors ${
                          c.activo
                            ? 'border border-red-200 text-red-600 hover:bg-red-50 dark:border-red-800 dark:text-red-400 dark:hover:bg-red-900/20'
                            : 'border border-emerald-200 text-emerald-600 hover:bg-emerald-50 dark:border-emerald-800 dark:text-emerald-400 dark:hover:bg-emerald-900/20'
                        }`}
                      >
                        {c.activo ? 'Desactivar' : 'Activar'}
                      </button>
                    )}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      {/* Tab: Turnos */}
      {tab === 'turnos' && (
        <div>
          {cargandoTurnos ? (
            <div className="text-center py-12 text-zinc-400">Cargando historial...</div>
          ) : turnos.length === 0 ? (
            <div className="text-center py-12 text-zinc-400">No hay turnos registrados.</div>
          ) : (
            <div className="overflow-x-auto rounded-2xl border border-zinc-200 dark:border-zinc-800">
              <table className="w-full text-sm">
                <thead className="bg-zinc-50 dark:bg-zinc-800 text-zinc-500 text-xs uppercase tracking-wide">
                  <tr>
                    <th className="text-left px-4 py-3">Caja / Sucursal</th>
                    <th className="text-left px-4 py-3">Cajero</th>
                    <th className="text-left px-4 py-3">Apertura</th>
                    <th className="text-left px-4 py-3">Cierre</th>
                    <th className="text-right px-4 py-3">Inicial</th>
                    <th className="text-right px-4 py-3">Esperado</th>
                    <th className="text-right px-4 py-3">Contado</th>
                    <th className="text-right px-4 py-3">Diferencia</th>
                    <th className="text-center px-4 py-3">Estado</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-zinc-100 dark:divide-zinc-800">
                  {turnos.map(t => (
                    <tr key={t.id_apertura} className="bg-white dark:bg-zinc-900 hover:bg-zinc-50 dark:hover:bg-zinc-800/50 transition-colors">
                      <td className="px-4 py-3">
                        <p className="font-medium text-zinc-900 dark:text-white">{t.caja_nombre}</p>
                        <p className="text-xs text-zinc-400">{t.sucursal_nombre}</p>
                      </td>
                      <td className="px-4 py-3 text-zinc-700 dark:text-zinc-300">{t.usuario_nombre} {t.usuario_apellido}</td>
                      <td className="px-4 py-3 text-zinc-600 dark:text-zinc-400 whitespace-nowrap">{fmtFecha(t.fecha_apertura)}</td>
                      <td className="px-4 py-3 text-zinc-600 dark:text-zinc-400 whitespace-nowrap">{fmtFecha(t.fecha_cierre)}</td>
                      <td className="px-4 py-3 text-right font-mono">Bs {fmt(t.monto_inicial)}</td>
                      <td className="px-4 py-3 text-right font-mono">{t.monto_esperado != null ? `Bs ${fmt(t.monto_esperado)}` : '—'}</td>
                      <td className="px-4 py-3 text-right font-mono">{t.monto_final != null ? `Bs ${fmt(t.monto_final)}` : '—'}</td>
                      <td className="px-4 py-3 text-right font-mono">{t.diferencia != null ? diferenciaBadge(t.diferencia) : '—'}</td>
                      <td className="px-4 py-3 text-center"><BadgeTurno estado={t.estado} /></td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      )}

      {/* Modales */}
      {(modal === 'nuevaCaja') && (
        <ModalCaja
          caja={cajaActiva}
          onConfirm={handleGuardarCaja}
          onClose={() => setModal(null)}
          guardando={guardando}
        />
      )}

      {modal === 'abrirTurno' && (
        <ModalAbrirTurno
          cajas={cajas}
          onConfirm={handleAbrirTurno}
          onClose={() => setModal(null)}
          guardando={guardando}
        />
      )}

      {modal === 'cerrarTurno' && turnoActivo && (
        <ModalCerrarTurno
          turno={turnoActivo}
          onConfirm={handleCerrarTurno}
          onClose={() => setModal(null)}
          guardando={guardando}
        />
      )}
    </PageWrapper>
  );
}
