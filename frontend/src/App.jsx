import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider }    from './contexts/AuthContext';
import { AbilityProvider } from './contexts/AbilityContext';
import { ThemeProvider }   from './contexts/ThemeContext'; 
import ProtectedRoute      from './components/ProtectedRoute';
import Sidebar             from './components/sidebar';

// ── Pages ────────────────────────────────────────────────────────────────
import Login        from './pages/Login';
import SinPermiso   from './pages/SinPermiso';
import Dashboard    from './pages/Dashboard';
import Roles        from './pages/roles/Roles';
import Usuarios       from './pages/usuarios/Usuarios';
import Sucursales     from './pages/sucursales/Sucursales';
import Productos      from './pages/productos/Productos';
import Catalogos      from './pages/catalogos/Catalogos';
import Clientes       from './pages/clientes/Clientes';
import Proveedores    from './pages/proveedores/Proveedores';
import Compras        from './pages/compras/Compras';
import NuevaCompra    from './pages/compras/NuevaCompra';
import Almacen        from './pages/almacen/Almacen';
import HistorialVentas from './pages/ventas/HistorialVentas';
import NuevaVenta     from './pages/ventas/NuevaVenta';
import VentaTicket    from './pages/ventas/VentaTicket';
import Caja           from './pages/caja/Caja';
import LayoutReportes from './pages/reportes/LayoutReportes';
import Backups        from './pages/backups/Backups';

// Nota: Reportes/Órdenes de salida aún no están integrados aquí.

// ── Layout con Sidebar ───────────────────────────────────────────────────
function AppLayout({ children }) {
  return (
    <div className="flex h-screen overflow-hidden
                    bg-gray-100  dark:bg-zinc-950
                    transition-colors duration-300">
      <Sidebar />
      <main className="flex-1 overflow-y-auto
                       bg-gray-100  dark:bg-zinc-950
                       transition-colors duration-300">
        <div className="pt-16 lg:pt-0 px-4 sm:px-6 py-4 sm:py-6 min-h-full">
          {children}
        </div>
      </main>
    </div>
  );
}

// ── Rutas protegidas reutilizables ───────────────────────────────────────
// Agrupa ProtectedRoute + AppLayout para no repetir estructura
function PageRoute({ action, subject, children }) {
  return (
    <ProtectedRoute action={action} subject={subject}>
      <AppLayout>
        {children}
      </AppLayout>
    </ProtectedRoute>
  );
}

// ── App ──────────────────────────────────────────────────────────────────
export default function App() {
  return (
    <BrowserRouter>
      <ThemeProvider>
      <AuthProvider>
        <AbilityProvider>
          <Routes>

            {/* ── Rutas públicas ──────────────────────────────────────── */}
            <Route path="/login"       element={<Login />} />
            <Route path="/sin-permiso" element={<SinPermiso />} />

            {/* ── Roles y permisos ────────────────────────────────────── */}
            <Route path="/roles" element={
              <PageRoute action="ver" subject="roles">
                <Roles />
              </PageRoute>
            }/>

            {/* ── Usuarios ───────────────────────────────────────────── */}
            <Route path="/usuarios" element={
              <PageRoute action="ver" subject="usuarios">
                <Usuarios />
              </PageRoute>
            }/>

            {/* ── Sucursales ───────────────────────────────────────────── */}
            <Route path="/sucursales" element={
              <PageRoute action="ver" subject="sucursales">
                <Sucursales />
              </PageRoute>
            }/>

            {/* ── Productos ────────────────────────────────────────────── */}
            <Route path="/productos" element={
              <PageRoute action="ver" subject="productos">
                <Productos />
              </PageRoute>
            }/>

            {/* ── Catálogos ────────────────────────────────────────────── */}
            <Route path="/catalogos" element={
              <PageRoute action="ver" subject="clasificaciones">
                <Catalogos />
              </PageRoute>
            }/>

            {/* ── Clientes ─────────────────────────────────────────────── */}
            <Route path="/clientes" element={
              <PageRoute action="ver" subject="clientes">
                <Clientes />
              </PageRoute>
            }/>

            {/* ── Proveedores ──────────────────────────────────────────── */}
            <Route path="/proveedores" element={
              <PageRoute action="ver" subject="proveedores">
                <Proveedores />
              </PageRoute>
            }/>

            {/* ── Compras ────────────────────────────────────────────── */}
            <Route path="/compras" element={
              <PageRoute action="ver" subject="compras">
                <Compras />
              </PageRoute>
            }/>
            <Route path="/compras/nueva" element={
              <PageRoute action="crear" subject="compras">
                <NuevaCompra />
              </PageRoute>
            }/>

            {/* ── Almacén ────────────────────────────────────────────── */}
            <Route path="/almacen" element={
              <PageRoute action="ver" subject="almacen">
                <Almacen />
              </PageRoute>
            }/>

            {/* ── Ventas (POS) ───────────────────────────────────────── */}
            <Route path="/ventas" element={
              <PageRoute action="ver" subject="ventas">
                <HistorialVentas />
              </PageRoute>
            }/>
            <Route path="/ventas/nueva" element={
              <PageRoute action="crear" subject="ventas">
                <NuevaVenta />
              </PageRoute>
            }/>
            <Route path="/ventas/:id/ticket" element={
              <ProtectedRoute action="ver" subject="ventas">
                <VentaTicket />
              </ProtectedRoute>
            }/>

            {/* ── Caja ───────────────────────────────────────────────── */}
            <Route path="/caja" element={
              <PageRoute action="ver" subject="caja">
                <Caja />
              </PageRoute>
            }/>

            {/* ── Reportes ───────────────────────────────────────────── */}
            <Route path="/reportes" element={
              <PageRoute action="ver" subject="reportes">
                <LayoutReportes />
              </PageRoute>
            }/>

            {/* ── Backups ────────────────────────────────────────────── */}
            <Route path="/backups" element={
              <PageRoute action="ver" subject="roles">
                <Backups />
              </PageRoute>
            }/>

            {/* ── Dashboard ───────────────────────────────────────────── */}
            <Route path="/dashboard" element={
              <PageRoute>
                <Dashboard />
              </PageRoute>
            }/>


            {/* ── Redirigir raíz y rutas desconocidas ─────────────────── */}
            <Route path="/"  element={<Navigate to="/dashboard" replace />} />
            <Route path="*"  element={<Navigate to="/dashboard" replace />} />

          </Routes>
        </AbilityProvider>
      </AuthProvider>
      </ThemeProvider>
    </BrowserRouter>
  );
}