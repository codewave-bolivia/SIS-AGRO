-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 03-06-2026 a las 13:23:41
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
-- Estructura de tabla para la tabla `apertura_cierre_caja`
--

CREATE TABLE `apertura_cierre_caja` (
  `id_apertura` int(11) NOT NULL,
  `id_caja` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `id_sucursal` int(11) NOT NULL,
  `monto_inicial` decimal(14,2) NOT NULL DEFAULT 0.00,
  `monto_esperado` decimal(14,2) DEFAULT NULL,
  `monto_final` decimal(14,2) DEFAULT NULL,
  `diferencia` decimal(14,2) DEFAULT NULL,
  `fecha_apertura` datetime NOT NULL DEFAULT current_timestamp(),
  `fecha_cierre` datetime DEFAULT NULL,
  `estado` enum('ABIERTA','CERRADA') NOT NULL DEFAULT 'ABIERTA',
  `observaciones` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `apertura_cierre_caja`
--

INSERT INTO `apertura_cierre_caja` (`id_apertura`, `id_caja`, `id_usuario`, `id_sucursal`, `monto_inicial`, `monto_esperado`, `monto_final`, `diferencia`, `fecha_apertura`, `fecha_cierre`, `estado`, `observaciones`) VALUES
(1, 1, 2, 1, 500.00, 4070.00, 4080.00, 10.00, '2026-05-20 08:00:00', '2026-05-20 18:30:00', 'CERRADA', 'Turno sin novedad. Sobrante Bs 10 por redondeo en cambio.'),
(2, 1, 3, 1, 500.00, 815.00, 500.00, -315.00, '2026-05-26 08:00:00', '2026-05-27 11:27:53', 'CERRADA', NULL),
(3, 3, 4, 2, 300.00, 300.00, 200.00, -100.00, '2026-05-26 08:30:00', '2026-06-01 04:26:43', 'CERRADA', NULL),
(4, 4, 1, 3, 50.00, 1025.00, 2000.00, 975.00, '2026-05-27 08:23:56', '2026-05-27 09:02:53', 'CERRADA', NULL),
(5, 4, 1, 3, 100.00, 1500.00, 1500.00, 0.00, '2026-05-27 09:03:35', '2026-05-27 09:05:21', 'CERRADA', NULL),
(6, 1, 5, 1, 100.00, 345.00, 345.00, 0.00, '2026-05-27 14:52:59', '2026-05-27 14:54:14', 'CERRADA', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `caja`
--

CREATE TABLE `caja` (
  `id_caja` int(11) NOT NULL,
  `id_sucursal` int(11) NOT NULL,
  `nombre` varchar(80) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `caja`
--

INSERT INTO `caja` (`id_caja`, `id_sucursal`, `nombre`, `descripcion`, `activo`, `creado_en`) VALUES
(1, 1, 'Caja Principal Sucursal Central', 'Caja principal de atención — Sucursal Central', 1, '2026-05-26 15:27:53'),
(2, 1, 'Caja 2 Sucursal central', 'Segunda caja para temporada alta — Sucursal Central', 1, '2026-05-26 15:27:53'),
(3, 2, 'Caja Principal Sucursal Norte', 'Caja única — Sucursal Norte', 1, '2026-05-26 15:27:53'),
(4, 3, 'Caja Principal Sucursal Cochabamba', 'Caja única — Sucursal Cochabamba', 1, '2026-05-26 15:27:53');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categoria_movimiento`
--

CREATE TABLE `categoria_movimiento` (
  `id_categoria` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `tipo` enum('INGRESO','EGRESO','AMBOS') NOT NULL DEFAULT 'AMBOS',
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `categoria_movimiento`
--

INSERT INTO `categoria_movimiento` (`id_categoria`, `nombre`, `tipo`, `activo`, `created_at`) VALUES
(1, 'Servicios básicos', 'EGRESO', 1, '2026-06-03 07:23:32'),
(2, 'Sueldos y salarios', 'EGRESO', 1, '2026-06-03 07:23:32'),
(3, 'Alquiler', 'EGRESO', 1, '2026-06-03 07:23:32'),
(4, 'Transporte', 'EGRESO', 1, '2026-06-03 07:23:32'),
(5, 'Mantenimiento', 'EGRESO', 1, '2026-06-03 07:23:32'),
(6, 'Otros gastos', 'EGRESO', 1, '2026-06-03 07:23:32'),
(7, 'Ingresos varios', 'INGRESO', 1, '2026-06-03 07:23:32'),
(8, 'Préstamos recibidos', 'INGRESO', 1, '2026-06-03 07:23:32');

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

--
-- Volcado de datos para la tabla `clasificacion_producto`
--

INSERT INTO `clasificacion_producto` (`id_clasificacion`, `nombre`, `descripcion`, `activo`) VALUES
(1, 'Semillas', 'Semillas certificadas para siembra', 1),
(2, 'Fertilizantes', 'Abonos y nutrientes para el suelo', 1),
(3, 'Agroquímicos', 'Herbicidas, fungicidas e insecticidas', 1),
(4, 'Veterinaria', 'Medicamentos y vacunas para animales', 1),
(5, 'Herramientas', 'Equipos y herramientas de labranza', 1),
(6, 'Alimento Animal', 'Balanceados y suplementos para ganado y aves', 1),
(7, 'Riego', 'Equipos y accesorios para sistemas de riego', 1);

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

--
-- Volcado de datos para la tabla `cliente`
--

INSERT INTO `cliente` (`id_cliente`, `ci_nit`, `nombre`, `apellido`, `empresa`, `telefono`, `correo`, `direccion`, `tipo_cliente`, `activo`, `creado_en`) VALUES
(1, '6012345001', 'Gerencia', NULL, 'Agroindustrias El Campo S.R.L.', '33412300', 'compras@elcampo.bo', 'Km 12 Carretera al Norte, Santa Cruz', 'MAYORISTA', 1, '2026-05-26 15:27:53'),
(2, '7023456002', 'Gerencia', NULL, 'Cooperativa Agrícola San Juan', '33423456', 'coop.sanjuan@gmail.com', 'Municipio San Juan, Santa Cruz', 'MAYORISTA', 1, '2026-05-26 15:27:53'),
(3, '8034567003', 'Gerencia', NULL, 'Hacienda Los Pinos', '71534560', 'lospinos@hotmail.com', 'Yapacaní, Santa Cruz', 'MAYORISTA', 1, '2026-05-26 15:27:53'),
(4, '3456701', 'Pedro', 'Quisbert Mamani', NULL, '76345678', NULL, 'Comunidad El Palmar, Cochabamba', 'MINORISTA', 1, '2026-05-26 15:27:53'),
(5, '4567802', 'Rosa', 'Torrico Alvarado', NULL, '71456789', NULL, 'Barrio San Aurelio, Santa Cruz', 'MINORISTA', 1, '2026-05-26 15:27:53'),
(6, '5678903', 'Jorge', 'Vaca Suárez', NULL, '68567890', NULL, 'Montero, Santa Cruz', 'MINORISTA', 1, '2026-05-26 15:27:53'),
(7, '6789004', 'Carmen', 'Aguilar López', NULL, '79678901', NULL, 'Warnes, Santa Cruz', 'MINORISTA', 1, '2026-05-26 15:27:53'),
(8, '7890105', 'Efraín', 'Chura Condori', NULL, '73789012', NULL, 'Colcapirhua, Cochabamba', 'MINORISTA', 1, '2026-05-26 15:27:53');

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

--
-- Volcado de datos para la tabla `compra`
--

INSERT INTO `compra` (`id_compra`, `id_proveedor`, `id_sucursal`, `id_usuario`, `nro_factura`, `fecha_compra`, `subtotal`, `descuento`, `total`, `estado`, `observaciones`, `creado_en`) VALUES
(1, 1, 1, 6, 'FACT-AGR-0001-2026', '2026-01-10', 24750.00, 750.00, 24000.00, 'RECIBIDO', NULL, '2026-05-26 15:27:53'),
(2, 5, 1, 6, 'FACT-AGR-0002-2026', '2026-02-05', 15900.00, 400.00, 15500.00, 'RECIBIDO', NULL, '2026-05-26 15:27:53'),
(3, 4, 2, 7, 'FACT-AGR-0003-2026', '2026-03-15', 14050.00, 50.00, 14000.00, 'RECIBIDO', NULL, '2026-05-26 15:27:53'),
(4, 3, 3, 8, 'FACT-AGR-0004-2026', '2026-04-20', 20000.00, 0.00, 20000.00, 'RECIBIDO', NULL, '2026-05-26 15:27:53'),
(5, 1, 3, 1, NULL, '2026-05-27', 40000.00, 0.00, 40000.00, 'RECIBIDO', NULL, '2026-05-27 08:56:36'),
(6, 1, 3, 1, NULL, '2026-05-27', 400.00, 0.00, 400.00, 'RECIBIDO', NULL, '2026-05-27 08:58:51'),
(7, 1, 3, 1, NULL, '2026-05-27', 2400.00, 0.00, 2400.00, 'RECIBIDO', NULL, '2026-05-27 15:02:25'),
(8, 1, 3, 1, NULL, '2026-05-27', 5000.00, 0.00, 5000.00, 'RECIBIDO', NULL, '2026-05-27 18:27:36'),
(9, 2, 3, 1, 'F-001', '2026-06-01', 1200.00, 0.00, 1200.00, 'RECIBIDO', 'nada', '2026-06-01 04:18:07');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `configuracion`
--

CREATE TABLE `configuracion` (
  `id_config` int(11) NOT NULL DEFAULT 1,
  `nombre_empresa` varchar(150) NOT NULL DEFAULT 'SIS-AGRO',
  `nit` varchar(30) DEFAULT NULL,
  `direccion` varchar(200) DEFAULT NULL,
  `ciudad` varchar(100) DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `correo` varchar(100) DEFAULT NULL,
  `actualizado_en` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `configuracion`
--

INSERT INTO `configuracion` (`id_config`, `nombre_empresa`, `nit`, `direccion`, `ciudad`, `telefono`, `correo`, `actualizado_en`) VALUES
(1, 'SIS-AGRO', NULL, NULL, NULL, NULL, NULL, '2026-06-02 10:53:40');

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

--
-- Volcado de datos para la tabla `detalle_compra`
--

INSERT INTO `detalle_compra` (`id_detalle_compra`, `id_compra`, `id_lote`, `id_producto`, `numero_lote_fab`, `fecha_produccion`, `fecha_vencimiento`, `cantidad_cajas`, `unidades_por_caja`, `precio_por_caja`, `subtotal`) VALUES
(1, 1, 1, 1, 'L-MAI-2601', '2025-10-01', '2027-09-30', 50, 1, 120.00, 6000.00),
(2, 1, 2, 2, 'L-SOY-2601', '2025-10-15', '2027-10-14', 30, 1, 95.00, 2850.00),
(3, 1, 3, 5, 'L-URE-2601', '2025-08-01', '2028-07-31', 40, 1, 210.00, 8400.00),
(4, 1, 4, 6, 'L-NPK-2601', '2025-09-01', '2028-08-31', 30, 1, 250.00, 7500.00),
(5, 2, 5, 8, 'L-RDP-2602', '2025-06-01', '2027-05-31', 20, 1, 180.00, 3600.00),
(6, 2, 6, 9, 'L-AMX-2602', '2025-07-01', '2027-06-30', 15, 1, 450.00, 6750.00),
(7, 2, 7, 10, 'L-DEC-2602', '2025-07-15', '2027-07-14', 10, 1, 280.00, 2800.00),
(8, 2, 8, 11, 'L-24D-2602', '2025-08-01', '2027-07-31', 25, 1, 90.00, 2250.00),
(9, 3, 9, 12, 'L-IVM-2603', '2025-11-01', '2027-10-31', 15, 1, 320.00, 4800.00),
(10, 3, 10, 13, 'L-VAC-2603', '2025-12-01', '2026-11-30', 20, 1, 280.00, 5600.00),
(11, 3, 11, 14, 'L-OXI-2603', '2025-11-15', '2027-11-14', 12, 1, 150.00, 1800.00),
(12, 3, 12, 15, 'L-BAL-2603', '2026-01-01', '2026-12-31', 30, 1, 195.00, 5850.00),
(13, 4, 13, 5, 'L-URE-2604', '2025-08-01', '2028-07-31', 35, 1, 210.00, 7350.00),
(14, 4, 14, 6, 'L-NPK-2604', '2025-09-01', '2028-08-31', 25, 1, 250.00, 6250.00),
(15, 4, 15, 7, 'L-SOP-2604', '2025-10-01', '2028-09-30', 20, 1, 320.00, 6400.00),
(16, 5, 18, 15, 'L-0903902', '2025-07-27', '2027-02-27', 20, 12, 2000.00, 40000.00),
(17, 6, 19, 15, 'L-1234', '2023-02-27', '2027-03-27', 2, 12, 200.00, 400.00),
(18, 7, 20, 9, NULL, '2025-09-27', '2026-06-27', 2, 12, 1200.00, 2400.00),
(19, 8, 21, 6, NULL, '2025-11-27', '2026-08-27', 1, 12, 5000.00, 5000.00),
(20, 9, 23, 16, 'L-0000', '2026-01-01', '2026-09-01', 1, 12, 1200.00, 1200.00);

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

--
-- Volcado de datos para la tabla `detalle_venta`
--

INSERT INTO `detalle_venta` (`id_detalle_venta`, `id_venta`, `id_lote`, `id_producto`, `tipo_cantidad`, `cantidad`, `precio_unitario`, `descuento_pct`, `descuento_monto`, `subtotal`) VALUES
(1, 1, 3, 5, 'CAJA', 10, 235.00, 8.00, 188.00, 2162.00),
(2, 1, 4, 6, 'CAJA', 7, 280.00, 8.00, 156.80, 1803.20),
(3, 2, 1, 1, 'CAJA', 3, 135.00, 0.00, 0.00, 405.00),
(4, 3, 5, 8, 'CAJA', 1, 210.00, 0.00, 0.00, 210.00),
(5, 3, 8, 11, 'CAJA', 1, 105.00, 0.00, 0.00, 105.00),
(6, 4, 3, 5, 'CAJA', 8, 210.00, 8.00, 134.40, 1545.60),
(7, 4, 4, 6, 'CAJA', 8, 250.00, 8.00, 160.00, 1840.00),
(8, 4, 6, 9, 'CAJA', 2, 450.00, 8.00, 72.00, 828.00),
(9, 5, 5, 8, 'CAJA', 1, 210.00, 0.00, 0.00, 210.00),
(10, 6, 9, 12, 'CAJA', 10, 320.00, 6.00, 192.00, 3008.00),
(11, 6, 10, 13, 'CAJA', 6, 280.00, 6.00, 100.80, 1579.20),
(12, 7, 18, 15, 'UNIDAD', 2, 215.00, 0.00, 0.00, 430.00),
(13, 8, 13, 5, 'UNIDAD', 1, 235.00, 0.00, 0.00, 235.00),
(14, 8, 16, 13, 'UNIDAD', 1, 310.00, 0.00, 0.00, 310.00),
(15, 9, 14, 6, 'UNIDAD', 1, 280.00, 0.00, 0.00, 280.00),
(16, 9, 18, 15, 'UNIDAD', 1, 215.00, 0.00, 0.00, 215.00),
(17, 10, 13, 5, 'UNIDAD', 1, 235.00, 0.00, 0.00, 235.00),
(18, 10, 15, 7, 'UNIDAD', 1, 360.00, 0.00, 0.00, 360.00),
(19, 10, 16, 13, 'UNIDAD', 1, 310.00, 0.00, 0.00, 310.00),
(20, 11, 13, 5, 'UNIDAD', 1, 235.00, 0.00, 0.00, 235.00),
(21, 11, 15, 7, 'UNIDAD', 1, 360.00, 0.00, 0.00, 360.00),
(22, 12, 13, 5, 'UNIDAD', 1, 235.00, 0.00, 0.00, 235.00),
(23, 12, 15, 7, 'UNIDAD', 1, 360.00, 0.00, 0.00, 360.00),
(24, 13, 14, 6, 'UNIDAD', 1, 280.00, 0.00, 0.00, 280.00),
(25, 13, 15, 7, 'UNIDAD', 1, 360.00, 0.00, 0.00, 360.00),
(26, 14, 1, 1, 'UNIDAD', 1, 135.00, 0.00, 0.00, 135.00),
(27, 14, 2, 2, 'UNIDAD', 1, 110.00, 0.00, 0.00, 110.00),
(28, 15, 21, 6, 'UNIDAD', 1, 280.00, 3.00, 8.40, 271.60),
(29, 15, 18, 15, 'UNIDAD', 1, 215.00, 3.00, 6.45, 208.55);

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

--
-- Volcado de datos para la tabla `lote`
--

INSERT INTO `lote` (`id_lote`, `id_producto`, `id_sucursal`, `numero_lote`, `fecha_produccion`, `fecha_vencimiento`, `fecha_ingreso_almacen`, `cantidad_cajas`, `unidades_por_caja`, `precio_por_caja`, `stock_cajas`, `stock_unidades`, `observaciones`, `activo`, `creado_en`) VALUES
(1, 1, 1, 'L-MAI-2601', '2025-10-01', '2027-09-30', '2026-01-10', 50, 1, 120.00, 89, 89, NULL, 1, '2026-05-26 15:27:53'),
(2, 2, 1, 'L-SOY-2601', '2025-10-15', '2027-10-14', '2026-01-10', 30, 1, 95.00, 99, 99, NULL, 1, '2026-05-26 15:27:53'),
(3, 5, 1, 'L-URE-2601', '2025-08-01', '2028-07-31', '2026-01-10', 40, 1, 210.00, 200, 200, NULL, 1, '2026-05-26 15:27:53'),
(4, 6, 1, 'L-NPK-2601', '2025-09-01', '2028-08-31', '2026-01-10', 30, 1, 250.00, 40, 40, NULL, 1, '2026-05-26 15:27:53'),
(5, 8, 1, 'L-RDP-2602', '2025-06-01', '2027-05-31', '2026-02-05', 20, 1, 180.00, 25, 25, NULL, 1, '2026-05-26 15:27:53'),
(6, 9, 1, 'L-AMX-2602', '2025-07-01', '2027-06-30', '2026-02-05', 15, 1, 450.00, 80, 80, NULL, 1, '2026-05-26 15:27:53'),
(7, 10, 1, 'L-DEC-2602', '2025-07-15', '2027-07-14', '2026-02-05', 10, 1, 280.00, 60, 60, NULL, 1, '2026-05-26 15:27:53'),
(8, 11, 1, 'L-24D-2602', '2025-08-01', '2027-07-31', '2026-02-05', 25, 1, 90.00, 50, 50, NULL, 1, '2026-05-26 15:27:53'),
(9, 12, 2, 'L-IVM-2603', '2025-11-01', '2027-10-31', '2026-03-15', 15, 1, 320.00, 20, 20, NULL, 1, '2026-05-26 15:27:53'),
(10, 13, 2, 'L-VAC-2603', '2025-12-01', '2026-11-30', '2026-03-15', 20, 1, 280.00, 20, 20, NULL, 1, '2026-05-26 15:27:53'),
(11, 14, 2, 'L-OXI-2603', '2025-11-15', '2027-11-14', '2026-03-15', 12, 1, 150.00, 59, 59, NULL, 1, '2026-05-26 15:27:53'),
(12, 15, 2, 'L-BAL-2603', '2026-01-01', '2026-12-31', '2026-03-15', 30, 1, 195.00, 10, 30, NULL, 1, '2026-05-26 15:27:53'),
(13, 5, 3, 'L-URE-2604', '2025-08-01', '2028-07-31', '2026-04-20', 35, 1, 210.00, 16, 16, NULL, 1, '2026-05-26 15:27:53'),
(14, 6, 3, 'L-NPK-2604', '2025-09-01', '2028-08-31', '2026-04-20', 25, 1, 250.00, 68, 68, NULL, 1, '2026-05-26 15:27:53'),
(15, 7, 3, 'L-SOP-2604', '2025-10-01', '2028-09-30', '2026-04-20', 20, 1, 320.00, 36, 36, NULL, 1, '2026-05-26 15:27:53'),
(16, 13, 3, 'L-VAC-2603', NULL, '2026-11-30', '2026-05-26', 1, 1, 280.00, 18, 18, NULL, 1, '2026-05-26 17:30:41'),
(17, 15, 3, 'L-BAL-2603', NULL, '2026-12-31', '2026-05-27', 20, 1, 195.00, 20, 0, NULL, 1, '2026-05-27 08:55:07'),
(18, 15, 3, 'L-0903902', '2025-07-27', '2027-02-27', '2026-05-27', 20, 12, 2000.00, 19, 236, NULL, 1, '2026-05-27 08:56:46'),
(19, 15, 3, 'L-1234', '2023-02-27', '2027-03-27', '2026-05-27', 2, 12, 200.00, 2, 24, NULL, 1, '2026-05-27 08:58:53'),
(20, 9, 3, NULL, '2025-09-27', '2026-06-27', '2026-05-27', 2, 12, 1200.00, 2, 24, NULL, 1, '2026-05-27 15:02:27'),
(21, 6, 3, NULL, '2025-11-27', '2026-08-27', '2026-05-27', 1, 12, 5000.00, 0, 11, NULL, 1, '2026-05-27 18:27:47'),
(22, 14, 3, 'L-OXI-2603', NULL, '2027-11-14', '2026-05-27', 1, 1, 150.00, 1, 1, NULL, 1, '2026-05-27 18:28:46'),
(23, 16, 3, 'L-0000', '2026-01-01', '2026-09-01', '2026-06-01', 1, 12, 1200.00, 1, 6, NULL, 1, '2026-06-01 04:18:19'),
(24, 16, 2, 'L-0000', NULL, '2026-09-01', '2026-06-01', 0, 12, 1200.00, 0, 6, NULL, 1, '2026-06-01 04:19:09');

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

--
-- Volcado de datos para la tabla `marca`
--

INSERT INTO `marca` (`id_marca`, `nombre`, `pais_origen`, `descripcion`, `activo`) VALUES
(1, 'Bayer CropScience', 'Alemania', 'Semillas y protección de cultivos', 1),
(2, 'Yara', 'Noruega', 'Fertilizantes y nutrición de cultivos', 1),
(3, 'Syngenta', 'Suiza', 'Agroquímicos y semillas protegidas', 1),
(4, 'Zoetis', 'Estados Unidos', 'Salud animal, vacunas y antiparasitarios', 1),
(5, 'SeedCo', 'Zimbabue', 'Semillas híbridas para trópico y subtrópico', 1),
(6, 'BASF', 'Alemania', 'Agroquímicos y soluciones agrícolas', 1),
(7, 'Ciproquim', 'Bolivia', 'Productos agropecuarios de fabricación nacional', 1),
(8, 'Disagro', 'Guatemala', 'Fertilizantes especializados para Latinoamérica', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `movimiento`
--

CREATE TABLE `movimiento` (
  `id_movimiento` int(11) NOT NULL,
  `tipo` enum('INGRESO','EGRESO') NOT NULL,
  `id_categoria` int(11) NOT NULL,
  `descripcion` varchar(255) NOT NULL,
  `monto` decimal(12,2) NOT NULL,
  `fecha` date NOT NULL,
  `id_sucursal` int(11) DEFAULT NULL,
  `id_usuario` int(11) NOT NULL,
  `observaciones` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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

--
-- Volcado de datos para la tabla `movimiento_almacen`
--

INSERT INTO `movimiento_almacen` (`id_movimiento`, `id_lote`, `id_sucursal`, `id_usuario`, `tipo`, `motivo`, `cantidad_cajas`, `cantidad_unidades`, `fecha_movimiento`, `referencia_id`, `referencia_tipo`, `observaciones`) VALUES
(1, 1, 1, 6, 'ENTRADA', 'Compra FACT-AGR-0001-2026', 50, 0, '2026-01-10 09:00:00', 1, 'COMPRA', NULL),
(2, 2, 1, 6, 'ENTRADA', 'Compra FACT-AGR-0001-2026', 30, 0, '2026-01-10 09:00:00', 1, 'COMPRA', NULL),
(3, 3, 1, 6, 'ENTRADA', 'Compra FACT-AGR-0001-2026', 40, 0, '2026-01-10 09:00:00', 1, 'COMPRA', NULL),
(4, 4, 1, 6, 'ENTRADA', 'Compra FACT-AGR-0001-2026', 30, 0, '2026-01-10 09:00:00', 1, 'COMPRA', NULL),
(5, 5, 1, 6, 'ENTRADA', 'Compra FACT-AGR-0002-2026', 20, 0, '2026-02-05 10:00:00', 2, 'COMPRA', NULL),
(6, 6, 1, 6, 'ENTRADA', 'Compra FACT-AGR-0002-2026', 15, 0, '2026-02-05 10:00:00', 2, 'COMPRA', NULL),
(7, 7, 1, 6, 'ENTRADA', 'Compra FACT-AGR-0002-2026', 10, 0, '2026-02-05 10:00:00', 2, 'COMPRA', NULL),
(8, 8, 1, 6, 'ENTRADA', 'Compra FACT-AGR-0002-2026', 25, 0, '2026-02-05 10:00:00', 2, 'COMPRA', NULL),
(9, 9, 2, 7, 'ENTRADA', 'Compra FACT-AGR-0003-2026', 15, 0, '2026-03-15 08:30:00', 3, 'COMPRA', NULL),
(10, 10, 2, 7, 'ENTRADA', 'Compra FACT-AGR-0003-2026', 20, 0, '2026-03-15 08:30:00', 3, 'COMPRA', NULL),
(11, 11, 2, 7, 'ENTRADA', 'Compra FACT-AGR-0003-2026', 12, 0, '2026-03-15 08:30:00', 3, 'COMPRA', NULL),
(12, 12, 2, 7, 'ENTRADA', 'Compra FACT-AGR-0003-2026', 30, 0, '2026-03-15 08:30:00', 3, 'COMPRA', NULL),
(13, 13, 3, 8, 'ENTRADA', 'Compra FACT-AGR-0004-2026', 35, 0, '2026-04-20 09:00:00', 4, 'COMPRA', NULL),
(14, 14, 3, 8, 'ENTRADA', 'Compra FACT-AGR-0004-2026', 25, 0, '2026-04-20 09:00:00', 4, 'COMPRA', NULL),
(15, 15, 3, 8, 'ENTRADA', 'Compra FACT-AGR-0004-2026', 20, 0, '2026-04-20 09:00:00', 4, 'COMPRA', NULL),
(16, 3, 1, 2, 'SALIDA', 'Venta VTA-0001-2026', 10, 0, '2026-05-20 09:30:00', 1, 'VENTA', NULL),
(17, 4, 1, 2, 'SALIDA', 'Venta VTA-0001-2026', 7, 0, '2026-05-20 09:30:00', 1, 'VENTA', NULL),
(18, 1, 1, 2, 'SALIDA', 'Venta VTA-0002-2026', 3, 0, '2026-05-20 11:00:00', 2, 'VENTA', NULL),
(19, 5, 1, 3, 'SALIDA', 'Venta VTA-0003-2026', 1, 0, '2026-05-26 09:15:00', 3, 'VENTA', NULL),
(20, 8, 1, 3, 'SALIDA', 'Venta VTA-0003-2026', 1, 0, '2026-05-26 09:15:00', 3, 'VENTA', NULL),
(21, 3, 1, 3, 'SALIDA', 'Venta VTA-0004-2026', 8, 0, '2026-05-26 10:00:00', 4, 'VENTA', NULL),
(22, 4, 1, 3, 'SALIDA', 'Venta VTA-0004-2026', 8, 0, '2026-05-26 10:00:00', 4, 'VENTA', NULL),
(23, 6, 1, 3, 'SALIDA', 'Venta VTA-0004-2026', 2, 0, '2026-05-26 10:00:00', 4, 'VENTA', NULL),
(24, 5, 1, 3, 'SALIDA', 'Venta VTA-0005-2026', 1, 0, '2026-05-26 11:30:00', 5, 'VENTA', NULL),
(25, 9, 2, 4, 'SALIDA', 'Venta VTA-0006-2026', 10, 0, '2026-05-26 09:00:00', 6, 'VENTA', NULL),
(26, 10, 2, 4, 'SALIDA', 'Venta VTA-0006-2026', 6, 0, '2026-05-26 09:00:00', 6, 'VENTA', NULL),
(27, 8, 1, 6, 'TRASLADO', 'Salida traslado a Sucursal Norte', 5, 0, '2026-05-15 14:00:00', 1, 'TRASLADO', NULL),
(28, 10, 2, 1, 'AJUSTE', 'Conteo fisico', 20, 20, '2026-05-26 17:29:05', NULL, 'MANUAL', NULL),
(29, 10, 2, 1, 'TRASLADO', 'Salida por traslado confirmado', 1, 20, '2026-05-26 17:30:41', 3, 'TRASLADO', NULL),
(30, 16, 3, 1, 'ENTRADA', 'Entrada por traslado confirmado', 1, 20, '2026-05-26 17:30:41', 3, 'TRASLADO', NULL),
(31, 10, 2, 1, 'AJUSTE', 'Conteo fisico', 20, 20, '2026-05-27 08:24:37', NULL, 'MANUAL', NULL),
(32, 12, 2, 1, 'AJUSTE', 'Conteo fisico', 30, 30, '2026-05-27 08:24:56', NULL, 'MANUAL', NULL),
(33, 5, 1, 1, 'AJUSTE', 'Conteo fisico', 25, 25, '2026-05-27 08:25:20', NULL, 'MANUAL', NULL),
(34, 6, 1, 1, 'AJUSTE', 'Conteo fisico', 80, 80, '2026-05-27 08:25:41', NULL, 'MANUAL', NULL),
(35, 7, 1, 1, 'AJUSTE', 'Conteo fisico', 60, 60, '2026-05-27 08:26:00', NULL, 'MANUAL', NULL),
(36, 8, 1, 1, 'AJUSTE', 'Conteo fisico', 50, 50, '2026-05-27 08:26:15', NULL, 'MANUAL', NULL),
(37, 1, 1, 1, 'AJUSTE', 'Conteo fisico', 90, 90, '2026-05-27 08:26:31', NULL, 'MANUAL', NULL),
(38, 2, 1, 1, 'AJUSTE', 'Conteo fisico', 100, 100, '2026-05-27 08:26:46', NULL, 'MANUAL', NULL),
(39, 9, 2, 1, 'AJUSTE', 'Conteo fisico', 20, 20, '2026-05-27 08:27:03', NULL, 'MANUAL', NULL),
(40, 11, 2, 1, 'AJUSTE', 'Conteo fisico', 60, 60, '2026-05-27 08:27:22', NULL, 'MANUAL', NULL),
(41, 13, 3, 1, 'AJUSTE', 'Conteo fisico', 20, 20, '2026-05-27 08:27:34', NULL, 'MANUAL', NULL),
(42, 3, 1, 1, 'AJUSTE', 'Conteo fisico', 200, 200, '2026-05-27 08:27:48', NULL, 'MANUAL', NULL),
(43, 14, 3, 1, 'AJUSTE', 'Conteo fisico', 70, 70, '2026-05-27 08:28:01', NULL, 'MANUAL', NULL),
(44, 4, 1, 1, 'AJUSTE', 'Conteo fisico', 40, 40, '2026-05-27 08:28:13', NULL, 'MANUAL', NULL),
(45, 15, 3, 1, 'AJUSTE', 'Conteo fisico', 40, 40, '2026-05-27 08:31:22', NULL, 'MANUAL', NULL),
(46, 12, 2, 1, 'TRASLADO', 'Salida por traslado confirmado', 20, 0, '2026-05-27 08:55:07', 4, 'TRASLADO', NULL),
(47, 17, 3, 1, 'ENTRADA', 'Entrada por traslado confirmado', 20, 0, '2026-05-27 08:55:07', 4, 'TRASLADO', NULL),
(48, 18, 3, 1, 'ENTRADA', 'INGRESO POR COMPRA', 20, 240, '2026-05-27 08:56:46', 5, 'COMPRA', NULL),
(49, 19, 3, 1, 'ENTRADA', 'INGRESO POR COMPRA', 2, 24, '2026-05-27 08:58:53', 6, 'COMPRA', NULL),
(50, 18, 3, 1, 'SALIDA', 'VENTA', 0, 2, '2026-05-27 09:00:39', 7, 'VENTA', NULL),
(51, 13, 3, 1, 'SALIDA', 'VENTA', 1, 1, '2026-05-27 09:01:37', 8, 'VENTA', NULL),
(52, 16, 3, 1, 'SALIDA', 'VENTA', 1, 1, '2026-05-27 09:01:37', 8, 'VENTA', NULL),
(53, 14, 3, 1, 'SALIDA', 'VENTA', 1, 1, '2026-05-27 09:03:50', 9, 'VENTA', NULL),
(54, 18, 3, 1, 'SALIDA', 'VENTA', 0, 1, '2026-05-27 09:03:50', 9, 'VENTA', NULL),
(55, 13, 3, 1, 'SALIDA', 'VENTA', 1, 1, '2026-05-27 09:04:26', 10, 'VENTA', NULL),
(56, 15, 3, 1, 'SALIDA', 'VENTA', 1, 1, '2026-05-27 09:04:26', 10, 'VENTA', NULL),
(57, 16, 3, 1, 'SALIDA', 'VENTA', 1, 1, '2026-05-27 09:04:26', 10, 'VENTA', NULL),
(58, 13, 3, 1, 'SALIDA', 'VENTA', 1, 1, '2026-05-27 10:16:32', 11, 'VENTA', NULL),
(59, 15, 3, 1, 'SALIDA', 'VENTA', 1, 1, '2026-05-27 10:16:32', 11, 'VENTA', NULL),
(60, 13, 3, 1, 'SALIDA', 'VENTA', 1, 1, '2026-05-27 11:20:30', 12, 'VENTA', NULL),
(61, 15, 3, 1, 'SALIDA', 'VENTA', 1, 1, '2026-05-27 11:20:30', 12, 'VENTA', NULL),
(62, 14, 3, 1, 'SALIDA', 'VENTA', 1, 1, '2026-05-27 14:35:51', 13, 'VENTA', NULL),
(63, 15, 3, 1, 'SALIDA', 'VENTA', 1, 1, '2026-05-27 14:35:51', 13, 'VENTA', NULL),
(64, 1, 1, 5, 'SALIDA', 'VENTA', 1, 1, '2026-05-27 14:53:07', 14, 'VENTA', NULL),
(65, 2, 1, 5, 'SALIDA', 'VENTA', 1, 1, '2026-05-27 14:53:07', 14, 'VENTA', NULL),
(66, 20, 3, 1, 'ENTRADA', 'INGRESO POR COMPRA', 2, 24, '2026-05-27 15:02:27', 7, 'COMPRA', NULL),
(67, 21, 3, 1, 'ENTRADA', 'INGRESO POR COMPRA', 1, 12, '2026-05-27 18:27:47', 8, 'COMPRA', NULL),
(68, 11, 2, 1, 'TRASLADO', 'Salida por traslado confirmado', 1, 1, '2026-05-27 18:28:46', 5, 'TRASLADO', NULL),
(69, 22, 3, 1, 'ENTRADA', 'Entrada por traslado confirmado', 1, 1, '2026-05-27 18:28:46', 5, 'TRASLADO', NULL),
(70, 21, 3, 1, 'SALIDA', 'VENTA', 0, 1, '2026-06-01 04:10:59', 15, 'VENTA', NULL),
(71, 18, 3, 1, 'SALIDA', 'VENTA', 0, 1, '2026-06-01 04:10:59', 15, 'VENTA', NULL),
(72, 23, 3, 1, 'ENTRADA', 'INGRESO POR COMPRA', 1, 12, '2026-06-01 04:18:19', 9, 'COMPRA', NULL),
(73, 23, 3, 1, 'TRASLADO', 'Salida por traslado confirmado', 0, 6, '2026-06-01 04:19:09', 6, 'TRASLADO', NULL),
(74, 24, 2, 1, 'ENTRADA', 'Entrada por traslado confirmado', 0, 6, '2026-06-01 04:19:09', 6, 'TRASLADO', NULL);

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
(44, 'productos', 'gestionar_imagen', 'productos.gestionar_imagen', 'Subir o eliminar imagen del producto'),
(45, 'almacen', 'ver', 'almacen.ver', 'Ver inventario general del almacén'),
(46, 'almacen', 'ver_lotes', 'almacen.ver_lotes', 'Ver listado detallado de lotes'),
(47, 'almacen', 'ver_lote_detalle', 'almacen.ver_lote_detalle', 'Ver ficha completa de un lote'),
(48, 'almacen', 'ver_costo_lote', 'almacen.ver_costo_lote', 'Ver precio de costo de cada lote'),
(49, 'almacen', 'ingresar', 'almacen.ingresar', 'Registrar entradas de productos al almacén'),
(50, 'almacen', 'ajustar', 'almacen.ajustar', 'Registrar ajustes de inventario'),
(51, 'almacen', 'trasladar', 'almacen.trasladar', 'Trasladar stock entre sucursales'),
(52, 'almacen', 'ver_movimientos', 'almacen.ver_movimientos', 'Ver historial de movimientos (kardex)'),
(53, 'almacen', 'ver_vencimientos', 'almacen.ver_vencimientos', 'Ver productos próximos a vencer'),
(54, 'almacen', 'dar_baja_lote', 'almacen.dar_baja_lote', 'Dar de baja un lote (vencido o dañado)'),
(55, 'proveedores', 'ver', 'proveedores.ver', 'Ver listado de proveedores'),
(56, 'proveedores', 'ver_detalle', 'proveedores.ver_detalle', 'Ver ficha completa de un proveedor'),
(57, 'proveedores', 'crear', 'proveedores.crear', 'Registrar nuevos proveedores'),
(58, 'proveedores', 'editar', 'proveedores.editar', 'Editar datos de un proveedor'),
(59, 'proveedores', 'eliminar', 'proveedores.eliminar', 'Eliminar proveedores del sistema'),
(60, 'proveedores', 'activar', 'proveedores.activar', 'Activar o desactivar un proveedor'),
(61, 'compras', 'ver', 'compras.ver', 'Ver historial de compras'),
(62, 'compras', 'ver_detalle', 'compras.ver_detalle', 'Ver detalle completo de una compra'),
(63, 'compras', 'ver_costo', 'compras.ver_costo', 'Ver precios de costo en las compras'),
(64, 'compras', 'crear', 'compras.crear', 'Registrar nuevas compras'),
(65, 'compras', 'editar', 'compras.editar', 'Editar compras en estado PENDIENTE'),
(66, 'compras', 'confirmar', 'compras.confirmar', 'Confirmar y cerrar una compra'),
(67, 'compras', 'anular', 'compras.anular', 'Anular una compra registrada'),
(68, 'compras', 'ver_todas_sucursales', 'compras.ver_todas_sucursales', 'Ver compras de todas las sucursales'),
(69, 'clientes', 'ver', 'clientes.ver', 'Ver listado de clientes'),
(70, 'clientes', 'ver_detalle', 'clientes.ver_detalle', 'Ver ficha completa de un cliente'),
(71, 'clientes', 'crear', 'clientes.crear', 'Registrar nuevos clientes'),
(72, 'clientes', 'editar', 'clientes.editar', 'Editar datos de un cliente'),
(73, 'clientes', 'eliminar', 'clientes.eliminar', 'Eliminar clientes del sistema'),
(74, 'clientes', 'activar', 'clientes.activar', 'Activar o desactivar un cliente'),
(75, 'clientes', 'ver_historial', 'clientes.ver_historial', 'Ver historial de compras de un cliente'),
(76, 'clientes', 'cambiar_tipo', 'clientes.cambiar_tipo', 'Cambiar tipo de cliente: minorista / mayorista'),
(77, 'ventas', 'ver', 'ventas.ver', 'Ver historial de ventas propias'),
(78, 'ventas', 'ver_detalle', 'ventas.ver_detalle', 'Ver detalle completo de una venta'),
(79, 'ventas', 'ver_todas', 'ventas.ver_todas', 'Ver ventas de todos los vendedores'),
(80, 'ventas', 'ver_todas_sucursales', 'ventas.ver_todas_sucursales', 'Ver ventas de todas las sucursales'),
(81, 'ventas', 'crear', 'ventas.crear', 'Registrar nuevas ventas'),
(82, 'ventas', 'anular', 'ventas.anular', 'Anular una venta realizada'),
(83, 'ventas', 'aplicar_descuento', 'ventas.aplicar_descuento', 'Aplicar descuento adicional en una venta'),
(84, 'ventas', 'descuento_libre', 'ventas.descuento_libre', 'Ingresar descuento libre (sin límite de porcentaje)'),
(85, 'ventas', 'vender_sin_stock', 'ventas.vender_sin_stock', 'Registrar venta aunque el stock sea 0'),
(86, 'ventas', 'ver_costo', 'ventas.ver_costo', 'Ver el costo y la utilidad de cada venta'),
(87, 'ventas', 'cambiar_precio', 'ventas.cambiar_precio', 'Modificar el precio en el momento de la venta'),
(88, 'ventas', 'reimprimir', 'ventas.reimprimir', 'Reimprimir comprobante de una venta'),
(89, 'traslados', 'ver', 'traslados.ver', 'Ver listado de traslados entre sucursales'),
(90, 'traslados', 'crear', 'traslados.crear', 'Crear un traslado de stock'),
(91, 'traslados', 'confirmar', 'traslados.confirmar', 'Confirmar un traslado pendiente'),
(92, 'traslados', 'cancelar', 'traslados.cancelar', 'Cancelar un traslado pendiente'),
(93, 'caja', 'ver', 'caja.ver', 'Ver listado de cajas registradas'),
(94, 'caja', 'crear', 'caja.crear', 'Registrar nuevas cajas'),
(95, 'caja', 'editar', 'caja.editar', 'Editar datos de una caja'),
(96, 'caja', 'activar', 'caja.activar', 'Activar o desactivar una caja'),
(97, 'caja', 'abrir', 'caja.abrir', 'Abrir turno de caja con monto inicial'),
(98, 'caja', 'cerrar', 'caja.cerrar', 'Cerrar turno de caja y registrar monto final'),
(99, 'caja', 'ver_movimientos', 'caja.ver_movimientos', 'Ver movimientos de efectivo de una caja'),
(100, 'caja', 'ver_todas', 'caja.ver_todas', 'Ver cajas de todas las sucursales'),
(101, 'caja', 'ver_historial', 'caja.ver_historial', 'Ver historial de aperturas y cierres de caja'),
(102, 'reportes', 'ventas_diarias', 'reportes.ventas_diarias', 'Ver reporte de ventas del día'),
(103, 'reportes', 'ventas_rango', 'reportes.ventas_rango', 'Ver reporte de ventas por rango de fechas'),
(104, 'reportes', 'ventas_vendedor', 'reportes.ventas_vendedor', 'Ver reporte de ventas por vendedor'),
(105, 'reportes', 'ventas_producto', 'reportes.ventas_producto', 'Ver reporte de ventas por producto'),
(106, 'reportes', 'ventas_cliente', 'reportes.ventas_cliente', 'Ver reporte de ventas por cliente'),
(107, 'reportes', 'compras', 'reportes.compras', 'Ver reporte de compras realizadas'),
(108, 'reportes', 'compras_proveedor', 'reportes.compras_proveedor', 'Ver reporte de compras por proveedor'),
(109, 'reportes', 'inventario', 'reportes.inventario', 'Ver reporte de inventario actual'),
(110, 'reportes', 'inventario_valorizado', 'reportes.inventario_valorizado', 'Ver inventario con valor de costo total'),
(111, 'reportes', 'ganancias', 'reportes.ganancias', 'Ver reporte de ganancias y utilidad bruta'),
(112, 'reportes', 'ganancias_producto', 'reportes.ganancias_producto', 'Ver utilidad desglosada por producto'),
(113, 'reportes', 'top_productos', 'reportes.top_productos', 'Ver ranking de productos más vendidos'),
(114, 'reportes', 'vencimientos', 'reportes.vencimientos', 'Ver reporte de productos próximos a vencer'),
(115, 'reportes', 'stock_bajo', 'reportes.stock_bajo', 'Ver productos por debajo del stock mínimo'),
(116, 'reportes', 'kardex', 'reportes.kardex', 'Ver kardex (historial de movimientos por lote)'),
(117, 'reportes', 'traslados', 'reportes.traslados', 'Ver reporte de traslados entre sucursales'),
(118, 'reportes', 'comparativo_sucursales', 'reportes.comparativo_sucursales', 'Comparar ventas y ganancias entre sucursales'),
(119, 'reportes', 'caja', 'reportes.caja', 'Ver reporte de arqueos y movimientos de caja'),
(120, 'configuracion', 'ver', 'configuracion.ver', 'Ver configuración general del sistema'),
(121, 'configuracion', 'editar', 'configuracion.editar', 'Editar configuración general del sistema'),
(122, 'movimientos', '', 'movimientos.ver', 'Ver libro de caja y movimientos'),
(123, 'movimientos', '', 'movimientos.crear', 'Registrar gasto/ingreso manual'),
(124, 'movimientos', '', 'movimientos.editar', 'Editar un movimiento manual'),
(125, 'movimientos', '', 'movimientos.eliminar', 'Eliminar un movimiento manual'),
(126, 'movimientos', '', 'movimientos.ver_todas', 'Ver movimientos de todas las sucursales'),
(127, 'categorias_movimiento', '', 'categorias_movimiento.ver', 'Ver categorías de movimientos'),
(128, 'categorias_movimiento', '', 'categorias_movimiento.gestionar', 'Crear/editar/eliminar categorías');

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
  `imagen` varchar(255) DEFAULT NULL,
  `precio_mayor` decimal(12,2) NOT NULL DEFAULT 0.00,
  `precio_menor` decimal(12,2) NOT NULL DEFAULT 0.00,
  `descuento_mayor` decimal(5,2) NOT NULL DEFAULT 0.00,
  `descuento_menor` decimal(5,2) NOT NULL DEFAULT 0.00,
  `stock_minimo` int(11) NOT NULL DEFAULT 0,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `producto`
--

INSERT INTO `producto` (`id_producto`, `id_clasificacion`, `id_marca`, `id_unidad`, `nombre`, `descripcion`, `codigo_barras`, `imagen`, `precio_mayor`, `precio_menor`, `descuento_mayor`, `descuento_menor`, `stock_minimo`, `activo`, `creado_en`) VALUES
(1, 1, 5, 5, 'Semilla Maíz Híbrido DK-7088', 'Maíz híbrido de alto rendimiento, apto para riego y secano', '7801234560001', NULL, 120.00, 135.00, 5.00, 0.00, 20, 1, '2026-05-26 15:27:53'),
(2, 1, 1, 5, 'Semilla Soya NK-S7209', 'Soya ciclo medio, alta tolerancia a enfermedades', '7801234560002', NULL, 95.00, 110.00, 5.00, 0.00, 15, 1, '2026-05-26 15:27:53'),
(3, 1, 5, 5, 'Semilla Sorgo NK-7829', 'Sorgo granífero resistente a sequía', '7801234560003', NULL, 75.00, 88.00, 4.00, 0.00, 10, 1, '2026-05-26 15:27:53'),
(4, 1, 5, 5, 'Semilla Girasol SY-4045', 'Girasol de alto contenido oleico', '7801234560004', NULL, 85.00, 98.00, 4.00, 0.00, 10, 1, '2026-05-26 15:27:53'),
(5, 2, 2, 4, 'Urea 46% Granulada', 'Nitrógeno al 46%, granulado, para todo tipo de cultivo', '7801234560005', NULL, 210.00, 235.00, 8.00, 2.00, 30, 1, '2026-05-26 15:27:53'),
(6, 2, 8, 4, 'Fertilizante NPK 15-15-15', 'Fórmula balanceada para inicio de cultivo', '7801234560006', NULL, 250.00, 280.00, 8.00, 2.00, 10, 1, '2026-05-26 15:27:53'),
(7, 2, 2, 4, 'Sulfato de Potasio K2SO4', 'Potasio de alta pureza, libre de cloro', '7801234560007', NULL, 320.00, 360.00, 6.00, 0.00, 15, 1, '2026-05-26 15:27:53'),
(8, 3, 1, 2, 'Herbicida Roundup 48 SL', 'Glifosato 48%, control total de malezas, envase 1 lt', '7801234560008', NULL, 180.00, 210.00, 10.00, 3.00, 20, 1, '2026-05-26 15:27:53'),
(9, 3, 3, 2, 'Fungicida Amistar Xtra 280 SC', 'Control de enfermedades foliares en soya y maíz, 1 lt', NULL, NULL, 450.00, 490.00, 8.00, 2.00, 10, 1, '2026-05-26 15:27:53'),
(10, 3, 6, 2, 'Insecticida Decis Forte 100 EC', 'Control de insectos masticadores y chupadores, 1 lt', '7801234560010', NULL, 280.00, 310.00, 7.00, 0.00, 10, 1, '2026-05-26 15:27:53'),
(11, 3, 7, 2, 'Herbicida 2,4-D Amina 72%', 'Control de malezas de hoja ancha, envase 1 lt', '7801234560011', NULL, 90.00, 105.00, 5.00, 0.00, 15, 1, '2026-05-26 15:27:53'),
(12, 4, 4, 3, 'Ivermectina 1% Inyectable 500ml', 'Antiparasitario de amplio espectro para bovinos y porcinos', '7801234560012', NULL, 320.00, 360.00, 6.00, 0.00, 15, 1, '2026-05-26 15:27:53'),
(13, 4, 4, 3, 'Vacuna Triple Bovina Clostridial 50 dosis', 'Protección contra clostridiosis en bovinos, frasco x50 dosis', '7801234560013', NULL, 280.00, 310.00, 5.00, 0.00, 10, 1, '2026-05-26 15:27:53'),
(14, 4, 4, 2, 'Oxitetraciclina 20% LA 100ml', 'Antibiótico de larga acción para bovinos y porcinos', '7801234560014', NULL, 150.00, 175.00, 5.00, 0.00, 12, 1, '2026-05-26 15:27:53'),
(15, 6, 7, 4, 'Balanceado Iniciador Pollos Parrillero', 'Alimento completo fase inicial 0-21 días, saco 50 kg', '7801234560015', 'producto_15_1780297659599.png', 195.00, 215.00, 7.00, 2.00, 10, 1, '2026-05-26 15:27:53'),
(16, 3, 6, 2, 'PRODUCTO PRUEBA 1', 'PRODUCTO DE PRUEBA', '7801234560009', NULL, 200.00, 190.00, 0.00, 0.00, 10, 1, '2026-06-01 04:16:40');

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

--
-- Volcado de datos para la tabla `proveedor`
--

INSERT INTO `proveedor` (`id_proveedor`, `empresa`, `nit`, `contacto`, `telefono`, `correo`, `direccion`, `activo`) VALUES
(1, 'Distribuidora Agro Bolivia S.R.L.', '1023456001', 'Fernando Suárez', '33491234', 'fsuarez@agrobolivia.com', 'Av. Grigotá N° 1200, Santa Cruz', 1),
(2, 'SeedCo Bolivia', '2034567002', 'Claudia Montaño', '33478965', 'cmontano@seedco.bo', 'Parque Industrial PI-7, Santa Cruz', 1),
(3, 'Yara Bolivia S.A.', '3045678003', 'Rodrigo Antezana', '44567891', 'rantezana@yara.com.bo', 'Av. América N° 450, Cochabamba', 1),
(4, 'Laboratorios Zoetis Bolivia', '4056789004', 'Valeria Peña', '76345678', 'vpena@zoetis.com.bo', 'Calle Comercio N° 300, La Paz', 1),
(5, 'Agroquímicos del Sur Ltda.', '5067890005', 'Marco Vargas', '72456789', 'mvargas@agrosur.com.bo', 'Barrio Urbari, Santa Cruz', 1);

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
(1, 'Administrador'),
(2, 'Vendedor'),
(3, 'Almacenero');

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
(1, 110),
(1, 111),
(1, 112),
(1, 113),
(1, 114),
(1, 115),
(1, 116),
(1, 117),
(1, 118),
(1, 119),
(1, 120),
(1, 121),
(1, 122),
(1, 123),
(1, 124),
(1, 125),
(1, 126),
(1, 127),
(1, 128),
(2, 15),
(2, 33),
(2, 34),
(2, 40),
(2, 43),
(2, 45),
(2, 51),
(2, 69),
(2, 70),
(2, 71),
(2, 72),
(2, 75),
(2, 76),
(2, 77),
(2, 78),
(2, 79),
(2, 81),
(2, 82),
(2, 83),
(2, 88),
(2, 93),
(2, 97),
(2, 98),
(2, 99),
(2, 100),
(2, 101),
(2, 102),
(2, 103),
(2, 106),
(3, 33),
(3, 34),
(3, 39),
(3, 43),
(3, 45),
(3, 46),
(3, 47),
(3, 48),
(3, 49),
(3, 50),
(3, 51),
(3, 52),
(3, 53),
(3, 54),
(3, 55),
(3, 56),
(3, 61),
(3, 62),
(3, 63),
(3, 64),
(3, 66),
(3, 89),
(3, 90),
(3, 91),
(3, 92),
(3, 109),
(3, 110),
(3, 114),
(3, 115),
(3, 116),
(3, 117),
(3, 119);

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
(1, 'Sucursal Central', 'Av. Cañoto N° 234, entre Warnes y Ñuflo de Chávez', 'Santa Cruz de la Sierra', '33412345', 'central@agropecuaria.bo', 1, '2026-05-26 15:27:53'),
(2, 'Sucursal Norte', 'Calle Montero N° 89, Zona Norte', 'Santa Cruz de la Sierra', '33498765', 'norte@agropecuaria.bo', 1, '2026-05-26 15:27:53'),
(3, 'Sucursal Cochabamba', 'Av. Blanco Galindo Km 5, Quillacollo', 'Cochabamba', '44523678', 'cbba@agropecuaria.bo', 1, '2026-05-26 15:27:53');

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

--
-- Volcado de datos para la tabla `traslado`
--

INSERT INTO `traslado` (`id_traslado`, `id_lote_origen`, `id_sucursal_dest`, `id_usuario`, `cantidad_cajas`, `cantidad_unidades`, `fecha_traslado`, `estado`, `observaciones`) VALUES
(1, 8, 2, 6, 5, 0, '2026-05-15 14:00:00', 'CONFIRMADO', 'Traslado de herbicida 2,4-D solicitado por sucursal norte'),
(2, 10, 3, 1, 20, 20, '2026-05-26 17:29:52', 'CANCELADO', NULL),
(3, 10, 3, 1, 1, 20, '2026-05-26 17:30:33', 'CONFIRMADO', NULL),
(4, 12, 3, 1, 20, 0, '2026-05-27 08:55:01', 'CONFIRMADO', NULL),
(5, 11, 3, 1, 1, 1, '2026-05-27 18:28:40', 'CONFIRMADO', NULL),
(6, 23, 2, 1, 0, 6, '2026-06-01 04:18:57', 'CONFIRMADO', 'ninguna');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `unidad_medida`
--

CREATE TABLE `unidad_medida` (
  `id_unidad` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `abreviatura` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `unidad_medida`
--

INSERT INTO `unidad_medida` (`id_unidad`, `nombre`, `abreviatura`) VALUES
(1, 'Kilogramo', 'kg'),
(2, 'Litro', 'lt'),
(3, 'Unidad', 'und'),
(4, 'Saco (50 kg)', 'saco'),
(5, 'Sobre', 'sobre'),
(6, 'Mililitro', 'ml'),
(7, 'Gramo', 'gr'),
(8, 'Caja', 'cja');

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
(1, 1, 3, '7512301', 'Carlos', 'Mendoza Vaca', '77812301', 'admin@agropecuaria.bo', '$2b$10$0mJZMb0UdWEo.0.4bbmIauwGq6EtZ3sCiQJZkJFL19UZPI68m/xie', 1, '2026-05-26 15:27:53'),
(2, 2, 1, '8023402', 'María', 'Flores Torrico', '76923402', 'mflores@agropecuaria.bo', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1, '2026-05-26 15:27:53'),
(3, 2, 1, '6534503', 'Roberto', 'Quiroga Pedraza', '71534503', 'rquiroga@agropecuaria.bo', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1, '2026-05-26 15:27:53'),
(4, 2, 2, '5245604', 'Lucía', 'Gutiérrez Molina', '79845604', 'lgutierrez@agropecuaria.bo', '$2b$10$QHK5RJFnv2RaqbLpJL2lUOFPMpjeX9mFsjCE8j3AMtB4l/o3AYmqC', 1, '2026-05-26 15:27:53'),
(5, 2, 1, '4356705', 'Pablo', 'Rojas Saavedra', '68956705', 'projas@agropecuaria.bo', '$2b$10$Q2Yr413cKkRQLImZTiTs8uDdAJBaIgIVwmTbTLYDi8dOZAOKzKo3a', 1, '2026-05-26 15:27:53'),
(6, 3, 1, '9167806', 'Juan', 'Mamani Condori', '72167806', 'jmamani@agropecuaria.bo', '$2b$10$zgjZaEMHPFCOY4TXMjDkw.Hp/sdvVt3CNc48KzB8.KjJurAFBuQX2', 1, '2026-05-26 15:27:53'),
(7, 3, 2, '3278907', 'Ana', 'Choque Limachi', '67378907', 'achoque@agropecuaria.bo', '$2b$10$nM1exkcz9/rXW/8iSrR.G.swrlyXHg8G3TG1pQxEVDjTVrs5M0fpC', 1, '2026-05-26 15:27:53'),
(8, 3, 3, '2389008', 'Diego', 'Quispe Huanca', '73489008', 'dquispe@agropecuaria.bo', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1, '2026-05-26 15:27:53');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `venta`
--

CREATE TABLE `venta` (
  `id_venta` int(11) NOT NULL,
  `id_sucursal` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `id_cliente` int(11) DEFAULT NULL,
  `id_apertura` int(11) DEFAULT NULL,
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
-- Volcado de datos para la tabla `venta`
--

INSERT INTO `venta` (`id_venta`, `id_sucursal`, `id_usuario`, `id_cliente`, `id_apertura`, `nro_factura`, `fecha_venta`, `tipo_venta`, `subtotal`, `descuento_total`, `total`, `monto_pagado`, `cambio`, `metodo_pago`, `estado`, `observaciones`) VALUES
(1, 1, 2, 2, 1, 'VTA-0001-2026', '2026-05-20 09:30:00', 'MAYOR', 4310.00, 344.80, 3965.20, 3965.20, 0.00, 'QR', 'COMPLETADA', NULL),
(2, 1, 2, 4, 1, 'VTA-0002-2026', '2026-05-20 11:00:00', 'MENOR', 405.00, 0.00, 405.00, 450.00, 45.00, 'EFECTIVO', 'COMPLETADA', NULL),
(3, 1, 3, NULL, 2, 'VTA-0003-2026', '2026-05-26 09:15:00', 'MENOR', 315.00, 0.00, 315.00, 400.00, 85.00, 'EFECTIVO', 'COMPLETADA', NULL),
(4, 1, 3, 3, 2, 'VTA-0004-2026', '2026-05-26 10:00:00', 'MAYOR', 4580.00, 366.40, 4213.60, 4213.60, 0.00, 'TRANSFERENCIA', 'COMPLETADA', NULL),
(5, 1, 3, 5, 2, 'VTA-0005-2026', '2026-05-26 11:30:00', 'MENOR', 210.00, 0.00, 210.00, 210.00, 0.00, 'QR', 'COMPLETADA', NULL),
(6, 2, 4, 2, 3, 'VTA-0006-2026', '2026-05-26 09:00:00', 'MAYOR', 4880.00, 292.80, 4587.20, 4587.20, 0.00, 'QR', 'COMPLETADA', NULL),
(7, 3, 1, NULL, NULL, NULL, '2026-05-27 09:00:39', 'MENOR', 430.00, 0.00, 430.00, 500.00, 70.00, 'EFECTIVO', 'COMPLETADA', NULL),
(8, 3, 1, NULL, NULL, NULL, '2026-05-27 09:01:37', 'MENOR', 545.00, 0.00, 545.00, 600.00, 55.00, 'EFECTIVO', 'COMPLETADA', NULL),
(9, 3, 1, NULL, NULL, NULL, '2026-05-27 09:03:50', 'MENOR', 495.00, 0.00, 495.00, 500.00, 5.00, 'EFECTIVO', 'COMPLETADA', NULL),
(10, 3, 1, NULL, NULL, NULL, '2026-05-27 09:04:26', 'MENOR', 905.00, 0.00, 905.00, 920.00, 15.00, 'EFECTIVO', 'COMPLETADA', NULL),
(11, 3, 1, NULL, NULL, NULL, '2026-05-27 10:16:32', 'MENOR', 595.00, 0.00, 595.00, 595.00, 0.00, 'EFECTIVO', 'COMPLETADA', NULL),
(12, 3, 1, 8, NULL, NULL, '2026-05-27 11:20:30', 'MENOR', 595.00, 0.00, 595.00, 595.00, 0.00, 'EFECTIVO', 'COMPLETADA', NULL),
(13, 3, 1, NULL, NULL, NULL, '2026-05-27 14:35:51', 'MENOR', 640.00, 0.00, 640.00, 640.00, 0.00, 'EFECTIVO', 'COMPLETADA', NULL),
(14, 1, 5, NULL, NULL, NULL, '2026-05-27 14:53:07', 'MENOR', 245.00, 0.00, 245.00, 245.00, 0.00, 'EFECTIVO', 'COMPLETADA', NULL),
(15, 3, 1, NULL, NULL, NULL, '2026-06-01 04:10:59', 'MENOR', 495.00, 14.85, 480.15, 480.15, 0.00, 'EFECTIVO', 'COMPLETADA', NULL);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `apertura_cierre_caja`
--
ALTER TABLE `apertura_cierre_caja`
  ADD PRIMARY KEY (`id_apertura`),
  ADD KEY `fk_acc_caja` (`id_caja`),
  ADD KEY `fk_acc_usuario` (`id_usuario`),
  ADD KEY `fk_acc_sucursal` (`id_sucursal`);

--
-- Indices de la tabla `caja`
--
ALTER TABLE `caja`
  ADD PRIMARY KEY (`id_caja`),
  ADD KEY `fk_caja_sucursal` (`id_sucursal`);

--
-- Indices de la tabla `categoria_movimiento`
--
ALTER TABLE `categoria_movimiento`
  ADD PRIMARY KEY (`id_categoria`),
  ADD UNIQUE KEY `uq_nombre` (`nombre`);

--
-- Indices de la tabla `clasificacion_producto`
--
ALTER TABLE `clasificacion_producto`
  ADD PRIMARY KEY (`id_clasificacion`),
  ADD UNIQUE KEY `uq_clasificacion_nombre` (`nombre`);

--
-- Indices de la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`id_cliente`),
  ADD UNIQUE KEY `uq_cliente_cinit` (`ci_nit`);

--
-- Indices de la tabla `compra`
--
ALTER TABLE `compra`
  ADD PRIMARY KEY (`id_compra`),
  ADD KEY `fk_compra_proveedor` (`id_proveedor`),
  ADD KEY `fk_compra_sucursal` (`id_sucursal`),
  ADD KEY `fk_compra_usuario` (`id_usuario`);

--
-- Indices de la tabla `configuracion`
--
ALTER TABLE `configuracion`
  ADD PRIMARY KEY (`id_config`);

--
-- Indices de la tabla `detalle_compra`
--
ALTER TABLE `detalle_compra`
  ADD PRIMARY KEY (`id_detalle_compra`),
  ADD KEY `fk_dc_compra` (`id_compra`),
  ADD KEY `fk_dc_lote` (`id_lote`),
  ADD KEY `fk_dc_producto` (`id_producto`);

--
-- Indices de la tabla `detalle_venta`
--
ALTER TABLE `detalle_venta`
  ADD PRIMARY KEY (`id_detalle_venta`),
  ADD KEY `fk_dv_venta` (`id_venta`),
  ADD KEY `fk_dv_lote` (`id_lote`),
  ADD KEY `fk_dv_producto` (`id_producto`);

--
-- Indices de la tabla `lote`
--
ALTER TABLE `lote`
  ADD PRIMARY KEY (`id_lote`),
  ADD KEY `fk_lote_producto` (`id_producto`),
  ADD KEY `fk_lote_sucursal` (`id_sucursal`);

--
-- Indices de la tabla `marca`
--
ALTER TABLE `marca`
  ADD PRIMARY KEY (`id_marca`);

--
-- Indices de la tabla `movimiento`
--
ALTER TABLE `movimiento`
  ADD PRIMARY KEY (`id_movimiento`),
  ADD KEY `id_categoria` (`id_categoria`),
  ADD KEY `id_sucursal` (`id_sucursal`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- Indices de la tabla `movimiento_almacen`
--
ALTER TABLE `movimiento_almacen`
  ADD PRIMARY KEY (`id_movimiento`),
  ADD KEY `fk_mov_lote` (`id_lote`),
  ADD KEY `fk_mov_sucursal` (`id_sucursal`),
  ADD KEY `fk_mov_usuario` (`id_usuario`);

--
-- Indices de la tabla `permiso`
--
ALTER TABLE `permiso`
  ADD PRIMARY KEY (`id_permiso`),
  ADD UNIQUE KEY `uq_permiso_clave` (`nombre_clave`);

--
-- Indices de la tabla `producto`
--
ALTER TABLE `producto`
  ADD PRIMARY KEY (`id_producto`),
  ADD UNIQUE KEY `uq_producto_barras` (`codigo_barras`),
  ADD KEY `fk_prod_clasificacion` (`id_clasificacion`),
  ADD KEY `fk_prod_marca` (`id_marca`),
  ADD KEY `fk_prod_unidad` (`id_unidad`);

--
-- Indices de la tabla `proveedor`
--
ALTER TABLE `proveedor`
  ADD PRIMARY KEY (`id_proveedor`),
  ADD UNIQUE KEY `uq_proveedor_nit` (`nit`);

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
  ADD KEY `fk_rp_permiso` (`id_permiso`);

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
  ADD KEY `fk_tras_lote` (`id_lote_origen`),
  ADD KEY `fk_tras_sucursal` (`id_sucursal_dest`),
  ADD KEY `fk_tras_usuario` (`id_usuario`);

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
  ADD UNIQUE KEY `uq_usuario_ci` (`ci`),
  ADD UNIQUE KEY `uq_usuario_correo` (`correo`),
  ADD KEY `fk_usuario_rol` (`id_rol`),
  ADD KEY `fk_usuario_sucursal` (`id_sucursal`);

--
-- Indices de la tabla `venta`
--
ALTER TABLE `venta`
  ADD PRIMARY KEY (`id_venta`),
  ADD KEY `fk_venta_sucursal` (`id_sucursal`),
  ADD KEY `fk_venta_usuario` (`id_usuario`),
  ADD KEY `fk_venta_cliente` (`id_cliente`),
  ADD KEY `fk_venta_apertura` (`id_apertura`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `apertura_cierre_caja`
--
ALTER TABLE `apertura_cierre_caja`
  MODIFY `id_apertura` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `caja`
--
ALTER TABLE `caja`
  MODIFY `id_caja` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `categoria_movimiento`
--
ALTER TABLE `categoria_movimiento`
  MODIFY `id_categoria` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `clasificacion_producto`
--
ALTER TABLE `clasificacion_producto`
  MODIFY `id_clasificacion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `cliente`
--
ALTER TABLE `cliente`
  MODIFY `id_cliente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `compra`
--
ALTER TABLE `compra`
  MODIFY `id_compra` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de la tabla `detalle_compra`
--
ALTER TABLE `detalle_compra`
  MODIFY `id_detalle_compra` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT de la tabla `detalle_venta`
--
ALTER TABLE `detalle_venta`
  MODIFY `id_detalle_venta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT de la tabla `lote`
--
ALTER TABLE `lote`
  MODIFY `id_lote` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT de la tabla `marca`
--
ALTER TABLE `marca`
  MODIFY `id_marca` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `movimiento`
--
ALTER TABLE `movimiento`
  MODIFY `id_movimiento` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `movimiento_almacen`
--
ALTER TABLE `movimiento_almacen`
  MODIFY `id_movimiento` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=75;

--
-- AUTO_INCREMENT de la tabla `permiso`
--
ALTER TABLE `permiso`
  MODIFY `id_permiso` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=129;

--
-- AUTO_INCREMENT de la tabla `producto`
--
ALTER TABLE `producto`
  MODIFY `id_producto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT de la tabla `proveedor`
--
ALTER TABLE `proveedor`
  MODIFY `id_proveedor` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `rol`
--
ALTER TABLE `rol`
  MODIFY `id_rol` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `sucursal`
--
ALTER TABLE `sucursal`
  MODIFY `id_sucursal` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `traslado`
--
ALTER TABLE `traslado`
  MODIFY `id_traslado` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `unidad_medida`
--
ALTER TABLE `unidad_medida`
  MODIFY `id_unidad` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `venta`
--
ALTER TABLE `venta`
  MODIFY `id_venta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `apertura_cierre_caja`
--
ALTER TABLE `apertura_cierre_caja`
  ADD CONSTRAINT `fk_acc_caja` FOREIGN KEY (`id_caja`) REFERENCES `caja` (`id_caja`),
  ADD CONSTRAINT `fk_acc_sucursal` FOREIGN KEY (`id_sucursal`) REFERENCES `sucursal` (`id_sucursal`),
  ADD CONSTRAINT `fk_acc_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`);

--
-- Filtros para la tabla `caja`
--
ALTER TABLE `caja`
  ADD CONSTRAINT `fk_caja_sucursal` FOREIGN KEY (`id_sucursal`) REFERENCES `sucursal` (`id_sucursal`);

--
-- Filtros para la tabla `compra`
--
ALTER TABLE `compra`
  ADD CONSTRAINT `fk_compra_proveedor` FOREIGN KEY (`id_proveedor`) REFERENCES `proveedor` (`id_proveedor`),
  ADD CONSTRAINT `fk_compra_sucursal` FOREIGN KEY (`id_sucursal`) REFERENCES `sucursal` (`id_sucursal`),
  ADD CONSTRAINT `fk_compra_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`);

--
-- Filtros para la tabla `detalle_compra`
--
ALTER TABLE `detalle_compra`
  ADD CONSTRAINT `fk_dc_compra` FOREIGN KEY (`id_compra`) REFERENCES `compra` (`id_compra`),
  ADD CONSTRAINT `fk_dc_lote` FOREIGN KEY (`id_lote`) REFERENCES `lote` (`id_lote`),
  ADD CONSTRAINT `fk_dc_producto` FOREIGN KEY (`id_producto`) REFERENCES `producto` (`id_producto`);

--
-- Filtros para la tabla `detalle_venta`
--
ALTER TABLE `detalle_venta`
  ADD CONSTRAINT `fk_dv_lote` FOREIGN KEY (`id_lote`) REFERENCES `lote` (`id_lote`),
  ADD CONSTRAINT `fk_dv_producto` FOREIGN KEY (`id_producto`) REFERENCES `producto` (`id_producto`),
  ADD CONSTRAINT `fk_dv_venta` FOREIGN KEY (`id_venta`) REFERENCES `venta` (`id_venta`);

--
-- Filtros para la tabla `lote`
--
ALTER TABLE `lote`
  ADD CONSTRAINT `fk_lote_producto` FOREIGN KEY (`id_producto`) REFERENCES `producto` (`id_producto`),
  ADD CONSTRAINT `fk_lote_sucursal` FOREIGN KEY (`id_sucursal`) REFERENCES `sucursal` (`id_sucursal`);

--
-- Filtros para la tabla `movimiento`
--
ALTER TABLE `movimiento`
  ADD CONSTRAINT `movimiento_ibfk_1` FOREIGN KEY (`id_categoria`) REFERENCES `categoria_movimiento` (`id_categoria`),
  ADD CONSTRAINT `movimiento_ibfk_2` FOREIGN KEY (`id_sucursal`) REFERENCES `sucursal` (`id_sucursal`),
  ADD CONSTRAINT `movimiento_ibfk_3` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`);

--
-- Filtros para la tabla `movimiento_almacen`
--
ALTER TABLE `movimiento_almacen`
  ADD CONSTRAINT `fk_mov_lote` FOREIGN KEY (`id_lote`) REFERENCES `lote` (`id_lote`),
  ADD CONSTRAINT `fk_mov_sucursal` FOREIGN KEY (`id_sucursal`) REFERENCES `sucursal` (`id_sucursal`),
  ADD CONSTRAINT `fk_mov_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`);

--
-- Filtros para la tabla `producto`
--
ALTER TABLE `producto`
  ADD CONSTRAINT `fk_prod_clasificacion` FOREIGN KEY (`id_clasificacion`) REFERENCES `clasificacion_producto` (`id_clasificacion`),
  ADD CONSTRAINT `fk_prod_marca` FOREIGN KEY (`id_marca`) REFERENCES `marca` (`id_marca`),
  ADD CONSTRAINT `fk_prod_unidad` FOREIGN KEY (`id_unidad`) REFERENCES `unidad_medida` (`id_unidad`);

--
-- Filtros para la tabla `rol_permiso`
--
ALTER TABLE `rol_permiso`
  ADD CONSTRAINT `fk_rp_permiso` FOREIGN KEY (`id_permiso`) REFERENCES `permiso` (`id_permiso`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_rp_rol` FOREIGN KEY (`id_rol`) REFERENCES `rol` (`id_rol`) ON DELETE CASCADE;

--
-- Filtros para la tabla `traslado`
--
ALTER TABLE `traslado`
  ADD CONSTRAINT `fk_tras_lote` FOREIGN KEY (`id_lote_origen`) REFERENCES `lote` (`id_lote`),
  ADD CONSTRAINT `fk_tras_sucursal` FOREIGN KEY (`id_sucursal_dest`) REFERENCES `sucursal` (`id_sucursal`),
  ADD CONSTRAINT `fk_tras_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`);

--
-- Filtros para la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD CONSTRAINT `fk_usuario_rol` FOREIGN KEY (`id_rol`) REFERENCES `rol` (`id_rol`),
  ADD CONSTRAINT `fk_usuario_sucursal` FOREIGN KEY (`id_sucursal`) REFERENCES `sucursal` (`id_sucursal`);

--
-- Filtros para la tabla `venta`
--
ALTER TABLE `venta`
  ADD CONSTRAINT `fk_venta_apertura` FOREIGN KEY (`id_apertura`) REFERENCES `apertura_cierre_caja` (`id_apertura`),
  ADD CONSTRAINT `fk_venta_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `cliente` (`id_cliente`),
  ADD CONSTRAINT `fk_venta_sucursal` FOREIGN KEY (`id_sucursal`) REFERENCES `sucursal` (`id_sucursal`),
  ADD CONSTRAINT `fk_venta_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
