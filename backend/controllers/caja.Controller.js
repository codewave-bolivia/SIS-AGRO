const db = require('../config/db');

const listarCajas = async (req, res) => {
  try {
    const puedeVerTodas = req.user.permisos.includes('caja.ver_todas');
    let query = `SELECT c.*, s.nombre as sucursal_nombre
                 FROM caja c
                 JOIN sucursal s ON c.id_sucursal = s.id_sucursal`;
    const params = [];
    if (!puedeVerTodas) {
      query += ' WHERE c.id_sucursal = ?';
      params.push(req.user.id_sucursal);
    }
    query += ' ORDER BY c.id_sucursal, c.nombre';
    const [rows] = await db.promise().query(query, params);
    return res.json(rows);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Error al listar cajas' });
  }
};

const crearCaja = async (req, res) => {
  const { nombre, descripcion, id_sucursal } = req.body;
  if (!nombre) return res.status(400).json({ error: 'El nombre es requerido' });
  const sucursal = id_sucursal || req.user.id_sucursal;
  try {
    const [result] = await db.promise().query(
      'INSERT INTO caja (id_sucursal, nombre, descripcion) VALUES (?, ?, ?)',
      [sucursal, nombre.trim(), descripcion || null]
    );
    return res.status(201).json({ mensaje: 'Caja creada', id_caja: result.insertId });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Error al crear caja' });
  }
};

const editarCaja = async (req, res) => {
  const { id } = req.params;
  const { nombre, descripcion } = req.body;
  if (!nombre) return res.status(400).json({ error: 'El nombre es requerido' });
  try {
    await db.promise().query(
      'UPDATE caja SET nombre = ?, descripcion = ? WHERE id_caja = ?',
      [nombre.trim(), descripcion || null, id]
    );
    return res.json({ mensaje: 'Caja actualizada' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Error al editar caja' });
  }
};

const toggleCaja = async (req, res) => {
  const { id } = req.params;
  try {
    const [rows] = await db.promise().query('SELECT activo FROM caja WHERE id_caja = ?', [id]);
    if (rows.length === 0) return res.status(404).json({ error: 'Caja no encontrada' });
    const nuevoEstado = rows[0].activo ? 0 : 1;
    await db.promise().query('UPDATE caja SET activo = ? WHERE id_caja = ?', [nuevoEstado, id]);
    return res.json({ mensaje: `Caja ${nuevoEstado ? 'activada' : 'desactivada'}` });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Error al cambiar estado de caja' });
  }
};

const listarTurnos = async (req, res) => {
  try {
    const puedeVerTodas = req.user.permisos.includes('caja.ver_todas');
    let query = `SELECT ac.*, c.nombre as caja_nombre, s.nombre as sucursal_nombre,
                        u.nombre as usuario_nombre, u.apellido as usuario_apellido
                 FROM apertura_cierre_caja ac
                 JOIN caja c ON ac.id_caja = c.id_caja
                 JOIN sucursal s ON ac.id_sucursal = s.id_sucursal
                 JOIN usuario u ON ac.id_usuario = u.id_usuario`;
    const params = [];
    if (!puedeVerTodas) {
      query += ' WHERE ac.id_sucursal = ?';
      params.push(req.user.id_sucursal);
    }
    query += ' ORDER BY ac.fecha_apertura DESC LIMIT 200';
    const [rows] = await db.promise().query(query, params);
    return res.json(rows);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Error al listar turnos' });
  }
};

const obtenerTurnoActivo = async (req, res) => {
  try {
    const [rows] = await db.promise().query(
      `SELECT ac.*, c.nombre as caja_nombre,
              u.nombre as usuario_nombre, u.apellido as usuario_apellido
       FROM apertura_cierre_caja ac
       JOIN caja c ON ac.id_caja = c.id_caja
       JOIN usuario u ON ac.id_usuario = u.id_usuario
       WHERE ac.id_sucursal = ? AND ac.estado = 'ABIERTA'
       ORDER BY ac.fecha_apertura DESC LIMIT 1`,
      [req.user.id_sucursal]
    );
    return res.json(rows.length === 0 ? null : rows[0]);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Error al obtener turno activo' });
  }
};

const abrirCaja = async (req, res) => {
  const { id_caja, monto_inicial, observaciones } = req.body;
  if (!id_caja) return res.status(400).json({ error: 'Debe seleccionar una caja' });
  try {
    const [abiertos] = await db.promise().query(
      `SELECT id_apertura FROM apertura_cierre_caja WHERE id_sucursal = ? AND estado = 'ABIERTA'`,
      [req.user.id_sucursal]
    );
    if (abiertos.length > 0) {
      return res.status(400).json({ error: 'Ya existe un turno abierto en esta sucursal. Cierre el turno actual primero.' });
    }
    const [cajaRows] = await db.promise().query(
      'SELECT id_caja FROM caja WHERE id_caja = ? AND id_sucursal = ? AND activo = 1',
      [id_caja, req.user.id_sucursal]
    );
    if (cajaRows.length === 0) {
      return res.status(400).json({ error: 'Caja no válida para esta sucursal' });
    }
    const [result] = await db.promise().query(
      `INSERT INTO apertura_cierre_caja (id_caja, id_usuario, id_sucursal, monto_inicial, observaciones)
       VALUES (?, ?, ?, ?, ?)`,
      [id_caja, req.user.id_usuario, req.user.id_sucursal, parseFloat(monto_inicial) || 0, observaciones || null]
    );
    return res.status(201).json({ mensaje: 'Turno abierto correctamente', id_apertura: result.insertId });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Error al abrir turno' });
  }
};

const cerrarCaja = async (req, res) => {
  const { id } = req.params;
  const { monto_final, observaciones } = req.body;
  try {
    const [turnoRows] = await db.promise().query(
      `SELECT * FROM apertura_cierre_caja WHERE id_apertura = ? AND id_sucursal = ? AND estado = 'ABIERTA'`,
      [id, req.user.id_sucursal]
    );
    if (turnoRows.length === 0) {
      return res.status(404).json({ error: 'Turno no encontrado o ya cerrado' });
    }
    const turno = turnoRows[0];

    const [ventasRows] = await db.promise().query(
      `SELECT COALESCE(SUM(total), 0) as total_efectivo
       FROM venta
       WHERE id_sucursal = ? AND metodo_pago = 'EFECTIVO' AND estado = 'COMPLETADA'
             AND fecha_venta >= ?`,
      [req.user.id_sucursal, turno.fecha_apertura]
    );
    const totalEfectivo = parseFloat(ventasRows[0].total_efectivo) || 0;
    const monto_esperado = parseFloat(turno.monto_inicial) + totalEfectivo;
    const monto_final_num = parseFloat(monto_final) || 0;
    const diferencia = monto_final_num - monto_esperado;

    await db.promise().query(
      `UPDATE apertura_cierre_caja
       SET monto_esperado = ?, monto_final = ?, diferencia = ?,
           observaciones = ?, fecha_cierre = NOW(), estado = 'CERRADA'
       WHERE id_apertura = ?`,
      [monto_esperado, monto_final_num, diferencia, observaciones || null, id]
    );
    return res.json({ mensaje: 'Turno cerrado correctamente', monto_esperado, monto_final: monto_final_num, diferencia });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Error al cerrar turno' });
  }
};

module.exports = { listarCajas, crearCaja, editarCaja, toggleCaja, listarTurnos, obtenerTurnoActivo, abrirCaja, cerrarCaja };
