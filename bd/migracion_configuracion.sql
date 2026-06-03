-- ================================================================
-- Migración: Módulo Configuración del Sistema
-- Ejecutar en la base de datos: bd_agropecuaria
-- ================================================================

-- Si la tabla YA EXISTE (caso de BD en producción), solo agregar la columna logo:
ALTER TABLE configuracion ADD COLUMN IF NOT EXISTS logo MEDIUMTEXT DEFAULT NULL;

-- Si la tabla NO EXISTE, crearla completa:
CREATE TABLE IF NOT EXISTS configuracion (
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

-- Step 2: Insertar fila inicial (solo si no existe)
INSERT IGNORE INTO configuracion (id_config) VALUES (1);

-- Step 3: Asignar permisos de configuracion al rol Administrador (id_rol = 1)
INSERT IGNORE INTO rol_permiso (id_rol, id_permiso)
SELECT 1, id_permiso FROM permiso WHERE modulo = 'configuracion';

-- Verificación:
-- SELECT id_config, nombre_empresa, nit, logo IS NOT NULL AS tiene_logo FROM configuracion;
-- SELECT rp.id_rol, p.nombre_clave FROM rol_permiso rp JOIN permiso p ON p.id_permiso = rp.id_permiso WHERE p.modulo = 'configuracion';
