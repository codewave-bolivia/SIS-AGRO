const db = require('../config/db');

// Listar todas las ventas
const listar = async (req, res) => {
  try {
    const [rows] = await db.promise().query(
      `SELECT v.*, c.nombre as cliente_nombre, c.apellido as cliente_apellido, c.ci_nit, 
              u.nombre as usuario_nombre, u.apellido as usuario_apellido
       FROM venta v
       LEFT JOIN cliente c ON v.id_cliente = c.id_cliente
       LEFT JOIN usuario u ON v.id_usuario = u.id_usuario
       ORDER BY v.fecha_venta DESC, v.id_venta DESC`
    );
    return res.json(rows);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Error al obtener historial de ventas' });
  }
};

// Obtener detalle completo de una venta
const obtener = async (req, res) => {
  const { id } = req.params;
  try {
    const [ventaRows] = await db.promise().query(
      `SELECT v.*, c.nombre as cliente_nombre, c.apellido as cliente_apellido, c.ci_nit, c.empresa,
              u.nombre as usuario_nombre, u.apellido as usuario_apellido
       FROM venta v
       LEFT JOIN cliente c ON v.id_cliente = c.id_cliente
       LEFT JOIN usuario u ON v.id_usuario = u.id_usuario
       WHERE v.id_venta = ?`, 
      [id]
    );

    if (ventaRows.length === 0) return res.status(404).json({ error: 'Venta no encontrada' });
    
    const venta = ventaRows[0];

    const [detalleRows] = await db.promise().query(
      `SELECT d.*, p.nombre as producto_nombre, p.codigo_barras, l.numero_lote
       FROM detalle_venta d
       JOIN producto p ON d.id_producto = p.id_producto
       JOIN lote l ON d.id_lote = l.id_lote
       WHERE d.id_venta = ?`,
      [id]
    );

    venta.detalles = detalleRows;
    return res.json(venta);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Error al obtener detalle de venta' });
  }
};

// Crear nueva venta con lógica FIFO para Lotes
const crear = async (req, res) => {
  const { 
    id_cliente, nro_factura, tipo_venta, subtotal, 
    descuento_total, total, monto_pagado, cambio, 
    metodo_pago, observaciones, detalles 
  } = req.body;
  
  const id_usuario = req.user.id_usuario;
  const id_sucursal = req.user.id_sucursal;

  if (!detalles || detalles.length === 0) {
    return res.status(400).json({ error: 'El carrito de ventas está vacío.' });
  }

  const connection = await db.promise().getConnection();
  
  try {
    await connection.beginTransaction();

    // 1. Validar Stock General antes de insertar la cabecera
    // Acumular la cantidad total requerida por producto (convirtiendo cajas a unidades si es necesario)
    const requerimientos = {};
    for (const item of detalles) {
      if (!requerimientos[item.id_producto]) {
        requerimientos[item.id_producto] = {
          cantidadRequerida: 0,
          itemsOriginales: [] // Guardamos las referencias para repartir los montos luego
        };
      }
      
      // Obtener unidades por caja del producto si el tipo es CAJA
      let unidades_a_descontar = parseFloat(item.cantidad);
      if (item.tipo_cantidad === 'CAJA') {
        // Necesitamos saber cuántas unidades tiene la caja de ese producto.
        // Asumiremos que el frontend envía item.unidades_por_caja para facilitar, o consultamos el catálogo/lote.
        // Para mayor precisión, consultaremos la tabla de lotes durante el FIFO, pero como estimación:
        if (!item.unidades_por_caja) {
           throw new Error(`Falta el parámetro unidades_por_caja para el producto ID ${item.id_producto} que se vende por CAJA.`);
        }
        unidades_a_descontar = parseFloat(item.cantidad) * parseFloat(item.unidades_por_caja);
      }

      requerimientos[item.id_producto].cantidadRequerida += unidades_a_descontar;
      requerimientos[item.id_producto].itemsOriginales.push({
        ...item,
        unidades_totales: unidades_a_descontar
      });
    }

    // 2. Insertar Cabecera de la Venta
    const [ventaResult] = await connection.query(
      `INSERT INTO venta 
        (id_sucursal, id_usuario, id_cliente, nro_factura, tipo_venta, subtotal, descuento_total, total, monto_pagado, cambio, metodo_pago, estado, observaciones) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'COMPLETADA', ?)`,
      [
        id_sucursal, id_usuario, id_cliente || null, nro_factura || null, 
        tipo_venta || 'MENOR', subtotal, descuento_total, total, 
        monto_pagado, cambio, metodo_pago || 'EFECTIVO', observaciones || null
      ]
    );
    const id_venta = ventaResult.insertId;

    // 3. Procesar FIFO por Producto
    for (const id_producto in requerimientos) {
      let unidadesFaltantes = requerimientos[id_producto].cantidadRequerida;

      // Obtener lotes activos del producto ordenados por vencimiento (FIFO)
      const [lotes] = await connection.query(
        `SELECT id_lote, stock_unidades, unidades_por_caja, numero_lote 
         FROM lote 
         WHERE id_producto = ? AND id_sucursal = ? AND stock_unidades > 0 AND activo = 1 
         ORDER BY fecha_vencimiento ASC, id_lote ASC FOR UPDATE`,
        [id_producto, id_sucursal]
      );

      // Calcular stock total disponible
      const stockDisponible = lotes.reduce((acc, l) => acc + l.stock_unidades, 0);
      if (stockDisponible < unidadesFaltantes) {
        throw new Error(`Stock insuficiente para el producto ID ${id_producto}. Requerido: ${unidadesFaltantes}, Disponible: ${stockDisponible}`);
      }

      // Descontar FIFO
      // Como un itemOriginal en el carrito puede abarcar varios lotes (o fracciones), 
      // generamos detalles de venta divididos por lote.
      
      let indexLote = 0;
      for (const itemOriginal of requerimientos[id_producto].itemsOriginales) {
        let unidadesItemFaltantes = itemOriginal.unidades_totales;

        while (unidadesItemFaltantes > 0 && indexLote < lotes.length) {
          const loteActual = lotes[indexLote];
          const descontarDeEsteLote = Math.min(unidadesItemFaltantes, loteActual.stock_unidades);

          // Actualizar memoria del lote
          loteActual.stock_unidades -= descontarDeEsteLote;
          unidadesItemFaltantes -= descontarDeEsteLote;

          // Prorratear precios y descuentos para el detalle de venta
          const proporcion = descontarDeEsteLote / itemOriginal.unidades_totales;
          const cantParaDetalle = parseFloat(itemOriginal.cantidad) * proporcion;
          const subtotalDetalle = parseFloat(itemOriginal.subtotal) * proporcion;
          const descMontoDetalle = parseFloat(itemOriginal.descuento_monto || 0) * proporcion;

          // Insertar Detalle Venta con ID Lote
          await connection.query(
            `INSERT INTO detalle_venta 
              (id_venta, id_lote, id_producto, tipo_cantidad, cantidad, precio_unitario, descuento_pct, descuento_monto, subtotal) 
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
            [
              id_venta, loteActual.id_lote, id_producto, itemOriginal.tipo_cantidad, 
              cantParaDetalle, itemOriginal.precio_unitario, itemOriginal.descuento_pct || 0, descMontoDetalle, subtotalDetalle
            ]
          );

          // Actualizar Lote en BD
          const nuevasCajas = Math.floor(loteActual.stock_unidades / loteActual.unidades_por_caja);
          await connection.query(
            'UPDATE lote SET stock_unidades = ?, stock_cajas = ? WHERE id_lote = ?',
            [loteActual.stock_unidades, nuevasCajas, loteActual.id_lote]
          );

          // Insertar Movimiento Almacén (SALIDA)
          await connection.query(
            `INSERT INTO movimiento_almacen 
              (id_lote, id_sucursal, id_usuario, tipo, motivo, cantidad_cajas, cantidad_unidades, referencia_id, referencia_tipo)
             VALUES (?, ?, ?, 'SALIDA', 'VENTA', ?, ?, ?, 'VENTA')`,
            [
              loteActual.id_lote, id_sucursal, id_usuario, 
              Math.floor(descontarDeEsteLote / loteActual.unidades_por_caja), descontarDeEsteLote, 
              id_venta
            ]
          );

          // Si el lote se agotó, pasar al siguiente en la próxima iteración del while
          if (loteActual.stock_unidades === 0) {
            indexLote++;
          }
        }
      }
    }

    await connection.commit();
    return res.status(201).json({ mensaje: 'Venta registrada con éxito', id_venta });

  } catch (err) {
    await connection.rollback();
    console.error('Error al procesar venta:', err);
    return res.status(500).json({ error: err.message || 'Error interno al registrar la venta' });
  } finally {
    connection.release();
  }
};

// Anular venta (Reversión completa de stock)
const anular = async (req, res) => {
  const { id } = req.params;
  const id_usuario = req.user.id_usuario;

  const connection = await db.promise().getConnection();

  try {
    await connection.beginTransaction();

    // 1. Validar estado de la venta
    const [ventaRows] = await connection.query('SELECT estado, id_sucursal FROM venta WHERE id_venta = ? FOR UPDATE', [id]);
    if (ventaRows.length === 0) throw new Error('Venta no encontrada');
    if (ventaRows[0].estado === 'ANULADA') throw new Error('La venta ya se encuentra anulada');

    const id_sucursal = ventaRows[0].id_sucursal;

    // 2. Recuperar detalles para revertir stock
    const [detalles] = await connection.query('SELECT * FROM detalle_venta WHERE id_venta = ?', [id]);

    for (const det of detalles) {
      // Necesitamos las unidades por caja del lote para el recalculo de cajas
      const [loteInfo] = await connection.query('SELECT stock_unidades, unidades_por_caja FROM lote WHERE id_lote = ? FOR UPDATE', [det.id_lote]);
      if (loteInfo.length === 0) continue;

      let unidades_a_devolver = parseFloat(det.cantidad);
      if (det.tipo_cantidad === 'CAJA') {
        unidades_a_devolver = parseFloat(det.cantidad) * loteInfo[0].unidades_por_caja;
      }

      const nuevoStockUnidades = loteInfo[0].stock_unidades + unidades_a_devolver;
      const nuevoStockCajas = Math.floor(nuevoStockUnidades / loteInfo[0].unidades_por_caja);

      // Actualizar stock del lote
      await connection.query(
        'UPDATE lote SET stock_unidades = ?, stock_cajas = ? WHERE id_lote = ?',
        [nuevoStockUnidades, nuevoStockCajas, det.id_lote]
      );

      // Registrar movimiento de almacén (ENTRADA por Anulación)
      await connection.query(
        `INSERT INTO movimiento_almacen 
          (id_lote, id_sucursal, id_usuario, tipo, motivo, cantidad_cajas, cantidad_unidades, referencia_id, referencia_tipo)
         VALUES (?, ?, ?, 'ENTRADA', 'ANULACION DE VENTA', ?, ?, ?, 'ANULACION')`,
        [
          det.id_lote, id_sucursal, id_usuario,
          Math.floor(unidades_a_devolver / loteInfo[0].unidades_por_caja), unidades_a_devolver,
          id
        ]
      );
    }

    // 3. Cambiar estado de la cabecera
    await connection.query('UPDATE venta SET estado = "ANULADA" WHERE id_venta = ?', [id]);

    await connection.commit();
    return res.json({ mensaje: 'Venta anulada y stock retornado correctamente' });

  } catch (err) {
    await connection.rollback();
    console.error('Error al anular venta:', err);
    return res.status(500).json({ error: err.message || 'Error interno al anular la venta' });
  } finally {
    connection.release();
  }
};

module.exports = {
  listar,
  obtener,
  crear,
  anular
};
