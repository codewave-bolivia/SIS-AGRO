-- ================================================================
-- Migración: Módulo Libro de Caja
-- Ejecutar en la base de datos: bd_agropecuaria
-- ================================================================

-- Tabla de categorías de movimientos
CREATE TABLE IF NOT EXISTS categoria_movimiento (
  id_categoria  INT          NOT NULL AUTO_INCREMENT,
  nombre        VARCHAR(100) NOT NULL,
  tipo          ENUM('INGRESO','EGRESO','AMBOS') NOT NULL DEFAULT 'AMBOS',
  activo        TINYINT(1)   NOT NULL DEFAULT 1,
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_categoria),
  UNIQUE KEY uq_nombre (nombre)
);

-- Tabla de movimientos manuales
CREATE TABLE IF NOT EXISTS movimiento (
  id_movimiento  INT            NOT NULL AUTO_INCREMENT,
  tipo           ENUM('INGRESO','EGRESO') NOT NULL,
  id_categoria   INT            NOT NULL,
  descripcion    VARCHAR(255)   NOT NULL,
  monto          DECIMAL(12,2)  NOT NULL,
  fecha          DATE           NOT NULL,
  id_sucursal    INT            DEFAULT NULL,
  id_usuario     INT            NOT NULL,
  observaciones  TEXT           DEFAULT NULL,
  created_at     DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_movimiento),
  FOREIGN KEY (id_categoria) REFERENCES categoria_movimiento(id_categoria),
  FOREIGN KEY (id_sucursal)  REFERENCES sucursal(id_sucursal),
  FOREIGN KEY (id_usuario)   REFERENCES usuario(id_usuario)
);

-- Categorías iniciales
INSERT IGNORE INTO categoria_movimiento (nombre, tipo) VALUES
  ('Servicios básicos',   'EGRESO'),
  ('Sueldos y salarios',  'EGRESO'),
  ('Alquiler',            'EGRESO'),
  ('Transporte',          'EGRESO'),
  ('Mantenimiento',       'EGRESO'),
  ('Otros gastos',        'EGRESO'),
  ('Ingresos varios',     'INGRESO'),
  ('Préstamos recibidos', 'INGRESO');

-- Permisos nuevos
INSERT IGNORE INTO permiso (nombre_clave, descripcion, modulo) VALUES
  ('movimientos.ver',                'Ver libro de caja y movimientos',         'movimientos'),
  ('movimientos.crear',              'Registrar gasto/ingreso manual',          'movimientos'),
  ('movimientos.editar',             'Editar un movimiento manual',             'movimientos'),
  ('movimientos.eliminar',           'Eliminar un movimiento manual',           'movimientos'),
  ('movimientos.ver_todas',          'Ver movimientos de todas las sucursales', 'movimientos'),
  ('categorias_movimiento.ver',      'Ver categorías de movimientos',           'categorias_movimiento'),
  ('categorias_movimiento.gestionar','Crear/editar/eliminar categorías',        'categorias_movimiento');

-- Asignar todos los permisos al Administrador (id_rol = 1)
INSERT IGNORE INTO rol_permiso (id_rol, id_permiso)
SELECT 1, id_permiso FROM permiso
WHERE modulo IN ('movimientos', 'categorias_movimiento');

-- Verificar:
-- SELECT * FROM categoria_movimiento;
-- SELECT p.nombre_clave FROM permiso p JOIN rol_permiso rp ON rp.id_permiso = p.id_permiso WHERE rp.id_rol = 1 AND p.modulo IN ('movimientos','categorias_movimiento');
