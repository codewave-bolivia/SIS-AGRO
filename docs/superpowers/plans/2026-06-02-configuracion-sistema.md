# Configuración del Sistema — Plan de Implementación

> **Para workers agénticos:** REQUIRED SUB-SKILL: Usar `superpowers:subagent-driven-development` (recomendado) o `superpowers:executing-plans` para implementar este plan tarea por tarea. Los pasos usan sintaxis checkbox (`- [ ]`) para seguimiento.
>
> **IMPORTANTE:** No hacer commits — el usuario los hace manualmente.

**Goal:** Módulo de configuración que permite al administrador editar los datos de la empresa (nombre, NIT, dirección, ciudad, teléfono, correo, logo) y que esos datos se reflejen en los PDFs exportados.

**Architecture:** Tabla `configuracion` de fila única en MariaDB con columna `logo MEDIUMTEXT` para base64; dos endpoints REST GET/PUT protegidos por los permisos 120-121 ya existentes; página React con formulario + upload de logo; `BotonesExportar.jsx` reemplaza el `fetch('/logo.png')` actual por una llamada al endpoint de config.

**Tech Stack:** Node.js + Express + MariaDB, React + Tailwind CSS, jsPDF (ya instalado)

---

## Archivos a crear/modificar

| Archivo | Acción |
|---------|--------|
| `backend/controllers/configuracion.Controller.js` | Crear |
| `backend/routes/configuracion.Routes.js` | Crear |
| `backend/app.js` | Modificar — registrar ruta |
| `frontend/src/services/configuracion.service.js` | Crear |
| `frontend/src/pages/configuracion/Configuracion.jsx` | Crear |
| `frontend/src/App.jsx` | Modificar — agregar ruta `/configuracion` |
| `frontend/src/components/sidebar.jsx` | Modificar — agregar entrada al menú |
| `frontend/src/pages/reportes/components/BotonesExportar.jsx` | Modificar — usar config en lugar de fetch('/logo.png') |

---

## Task 1: Crear la tabla `configuracion` en la base de datos

**Files:**
- No hay archivos — ejecutar SQL directo en MariaDB

- [ ] **Step 1: Ejecutar el SQL de creación en MariaDB**

Conectarse a la BD `bd_agropecuaria` y ejecutar:

```sql
CREATE TABLE configuracion (
  id_config        INT          NOT NULL DEFAULT 1,
  nombre_empresa   VARCHAR(150) NOT NULL DEFAULT 'SIS-AGRO',
  nit              VARCHAR(30)           DEFAULT NULL,
  direccion        VARCHAR(200)          DEFAULT NULL,
  ciudad           VARCHAR(100)          DEFAULT NULL,
  telefono         VARCHAR(20)           DEFAULT NULL,
  correo           VARCHAR(100)          DEFAULT NULL,
  logo             MEDIUMTEXT            DEFAULT NULL,
  actualizado_en   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
                                ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_config),
  CONSTRAINT chk_single_row CHECK (id_config = 1)
);

INSERT INTO configuracion (id_config) VALUES (1);
```

- [ ] **Step 2: Verificar que la fila inicial fue creada**

```sql
SELECT id_config, nombre_empresa, nit, direccion, ciudad, telefono, correo,
       logo IS NOT NULL AS tiene_logo, actualizado_en
FROM configuracion;
```

Resultado esperado: 1 fila con `id_config=1`, `nombre_empresa='SIS-AGRO'`, resto NULL.

- [ ] **Step 3: Verificar que los permisos de configuración están asignados al Administrador (rol id=1)**

```sql
SELECT rp.id_rol, p.nombre_clave
FROM rol_permiso rp
JOIN permiso p ON p.id_permiso = rp.id_permiso
WHERE p.modulo = 'configuracion';
```

Resultado esperado: 2 filas con `id_rol=1` y claves `configuracion.ver` y `configuracion.editar`.

Si NO aparecen, ejecutar:

```sql
INSERT IGNORE INTO rol_permiso (id_rol, id_permiso)
SELECT 1, id_permiso FROM permiso WHERE modulo = 'configuracion';
```

---

## Task 2: Backend — Controller

**Files:**
- Create: `backend/controllers/configuracion.Controller.js`

- [ ] **Step 1: Crear el archivo del controller**

Crear `backend/controllers/configuracion.Controller.js` con el siguiente contenido completo:

```js
const db = require('../config/db');

const obtener = async (req, res) => {
  try {
    const [rows] = await db.promise().query(
      'SELECT * FROM configuracion WHERE id_config = 1'
    );
    if (rows.length === 0) {
      return res.json({
        nombre_empresa: 'SIS-AGRO',
        nit: null,
        direccion: null,
        ciudad: null,
        telefono: null,
        correo: null,
        logo: null,
      });
    }
    return res.json(rows[0]);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Error al obtener la configuración' });
  }
};

const actualizar = async (req, res) => {
  const { nombre_empresa, nit, direccion, ciudad, telefono, correo, logo } = req.body;

  if (!nombre_empresa || !nombre_empresa.trim()) {
    return res.status(400).json({ error: 'El nombre de la empresa es obligatorio' });
  }
  if (logo && logo !== '' && !logo.startsWith('data:image/')) {
    return res.status(400).json({ error: 'Formato de logo inválido' });
  }
  if (logo && logo.length > 700000) {
    return res.status(400).json({ error: 'El logo supera el tamaño máximo permitido (500 KB)' });
  }

  try {
    await db.promise().query(
      `UPDATE configuracion
       SET nombre_empresa=?, nit=?, direccion=?, ciudad=?, telefono=?, correo=?, logo=?
       WHERE id_config=1`,
      [
        nombre_empresa.trim(),
        nit   || null,
        direccion || null,
        ciudad    || null,
        telefono  || null,
        correo    || null,
        logo === '' ? null : (logo || null),
      ]
    );
    const [rows] = await db.promise().query(
      'SELECT * FROM configuracion WHERE id_config = 1'
    );
    return res.json(rows[0]);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Error al actualizar la configuración' });
  }
};

module.exports = { obtener, actualizar };
```

- [ ] **Step 2: Verificar que no hay errores de sintaxis**

```bash
node -e "require('./backend/controllers/configuracion.Controller.js'); console.log('OK')"
```

Resultado esperado: `OK`

---

## Task 3: Backend — Route y registro en app.js

**Files:**
- Create: `backend/routes/configuracion.Routes.js`
- Modify: `backend/app.js`

- [ ] **Step 1: Crear el archivo de rutas**

Crear `backend/routes/configuracion.Routes.js`:

```js
const router = require('express').Router();
const { authMiddleware, checkPermission } = require('../middlewares/authMiddleware');
const ctrl = require('../controllers/configuracion.Controller');

router.use(authMiddleware);

router.get('/', checkPermission('ver',    'configuracion'), ctrl.obtener);
router.put('/', checkPermission('editar', 'configuracion'), ctrl.actualizar);

module.exports = router;
```

- [ ] **Step 2: Registrar la ruta en `backend/app.js`**

En `backend/app.js`, agregar después de la línea `const backupRoutes = require('./routes/backup.Routes');` (línea 21):

```js
const configuracionRoutes = require('./routes/configuracion.Routes');
```

Y después de la línea `app.use('/api/backups', backupRoutes);` (línea 57):

```js
app.use('/api/configuracion', configuracionRoutes);
```

- [ ] **Step 3: Probar los endpoints con el servidor corriendo**

Con el backend ejecutándose (`npm run dev` en `backend/`), usando un token de administrador:

```bash
# GET — debe devolver la config inicial
curl -H "Authorization: Bearer <TOKEN>" http://localhost:3000/api/configuracion

# Resultado esperado:
# {"id_config":1,"nombre_empresa":"SIS-AGRO","nit":null,...,"logo":null,...}

# PUT — actualizar nombre
curl -X PUT -H "Authorization: Bearer <TOKEN>" -H "Content-Type: application/json" \
  -d '{"nombre_empresa":"Cooperativa Agropecuaria","nit":"12345678"}' \
  http://localhost:3000/api/configuracion

# Resultado esperado: objeto actualizado con nombre_empresa="Cooperativa Agropecuaria"
```

---

## Task 4: Frontend — Servicio

**Files:**
- Create: `frontend/src/services/configuracion.service.js`

- [ ] **Step 1: Crear el archivo del servicio**

Crear `frontend/src/services/configuracion.service.js`:

```js
import api from '../api/axios';

const configuracionService = {
  obtener:    ()     => api.get('/configuracion'),
  actualizar: (data) => api.put('/configuracion', data),
};

export default configuracionService;
```

---

## Task 5: Frontend — Página Configuracion.jsx

**Files:**
- Create: `frontend/src/pages/configuracion/Configuracion.jsx`

- [ ] **Step 1: Crear la carpeta y el archivo de la página**

Crear `frontend/src/pages/configuracion/Configuracion.jsx` con el siguiente contenido completo:

```jsx
import { useState, useEffect, useCallback, useRef } from 'react';
import PageWrapper from '../../components/PageWrapper';
import configuracionService from '../../services/configuracion.service';
import { usePermission } from '../../hooks/usePermission';

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

const FORM_VACIO = {
  nombre_empresa: '',
  nit: '',
  direccion: '',
  ciudad: '',
  telefono: '',
  correo: '',
  logo: null,
};

export default function Configuracion() {
  const { puede } = usePermission();
  const puedeEditar = puede('editar', 'configuracion');
  const fileInputRef = useRef(null);

  const [configOriginal, setConfigOriginal] = useState(null);
  const [form, setForm]       = useState(FORM_VACIO);
  const [cargando, setCargando]   = useState(true);
  const [guardando, setGuardando] = useState(false);
  const [toast, setToast]         = useState(null);

  const mostrarToast = (tipo, msg) => {
    setToast({ tipo, msg });
    setTimeout(() => setToast(null), 3500);
  };

  const configToForm = (data) => ({
    nombre_empresa: data.nombre_empresa || '',
    nit:       data.nit       || '',
    direccion: data.direccion || '',
    ciudad:    data.ciudad    || '',
    telefono:  data.telefono  || '',
    correo:    data.correo    || '',
    logo:      data.logo      || null,
  });

  const cargarConfig = useCallback(async () => {
    setCargando(true);
    try {
      const res = await configuracionService.obtener();
      setConfigOriginal(res.data);
      setForm(configToForm(res.data));
    } catch {
      mostrarToast('error', 'Error al cargar la configuración');
    } finally {
      setCargando(false);
    }
  }, []);

  useEffect(() => { cargarConfig(); }, [cargarConfig]);

  const hayCambios = configOriginal !== null && (
    form.nombre_empresa !== (configOriginal.nombre_empresa || '') ||
    form.nit            !== (configOriginal.nit            || '') ||
    form.direccion      !== (configOriginal.direccion      || '') ||
    form.ciudad         !== (configOriginal.ciudad         || '') ||
    form.telefono       !== (configOriginal.telefono       || '') ||
    form.correo         !== (configOriginal.correo         || '') ||
    form.logo           !== (configOriginal.logo           || null)
  );

  const handleCampo = (e) => {
    const { name, value } = e.target;
    setForm(f => ({ ...f, [name]: value }));
  };

  const handleLogoChange = (e) => {
    const file = e.target.files[0];
    if (!file) return;
    if (file.size > 500 * 1024) {
      mostrarToast('error', 'El logo no puede superar 500 KB');
      e.target.value = '';
      return;
    }
    const reader = new FileReader();
    reader.onloadend = () => setForm(f => ({ ...f, logo: reader.result }));
    reader.readAsDataURL(file);
  };

  const handleGuardar = async () => {
    if (!form.nombre_empresa.trim()) {
      mostrarToast('error', 'El nombre de la empresa es obligatorio');
      return;
    }
    setGuardando(true);
    try {
      await configuracionService.actualizar(form);
      mostrarToast('ok', 'Configuración guardada correctamente');
      await cargarConfig();
    } catch (err) {
      mostrarToast('error', err.response?.data?.error || 'Error al guardar la configuración');
    } finally {
      setGuardando(false);
    }
  };

  const inputClass = (readonly) =>
    `w-full px-3 py-2 rounded-lg text-sm border outline-none transition-colors
     ${readonly
       ? 'bg-zinc-50 dark:bg-zinc-800/50 border-zinc-200 dark:border-zinc-700 text-zinc-500 dark:text-zinc-400 cursor-not-allowed'
       : 'bg-white dark:bg-zinc-800 border-zinc-200 dark:border-zinc-700 text-zinc-900 dark:text-white focus:ring-2 focus:ring-emerald-500 focus:border-transparent'}`;

  return (
    <PageWrapper>
      <Toast toast={toast} />

      {/* Header */}
      <div className="mb-6">
        <h1 className="text-xl font-bold text-zinc-900 dark:text-white flex items-center gap-2">
          ⚙️ Configuración del Sistema
        </h1>
        <p className="text-sm text-zinc-500 dark:text-zinc-400 mt-1">
          Datos de la empresa que aparecen en los reportes PDF exportados.
        </p>
      </div>

      {cargando ? (
        <div className="flex justify-center py-20">
          <span className="w-7 h-7 rounded-full border-2 border-zinc-300 dark:border-zinc-600 border-t-emerald-500 animate-spin" />
        </div>
      ) : (
        <div className="max-w-2xl space-y-6">

          {/* Sección: Logo */}
          <div className="bg-white dark:bg-zinc-900 rounded-xl border border-zinc-200 dark:border-zinc-800 p-5">
            <h2 className="text-sm font-bold text-zinc-700 dark:text-zinc-300 uppercase tracking-wider mb-4">
              Logo de la empresa
            </h2>
            <div className="flex items-center gap-5">
              {/* Preview */}
              <div className="w-24 h-24 rounded-xl border-2 border-dashed border-zinc-300 dark:border-zinc-600 flex items-center justify-center overflow-hidden bg-zinc-50 dark:bg-zinc-800 shrink-0">
                {form.logo
                  ? <img src={form.logo} alt="Logo" className="w-full h-full object-contain p-2" />
                  : <span className="text-3xl text-zinc-300 dark:text-zinc-600">🖼️</span>
                }
              </div>
              {/* Controles */}
              <div className="flex flex-col gap-2">
                {puedeEditar && (
                  <>
                    <label className="cursor-pointer inline-flex items-center gap-2 px-3 py-1.5 text-sm font-medium bg-zinc-100 dark:bg-zinc-700 text-zinc-700 dark:text-zinc-300 hover:bg-zinc-200 dark:hover:bg-zinc-600 rounded-lg transition-colors">
                      📁 Cambiar logo
                      <input
                        ref={fileInputRef}
                        type="file"
                        accept="image/png,image/jpeg,image/webp"
                        className="hidden"
                        onChange={handleLogoChange}
                      />
                    </label>
                    {form.logo && (
                      <button
                        onClick={() => { setForm(f => ({ ...f, logo: '' })); if (fileInputRef.current) fileInputRef.current.value = ''; }}
                        className="inline-flex items-center gap-2 px-3 py-1.5 text-sm font-medium text-red-600 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-500/10 rounded-lg transition-colors"
                      >
                        🗑 Quitar logo
                      </button>
                    )}
                  </>
                )}
                <p className="text-xs text-zinc-400 dark:text-zinc-500">PNG, JPG o WEBP · Máx 500 KB</p>
              </div>
            </div>
          </div>

          {/* Sección: Datos de la empresa */}
          <div className="bg-white dark:bg-zinc-900 rounded-xl border border-zinc-200 dark:border-zinc-800 p-5">
            <h2 className="text-sm font-bold text-zinc-700 dark:text-zinc-300 uppercase tracking-wider mb-4">
              Datos de la empresa
            </h2>
            <div className="space-y-4">

              {/* Nombre */}
              <div>
                <label className="block text-sm font-medium text-zinc-700 dark:text-zinc-300 mb-1">
                  Nombre de la empresa <span className="text-red-500">*</span>
                </label>
                <input
                  type="text"
                  name="nombre_empresa"
                  value={form.nombre_empresa}
                  onChange={handleCampo}
                  readOnly={!puedeEditar}
                  placeholder="Ej: Cooperativa Agropecuaria del Norte"
                  className={inputClass(!puedeEditar)}
                />
              </div>

              {/* NIT */}
              <div>
                <label className="block text-sm font-medium text-zinc-700 dark:text-zinc-300 mb-1">NIT</label>
                <input
                  type="text"
                  name="nit"
                  value={form.nit}
                  onChange={handleCampo}
                  readOnly={!puedeEditar}
                  placeholder="Ej: 123456789"
                  className={inputClass(!puedeEditar)}
                />
              </div>

              {/* Dirección + Ciudad */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-zinc-700 dark:text-zinc-300 mb-1">Dirección</label>
                  <input
                    type="text"
                    name="direccion"
                    value={form.direccion}
                    onChange={handleCampo}
                    readOnly={!puedeEditar}
                    placeholder="Ej: Av. Principal 123"
                    className={inputClass(!puedeEditar)}
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-zinc-700 dark:text-zinc-300 mb-1">Ciudad</label>
                  <input
                    type="text"
                    name="ciudad"
                    value={form.ciudad}
                    onChange={handleCampo}
                    readOnly={!puedeEditar}
                    placeholder="Ej: Santa Cruz"
                    className={inputClass(!puedeEditar)}
                  />
                </div>
              </div>

              {/* Teléfono + Correo */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-zinc-700 dark:text-zinc-300 mb-1">Teléfono</label>
                  <input
                    type="text"
                    name="telefono"
                    value={form.telefono}
                    onChange={handleCampo}
                    readOnly={!puedeEditar}
                    placeholder="Ej: +591 3 3456789"
                    className={inputClass(!puedeEditar)}
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-zinc-700 dark:text-zinc-300 mb-1">Correo</label>
                  <input
                    type="email"
                    name="correo"
                    value={form.correo}
                    onChange={handleCampo}
                    readOnly={!puedeEditar}
                    placeholder="Ej: info@empresa.com"
                    className={inputClass(!puedeEditar)}
                  />
                </div>
              </div>
            </div>
          </div>

          {/* Botón guardar */}
          {puedeEditar && (
            <div className="flex justify-end">
              <button
                onClick={handleGuardar}
                disabled={guardando || !hayCambios}
                className="flex items-center gap-2 px-5 py-2.5 rounded-xl text-sm font-bold
                           bg-emerald-600 hover:bg-emerald-500 text-white shadow-sm
                           disabled:bg-zinc-200 dark:disabled:bg-zinc-700
                           disabled:text-zinc-400 disabled:cursor-not-allowed
                           transition-colors"
              >
                {guardando ? (
                  <>
                    <span className="w-4 h-4 border-2 border-white/40 border-t-white rounded-full animate-spin" />
                    Guardando...
                  </>
                ) : (
                  '💾 Guardar cambios'
                )}
              </button>
            </div>
          )}
        </div>
      )}
    </PageWrapper>
  );
}
```

- [ ] **Step 2: Verificar que el frontend compila sin errores**

```bash
cd frontend && npm run build
```

Resultado esperado: `✓ built in X.XXs` sin errores.

---

## Task 6: Frontend — Ruta en App.jsx y entrada en Sidebar

**Files:**
- Modify: `frontend/src/App.jsx`
- Modify: `frontend/src/components/sidebar.jsx`

- [ ] **Step 1: Agregar el import de la página en `frontend/src/App.jsx`**

Después de la línea `import Backups from './pages/backups/Backups';` (línea 28), agregar:

```js
import Configuracion from './pages/configuracion/Configuracion';
```

- [ ] **Step 2: Agregar la ruta en el bloque `<Routes>` de `frontend/src/App.jsx`**

Después del bloque de Backups (antes del bloque de Dashboard), agregar:

```jsx
{/* ── Configuración ──────────────────────────────────────────── */}
<Route path="/configuracion" element={
  <PageRoute action="ver" subject="configuracion">
    <Configuracion />
  </PageRoute>
}/>
```

- [ ] **Step 3: Agregar entrada al menú en `frontend/src/components/sidebar.jsx`**

En el array `MENU_ITEMS`, agregar antes de la entrada de `'Sucursales'`:

```js
{ label: 'Configuración', path: '/configuracion', icono: '⚙️', action: 'ver', subject: 'configuracion' },
```

El bloque `MENU_ITEMS` quedaría con esta entrada visible solo para usuarios con permiso `configuracion.ver`.

- [ ] **Step 4: Verificar que el frontend compila sin errores**

```bash
cd frontend && npm run build
```

Resultado esperado: `✓ built in X.XXs` sin errores.

---

## Task 7: Integrar `BotonesExportar.jsx` con la configuración

**Files:**
- Modify: `frontend/src/pages/reportes/components/BotonesExportar.jsx`

El objetivo es: reemplazar el `fetch('/logo.png')` actual por una llamada a `configuracionService.obtener()`, y usar `config.nombre_empresa` en lugar del texto `'SIS-AGRO'` hardcodeado.

- [ ] **Step 1: Agregar el import del servicio al inicio del archivo**

Después de `import autoTable from 'jspdf-autotable';` (línea 3), agregar:

```js
import configuracionService from '../../../services/configuracion.service';
```

- [ ] **Step 2: Actualizar la firma de `dibujarHeader` para aceptar `nombreEmpresa`**

Cambiar la línea:

```js
function dibujarHeader(doc, titulo, subtitulo, logoDataUrl) {
```

Por:

```js
function dibujarHeader(doc, titulo, subtitulo, logoDataUrl, nombreEmpresa = 'SIS-AGRO') {
```

- [ ] **Step 3: Reemplazar `'SIS-AGRO'` hardcodeado dentro de `dibujarHeader`**

Cambiar la línea:

```js
  doc.text('SIS-AGRO', textX, 11);
```

Por:

```js
  doc.text(nombreEmpresa, textX, 11);
```

- [ ] **Step 4: Actualizar `dibujarFooter` para aceptar `nombreEmpresa`**

Cambiar la línea:

```js
function dibujarFooter(doc) {
```

Por:

```js
function dibujarFooter(doc, nombreEmpresa = 'SIS-AGRO') {
```

Y cambiar la línea con el texto del footer:

```js
    doc.text('SIS-AGRO — Sistema de Gestión Agropecuaria', 10, ph - 7);
```

Por:

```js
    doc.text(`${nombreEmpresa} — Sistema de Gestión Agropecuaria`, 10, ph - 7);
```

- [ ] **Step 5: Reemplazar el bloque `fetch('/logo.png')` dentro de `exportarPDF`**

Localizar y reemplazar el bloque completo:

```js
      // Cargar logo como data URL
      let logoDataUrl = null;
      try {
        const res  = await fetch('/logo.png');
        const blob = await res.blob();
        logoDataUrl = await new Promise(resolve => {
          const reader = new FileReader();
          reader.onloadend = () => resolve(reader.result);
          reader.readAsDataURL(blob);
        });
      } catch { /* si falla, se omite el logo */ }
```

Por:

```js
      // Cargar config de empresa (nombre + logo)
      let config = { nombre_empresa: 'SIS-AGRO', logo: null };
      try {
        const res = await configuracionService.obtener();
        config = res.data;
      } catch { /* usa valores por defecto */ }
      const logoDataUrl = config.logo || null;
```

- [ ] **Step 6: Actualizar las llamadas a `dibujarHeader` y `dibujarFooter` para pasar `nombreEmpresa`**

Cambiar la primera llamada a `dibujarHeader`:

```js
      const headerH  = dibujarHeader(doc, tituloLimpio, subtitulo, logoDataUrl);
```

Por:

```js
      const headerH  = dibujarHeader(doc, tituloLimpio, subtitulo, logoDataUrl, config.nombre_empresa);
```

Cambiar la llamada dentro de `didDrawPage`:

```js
          if (data.pageNumber > 1) {
            dibujarHeader(doc, tituloLimpio, subtitulo, logoDataUrl);
          }
```

Por:

```js
          if (data.pageNumber > 1) {
            dibujarHeader(doc, tituloLimpio, subtitulo, logoDataUrl, config.nombre_empresa);
          }
```

Cambiar la llamada a `dibujarFooter`:

```js
      dibujarFooter(doc);
```

Por:

```js
      dibujarFooter(doc, config.nombre_empresa);
```

- [ ] **Step 7: Verificar que el frontend compila sin errores**

```bash
cd frontend && npm run build
```

Resultado esperado: `✓ built in X.XXs` sin errores.

---

## Task 8: Prueba funcional completa

- [ ] **Step 1: Levantar backend y frontend**

```bash
# Terminal 1
cd backend && npm run dev

# Terminal 2
cd frontend && npm run dev
```

- [ ] **Step 2: Probar la página de configuración**

1. Iniciar sesión como Administrador
2. Navegar a `/configuracion` — debe aparecer la página con el formulario vacío y el menú lateral con "⚙️ Configuración"
3. Completar: Nombre de empresa = "Cooperativa Agropecuaria", NIT = "123456"
4. Hacer clic en "Guardar cambios" — debe aparecer toast verde "Configuración guardada correctamente"
5. Recargar la página — los datos deben persistir

- [ ] **Step 3: Probar upload de logo**

1. En la página de configuración, hacer clic en "📁 Cambiar logo"
2. Seleccionar una imagen PNG/JPG de menos de 500 KB
3. Verificar que el preview aparece inmediatamente
4. Hacer clic en "Guardar cambios" — toast verde
5. Recargar — el logo debe seguir apareciendo

- [ ] **Step 4: Probar integración con PDF**

1. Ir a Reportes → cualquier reporte con datos
2. Hacer clic en "Exportar PDF"
3. Verificar que el PDF generado muestra:
   - El logo subido (o sin logo si no se subió) en el header
   - El nombre "Cooperativa Agropecuaria" (o el que se configuró) en el header
   - El mismo nombre en el footer de cada página

- [ ] **Step 5: Probar restricción de permisos**

1. Iniciar sesión con un usuario que tenga `configuracion.ver` pero NO `configuracion.editar`
2. Ir a `/configuracion` — debe cargar la página
3. Verificar que los inputs están en modo `readOnly` y no aparece el botón "Guardar cambios"
4. Con un usuario sin `configuracion.ver` — el ítem "Configuración" no debe aparecer en el sidebar
