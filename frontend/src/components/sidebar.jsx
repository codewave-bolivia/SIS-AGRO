import { useState, useEffect } from 'react';
import { NavLink, useNavigate, useLocation } from 'react-router-dom';
import { useAuth }           from '../contexts/AuthContext';
import { useAbilityUpdater } from '../contexts/AbilityContext';
import { usePermission }     from '../hooks/usePermission';
import { useTheme }          from '../contexts/ThemeContext';

const MENU_ITEMS = [
  { label: 'Dashboard',         path: '/dashboard',      icono: '📊', action: null,              subject: null },
  { label: 'Productos',         path: '/productos',      icono: '📦', action: 'ver',             subject: 'productos' },
  { label: 'Catálogos',         path: '/catalogos',      icono: '🏷️', action: 'ver',             subject: 'clasificaciones' },
  { label: 'Clientes',          path: '/clientes',       icono: '🧑‍🌾', action: 'ver',             subject: 'clientes' },
  { label: 'Proveedores',       path: '/proveedores',    icono: '🤝', action: 'ver',             subject: 'proveedores' },
  { label: 'Ventas (POS)',      path: '/ventas',         icono: '🧾', action: 'ver',             subject: 'ventas' },
  { label: 'Caja',              path: '/caja',           icono: '🏧', action: 'ver',             subject: 'caja' },
  { label: 'Compras / Ingresos',path: '/compras',        icono: '🛒', action: 'ver',             subject: 'compras' },
  { label: 'Almacén (Stock)',   path: '/almacen',        icono: '📦', action: 'ver',             subject: 'almacen' },
  { label: 'Reportes',          path: '/reportes',       icono: '📈', action: null, subject: null,
    anyPermission: [
      { action: 'ventas_diarias',        subject: 'reportes' },
      { action: 'ventas_rango',          subject: 'reportes' },
      { action: 'ventas_vendedor',       subject: 'reportes' },
      { action: 'ventas_producto',       subject: 'reportes' },
      { action: 'ventas_cliente',        subject: 'reportes' },
      { action: 'compras',               subject: 'reportes' },
      { action: 'compras_proveedor',     subject: 'reportes' },
      { action: 'inventario',            subject: 'reportes' },
      { action: 'inventario_valorizado', subject: 'reportes' },
      { action: 'ganancias',             subject: 'reportes' },
      { action: 'ganancias_producto',    subject: 'reportes' },
      { action: 'top_productos',         subject: 'reportes' },
      { action: 'vencimientos',          subject: 'reportes' },
      { action: 'stock_bajo',            subject: 'reportes' },
      { action: 'kardex',                subject: 'reportes' },
      { action: 'traslados',             subject: 'reportes' },
      { action: 'comparativo_sucursales',subject: 'reportes' },
      { action: 'caja',                  subject: 'reportes' },
    ]
  },
  { label: 'Sucursales',        path: '/sucursales',     icono: '🏢', action: 'ver',             subject: 'sucursales' },
  { label: 'Usuarios',          path: '/usuarios',       icono: '👥', action: 'ver',             subject: 'usuarios' },
  { label: 'Roles y Permisos',  path: '/roles',          icono: '🔐', action: 'ver',             subject: 'roles' },
];

// ── Toggle tema ───────────────────────────────────────────────────────────
function ToggleTema() {
  const { tema, toggleTema } = useTheme();
  const isDark = tema === 'dark';

  return (
    <button
      onClick={toggleTema}
      title={isDark ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro'}
      className={`relative inline-flex items-center w-12 h-6 rounded-full
                  transition-colors duration-300 focus:outline-none
                  ${isDark ? 'bg-yellow-400' : 'bg-zinc-300'}`}
    >
      <span
        className={`absolute left-0.5 w-5 h-5 rounded-full shadow-md
                    flex items-center justify-center text-xs bg-white
                    transition-transform duration-300
                    ${isDark ? 'translate-x-6' : 'translate-x-0'}`}
      >
        {isDark ? '🌙' : '☀️'}
      </span>
    </button>
  );
}

// ── Ítem de navegación ────────────────────────────────────────────────────
function MenuItem({ path, label, icono, onClose }) {
  return (
    <NavLink
      to={path}
      onClick={onClose}
      className={({ isActive }) =>
        `flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium
         transition-all duration-200 ${
          isActive
            ? 'bg-yellow-400 text-zinc-900 shadow-md shadow-yellow-400/20'
            : `text-zinc-500 dark:text-zinc-400
               hover:bg-zinc-100 dark:hover:bg-zinc-800
               hover:text-zinc-900 dark:hover:text-white`
        }`
      }
    >
      <span className="text-base w-5 text-center shrink-0 leading-none">
        {icono}
      </span>
      <span className="truncate">{label}</span>
    </NavLink>
  );
}

// ── Contenido del sidebar ─────────────────────────────────────────────────
function SidebarContent({ onClose }) {
  const { usuario, logout } = useAuth();
  const { limpiar }         = useAbilityUpdater();
  const { puede }           = usePermission();
  const navigate            = useNavigate();

  const handleLogout = () => {
    logout();
    limpiar();
    onClose?.();
    navigate('/login');
  };

  const itemsVisibles = MENU_ITEMS.filter(({ action, subject, anyPermission }) => {
    if (anyPermission) return anyPermission.some(p => puede(p.action, p.subject));
    if (!action || !subject) return true;
    return puede(action, subject);
  });

  const iniciales = [usuario?.nombre?.[0], usuario?.apellido?.[0]]
    .filter(Boolean).join('').toUpperCase() || '?';

  return (
    <div className="flex flex-col h-full
                    bg-white dark:bg-zinc-900
                    border-r border-zinc-200 dark:border-zinc-800
                    transition-colors duration-300">

      {/* ── LOGO — sin fondo, imagen directa ─────────────────────────── */}
      <div className="flex flex-col items-center pt-6 pb-5
                      border-b border-zinc-200 dark:border-zinc-800 px-4">

        {/* ✅ Solo imagen, sin div contenedor */}
        <img
          src="/logo.png"
          alt="Logo Cooperativa"
          className="w-50 h-20 object-contain mb-3
                     drop-shadow-md hover:scale-105
                     transition-transform duration-300"
          onError={(e) => {
            e.target.style.display = 'none';
            e.target.parentElement.innerHTML +=
              '<span style="font-size:2.5rem;margin-bottom:0.75rem">📦</span>';
          }}
        />

        {/* Toggle tema */}
        <div className="flex items-center gap-2 mt-4">
          <span className="text-xs text-zinc-400 dark:text-zinc-500">☀️</span>
          <ToggleTema />
          <span className="text-xs text-zinc-400 dark:text-zinc-500">🌙</span>
        </div>
      </div>

      {/* ── INFO USUARIO ─────────────────────────────────────────────── */}
      <div className="mx-3 mt-4 mb-2 rounded-xl px-3 py-3
                      bg-zinc-50 dark:bg-zinc-800
                      border border-zinc-200 dark:border-zinc-700">
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-xl bg-yellow-400 text-zinc-900
                          flex items-center justify-center text-sm font-bold
                          shrink-0 shadow-sm">
            {iniciales}
          </div>
          <div className="min-w-0">
            <p className="text-zinc-900 dark:text-white text-sm font-semibold
                          truncate leading-tight">
              {usuario?.nombre} {usuario?.apellido}
            </p>
            <p className="text-zinc-500 dark:text-zinc-400 text-xs truncate">
              {usuario?.correo}
            </p>
          </div>
        </div>
        <div className="mt-2.5 flex items-center gap-1.5">
          <span className="w-1.5 h-1.5 bg-green-500 rounded-full
                           animate-pulse shrink-0" />
          <span className="text-xs text-green-600 dark:text-green-400 font-semibold">
            {usuario?.rol_nombre ?? `Rol ${usuario?.rol}`}
          </span>
        </div>
      </div>

      {/* ── NAVEGACIÓN ───────────────────────────────────────────────── */}
      <nav className="flex-1 px-3 py-3 overflow-y-auto space-y-0.5">
        <p className="text-xs font-semibold uppercase tracking-widest
                      text-zinc-400 dark:text-zinc-600 px-3 mb-2">
          Menú principal
        </p>
        {itemsVisibles.map((item) => (
          <MenuItem key={item.path} {...item} onClose={onClose} />
        ))}
      </nav>

      {/* ── FOOTER ───────────────────────────────────────────────────── */}
      <div className="px-3 pb-4 pt-3
                      border-t border-zinc-200 dark:border-zinc-800 space-y-1">
        <p className="text-xs text-zinc-400 dark:text-zinc-600 px-3 mb-2">
          v1.0.0 
        </p>
        <button
          onClick={handleLogout}
          className="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl
                     text-sm font-medium transition-all duration-200
                     text-zinc-500 dark:text-zinc-400
                     hover:bg-red-50 dark:hover:bg-red-500/10
                     hover:text-red-600 dark:hover:text-red-400
                     border border-transparent
                     hover:border-red-200 dark:hover:border-red-500/20"
        >
          <span className="text-base w-5 text-center shrink-0">🚪</span>
          <span>Cerrar sesión</span>
        </button>
      </div>

    </div>
  );
}

// ── Sidebar principal ─────────────────────────────────────────────────────
export default function Sidebar() {
  const [drawerAbierto, setDrawerAbierto] = useState(false);
  const location = useLocation();

  useEffect(() => {
    setDrawerAbierto(false);
  }, [location.pathname]);

  useEffect(() => {
    document.body.style.overflow = drawerAbierto ? 'hidden' : '';
    return () => { document.body.style.overflow = ''; };
  }, [drawerAbierto]);

  return (
    <>
      {/* DESKTOP */}
      <aside className="hidden lg:flex w-64 shrink-0 flex-col h-screen sticky top-0">
        <SidebarContent />
      </aside>

      {/* MOBILE — botón hamburguesa */}
      <button
        onClick={() => setDrawerAbierto(true)}
        aria-label="Abrir menú"
        className="lg:hidden fixed top-3.5 left-4 z-40 w-10 h-10
                   flex items-center justify-center rounded-xl
                   bg-white dark:bg-zinc-900
                   border border-zinc-200 dark:border-zinc-700
                   text-zinc-700 dark:text-white
                   shadow-md hover:border-yellow-400
                   transition-all duration-200"
      >
        <svg className="w-5 h-5" fill="none" stroke="currentColor"
             strokeWidth={2} viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round"
                d="M4 6h16M4 12h16M4 18h16" />
        </svg>
      </button>

      {/* MOBILE — topbar */}
      <div className="lg:hidden fixed top-0 left-0 right-0 z-30 h-14
                      bg-white dark:bg-zinc-900
                      border-b border-zinc-200 dark:border-zinc-800
                      flex items-center justify-center shadow-sm
                      transition-colors duration-300">
        <p className="text-sm font-bold text-zinc-900 dark:text-white">
          SIS-AGRO
        </p>
      </div>

      {/* MOBILE — overlay */}
      <div
        onClick={() => setDrawerAbierto(false)}
        className={`lg:hidden fixed inset-0 z-40 bg-black/60 backdrop-blur-sm
                    transition-opacity duration-300
                    ${drawerAbierto
                      ? 'opacity-100 pointer-events-auto'
                      : 'opacity-0 pointer-events-none'}`}
      />

      {/* MOBILE — drawer */}
      <div
        className={`lg:hidden fixed top-0 left-0 h-full w-72 z-50
                    shadow-2xl shadow-black/40
                    transform transition-transform duration-300 ease-in-out
                    ${drawerAbierto ? 'translate-x-0' : '-translate-x-full'}`}
      >
        <button
          onClick={() => setDrawerAbierto(false)}
          aria-label="Cerrar menú"
          className="absolute top-3 right-3 z-10 w-8 h-8 rounded-lg
                     flex items-center justify-center
                     bg-zinc-100 dark:bg-zinc-800
                     text-zinc-500 dark:text-zinc-400
                     hover:text-zinc-900 dark:hover:text-white
                     transition-colors"
        >
          <svg className="w-4 h-4" fill="none" stroke="currentColor"
               strokeWidth={2} viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round"
                  d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
        <SidebarContent onClose={() => setDrawerAbierto(false)} />
      </div>
    </>
  );
}