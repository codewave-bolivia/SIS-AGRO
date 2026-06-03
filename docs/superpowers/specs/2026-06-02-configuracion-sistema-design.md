# Configuración del Sistema — Diseño

> **Para workers agénticos:** Usar `superpowers:subagent-driven-development` (recomendado) o `superpowers:executing-plans` para implementar este spec tarea por tarea.

**Goal:** Permitir que el administrador configure los datos de la empresa (nombre, NIT, dirección, ciudad, teléfono, correo, logo) desde una página de ajustes, y que esos datos se reflejen automáticamente en los encabezados de los PDFs exportados.

**Architecture:** Tabla `configuracion` de fila única en MariaDB (logo guardado como base64 en columna `MEDIUMTEXT`); backend con dos endpoints REST (GET/PUT); página React con formulario + upload de logo protegida por permisos existentes; `BotonesExportar.jsx` consume la config al generar PDFs eliminando el `fetch('/logo.png')` actual.

**Tech Stack:** Node.js + Express + MariaDB (backend), React + Tailwind CSS (frontend), jsPDF (integración PDF)

---

## 1. Base de Datos

### Tabla nueva: `configuracion`

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

-- Fila inicial con valores por defecto
INSERT INTO configuracion (id_config) VALUES (1);
```

**Invariante:** Solo existe la fila con `id_config = 1`. El backend nunca hace INSERT, solo UPDATE.

**Logo:** Se almacena como data URL base64 (ej: `data:image/png;base64,...`). Tamaño máximo aceptado: 500 KB antes de codificar. Formatos válidos: PNG, JPG, WEBP.

---

## 2. Backend

### Archivos

| Archivo | Acción |
|---------|--------|
| `backend/controllers/configuracion.Controller.js` | Crear |
| `backend/routes/configuracion.Routes.js` | Crear |
| `backend/app.js` | Modificar — registrar la ruta |

### Endpoints

#### `GET /api/configuracion`
- Permiso requerido: `configuracion.ver`
- Respuesta 200: objeto con los 6 campos + `actualizado_en`
- Si la fila no existe (por alguna razón): devuelve objeto con valores vacíos, no error 500

#### `PUT /api/configuracion`
- Permiso requerido: `configuracion.editar`
- Body: `{ nombre_empresa, nit, direccion, ciudad, telefono, correo, logo }`
- `logo`: string base64 data URL, o `null` para mantener el logo actual, o `""` para eliminar el logo
- Validación: `nombre_empresa` no puede estar vacío; si `logo` presente, verificar que sea data URL válida y tamaño ≤ 500 KB
- Acción: `UPDATE configuracion SET ... WHERE id_config = 1`
- Respuesta 200: objeto actualizado completo (incluyendo `logo`)

### Estructura del controller

```js
const obtener = async (req, res) => { /* SELECT * FROM configuracion WHERE id_config = 1 */ };
const actualizar = async (req, res) => { /* UPDATE ... WHERE id_config = 1 */ };
module.exports = { obtener, actualizar };
```

### Registro en app.js

```js
const configuracionRoutes = require('./routes/configuracion.Routes');
app.use('/api/configuracion', configuracionRoutes);
```

---

## 3. Frontend

### Archivos

| Archivo | Acción |
|---------|--------|
| `frontend/src/services/configuracion.service.js` | Crear |
| `frontend/src/pages/configuracion/Configuracion.jsx` | Crear |
| `frontend/src/components/sidebar.jsx` | Modificar — agregar entrada |
| `frontend/src/App.jsx` (o router) | Modificar — agregar ruta `/configuracion` |

### Servicio

```js
import api from './api';
const configuracionService = {
  obtener:    () => api.get('/configuracion'),
  actualizar: (data) => api.put('/configuracion', data),
};
export default configuracionService;
```

### Página `Configuracion.jsx`

- Carga la config actual con `useEffect` al montar
- Formulario con 6 campos: Nombre de empresa*, NIT, Dirección, Ciudad, Teléfono, Correo
- `*` campo obligatorio
- **Sección de logo:**
  - Muestra preview del logo actual (o un placeholder si no hay)
  - Botón "Cambiar logo" abre `<input type="file" accept="image/png,image/jpeg,image/webp">`
  - Al seleccionar archivo: validar tamaño ≤ 500 KB, convertir a base64 con `FileReader`, mostrar preview inmediato
  - Botón "Quitar logo" visible solo si hay logo guardado — pone `logo = ""`
- Botón "Guardar cambios" — deshabilitado si no hay cambios (`hayCambios` comparando form vs datos originales)
- Toast de éxito/error tras guardar (mismo patrón que `Compras.jsx`)
- Campos protegidos: si el usuario solo tiene `configuracion.ver` (sin `.editar`), los inputs son `readOnly` y botones de logo deshabilitados

### Sidebar

Agregar en `MENU_ITEMS` de `sidebar.jsx`, antes de "Sucursales":

```js
{ label: 'Configuración', path: '/configuracion', icono: '⚙️', action: 'ver', subject: 'configuracion' },
```

---

## 4. Integración PDF — `BotonesExportar.jsx`

Al iniciar `exportarPDF`, reemplazar el bloque `fetch('/logo.png')` actual por una llamada a config:

```js
// Reemplaza el bloque fetch('/logo.png') existente
let config = { nombre_empresa: 'SIS-AGRO', logo: null };
try {
  const res = await configuracionService.obtener();
  config = res.data;
} catch { /* usa valores por defecto */ }
const logoDataUrl = config.logo || null; // ya viene como data URL, listo para addImage
```

En `dibujarHeader`, reemplazar el texto hardcodeado:
- `'SIS-AGRO'` → `config.nombre_empresa`
- `'Sistema de Gestión Agropecuaria'` → queda fijo (subtítulo del sistema, no del negocio)
- Footer: `'SIS-AGRO — Sistema de Gestión Agropecuaria'` → `` `${config.nombre_empresa} — Sistema de Gestión Agropecuaria` ``

**Ventaja:** Se elimina el `fetch('/logo.png')` + FileReader actual — el logo ya llega como data URL directo de la config.

---

## 5. Permisos

Los permisos ya están en la BD (`id_permiso` 120 y 121). Solo hay que asegurarse de que el rol Administrador los tenga asignados (verificar en `rol_permiso`).

---

## 6. Flujo completo

```
Admin abre /configuracion
  → GET /api/configuracion → muestra datos actuales
  → edita campos → botón "Guardar" activo
  → PUT /api/configuracion → toast "Configuración guardada"

Cualquier usuario exporta un PDF
  → exportarPDF() llama GET /api/configuracion
  → logoDataUrl = config.logo (ya es data URL, sin fetch adicional)
  → dibujarHeader usa config.nombre_empresa + logoDataUrl
  → PDF generado con nombre y logo real de la empresa
```

---

## 7. Lo que NO incluye este módulo

- IVA, moneda, mensajes de ticket (fuera de scope — solo Grupo A)
- Historial de cambios de configuración
- Actualización del logo en el sidebar (el sidebar sigue usando `/logo.png` estático; el logo de la config solo aplica a los PDFs exportados)
