-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 08-05-2026 a las 15:07:57
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `bd_agropecuaria`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clasificacion_producto`
--

CREATE TABLE `clasificacion_producto` (
  `id_clasificacion` int(11) NOT NULL,
  `nombre` varchar(80) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cliente`
--

CREATE TABLE `cliente` (
  `id_cliente` int(11) NOT NULL,
  `ci_nit` varchar(20) DEFAULT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellido` varchar(100) DEFAULT NULL,
  `empresa` varchar(150) DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `correo` varchar(100) DEFAULT NULL,
  `direccion` varchar(200) DEFAULT NULL,
  `tipo_cliente` enum('MINORISTA','MAYORISTA') NOT NULL DEFAULT 'MINORISTA',
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `compra`
--

CREATE TABLE `compra` (
  `id_compra` int(11) NOT NULL,
  `id_proveedor` int(11) DEFAULT NULL,
  `id_sucursal` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `nro_factura` varchar(60) DEFAULT NULL,
  `fecha_compra` date NOT NULL,
  `subtotal` decimal(14,2) NOT NULL DEFAULT 0.00,
  `descuento` decimal(14,2) NOT NULL DEFAULT 0.00,
  `total` decimal(14,2) NOT NULL DEFAULT 0.00,
  `estado` enum('PENDIENTE','RECIBIDO','CANCELADO') NOT NULL DEFAULT 'RECIBIDO',
  `observaciones` text DEFAULT NULL,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_compra`
--

CREATE TABLE `detalle_compra` (
  `id_detalle_compra` int(11) NOT NULL,
  `id_compra` int(11) NOT NULL,
  `id_lote` int(11) DEFAULT NULL,
  `id_producto` int(11) NOT NULL,
  `numero_lote_fab` varchar(60) DEFAULT NULL,
  `fecha_produccion` date DEFAULT NULL,
  `fecha_vencimiento` date DEFAULT NULL,
  `cantidad_cajas` int(11) NOT NULL DEFAULT 0,
  `unidades_por_caja` int(11) NOT NULL DEFAULT 1,
  `precio_por_caja` decimal(12,2) NOT NULL DEFAULT 0.00,
  `subtotal` decimal(14,2) NOT NULL DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_venta`
--

CREATE TABLE `detalle_venta` (
  `id_detalle_venta` int(11) NOT NULL,
  `id_venta` int(11) NOT NULL,
  `id_lote` int(11) NOT NULL,
  `id_producto` int(11) NOT NULL,
  `tipo_cantidad` enum('CAJA','UNIDAD') NOT NULL DEFAULT 'UNIDAD',
  `cantidad` int(11) NOT NULL DEFAULT 1,
  `precio_unitario` decimal(12,2) NOT NULL,
  `descuento_pct` decimal(5,2) NOT NULL DEFAULT 0.00,
  `descuento_monto` decimal(12,2) NOT NULL DEFAULT 0.00,
  `subtotal` decimal(14,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `lote`
--

CREATE TABLE `lote` (
  `id_lote` int(11) NOT NULL,
  `id_producto` int(11) NOT NULL,
  `id_sucursal` int(11) NOT NULL,
  `numero_lote` varchar(60) DEFAULT NULL,
  `fecha_produccion` date DEFAULT NULL,
  `fecha_vencimiento` date DEFAULT NULL,
  `fecha_ingreso_almacen` date NOT NULL,
  `cantidad_cajas` int(11) NOT NULL DEFAULT 0,
  `unidades_por_caja` int(11) NOT NULL DEFAULT 1,
  `precio_por_caja` decimal(12,2) NOT NULL DEFAULT 0.00,
  `stock_cajas` int(11) NOT NULL DEFAULT 0,
  `stock_unidades` int(11) NOT NULL DEFAULT 0,
  `observaciones` text DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `marca`
--

CREATE TABLE `marca` (
  `id_marca` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `pais_origen` varchar(60) DEFAULT NULL,
  `descripcion` text DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `movimiento_almacen`
--

CREATE TABLE `movimiento_almacen` (
  `id_movimiento` int(11) NOT NULL,
  `id_lote` int(11) NOT NULL,
  `id_sucursal` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `tipo` enum('ENTRADA','SALIDA','AJUSTE','TRASLADO') NOT NULL,
  `motivo` varchar(100) NOT NULL,
  `cantidad_cajas` int(11) NOT NULL DEFAULT 0,
  `cantidad_unidades` int(11) NOT NULL DEFAULT 0,
  `fecha_movimiento` datetime NOT NULL DEFAULT current_timestamp(),
  `referencia_id` int(11) DEFAULT NULL,
  `referencia_tipo` varchar(30) DEFAULT NULL,
  `observaciones` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `permiso`
--

CREATE TABLE `permiso` (
  `id_permiso` int(11) NOT NULL,
  `modulo` varchar(50) NOT NULL,
  `accion` varchar(50) NOT NULL,
  `nombre_clave` varchar(80) NOT NULL,
  `descripcion` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `permiso`
--

INSERT INTO `permiso` (`id_permiso`, `modulo`, `accion`, `nombre_clave`, `descripcion`) VALUES
(1, 'roles', 'ver', 'roles.ver', 'Ver listado de roles del sistema'),
(2, 'roles', 'crear', 'roles.crear', 'Crear nuevos roles'),
(3, 'roles', 'editar', 'roles.editar', 'Editar nombre de un rol'),
(4, 'roles', 'eliminar', 'roles.eliminar', 'Eliminar roles del sistema'),
(5, 'roles', 'gestionar_permisos', 'roles.gestionar_permisos', 'Asignar y quitar permisos a un rol'),
(6, 'usuarios', 'ver', 'usuarios.ver', 'Ver listado de usuarios del sistema'),
(7, 'usuarios', 'ver_detalle', 'usuarios.ver_detalle', 'Ver ficha completa de un usuario'),
(8, 'usuarios', 'crear', 'usuarios.crear', 'Crear nuevos usuarios'),
(9, 'usuarios', 'editar', 'usuarios.editar', 'Editar datos de un usuario'),
(10, 'usuarios', 'eliminar', 'usuarios.eliminar', 'Eliminar usuarios del sistema'),
(11, 'usuarios', 'activar', 'usuarios.activar', 'Activar o desactivar un usuario'),
(12, 'usuarios', 'cambiar_rol', 'usuarios.cambiar_rol', 'Cambiar el rol asignado a un usuario'),
(13, 'usuarios', 'cambiar_sucursal', 'usuarios.cambiar_sucursal', 'Reasignar usuario a otra sucursal'),
(14, 'usuarios', 'resetear_clave', 'usuarios.resetear_clave', 'Restablecer contraseña de un usuario'),
(15, 'sucursales', 'ver', 'sucursales.ver', 'Ver listado de sucursales'),
(16, 'sucursales', 'ver_detalle', 'sucursales.ver_detalle', 'Ver ficha completa de una sucursal'),
(17, 'sucursales', 'crear', 'sucursales.crear', 'Registrar nuevas sucursales'),
(18, 'sucursales', 'editar', 'sucursales.editar', 'Editar datos de una sucursal'),
(19, 'sucursales', 'eliminar', 'sucursales.eliminar', 'Eliminar sucursales del sistema'),
(20, 'sucursales', 'activar', 'sucursales.activar', 'Activar o desactivar una sucursal'),
(21, 'clasificaciones', 'ver', 'clasificaciones.ver', 'Ver listado de clasificaciones'),
(22, 'clasificaciones', 'crear', 'clasificaciones.crear', 'Crear clasificaciones de producto'),
(23, 'clasificaciones', 'editar', 'clasificaciones.editar', 'Editar una clasificación'),
(24, 'clasificaciones', 'eliminar', 'clasificaciones.eliminar', 'Eliminar una clasificación'),
(25, 'marcas', 'ver', 'marcas.ver', 'Ver listado de marcas'),
(26, 'marcas', 'crear', 'marcas.crear', 'Registrar nuevas marcas'),
(27, 'marcas', 'editar', 'marcas.editar', 'Editar datos de una marca'),
(28, 'marcas', 'eliminar', 'marcas.eliminar', 'Eliminar marcas del sistema'),
(29, 'unidades', 'ver', 'unidades.ver', 'Ver listado de unidades de medida'),
(30, 'unidades', 'crear', 'unidades.crear', 'Crear unidades de medida'),
(31, 'unidades', 'editar', 'unidades.editar', 'Editar una unidad de medida'),
(32, 'unidades', 'eliminar', 'unidades.eliminar', 'Eliminar unidades de medida'),
(33, 'productos', 'ver', 'productos.ver', 'Ver catálogo de productos'),
(34, 'productos', 'ver_detalle', 'productos.ver_detalle', 'Ver ficha completa de un producto'),
(35, 'productos', 'crear', 'productos.crear', 'Agregar productos al catálogo'),
(36, 'productos', 'editar', 'productos.editar', 'Editar datos generales del producto'),
(37, 'productos', 'eliminar', 'productos.eliminar', 'Eliminar productos del catálogo'),
(38, 'productos', 'activar', 'productos.activar', 'Activar o desactivar un producto'),
(39, 'productos', 'ver_costo', 'productos.ver_costo', 'Ver precio de costo (precio_por_caja del lote)'),
(40, 'productos', 'ver_precios', 'productos.ver_precios', 'Ver precios de venta mayor y menor'),
(41, 'productos', 'editar_precios', 'productos.editar_precios', 'Modificar precios de venta mayor y menor'),
(42, 'productos', 'editar_descuentos', 'productos.editar_descuentos', 'Modificar porcentajes de descuento'),
(43, 'productos', 'ver_stock', 'productos.ver_stock', 'Ver stock disponible de productos'),
(44, 'almacen', 'ver', 'almacen.ver', 'Ver inventario general del almacén'),
(45, 'almacen', 'ver_lotes', 'almacen.ver_lotes', 'Ver listado detallado de lotes'),
(46, 'almacen', 'ver_lote_detalle', 'almacen.ver_lote_detalle', 'Ver ficha completa de un lote'),
(47, 'almacen', 'ver_costo_lote', 'almacen.ver_costo_lote', 'Ver precio de costo de cada lote'),
(48, 'almacen', 'ingresar', 'almacen.ingresar', 'Registrar entradas de productos al almacén'),
(49, 'almacen', 'ajustar', 'almacen.ajustar', 'Registrar ajustes de inventario'),
(50, 'almacen', 'trasladar', 'almacen.trasladar', 'Trasladar stock entre sucursales'),
(51, 'almacen', 'ver_movimientos', 'almacen.ver_movimientos', 'Ver historial de movimientos (kardex)'),
(52, 'almacen', 'ver_vencimientos', 'almacen.ver_vencimientos', 'Ver productos próximos a vencer'),
(53, 'almacen', 'dar_baja_lote', 'almacen.dar_baja_lote', 'Dar de baja un lote (vencido o dañado)'),
(54, 'proveedores', 'ver', 'proveedores.ver', 'Ver listado de proveedores'),
(55, 'proveedores', 'ver_detalle', 'proveedores.ver_detalle', 'Ver ficha completa de un proveedor'),
(56, 'proveedores', 'crear', 'proveedores.crear', 'Registrar nuevos proveedores'),
(57, 'proveedores', 'editar', 'proveedores.editar', 'Editar datos de un proveedor'),
(58, 'proveedores', 'eliminar', 'proveedores.eliminar', 'Eliminar proveedores del sistema'),
(59, 'proveedores', 'activar', 'proveedores.activar', 'Activar o desactivar un proveedor'),
(60, 'compras', 'ver', 'compras.ver', 'Ver historial de compras'),
(61, 'compras', 'ver_detalle', 'compras.ver_detalle', 'Ver detalle completo de una compra'),
(62, 'compras', 'ver_costo', 'compras.ver_costo', 'Ver precios de costo en las compras'),
(63, 'compras', 'crear', 'compras.crear', 'Registrar nuevas compras'),
(64, 'compras', 'editar', 'compras.editar', 'Editar compras en estado PENDIENTE'),
(65, 'compras', 'confirmar', 'compras.confirmar', 'Confirmar y cerrar una compra'),
(66, 'compras', 'anular', 'compras.anular', 'Anular una compra registrada'),
(67, 'compras', 'ver_todas_sucursales', 'compras.ver_todas_sucursales', 'Ver compras de todas las sucursales'),
(68, 'clientes', 'ver', 'clientes.ver', 'Ver listado de clientes'),
(69, 'clientes', 'ver_detalle', 'clientes.ver_detalle', 'Ver ficha completa de un cliente'),
(70, 'clientes', 'crear', 'clientes.crear', 'Registrar nuevos clientes'),
(71, 'clientes', 'editar', 'clientes.editar', 'Editar datos de un cliente'),
(72, 'clientes', 'eliminar', 'clientes.eliminar', 'Eliminar clientes del sistema'),
(73, 'clientes', 'activar', 'clientes.activar', 'Activar o desactivar un cliente'),
(74, 'clientes', 'ver_historial', 'clientes.ver_historial', 'Ver historial de compras de un cliente'),
(75, 'clientes', 'cambiar_tipo', 'clientes.cambiar_tipo', 'Cambiar tipo de cliente: minorista / mayorista'),
(76, 'ventas', 'ver', 'ventas.ver', 'Ver historial de ventas propias'),
(77, 'ventas', 'ver_detalle', 'ventas.ver_detalle', 'Ver detalle completo de una venta'),
(78, 'ventas', 'ver_todas', 'ventas.ver_todas', 'Ver ventas de todos los vendedores'),
(79, 'ventas', 'ver_todas_sucursales', 'ventas.ver_todas_sucursales', 'Ver ventas de todas las sucursales'),
(80, 'ventas', 'crear', 'ventas.crear', 'Registrar nuevas ventas'),
(81, 'ventas', 'anular', 'ventas.anular', 'Anular una venta realizada'),
(82, 'ventas', 'aplicar_descuento', 'ventas.aplicar_descuento', 'Aplicar descuento adicional en una venta'),
(83, 'ventas', 'descuento_libre', 'ventas.descuento_libre', 'Ingresar descuento libre (sin límite de porcentaje)'),
(84, 'ventas', 'vender_sin_stock', 'ventas.vender_sin_stock', 'Registrar venta aunque el stock sea 0'),
(85, 'ventas', 'ver_costo', 'ventas.ver_costo', 'Ver el costo y la utilidad de cada venta'),
(86, 'ventas', 'cambiar_precio', 'ventas.cambiar_precio', 'Modificar el precio en el momento de la venta'),
(87, 'ventas', 'reimprimir', 'ventas.reimprimir', 'Reimprimir comprobante de una venta'),
(88, 'traslados', 'ver', 'traslados.ver', 'Ver listado de traslados entre sucursales'),
(89, 'traslados', 'crear', 'traslados.crear', 'Crear un traslado de stock'),
(90, 'traslados', 'confirmar', 'traslados.confirmar', 'Confirmar un traslado pendiente'),
(91, 'traslados', 'cancelar', 'traslados.cancelar', 'Cancelar un traslado pendiente'),
(92, 'reportes', 'ventas_diarias', 'reportes.ventas_diarias', 'Ver reporte de ventas del día'),
(93, 'reportes', 'ventas_rango', 'reportes.ventas_rango', 'Ver reporte de ventas por rango de fechas'),
(94, 'reportes', 'ventas_vendedor', 'reportes.ventas_vendedor', 'Ver reporte de ventas por vendedor'),
(95, 'reportes', 'ventas_producto', 'reportes.ventas_producto', 'Ver reporte de ventas por producto'),
(96, 'reportes', 'ventas_cliente', 'reportes.ventas_cliente', 'Ver reporte de ventas por cliente'),
(97, 'reportes', 'compras', 'reportes.compras', 'Ver reporte de compras realizadas'),
(98, 'reportes', 'compras_proveedor', 'reportes.compras_proveedor', 'Ver reporte de compras por proveedor'),
(99, 'reportes', 'inventario', 'reportes.inventario', 'Ver reporte de inventario actual'),
(100, 'reportes', 'inventario_valorizado', 'reportes.inventario_valorizado', 'Ver inventario con valor de costo total'),
(101, 'reportes', 'ganancias', 'reportes.ganancias', 'Ver reporte de ganancias y utilidad bruta'),
(102, 'reportes', 'ganancias_producto', 'reportes.ganancias_producto', 'Ver utilidad desglosada por producto'),
(103, 'reportes', 'top_productos', 'reportes.top_productos', 'Ver ranking de productos más vendidos'),
(104, 'reportes', 'vencimientos', 'reportes.vencimientos', 'Ver reporte de productos próximos a vencer'),
(105, 'reportes', 'stock_bajo', 'reportes.stock_bajo', 'Ver productos por debajo del stock mínimo'),
(106, 'reportes', 'kardex', 'reportes.kardex', 'Ver kardex (historial de movimientos por lote)'),
(107, 'reportes', 'traslados', 'reportes.traslados', 'Ver reporte de traslados entre sucursales'),
(108, 'reportes', 'comparativo_sucursales', 'reportes.comparativo_sucursales', 'Comparar ventas y ganancias entre sucursales'),
(109, 'configuracion', 'ver', 'configuracion.ver', 'Ver configuración general del sistema'),
(110, 'configuracion', 'editar', 'configuracion.editar', 'Editar configuración general del sistema');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto`
--

CREATE TABLE `producto` (
  `id_producto` int(11) NOT NULL,
  `id_clasificacion` int(11) NOT NULL,
  `id_marca` int(11) NOT NULL,
  `id_unidad` int(11) NOT NULL,
  `nombre` varchar(150) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `codigo_barras` varchar(60) DEFAULT NULL,
  `precio_mayor` decimal(12,2) NOT NULL DEFAULT 0.00,
  `precio_menor` decimal(12,2) NOT NULL DEFAULT 0.00,
  `descuento_mayor` decimal(5,2) NOT NULL DEFAULT 0.00,
  `descuento_menor` decimal(5,2) NOT NULL DEFAULT 0.00,
  `stock_minimo` int(11) NOT NULL DEFAULT 0,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `proveedor`
--

CREATE TABLE `proveedor` (
  `id_proveedor` int(11) NOT NULL,
  `empresa` varchar(150) NOT NULL,
  `nit` varchar(30) DEFAULT NULL,
  `contacto` varchar(100) DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `correo` varchar(100) DEFAULT NULL,
  `direccion` varchar(200) DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rol`
--

CREATE TABLE `rol` (
  `id_rol` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `rol`
--

INSERT INTO `rol` (`id_rol`, `nombre`) VALUES
(1, 'ADMINISTRADOR');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rol_permiso`
--

CREATE TABLE `rol_permiso` (
  `id_rol` int(11) NOT NULL,
  `id_permiso` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `rol_permiso`
--

INSERT INTO `rol_permiso` (`id_rol`, `id_permiso`) VALUES
(1, 1),
(1, 2),
(1, 3),
(1, 4),
(1, 5),
(1, 6),
(1, 7),
(1, 8),
(1, 9),
(1, 10),
(1, 11),
(1, 12),
(1, 13),
(1, 14),
(1, 15),
(1, 16),
(1, 17),
(1, 18),
(1, 19),
(1, 20),
(1, 21),
(1, 22),
(1, 23),
(1, 24),
(1, 25),
(1, 26),
(1, 27),
(1, 28),
(1, 29),
(1, 30),
(1, 31),
(1, 32),
(1, 33),
(1, 34),
(1, 35),
(1, 36),
(1, 37),
(1, 38),
(1, 39),
(1, 40),
(1, 41),
(1, 42),
(1, 43),
(1, 44),
(1, 45),
(1, 46),
(1, 47),
(1, 48),
(1, 49),
(1, 50),
(1, 51),
(1, 52),
(1, 53),
(1, 54),
(1, 55),
(1, 56),
(1, 57),
(1, 58),
(1, 59),
(1, 60),
(1, 61),
(1, 62),
(1, 63),
(1, 64),
(1, 65),
(1, 66),
(1, 67),
(1, 68),
(1, 69),
(1, 70),
(1, 71),
(1, 72),
(1, 73),
(1, 74),
(1, 75),
(1, 76),
(1, 77),
(1, 78),
(1, 79),
(1, 80),
(1, 81),
(1, 82),
(1, 83),
(1, 84),
(1, 85),
(1, 86),
(1, 87),
(1, 88),
(1, 89),
(1, 90),
(1, 91),
(1, 92),
(1, 93),
(1, 94),
(1, 95),
(1, 96),
(1, 97),
(1, 98),
(1, 99),
(1, 100),
(1, 101),
(1, 102),
(1, 103),
(1, 104),
(1, 105),
(1, 106),
(1, 107),
(1, 108),
(1, 109),
(1, 110);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sucursal`
--

CREATE TABLE `sucursal` (
  `id_sucursal` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `direccion` varchar(200) NOT NULL,
  `ciudad` varchar(100) NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `correo` varchar(100) DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `sucursal`
--

INSERT INTO `sucursal` (`id_sucursal`, `nombre`, `direccion`, `ciudad`, `telefono`, `correo`, `activo`, `creado_en`) VALUES
(1, 'Central', 'calle tajibos', 'chimore', '74852612', NULL, 1, '2026-05-08 08:57:49');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `traslado`
--

CREATE TABLE `traslado` (
  `id_traslado` int(11) NOT NULL,
  `id_lote_origen` int(11) NOT NULL,
  `id_sucursal_dest` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `cantidad_cajas` int(11) NOT NULL DEFAULT 0,
  `cantidad_unidades` int(11) NOT NULL DEFAULT 0,
  `fecha_traslado` datetime NOT NULL DEFAULT current_timestamp(),
  `estado` enum('PENDIENTE','CONFIRMADO','CANCELADO') NOT NULL DEFAULT 'PENDIENTE',
  `observaciones` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `unidad_medida`
--

CREATE TABLE `unidad_medida` (
  `id_unidad` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `abreviatura` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `id_usuario` int(11) NOT NULL,
  `id_rol` int(11) DEFAULT NULL,
  `id_sucursal` int(11) DEFAULT NULL,
  `ci` varchar(20) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellido` varchar(100) NOT NULL,
  `celular` varchar(20) DEFAULT NULL,
  `correo` varchar(100) DEFAULT NULL,
  `contrasena` varchar(255) NOT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`id_usuario`, `id_rol`, `id_sucursal`, `ci`, `nombre`, `apellido`, `celular`, `correo`, `contrasena`, `activo`, `creado_en`) VALUES
(1, 1, 1, '9391668', 'Felipe', 'Mejia', '74819122', 'felipe@gmail.com', '$2b$10$qSC2iZ4BGRaPBpbuO/JnCekATmnaQ.2AoskxHzmjQItUZkiYklfXi', 1, '2026-05-08 09:03:43');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `venta`
--

CREATE TABLE `venta` (
  `id_venta` int(11) NOT NULL,
  `id_sucursal` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `id_cliente` int(11) DEFAULT NULL,
  `nro_factura` varchar(60) DEFAULT NULL,
  `fecha_venta` datetime NOT NULL DEFAULT current_timestamp(),
  `tipo_venta` enum('MENOR','MAYOR') NOT NULL DEFAULT 'MENOR',
  `subtotal` decimal(14,2) NOT NULL DEFAULT 0.00,
  `descuento_total` decimal(14,2) NOT NULL DEFAULT 0.00,
  `total` decimal(14,2) NOT NULL DEFAULT 0.00,
  `monto_pagado` decimal(14,2) NOT NULL DEFAULT 0.00,
  `cambio` decimal(14,2) NOT NULL DEFAULT 0.00,
  `metodo_pago` enum('EFECTIVO','TRANSFERENCIA','QR','CREDITO','OTRO') NOT NULL DEFAULT 'EFECTIVO',
  `estado` enum('COMPLETADA','ANULADA','PENDIENTE') NOT NULL DEFAULT 'COMPLETADA',
  `observaciones` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `clasificacion_producto`
--
ALTER TABLE `clasificacion_producto`
  ADD PRIMARY KEY (`id_clasificacion`),
  ADD UNIQUE KEY `nombre` (`nombre`);

--
-- Indices de la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`id_cliente`),
  ADD UNIQUE KEY `ci_nit` (`ci_nit`);

--
-- Indices de la tabla `compra`
--
ALTER TABLE `compra`
  ADD PRIMARY KEY (`id_compra`),
  ADD KEY `id_proveedor` (`id_proveedor`),
  ADD KEY `id_sucursal` (`id_sucursal`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- Indices de la tabla `detalle_compra`
--
ALTER TABLE `detalle_compra`
  ADD PRIMARY KEY (`id_detalle_compra`),
  ADD KEY `id_compra` (`id_compra`),
  ADD KEY `id_lote` (`id_lote`),
  ADD KEY `id_producto` (`id_producto`);

--
-- Indices de la tabla `detalle_venta`
--
ALTER TABLE `detalle_venta`
  ADD PRIMARY KEY (`id_detalle_venta`),
  ADD KEY `id_venta` (`id_venta`),
  ADD KEY `id_lote` (`id_lote`),
  ADD KEY `id_producto` (`id_producto`);

--
-- Indices de la tabla `lote`
--
ALTER TABLE `lote`
  ADD PRIMARY KEY (`id_lote`),
  ADD KEY `id_producto` (`id_producto`),
  ADD KEY `id_sucursal` (`id_sucursal`);

--
-- Indices de la tabla `marca`
--
ALTER TABLE `marca`
  ADD PRIMARY KEY (`id_marca`);

--
-- Indices de la tabla `movimiento_almacen`
--
ALTER TABLE `movimiento_almacen`
  ADD PRIMARY KEY (`id_movimiento`),
  ADD KEY `id_lote` (`id_lote`),
  ADD KEY `id_sucursal` (`id_sucursal`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- Indices de la tabla `permiso`
--
ALTER TABLE `permiso`
  ADD PRIMARY KEY (`id_permiso`),
  ADD UNIQUE KEY `nombre_clave` (`nombre_clave`);

--
-- Indices de la tabla `producto`
--
ALTER TABLE `producto`
  ADD PRIMARY KEY (`id_producto`),
  ADD UNIQUE KEY `codigo_barras` (`codigo_barras`),
  ADD KEY `id_clasificacion` (`id_clasificacion`),
  ADD KEY `id_marca` (`id_marca`),
  ADD KEY `id_unidad` (`id_unidad`);

--
-- Indices de la tabla `proveedor`
--
ALTER TABLE `proveedor`
  ADD PRIMARY KEY (`id_proveedor`),
  ADD UNIQUE KEY `nit` (`nit`);

--
-- Indices de la tabla `rol`
--
ALTER TABLE `rol`
  ADD PRIMARY KEY (`id_rol`);

--
-- Indices de la tabla `rol_permiso`
--
ALTER TABLE `rol_permiso`
  ADD PRIMARY KEY (`id_rol`,`id_permiso`),
  ADD KEY `id_permiso` (`id_permiso`);

--
-- Indices de la tabla `sucursal`
--
ALTER TABLE `sucursal`
  ADD PRIMARY KEY (`id_sucursal`);

--
-- Indices de la tabla `traslado`
--
ALTER TABLE `traslado`
  ADD PRIMARY KEY (`id_traslado`),
  ADD KEY `id_lote_origen` (`id_lote_origen`),
  ADD KEY `id_sucursal_dest` (`id_sucursal_dest`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- Indices de la tabla `unidad_medida`
--
ALTER TABLE `unidad_medida`
  ADD PRIMARY KEY (`id_unidad`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `ci` (`ci`),
  ADD UNIQUE KEY `correo` (`correo`),
  ADD KEY `id_rol` (`id_rol`),
  ADD KEY `id_sucursal` (`id_sucursal`);

--
-- Indices de la tabla `venta`
--
ALTER TABLE `venta`
  ADD PRIMARY KEY (`id_venta`),
  ADD KEY `id_sucursal` (`id_sucursal`),
  ADD KEY `id_usuario` (`id_usuario`),
  ADD KEY `id_cliente` (`id_cliente`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `clasificacion_producto`
--
ALTER TABLE `clasificacion_producto`
  MODIFY `id_clasificacion` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `cliente`
--
ALTER TABLE `cliente`
  MODIFY `id_cliente` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `compra`
--
ALTER TABLE `compra`
  MODIFY `id_compra` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `detalle_compra`
--
ALTER TABLE `detalle_compra`
  MODIFY `id_detalle_compra` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `detalle_venta`
--
ALTER TABLE `detalle_venta`
  MODIFY `id_detalle_venta` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `lote`
--
ALTER TABLE `lote`
  MODIFY `id_lote` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `marca`
--
ALTER TABLE `marca`
  MODIFY `id_marca` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `movimiento_almacen`
--
ALTER TABLE `movimiento_almacen`
  MODIFY `id_movimiento` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `permiso`
--
ALTER TABLE `permiso`
  MODIFY `id_permiso` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=111;

--
-- AUTO_INCREMENT de la tabla `producto`
--
ALTER TABLE `producto`
  MODIFY `id_producto` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `proveedor`
--
ALTER TABLE `proveedor`
  MODIFY `id_proveedor` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `rol`
--
ALTER TABLE `rol`
  MODIFY `id_rol` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `sucursal`
--
ALTER TABLE `sucursal`
  MODIFY `id_sucursal` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `traslado`
--
ALTER TABLE `traslado`
  MODIFY `id_traslado` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `unidad_medida`
--
ALTER TABLE `unidad_medida`
  MODIFY `id_unidad` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `venta`
--
ALTER TABLE `venta`
  MODIFY `id_venta` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `compra`
--
ALTER TABLE `compra`
  ADD CONSTRAINT `compra_ibfk_1` FOREIGN KEY (`id_proveedor`) REFERENCES `proveedor` (`id_proveedor`) ON DELETE SET NULL,
  ADD CONSTRAINT `compra_ibfk_2` FOREIGN KEY (`id_sucursal`) REFERENCES `sucursal` (`id_sucursal`),
  ADD CONSTRAINT `compra_ibfk_3` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`);

--
-- Filtros para la tabla `detalle_compra`
--
ALTER TABLE `detalle_compra`
  ADD CONSTRAINT `detalle_compra_ibfk_1` FOREIGN KEY (`id_compra`) REFERENCES `compra` (`id_compra`) ON DELETE CASCADE,
  ADD CONSTRAINT `detalle_compra_ibfk_2` FOREIGN KEY (`id_lote`) REFERENCES `lote` (`id_lote`) ON DELETE SET NULL,
  ADD CONSTRAINT `detalle_compra_ibfk_3` FOREIGN KEY (`id_producto`) REFERENCES `producto` (`id_producto`);

--
-- Filtros para la tabla `detalle_venta`
--
ALTER TABLE `detalle_venta`
  ADD CONSTRAINT `detalle_venta_ibfk_1` FOREIGN KEY (`id_venta`) REFERENCES `venta` (`id_venta`) ON DELETE CASCADE,
  ADD CONSTRAINT `detalle_venta_ibfk_2` FOREIGN KEY (`id_lote`) REFERENCES `lote` (`id_lote`),
  ADD CONSTRAINT `detalle_venta_ibfk_3` FOREIGN KEY (`id_producto`) REFERENCES `producto` (`id_producto`);

--
-- Filtros para la tabla `lote`
--
ALTER TABLE `lote`
  ADD CONSTRAINT `lote_ibfk_1` FOREIGN KEY (`id_producto`) REFERENCES `producto` (`id_producto`),
  ADD CONSTRAINT `lote_ibfk_2` FOREIGN KEY (`id_sucursal`) REFERENCES `sucursal` (`id_sucursal`);

--
-- Filtros para la tabla `movimiento_almacen`
--
ALTER TABLE `movimiento_almacen`
  ADD CONSTRAINT `movimiento_almacen_ibfk_1` FOREIGN KEY (`id_lote`) REFERENCES `lote` (`id_lote`),
  ADD CONSTRAINT `movimiento_almacen_ibfk_2` FOREIGN KEY (`id_sucursal`) REFERENCES `sucursal` (`id_sucursal`),
  ADD CONSTRAINT `movimiento_almacen_ibfk_3` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`);

--
-- Filtros para la tabla `producto`
--
ALTER TABLE `producto`
  ADD CONSTRAINT `producto_ibfk_1` FOREIGN KEY (`id_clasificacion`) REFERENCES `clasificacion_producto` (`id_clasificacion`),
  ADD CONSTRAINT `producto_ibfk_2` FOREIGN KEY (`id_marca`) REFERENCES `marca` (`id_marca`),
  ADD CONSTRAINT `producto_ibfk_3` FOREIGN KEY (`id_unidad`) REFERENCES `unidad_medida` (`id_unidad`);

--
-- Filtros para la tabla `rol_permiso`
--
ALTER TABLE `rol_permiso`
  ADD CONSTRAINT `rol_permiso_ibfk_1` FOREIGN KEY (`id_rol`) REFERENCES `rol` (`id_rol`) ON DELETE CASCADE,
  ADD CONSTRAINT `rol_permiso_ibfk_2` FOREIGN KEY (`id_permiso`) REFERENCES `permiso` (`id_permiso`) ON DELETE CASCADE;

--
-- Filtros para la tabla `traslado`
--
ALTER TABLE `traslado`
  ADD CONSTRAINT `traslado_ibfk_1` FOREIGN KEY (`id_lote_origen`) REFERENCES `lote` (`id_lote`),
  ADD CONSTRAINT `traslado_ibfk_2` FOREIGN KEY (`id_sucursal_dest`) REFERENCES `sucursal` (`id_sucursal`),
  ADD CONSTRAINT `traslado_ibfk_3` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`);

--
-- Filtros para la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD CONSTRAINT `usuario_ibfk_1` FOREIGN KEY (`id_rol`) REFERENCES `rol` (`id_rol`) ON DELETE SET NULL,
  ADD CONSTRAINT `usuario_ibfk_2` FOREIGN KEY (`id_sucursal`) REFERENCES `sucursal` (`id_sucursal`) ON DELETE SET NULL;

--
-- Filtros para la tabla `venta`
--
ALTER TABLE `venta`
  ADD CONSTRAINT `venta_ibfk_1` FOREIGN KEY (`id_sucursal`) REFERENCES `sucursal` (`id_sucursal`),
  ADD CONSTRAINT `venta_ibfk_2` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`),
  ADD CONSTRAINT `venta_ibfk_3` FOREIGN KEY (`id_cliente`) REFERENCES `cliente` (`id_cliente`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
