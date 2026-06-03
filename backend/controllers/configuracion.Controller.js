const fs   = require('fs');
const path = require('path');
const db   = require('../config/db');

const UPLOADS_DIR = path.join(__dirname, '../uploads');

function buildLogoUrl(req, logoPath, updatedAt) {
  if (!logoPath) return null;
  const ts = updatedAt ? new Date(updatedAt).getTime() : Date.now();
  return `${req.protocol}://${req.get('host')}${logoPath}?v=${ts}`;
}

function eliminarLogoAnterior() {
  try {
    fs.readdirSync(UPLOADS_DIR)
      .filter(f => f.startsWith('config-logo.'))
      .forEach(f => fs.unlinkSync(path.join(UPLOADS_DIR, f)));
  } catch { /* silencioso */ }
}

const obtener = async (req, res) => {
  try {
    const [rows] = await db.promise().query(
      'SELECT * FROM configuracion WHERE id_config = 1'
    );
    if (rows.length === 0) {
      return res.json({
        nombre_empresa: 'SIS-AGRO',
        nit: null, direccion: null, ciudad: null,
        telefono: null, correo: null, logo: null,
      });
    }
    const config = { ...rows[0], logo: buildLogoUrl(req, rows[0].logo, rows[0].actualizado_en) };
    return res.json(config);
  } catch (err) {
    console.error('[obtener]', err);
    return res.status(500).json({ error: 'Error al obtener la configuración' });
  }
};

const actualizar = async (req, res) => {
  const { nombre_empresa, nit, direccion, ciudad, telefono, correo, logo } = req.body;

  if (!nombre_empresa || !nombre_empresa.trim()) {
    return res.status(400).json({ error: 'El nombre de la empresa es obligatorio' });
  }

  let logoPath = null;

  if (logo && logo.startsWith('data:image/')) {
    // Nueva imagen en base64 — guardar en disco
    const matches = logo.match(/^data:image\/(\w+);base64,(.+)$/s);
    if (!matches) {
      return res.status(400).json({ error: 'Formato de logo inválido' });
    }
    const rawExt   = matches[1];
    const ext      = rawExt === 'jpeg' ? 'jpg' : rawExt;
    const b64Data  = matches[2];
    const sizeBytes = Math.ceil(b64Data.length * 3 / 4);
    if (sizeBytes > 5 * 1024 * 1024) {
      return res.status(400).json({ error: 'El logo supera el tamaño máximo permitido (5 MB)' });
    }
    eliminarLogoAnterior();
    const filename = `config-logo.${ext}`;
    fs.writeFileSync(path.join(UPLOADS_DIR, filename), Buffer.from(b64Data, 'base64'));
    logoPath = `/uploads/${filename}`;

  } else if (logo && logo.startsWith('http')) {
    // URL completa devuelta por el frontend sin cambios — extraer solo el path
    try {
      logoPath = new URL(logo).pathname;
    } catch {
      logoPath = null;
    }

  } else {
    // Logo quitado ('' o null)
    eliminarLogoAnterior();
    logoPath = null;
  }

  try {
    await db.promise().query(
      `UPDATE configuracion
       SET nombre_empresa=?, nit=?, direccion=?, ciudad=?, telefono=?, correo=?, logo=?
       WHERE id_config=1`,
      [
        nombre_empresa.trim(),
        nit       || null,
        direccion || null,
        ciudad    || null,
        telefono  || null,
        correo    || null,
        logoPath,
      ]
    );
    const [rows] = await db.promise().query(
      'SELECT * FROM configuracion WHERE id_config = 1'
    );
    const config = { ...rows[0], logo: buildLogoUrl(req, rows[0].logo, rows[0].actualizado_en) };
    return res.json(config);
  } catch (err) {
    console.error('[actualizar]', err);
    return res.status(500).json({ error: 'Error al actualizar la configuración' });
  }
};

module.exports = { obtener, actualizar };
