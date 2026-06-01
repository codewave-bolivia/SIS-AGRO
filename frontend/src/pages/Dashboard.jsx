import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth }       from '../contexts/AuthContext';
import { usePermission } from '../hooks/usePermission';
import reporteService    from '../services/reporte.service';
import PageWrapper       from '../components/PageWrapper';

// ── Helpers ─────────────────────────────────────────────────────────────────
const fmtBs  = (n) =>
  new Intl.NumberFormat('es-BO', { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(parseFloat(n || 0));
const fmtInt = (n) =>
  new Intl.NumberFormat('es-BO').format(parseInt(n || 0));

function saludoHora() {
  const h = new Date().getHours();
  if (h < 12) return 'Buenos días';
  if (h < 19) return 'Buenas tardes';
  return 'Buenas noches';
}

function fechaLarga() {
  return new Date().toLocaleDateString('es-BO', {
    weekday: 'long', year: 'numeric', month: 'long', day: 'numeric',
  });
}

// ── Skeleton ─────────────────────────────────────────────────────────────────
function Skel({ className = '' }) {
  return <div className={`animate-pulse bg-zinc-100 dark:bg-zinc-800 rounded-lg ${className}`} />;
}

// ── KPI Card ─────────────────────────────────────────────────────────────────
const KPI_COLORS = {
  emerald : 'bg-emerald-500',
  yellow  : 'bg-yellow-400',
  sky     : 'bg-sky-500',
  orange  : 'bg-orange-400',
  red     : 'bg-red-500',
  violet  : 'bg-violet-500',
};

function KpiCard({ label, value, prefix = '', icon, colorKey = 'emerald', cargando, sub }) {
  const bar = KPI_COLORS[colorKey] ?? KPI_COLORS.emerald;
  return (
    <div className="relative overflow-hidden rounded-2xl border
                    border-zinc-200 dark:border-zinc-800
                    bg-white dark:bg-zinc-900
                    shadow-sm hover:shadow-md transition-shadow duration-200 p-5">
      {/* color accent */}
      <div className={`absolute inset-x-0 top-0 h-1 ${bar}`} />

      <div className="flex items-start justify-between gap-3">
        <div className="flex-1 min-w-0">
          <p className="text-[11px] font-semibold uppercase tracking-widest
                        text-zinc-400 dark:text-zinc-500 mb-1.5">
            {label}
          </p>
          {cargando ? (
            <Skel className="h-8 w-28 mt-1" />
          ) : (
            <p className="text-2xl font-black text-zinc-900 dark:text-white leading-none">
              {prefix && (
                <span className="text-sm font-semibold text-zinc-400 mr-1">{prefix}</span>
              )}
              {value}
            </p>
          )}
          {!cargando && sub && (
            <p className="text-xs text-zinc-400 dark:text-zinc-500 mt-1.5">{sub}</p>
          )}
        </div>
        {/* icon bubble */}
        <div className={`w-11 h-11 rounded-xl flex items-center justify-center
                         text-xl shrink-0 bg-zinc-50 dark:bg-zinc-800`}>
          {icon}
        </div>
      </div>
    </div>
  );
}

// ── Barra de producto ─────────────────────────────────────────────────────────
const BAR_COLORS = [
  'bg-yellow-400', 'bg-emerald-500', 'bg-sky-500',
  'bg-violet-500', 'bg-orange-400',  'bg-pink-500',
  'bg-teal-500',   'bg-rose-400',
];

function BarProducto({ nombre, valor, max, rank }) {
  const pct = max > 0 ? Math.max(4, (valor / max) * 100) : 4;
  const color = BAR_COLORS[rank % BAR_COLORS.length];
  return (
    <div className="flex items-center gap-3 group">
      <span className="text-[11px] font-bold text-zinc-400 w-4 text-right shrink-0">
        {rank + 1}
      </span>
      <div className="flex-1 min-w-0">
        <div className="flex justify-between items-center mb-1 gap-2">
          <span className="text-xs font-medium text-zinc-700 dark:text-zinc-300 truncate">
            {nombre}
          </span>
          <span className="text-xs font-bold text-zinc-900 dark:text-white shrink-0">
            Bs {fmtBs(valor)}
          </span>
        </div>
        <div className="h-1.5 bg-zinc-100 dark:bg-zinc-800 rounded-full overflow-hidden">
          <div
            className={`h-full rounded-full transition-all duration-700 delay-75 ${color}`}
            style={{ width: `${pct}%` }}
          />
        </div>
      </div>
    </div>
  );
}

// ── Alerta badge días ─────────────────────────────────────────────────────────
function DiasBadge({ dias }) {
  if (dias <= 0)
    return <span className="text-[11px] font-bold px-2 py-0.5 rounded-full
                             bg-red-100 dark:bg-red-900/40
                             text-red-700 dark:text-red-300">Vencido</span>;
  if (dias <= 7)
    return <span className="text-[11px] font-bold px-2 py-0.5 rounded-full
                             bg-red-100 dark:bg-red-900/40
                             text-red-700 dark:text-red-300">{dias}d</span>;
  return <span className="text-[11px] font-bold px-2 py-0.5 rounded-full
                           bg-amber-100 dark:bg-amber-900/40
                           text-amber-700 dark:text-amber-300">{dias}d</span>;
}

// ── Fila de alerta (venc / stock) ─────────────────────────────────────────────
function AlertRow({ nombre, sub, badge }) {
  return (
    <div className="flex items-center justify-between gap-2
                    px-3 py-2 rounded-xl
                    bg-zinc-50 dark:bg-zinc-800/60
                    border border-zinc-100 dark:border-zinc-800">
      <div className="min-w-0 flex-1">
        <p className="text-xs font-semibold text-zinc-800 dark:text-zinc-200 truncate">{nombre}</p>
        <p className="text-[11px] text-zinc-400">{sub}</p>
      </div>
      {badge}
    </div>
  );
}

// ── Panel contenedor ──────────────────────────────────────────────────────────
function Panel({ title, badge, children, className = '' }) {
  return (
    <div className={`rounded-2xl border border-zinc-200 dark:border-zinc-800
                     bg-white dark:bg-zinc-900 p-5 shadow-sm ${className}`}>
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-sm font-bold text-zinc-900 dark:text-white">{title}</h2>
        {badge}
      </div>
      {children}
    </div>
  );
}

// ── Estado vacío ──────────────────────────────────────────────────────────────
function Empty({ icon, msg }) {
  return (
    <div className="flex flex-col items-center justify-center py-8 gap-2">
      <span className="text-3xl opacity-40">{icon}</span>
      <p className="text-xs text-zinc-400 text-center">{msg}</p>
    </div>
  );
}

// ── Acceso rápido ─────────────────────────────────────────────────────────────
function QuickBtn({ to, icon, label, desc, onClick }) {
  return (
    <button
      onClick={() => onClick(to)}
      className="flex items-center gap-3 p-3.5 rounded-xl text-left w-full
                 bg-zinc-50 dark:bg-zinc-800/50
                 border border-zinc-200 dark:border-zinc-700
                 hover:border-yellow-400 hover:bg-yellow-50 dark:hover:bg-yellow-400/10
                 transition-all duration-200 group"
    >
      <span className="text-xl w-8 h-8 flex items-center justify-center shrink-0 rounded-lg
                       bg-white dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700
                       group-hover:border-yellow-400">
        {icon}
      </span>
      <div className="min-w-0 flex-1">
        <p className="text-xs font-bold text-zinc-800 dark:text-white
                      group-hover:text-yellow-600 dark:group-hover:text-yellow-400 truncate">
          {label}
        </p>
        <p className="text-[11px] text-zinc-400 truncate">{desc}</p>
      </div>
    </button>
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────
export default function Dashboard() {
  const { usuario }  = useAuth();
  const { puede }    = usePermission();
  const navigate     = useNavigate();

  // ── Permisos relevantes ──────────────────────────────────────────────────
  const pFinanciero = puede('ganancias',     'reportes');
  const pTop        = puede('top_productos', 'reportes');
  const pVenc       = puede('vencimientos',  'reportes');
  const pStockBajo  = puede('stock_bajo',    'reportes');

  // ── Estado ───────────────────────────────────────────────────────────────
  const [fin,      setFin]      = useState(null);
  const [top,      setTop]      = useState([]);
  const [venc,     setVenc]     = useState([]);
  const [stock,    setStock]    = useState([]);

  const [ldFin,    setLdFin]    = useState(false);
  const [ldTop,    setLdTop]    = useState(false);
  const [ldVenc,   setLdVenc]   = useState(false);
  const [ldStock,  setLdStock]  = useState(false);

  // ── Carga ─────────────────────────────────────────────────────────────────
  const cargar = useCallback(async () => {
    if (pFinanciero) {
      setLdFin(true);
      try   { const r = await reporteService.financiero();            setFin(r.data); }
      catch { /* silencioso */ }
      finally { setLdFin(false); }
    }
    if (pTop) {
      setLdTop(true);
      try   { const r = await reporteService.topProductos();         setTop(r.data.slice(0, 8)); }
      catch { /* silencioso */ }
      finally { setLdTop(false); }
    }
    if (pVenc) {
      setLdVenc(true);
      try   { const r = await reporteService.vencimientos();         setVenc(r.data.slice(0, 6)); }
      catch { /* silencioso */ }
      finally { setLdVenc(false); }
    }
    if (pStockBajo) {
      setLdStock(true);
      try   { const r = await reporteService.inventario('stock_bajo'); setStock(r.data.data ?? []); }
      catch { /* silencioso */ }
      finally { setLdStock(false); }
    }
  }, [pFinanciero, pTop, pVenc, pStockBajo]);

  useEffect(() => { cargar(); }, [cargar]);

  // ── Quick links (por permiso) ────────────────────────────────────────────
  const quickLinks = [
    { to: '/ventas/nueva',  icon: '🧾', label: 'Nueva Venta',      desc: 'Registrar POS',          show: puede('crear', 'ventas')     },
    { to: '/compras/nueva', icon: '🛒', label: 'Nueva Compra',     desc: 'Registrar ingreso',      show: puede('crear', 'compras')    },
    { to: '/ventas',        icon: '📋', label: 'Historial Ventas', desc: 'Ver ventas',             show: puede('ver',   'ventas')     },
    { to: '/caja',          icon: '🏧', label: 'Caja',             desc: 'Turnos de caja',         show: puede('ver',   'caja')       },
    { to: '/productos',     icon: '📦', label: 'Productos',        desc: 'Catálogo',               show: puede('ver',   'productos')  },
    { to: '/almacen',       icon: '🏪', label: 'Almacén',          desc: 'Stock e inventario',     show: puede('ver',   'almacen')    },
    { to: '/clientes',      icon: '🧑‍🌾', label: 'Clientes',        desc: 'Gestión de clientes',   show: puede('ver',   'clientes')   },
    { to: '/compras',       icon: '📂', label: 'Compras',          desc: 'Historial compras',      show: puede('ver',   'compras')    },
    { to: '/proveedores',   icon: '🤝', label: 'Proveedores',      desc: 'Gestión de proveedores', show: puede('ver',   'proveedores')},
    { to: '/reportes',      icon: '📈', label: 'Reportes',         desc: 'Estadísticas',           show: ['ventas_diarias','ganancias','inventario','top_productos','caja'].some(a => puede(a, 'reportes')) },
    { to: '/usuarios',      icon: '👥', label: 'Usuarios',         desc: 'Gestión de usuarios',    show: puede('ver',   'usuarios')   },
    { to: '/sucursales',    icon: '🏢', label: 'Sucursales',       desc: 'Gestión sucursales',     show: puede('ver',   'sucursales') },
  ].filter(l => l.show);

  // ── Datos derivados ───────────────────────────────────────────────────────
  const maxTop = top.length > 0
    ? Math.max(...top.map(p => parseFloat(p.ingresos_generados || 0)))
    : 1;

  const iniciales = [usuario?.nombre?.[0], usuario?.apellido?.[0]]
    .filter(Boolean).join('').toUpperCase() || '?';

  // ── No hay ningún widget con datos → mostrar bienvenida simple ──────────
  const tieneAlgunWidget = pFinanciero || pTop || pVenc || pStockBajo;

  return (
    <PageWrapper>
      <div className="max-w-7xl mx-auto space-y-5">

        {/* ═══ HEADER ════════════════════════════════════════════════════════ */}
        <div className="rounded-2xl border border-zinc-200 dark:border-zinc-800
                        bg-white dark:bg-zinc-900 shadow-sm px-6 py-5
                        flex flex-col sm:flex-row sm:items-center gap-4">
          <div className="flex-1 min-w-0">
            <p className="text-[11px] font-semibold uppercase tracking-widest
                          text-zinc-400 dark:text-zinc-500 mb-0.5">
              {saludoHora()}
            </p>
            <h1 className="text-2xl font-black text-zinc-900 dark:text-white truncate">
              {usuario?.nombre} {usuario?.apellido}
            </h1>
            <p className="text-sm text-zinc-400 dark:text-zinc-500 capitalize mt-0.5">
              {fechaLarga()}
            </p>
          </div>

          {/* Info usuario */}
          <div className="flex items-center gap-3 shrink-0">
            <div className="hidden sm:flex flex-col items-end">
              <span className="text-[11px] text-zinc-400 uppercase tracking-wide">Rol</span>
              <span className="text-sm font-bold text-zinc-700 dark:text-zinc-300">
                {usuario?.rol_nombre ?? `Rol ${usuario?.rol}`}
              </span>
            </div>
            <div className="w-11 h-11 rounded-xl bg-yellow-400 text-zinc-900
                            flex items-center justify-center text-sm font-black shrink-0
                            shadow-sm shadow-yellow-400/30">
              {iniciales}
            </div>
          </div>
        </div>

        {/* ═══ KPI CARDS (solo si tiene permiso de ganancias) ════════════════ */}
        {pFinanciero && (
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
            <KpiCard
              label="Ventas hoy"
              value={fmtInt(fin?.ventas_hoy_cantidad)}
              icon="🧾"
              colorKey="emerald"
              cargando={ldFin}
              sub={`Bs ${fmtBs(fin?.ingresos_hoy)} ingresos`}
            />
            <KpiCard
              label="Ingresos del mes"
              value={fmtBs(fin?.ingresos_mes)}
              prefix="Bs"
              icon="💵"
              colorKey="yellow"
              cargando={ldFin}
            />
            <KpiCard
              label="Compras del mes"
              value={fmtBs(fin?.egresos_mes)}
              prefix="Bs"
              icon="🛒"
              colorKey="orange"
              cargando={ldFin}
            />
          </div>
        )}

        {/* ═══ GRID CENTRAL ══════════════════════════════════════════════════ */}
        {tieneAlgunWidget && (
          <div className={`grid gap-4 ${
            pTop && (pVenc || pStockBajo)
              ? 'grid-cols-1 xl:grid-cols-3'
              : 'grid-cols-1'
          }`}>

            {/* ─ Top Productos ─────────────────────────────────────────── */}
            {pTop && (
              <Panel
                title="🏆 Top Productos"
                badge={<span className="text-xs text-zinc-400">ingresos totales</span>}
                className={pVenc || pStockBajo ? 'xl:col-span-2' : ''}
              >
                {ldTop ? (
                  <div className="space-y-3">
                    {[...Array(5)].map((_, i) => <Skel key={i} className="h-8 w-full" />)}
                  </div>
                ) : top.length === 0 ? (
                  <Empty icon="📦" msg="Sin ventas registradas aún" />
                ) : (
                  <div className="space-y-3">
                    {top.map((p, i) => (
                      <BarProducto
                        key={p.id_producto}
                        nombre={p.nombre}
                        valor={parseFloat(p.ingresos_generados || 0)}
                        max={maxTop}
                        rank={i}
                      />
                    ))}
                  </div>
                )}
              </Panel>
            )}

            {/* ─ Columna alertas ───────────────────────────────────────── */}
            {(pVenc || pStockBajo) && (
              <div className="flex flex-col gap-4">

                {/* Vencimientos */}
                {pVenc && (
                  <Panel
                    title="⏰ Próximos a vencer"
                    badge={
                      venc.length > 0 && (
                        <span className="text-[11px] font-bold px-2 py-0.5 rounded-full
                                         bg-amber-100 dark:bg-amber-900/30
                                         text-amber-700 dark:text-amber-300">
                          {venc.length}
                        </span>
                      )
                    }
                    className="flex-1"
                  >
                    {ldVenc ? (
                      <div className="space-y-2">
                        {[...Array(3)].map((_, i) => <Skel key={i} className="h-10 w-full" />)}
                      </div>
                    ) : venc.length === 0 ? (
                      <Empty icon="✅" msg="Sin productos próximos a vencer" />
                    ) : (
                      <div className="space-y-2">
                        {venc.map(v => (
                          <AlertRow
                            key={v.id_lote}
                            nombre={v.producto_nombre}
                            sub={v.numero_lote ? `Lote: ${v.numero_lote}` : `Lote #${v.id_lote}`}
                            badge={<DiasBadge dias={v.dias_restantes} />}
                          />
                        ))}
                      </div>
                    )}
                  </Panel>
                )}

                {/* Stock bajo */}
                {pStockBajo && (
                  <Panel
                    title="⚠️ Stock bajo"
                    badge={
                      stock.length > 0 && (
                        <span className="text-[11px] font-bold px-2 py-0.5 rounded-full
                                         bg-red-100 dark:bg-red-900/30
                                         text-red-700 dark:text-red-300">
                          {stock.length}
                        </span>
                      )
                    }
                    className="flex-1"
                  >
                    {ldStock ? (
                      <div className="space-y-2">
                        {[...Array(3)].map((_, i) => <Skel key={i} className="h-10 w-full" />)}
                      </div>
                    ) : stock.length === 0 ? (
                      <Empty icon="✅" msg="Todos los productos en stock normal" />
                    ) : (
                      <div className="space-y-2">
                        {stock.map(s => (
                          <AlertRow
                            key={s.id_producto}
                            nombre={s.nombre}
                            sub={`Mínimo: ${s.stock_minimo} uds`}
                            badge={
                              <span className="text-[11px] font-bold px-2 py-0.5 rounded-full
                                               bg-red-100 dark:bg-red-900/40
                                               text-red-700 dark:text-red-300 shrink-0">
                                {s.stock_total_unidades} uds
                              </span>
                            }
                          />
                        ))}
                      </div>
                    )}
                  </Panel>
                )}
              </div>
            )}
          </div>
        )}

        {/* ═══ BIENVENIDA (si no hay ningún widget de reportes) ══════════════ */}
        {!tieneAlgunWidget && (
          <div className="rounded-2xl border border-zinc-200 dark:border-zinc-800
                          bg-white dark:bg-zinc-900 shadow-sm px-6 py-12
                          flex flex-col items-center justify-center text-center">
            <span className="text-5xl mb-4">🌱</span>
            <h2 className="text-lg font-bold text-zinc-800 dark:text-white mb-1">
              Bienvenido a SIS-AGRO
            </h2>
            <p className="text-sm text-zinc-400 max-w-xs">
              Usa el menú lateral para acceder a los módulos disponibles para tu rol.
            </p>
          </div>
        )}

        {/* ═══ ACCESO RÁPIDO ════════════════════════════════════════════════ */}
        {quickLinks.length > 0 && (
          <div className="rounded-2xl border border-zinc-200 dark:border-zinc-800
                          bg-white dark:bg-zinc-900 shadow-sm p-5">
            <h2 className="text-sm font-bold text-zinc-900 dark:text-white mb-3">
              ⚡ Acceso rápido
            </h2>
            <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 xl:grid-cols-6 gap-2">
              {quickLinks.map(l => (
                <QuickBtn key={l.to} {...l} onClick={navigate} />
              ))}
            </div>
          </div>
        )}

        {/* ═══ FOOTER INFO ══════════════════════════════════════════════════ */}
        <div className="flex items-center justify-between px-1 pb-2 text-[11px] text-zinc-300 dark:text-zinc-700">
          <span>SIS-AGRO v1.0.0</span>
          <span>Sucursal #{usuario?.id_sucursal} · {usuario?.rol_nombre}</span>
        </div>

      </div>
    </PageWrapper>
  );
}
