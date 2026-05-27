-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: bd_agropecuaria
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `apertura_cierre_caja`
--

DROP TABLE IF EXISTS `apertura_cierre_caja`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `apertura_cierre_caja` (
  `id_apertura` int(11) NOT NULL AUTO_INCREMENT,
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
  `observaciones` text DEFAULT NULL,
  PRIMARY KEY (`id_apertura`),
  KEY `fk_acc_caja` (`id_caja`),
  KEY `fk_acc_usuario` (`id_usuario`),
  KEY `fk_acc_sucursal` (`id_sucursal`),
  CONSTRAINT `fk_acc_caja` FOREIGN KEY (`id_caja`) REFERENCES `caja` (`id_caja`),
  CONSTRAINT `fk_acc_sucursal` FOREIGN KEY (`id_sucursal`) REFERENCES `sucursal` (`id_sucursal`),
  CONSTRAINT `fk_acc_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `apertura_cierre_caja`
--

LOCK TABLES `apertura_cierre_caja` WRITE;
/*!40000 ALTER TABLE `apertura_cierre_caja` DISABLE KEYS */;
INSERT INTO `apertura_cierre_caja` VALUES (1,1,2,1,500.00,4070.00,4080.00,10.00,'2026-05-20 08:00:00','2026-05-20 18:30:00','CERRADA','Turno sin novedad. Sobrante Bs 10 por redondeo en cambio.'),(2,1,3,1,500.00,815.00,500.00,-315.00,'2026-05-26 08:00:00','2026-05-27 11:27:53','CERRADA',NULL),(3,3,4,2,300.00,NULL,NULL,NULL,'2026-05-26 08:30:00',NULL,'ABIERTA',NULL),(4,4,1,3,50.00,1025.00,2000.00,975.00,'2026-05-27 08:23:56','2026-05-27 09:02:53','CERRADA',NULL),(5,4,1,3,100.00,1500.00,1500.00,0.00,'2026-05-27 09:03:35','2026-05-27 09:05:21','CERRADA',NULL);
/*!40000 ALTER TABLE `apertura_cierre_caja` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `caja`
--

DROP TABLE IF EXISTS `caja`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `caja` (
  `id_caja` int(11) NOT NULL AUTO_INCREMENT,
  `id_sucursal` int(11) NOT NULL,
  `nombre` varchar(80) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_caja`),
  KEY `fk_caja_sucursal` (`id_sucursal`),
  CONSTRAINT `fk_caja_sucursal` FOREIGN KEY (`id_sucursal`) REFERENCES `sucursal` (`id_sucursal`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `caja`
--

LOCK TABLES `caja` WRITE;
/*!40000 ALTER TABLE `caja` DISABLE KEYS */;
INSERT INTO `caja` VALUES (1,1,'Caja Principal Sucursal Central','Caja principal de atención — Sucursal Central',0,'2026-05-26 15:27:53'),(2,1,'Caja 2 Sucursal central','Segunda caja para temporada alta — Sucursal Central',0,'2026-05-26 15:27:53'),(3,2,'Caja Principal Sucursal Norte','Caja única — Sucursal Norte',0,'2026-05-26 15:27:53'),(4,3,'Caja Principal Sucursal Cochabamba','Caja única — Sucursal Cochabamba',0,'2026-05-26 15:27:53');
/*!40000 ALTER TABLE `caja` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clasificacion_producto`
--

DROP TABLE IF EXISTS `clasificacion_producto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `clasificacion_producto` (
  `id_clasificacion` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(80) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id_clasificacion`),
  UNIQUE KEY `uq_clasificacion_nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clasificacion_producto`
--

LOCK TABLES `clasificacion_producto` WRITE;
/*!40000 ALTER TABLE `clasificacion_producto` DISABLE KEYS */;
INSERT INTO `clasificacion_producto` VALUES (1,'Semillas','Semillas certificadas para siembra',1),(2,'Fertilizantes','Abonos y nutrientes para el suelo',1),(3,'Agroquímicos','Herbicidas, fungicidas e insecticidas',1),(4,'Veterinaria','Medicamentos y vacunas para animales',1),(5,'Herramientas','Equipos y herramientas de labranza',1),(6,'Alimento Animal','Balanceados y suplementos para ganado y aves',1),(7,'Riego','Equipos y accesorios para sistemas de riego',1);
/*!40000 ALTER TABLE `clasificacion_producto` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cliente`
--

DROP TABLE IF EXISTS `cliente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cliente` (
  `id_cliente` int(11) NOT NULL AUTO_INCREMENT,
  `ci_nit` varchar(20) DEFAULT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellido` varchar(100) DEFAULT NULL,
  `empresa` varchar(150) DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `correo` varchar(100) DEFAULT NULL,
  `direccion` varchar(200) DEFAULT NULL,
  `tipo_cliente` enum('MINORISTA','MAYORISTA') NOT NULL DEFAULT 'MINORISTA',
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_cliente`),
  UNIQUE KEY `uq_cliente_cinit` (`ci_nit`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cliente`
--

LOCK TABLES `cliente` WRITE;
/*!40000 ALTER TABLE `cliente` DISABLE KEYS */;
INSERT INTO `cliente` VALUES (1,'6012345001','Gerencia',NULL,'Agroindustrias El Campo S.R.L.','33412300','compras@elcampo.bo','Km 12 Carretera al Norte, Santa Cruz','MAYORISTA',1,'2026-05-26 15:27:53'),(2,'7023456002','Gerencia',NULL,'Cooperativa Agrícola San Juan','33423456','coop.sanjuan@gmail.com','Municipio San Juan, Santa Cruz','MAYORISTA',1,'2026-05-26 15:27:53'),(3,'8034567003','Gerencia',NULL,'Hacienda Los Pinos','71534560','lospinos@hotmail.com','Yapacaní, Santa Cruz','MAYORISTA',1,'2026-05-26 15:27:53'),(4,'3456701','Pedro','Quisbert Mamani',NULL,'76345678',NULL,'Comunidad El Palmar, Cochabamba','MINORISTA',1,'2026-05-26 15:27:53'),(5,'4567802','Rosa','Torrico Alvarado',NULL,'71456789',NULL,'Barrio San Aurelio, Santa Cruz','MINORISTA',1,'2026-05-26 15:27:53'),(6,'5678903','Jorge','Vaca Suárez',NULL,'68567890',NULL,'Montero, Santa Cruz','MINORISTA',1,'2026-05-26 15:27:53'),(7,'6789004','Carmen','Aguilar López',NULL,'79678901',NULL,'Warnes, Santa Cruz','MINORISTA',1,'2026-05-26 15:27:53'),(8,'7890105','Efraín','Chura Condori',NULL,'73789012',NULL,'Colcapirhua, Cochabamba','MINORISTA',1,'2026-05-26 15:27:53');
/*!40000 ALTER TABLE `cliente` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `compra`
--

DROP TABLE IF EXISTS `compra`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `compra` (
  `id_compra` int(11) NOT NULL AUTO_INCREMENT,
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
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_compra`),
  KEY `fk_compra_proveedor` (`id_proveedor`),
  KEY `fk_compra_sucursal` (`id_sucursal`),
  KEY `fk_compra_usuario` (`id_usuario`),
  CONSTRAINT `fk_compra_proveedor` FOREIGN KEY (`id_proveedor`) REFERENCES `proveedor` (`id_proveedor`),
  CONSTRAINT `fk_compra_sucursal` FOREIGN KEY (`id_sucursal`) REFERENCES `sucursal` (`id_sucursal`),
  CONSTRAINT `fk_compra_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `compra`
--

LOCK TABLES `compra` WRITE;
/*!40000 ALTER TABLE `compra` DISABLE KEYS */;
INSERT INTO `compra` VALUES (1,1,1,6,'FACT-AGR-0001-2026','2026-01-10',24750.00,750.00,24000.00,'RECIBIDO',NULL,'2026-05-26 15:27:53'),(2,5,1,6,'FACT-AGR-0002-2026','2026-02-05',15900.00,400.00,15500.00,'RECIBIDO',NULL,'2026-05-26 15:27:53'),(3,4,2,7,'FACT-AGR-0003-2026','2026-03-15',14050.00,50.00,14000.00,'RECIBIDO',NULL,'2026-05-26 15:27:53'),(4,3,3,8,'FACT-AGR-0004-2026','2026-04-20',20000.00,0.00,20000.00,'RECIBIDO',NULL,'2026-05-26 15:27:53'),(5,1,3,1,NULL,'2026-05-27',40000.00,0.00,40000.00,'RECIBIDO',NULL,'2026-05-27 08:56:36'),(6,1,3,1,NULL,'2026-05-27',400.00,0.00,400.00,'RECIBIDO',NULL,'2026-05-27 08:58:51');
/*!40000 ALTER TABLE `compra` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `detalle_compra`
--

DROP TABLE IF EXISTS `detalle_compra`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `detalle_compra` (
  `id_detalle_compra` int(11) NOT NULL AUTO_INCREMENT,
  `id_compra` int(11) NOT NULL,
  `id_lote` int(11) DEFAULT NULL,
  `id_producto` int(11) NOT NULL,
  `numero_lote_fab` varchar(60) DEFAULT NULL,
  `fecha_produccion` date DEFAULT NULL,
  `fecha_vencimiento` date DEFAULT NULL,
  `cantidad_cajas` int(11) NOT NULL DEFAULT 0,
  `unidades_por_caja` int(11) NOT NULL DEFAULT 1,
  `precio_por_caja` decimal(12,2) NOT NULL DEFAULT 0.00,
  `subtotal` decimal(14,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`id_detalle_compra`),
  KEY `fk_dc_compra` (`id_compra`),
  KEY `fk_dc_lote` (`id_lote`),
  KEY `fk_dc_producto` (`id_producto`),
  CONSTRAINT `fk_dc_compra` FOREIGN KEY (`id_compra`) REFERENCES `compra` (`id_compra`),
  CONSTRAINT `fk_dc_lote` FOREIGN KEY (`id_lote`) REFERENCES `lote` (`id_lote`),
  CONSTRAINT `fk_dc_producto` FOREIGN KEY (`id_producto`) REFERENCES `producto` (`id_producto`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detalle_compra`
--

LOCK TABLES `detalle_compra` WRITE;
/*!40000 ALTER TABLE `detalle_compra` DISABLE KEYS */;
INSERT INTO `detalle_compra` VALUES (1,1,1,1,'L-MAI-2601','2025-10-01','2027-09-30',50,1,120.00,6000.00),(2,1,2,2,'L-SOY-2601','2025-10-15','2027-10-14',30,1,95.00,2850.00),(3,1,3,5,'L-URE-2601','2025-08-01','2028-07-31',40,1,210.00,8400.00),(4,1,4,6,'L-NPK-2601','2025-09-01','2028-08-31',30,1,250.00,7500.00),(5,2,5,8,'L-RDP-2602','2025-06-01','2027-05-31',20,1,180.00,3600.00),(6,2,6,9,'L-AMX-2602','2025-07-01','2027-06-30',15,1,450.00,6750.00),(7,2,7,10,'L-DEC-2602','2025-07-15','2027-07-14',10,1,280.00,2800.00),(8,2,8,11,'L-24D-2602','2025-08-01','2027-07-31',25,1,90.00,2250.00),(9,3,9,12,'L-IVM-2603','2025-11-01','2027-10-31',15,1,320.00,4800.00),(10,3,10,13,'L-VAC-2603','2025-12-01','2026-11-30',20,1,280.00,5600.00),(11,3,11,14,'L-OXI-2603','2025-11-15','2027-11-14',12,1,150.00,1800.00),(12,3,12,15,'L-BAL-2603','2026-01-01','2026-12-31',30,1,195.00,5850.00),(13,4,13,5,'L-URE-2604','2025-08-01','2028-07-31',35,1,210.00,7350.00),(14,4,14,6,'L-NPK-2604','2025-09-01','2028-08-31',25,1,250.00,6250.00),(15,4,15,7,'L-SOP-2604','2025-10-01','2028-09-30',20,1,320.00,6400.00),(16,5,18,15,'L-0903902','2025-07-27','2027-02-27',20,12,2000.00,40000.00),(17,6,19,15,'L-1234','2023-02-27','2027-03-27',2,12,200.00,400.00);
/*!40000 ALTER TABLE `detalle_compra` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `detalle_venta`
--

DROP TABLE IF EXISTS `detalle_venta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `detalle_venta` (
  `id_detalle_venta` int(11) NOT NULL AUTO_INCREMENT,
  `id_venta` int(11) NOT NULL,
  `id_lote` int(11) NOT NULL,
  `id_producto` int(11) NOT NULL,
  `tipo_cantidad` enum('CAJA','UNIDAD') NOT NULL DEFAULT 'UNIDAD',
  `cantidad` int(11) NOT NULL DEFAULT 1,
  `precio_unitario` decimal(12,2) NOT NULL,
  `descuento_pct` decimal(5,2) NOT NULL DEFAULT 0.00,
  `descuento_monto` decimal(12,2) NOT NULL DEFAULT 0.00,
  `subtotal` decimal(14,2) NOT NULL,
  PRIMARY KEY (`id_detalle_venta`),
  KEY `fk_dv_venta` (`id_venta`),
  KEY `fk_dv_lote` (`id_lote`),
  KEY `fk_dv_producto` (`id_producto`),
  CONSTRAINT `fk_dv_lote` FOREIGN KEY (`id_lote`) REFERENCES `lote` (`id_lote`),
  CONSTRAINT `fk_dv_producto` FOREIGN KEY (`id_producto`) REFERENCES `producto` (`id_producto`),
  CONSTRAINT `fk_dv_venta` FOREIGN KEY (`id_venta`) REFERENCES `venta` (`id_venta`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detalle_venta`
--

LOCK TABLES `detalle_venta` WRITE;
/*!40000 ALTER TABLE `detalle_venta` DISABLE KEYS */;
INSERT INTO `detalle_venta` VALUES (1,1,3,5,'CAJA',10,235.00,8.00,188.00,2162.00),(2,1,4,6,'CAJA',7,280.00,8.00,156.80,1803.20),(3,2,1,1,'CAJA',3,135.00,0.00,0.00,405.00),(4,3,5,8,'CAJA',1,210.00,0.00,0.00,210.00),(5,3,8,11,'CAJA',1,105.00,0.00,0.00,105.00),(6,4,3,5,'CAJA',8,210.00,8.00,134.40,1545.60),(7,4,4,6,'CAJA',8,250.00,8.00,160.00,1840.00),(8,4,6,9,'CAJA',2,450.00,8.00,72.00,828.00),(9,5,5,8,'CAJA',1,210.00,0.00,0.00,210.00),(10,6,9,12,'CAJA',10,320.00,6.00,192.00,3008.00),(11,6,10,13,'CAJA',6,280.00,6.00,100.80,1579.20),(12,7,18,15,'UNIDAD',2,215.00,0.00,0.00,430.00),(13,8,13,5,'UNIDAD',1,235.00,0.00,0.00,235.00),(14,8,16,13,'UNIDAD',1,310.00,0.00,0.00,310.00),(15,9,14,6,'UNIDAD',1,280.00,0.00,0.00,280.00),(16,9,18,15,'UNIDAD',1,215.00,0.00,0.00,215.00),(17,10,13,5,'UNIDAD',1,235.00,0.00,0.00,235.00),(18,10,15,7,'UNIDAD',1,360.00,0.00,0.00,360.00),(19,10,16,13,'UNIDAD',1,310.00,0.00,0.00,310.00),(20,11,13,5,'UNIDAD',1,235.00,0.00,0.00,235.00),(21,11,15,7,'UNIDAD',1,360.00,0.00,0.00,360.00),(22,12,13,5,'UNIDAD',1,235.00,0.00,0.00,235.00),(23,12,15,7,'UNIDAD',1,360.00,0.00,0.00,360.00),(24,13,14,6,'UNIDAD',1,280.00,0.00,0.00,280.00),(25,13,15,7,'UNIDAD',1,360.00,0.00,0.00,360.00);
/*!40000 ALTER TABLE `detalle_venta` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lote`
--

DROP TABLE IF EXISTS `lote`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lote` (
  `id_lote` int(11) NOT NULL AUTO_INCREMENT,
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
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_lote`),
  KEY `fk_lote_producto` (`id_producto`),
  KEY `fk_lote_sucursal` (`id_sucursal`),
  CONSTRAINT `fk_lote_producto` FOREIGN KEY (`id_producto`) REFERENCES `producto` (`id_producto`),
  CONSTRAINT `fk_lote_sucursal` FOREIGN KEY (`id_sucursal`) REFERENCES `sucursal` (`id_sucursal`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lote`
--

LOCK TABLES `lote` WRITE;
/*!40000 ALTER TABLE `lote` DISABLE KEYS */;
INSERT INTO `lote` VALUES (1,1,1,'L-MAI-2601','2025-10-01','2027-09-30','2026-01-10',50,1,120.00,90,90,NULL,1,'2026-05-26 15:27:53'),(2,2,1,'L-SOY-2601','2025-10-15','2027-10-14','2026-01-10',30,1,95.00,100,100,NULL,1,'2026-05-26 15:27:53'),(3,5,1,'L-URE-2601','2025-08-01','2028-07-31','2026-01-10',40,1,210.00,200,200,NULL,1,'2026-05-26 15:27:53'),(4,6,1,'L-NPK-2601','2025-09-01','2028-08-31','2026-01-10',30,1,250.00,40,40,NULL,1,'2026-05-26 15:27:53'),(5,8,1,'L-RDP-2602','2025-06-01','2027-05-31','2026-02-05',20,1,180.00,25,25,NULL,1,'2026-05-26 15:27:53'),(6,9,1,'L-AMX-2602','2025-07-01','2027-06-30','2026-02-05',15,1,450.00,80,80,NULL,1,'2026-05-26 15:27:53'),(7,10,1,'L-DEC-2602','2025-07-15','2027-07-14','2026-02-05',10,1,280.00,60,60,NULL,1,'2026-05-26 15:27:53'),(8,11,1,'L-24D-2602','2025-08-01','2027-07-31','2026-02-05',25,1,90.00,50,50,NULL,1,'2026-05-26 15:27:53'),(9,12,2,'L-IVM-2603','2025-11-01','2027-10-31','2026-03-15',15,1,320.00,20,20,NULL,1,'2026-05-26 15:27:53'),(10,13,2,'L-VAC-2603','2025-12-01','2026-11-30','2026-03-15',20,1,280.00,20,20,NULL,1,'2026-05-26 15:27:53'),(11,14,2,'L-OXI-2603','2025-11-15','2027-11-14','2026-03-15',12,1,150.00,60,60,NULL,1,'2026-05-26 15:27:53'),(12,15,2,'L-BAL-2603','2026-01-01','2026-12-31','2026-03-15',30,1,195.00,10,30,NULL,1,'2026-05-26 15:27:53'),(13,5,3,'L-URE-2604','2025-08-01','2028-07-31','2026-04-20',35,1,210.00,16,16,NULL,1,'2026-05-26 15:27:53'),(14,6,3,'L-NPK-2604','2025-09-01','2028-08-31','2026-04-20',25,1,250.00,68,68,NULL,1,'2026-05-26 15:27:53'),(15,7,3,'L-SOP-2604','2025-10-01','2028-09-30','2026-04-20',20,1,320.00,36,36,NULL,1,'2026-05-26 15:27:53'),(16,13,3,'L-VAC-2603',NULL,'2026-11-30','2026-05-26',1,1,280.00,18,18,NULL,1,'2026-05-26 17:30:41'),(17,15,3,'L-BAL-2603',NULL,'2026-12-31','2026-05-27',20,1,195.00,20,0,NULL,1,'2026-05-27 08:55:07'),(18,15,3,'L-0903902','2025-07-27','2027-02-27','2026-05-27',20,12,2000.00,19,237,NULL,1,'2026-05-27 08:56:46'),(19,15,3,'L-1234','2023-02-27','2027-03-27','2026-05-27',2,12,200.00,2,24,NULL,1,'2026-05-27 08:58:53');
/*!40000 ALTER TABLE `lote` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `marca`
--

DROP TABLE IF EXISTS `marca`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `marca` (
  `id_marca` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `pais_origen` varchar(60) DEFAULT NULL,
  `descripcion` text DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id_marca`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `marca`
--

LOCK TABLES `marca` WRITE;
/*!40000 ALTER TABLE `marca` DISABLE KEYS */;
INSERT INTO `marca` VALUES (1,'Bayer CropScience','Alemania','Semillas y protección de cultivos',1),(2,'Yara','Noruega','Fertilizantes y nutrición de cultivos',1),(3,'Syngenta','Suiza','Agroquímicos y semillas protegidas',1),(4,'Zoetis','Estados Unidos','Salud animal, vacunas y antiparasitarios',1),(5,'SeedCo','Zimbabue','Semillas híbridas para trópico y subtrópico',1),(6,'BASF','Alemania','Agroquímicos y soluciones agrícolas',1),(7,'Ciproquim','Bolivia','Productos agropecuarios de fabricación nacional',1),(8,'Disagro','Guatemala','Fertilizantes especializados para Latinoamérica',1);
/*!40000 ALTER TABLE `marca` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `movimiento_almacen`
--

DROP TABLE IF EXISTS `movimiento_almacen`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `movimiento_almacen` (
  `id_movimiento` int(11) NOT NULL AUTO_INCREMENT,
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
  `observaciones` text DEFAULT NULL,
  PRIMARY KEY (`id_movimiento`),
  KEY `fk_mov_lote` (`id_lote`),
  KEY `fk_mov_sucursal` (`id_sucursal`),
  KEY `fk_mov_usuario` (`id_usuario`),
  CONSTRAINT `fk_mov_lote` FOREIGN KEY (`id_lote`) REFERENCES `lote` (`id_lote`),
  CONSTRAINT `fk_mov_sucursal` FOREIGN KEY (`id_sucursal`) REFERENCES `sucursal` (`id_sucursal`),
  CONSTRAINT `fk_mov_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `movimiento_almacen`
--

LOCK TABLES `movimiento_almacen` WRITE;
/*!40000 ALTER TABLE `movimiento_almacen` DISABLE KEYS */;
INSERT INTO `movimiento_almacen` VALUES (1,1,1,6,'ENTRADA','Compra FACT-AGR-0001-2026',50,0,'2026-01-10 09:00:00',1,'COMPRA',NULL),(2,2,1,6,'ENTRADA','Compra FACT-AGR-0001-2026',30,0,'2026-01-10 09:00:00',1,'COMPRA',NULL),(3,3,1,6,'ENTRADA','Compra FACT-AGR-0001-2026',40,0,'2026-01-10 09:00:00',1,'COMPRA',NULL),(4,4,1,6,'ENTRADA','Compra FACT-AGR-0001-2026',30,0,'2026-01-10 09:00:00',1,'COMPRA',NULL),(5,5,1,6,'ENTRADA','Compra FACT-AGR-0002-2026',20,0,'2026-02-05 10:00:00',2,'COMPRA',NULL),(6,6,1,6,'ENTRADA','Compra FACT-AGR-0002-2026',15,0,'2026-02-05 10:00:00',2,'COMPRA',NULL),(7,7,1,6,'ENTRADA','Compra FACT-AGR-0002-2026',10,0,'2026-02-05 10:00:00',2,'COMPRA',NULL),(8,8,1,6,'ENTRADA','Compra FACT-AGR-0002-2026',25,0,'2026-02-05 10:00:00',2,'COMPRA',NULL),(9,9,2,7,'ENTRADA','Compra FACT-AGR-0003-2026',15,0,'2026-03-15 08:30:00',3,'COMPRA',NULL),(10,10,2,7,'ENTRADA','Compra FACT-AGR-0003-2026',20,0,'2026-03-15 08:30:00',3,'COMPRA',NULL),(11,11,2,7,'ENTRADA','Compra FACT-AGR-0003-2026',12,0,'2026-03-15 08:30:00',3,'COMPRA',NULL),(12,12,2,7,'ENTRADA','Compra FACT-AGR-0003-2026',30,0,'2026-03-15 08:30:00',3,'COMPRA',NULL),(13,13,3,8,'ENTRADA','Compra FACT-AGR-0004-2026',35,0,'2026-04-20 09:00:00',4,'COMPRA',NULL),(14,14,3,8,'ENTRADA','Compra FACT-AGR-0004-2026',25,0,'2026-04-20 09:00:00',4,'COMPRA',NULL),(15,15,3,8,'ENTRADA','Compra FACT-AGR-0004-2026',20,0,'2026-04-20 09:00:00',4,'COMPRA',NULL),(16,3,1,2,'SALIDA','Venta VTA-0001-2026',10,0,'2026-05-20 09:30:00',1,'VENTA',NULL),(17,4,1,2,'SALIDA','Venta VTA-0001-2026',7,0,'2026-05-20 09:30:00',1,'VENTA',NULL),(18,1,1,2,'SALIDA','Venta VTA-0002-2026',3,0,'2026-05-20 11:00:00',2,'VENTA',NULL),(19,5,1,3,'SALIDA','Venta VTA-0003-2026',1,0,'2026-05-26 09:15:00',3,'VENTA',NULL),(20,8,1,3,'SALIDA','Venta VTA-0003-2026',1,0,'2026-05-26 09:15:00',3,'VENTA',NULL),(21,3,1,3,'SALIDA','Venta VTA-0004-2026',8,0,'2026-05-26 10:00:00',4,'VENTA',NULL),(22,4,1,3,'SALIDA','Venta VTA-0004-2026',8,0,'2026-05-26 10:00:00',4,'VENTA',NULL),(23,6,1,3,'SALIDA','Venta VTA-0004-2026',2,0,'2026-05-26 10:00:00',4,'VENTA',NULL),(24,5,1,3,'SALIDA','Venta VTA-0005-2026',1,0,'2026-05-26 11:30:00',5,'VENTA',NULL),(25,9,2,4,'SALIDA','Venta VTA-0006-2026',10,0,'2026-05-26 09:00:00',6,'VENTA',NULL),(26,10,2,4,'SALIDA','Venta VTA-0006-2026',6,0,'2026-05-26 09:00:00',6,'VENTA',NULL),(27,8,1,6,'TRASLADO','Salida traslado a Sucursal Norte',5,0,'2026-05-15 14:00:00',1,'TRASLADO',NULL),(28,10,2,1,'AJUSTE','Conteo fisico',20,20,'2026-05-26 17:29:05',NULL,'MANUAL',NULL),(29,10,2,1,'TRASLADO','Salida por traslado confirmado',1,20,'2026-05-26 17:30:41',3,'TRASLADO',NULL),(30,16,3,1,'ENTRADA','Entrada por traslado confirmado',1,20,'2026-05-26 17:30:41',3,'TRASLADO',NULL),(31,10,2,1,'AJUSTE','Conteo fisico',20,20,'2026-05-27 08:24:37',NULL,'MANUAL',NULL),(32,12,2,1,'AJUSTE','Conteo fisico',30,30,'2026-05-27 08:24:56',NULL,'MANUAL',NULL),(33,5,1,1,'AJUSTE','Conteo fisico',25,25,'2026-05-27 08:25:20',NULL,'MANUAL',NULL),(34,6,1,1,'AJUSTE','Conteo fisico',80,80,'2026-05-27 08:25:41',NULL,'MANUAL',NULL),(35,7,1,1,'AJUSTE','Conteo fisico',60,60,'2026-05-27 08:26:00',NULL,'MANUAL',NULL),(36,8,1,1,'AJUSTE','Conteo fisico',50,50,'2026-05-27 08:26:15',NULL,'MANUAL',NULL),(37,1,1,1,'AJUSTE','Conteo fisico',90,90,'2026-05-27 08:26:31',NULL,'MANUAL',NULL),(38,2,1,1,'AJUSTE','Conteo fisico',100,100,'2026-05-27 08:26:46',NULL,'MANUAL',NULL),(39,9,2,1,'AJUSTE','Conteo fisico',20,20,'2026-05-27 08:27:03',NULL,'MANUAL',NULL),(40,11,2,1,'AJUSTE','Conteo fisico',60,60,'2026-05-27 08:27:22',NULL,'MANUAL',NULL),(41,13,3,1,'AJUSTE','Conteo fisico',20,20,'2026-05-27 08:27:34',NULL,'MANUAL',NULL),(42,3,1,1,'AJUSTE','Conteo fisico',200,200,'2026-05-27 08:27:48',NULL,'MANUAL',NULL),(43,14,3,1,'AJUSTE','Conteo fisico',70,70,'2026-05-27 08:28:01',NULL,'MANUAL',NULL),(44,4,1,1,'AJUSTE','Conteo fisico',40,40,'2026-05-27 08:28:13',NULL,'MANUAL',NULL),(45,15,3,1,'AJUSTE','Conteo fisico',40,40,'2026-05-27 08:31:22',NULL,'MANUAL',NULL),(46,12,2,1,'TRASLADO','Salida por traslado confirmado',20,0,'2026-05-27 08:55:07',4,'TRASLADO',NULL),(47,17,3,1,'ENTRADA','Entrada por traslado confirmado',20,0,'2026-05-27 08:55:07',4,'TRASLADO',NULL),(48,18,3,1,'ENTRADA','INGRESO POR COMPRA',20,240,'2026-05-27 08:56:46',5,'COMPRA',NULL),(49,19,3,1,'ENTRADA','INGRESO POR COMPRA',2,24,'2026-05-27 08:58:53',6,'COMPRA',NULL),(50,18,3,1,'SALIDA','VENTA',0,2,'2026-05-27 09:00:39',7,'VENTA',NULL),(51,13,3,1,'SALIDA','VENTA',1,1,'2026-05-27 09:01:37',8,'VENTA',NULL),(52,16,3,1,'SALIDA','VENTA',1,1,'2026-05-27 09:01:37',8,'VENTA',NULL),(53,14,3,1,'SALIDA','VENTA',1,1,'2026-05-27 09:03:50',9,'VENTA',NULL),(54,18,3,1,'SALIDA','VENTA',0,1,'2026-05-27 09:03:50',9,'VENTA',NULL),(55,13,3,1,'SALIDA','VENTA',1,1,'2026-05-27 09:04:26',10,'VENTA',NULL),(56,15,3,1,'SALIDA','VENTA',1,1,'2026-05-27 09:04:26',10,'VENTA',NULL),(57,16,3,1,'SALIDA','VENTA',1,1,'2026-05-27 09:04:26',10,'VENTA',NULL),(58,13,3,1,'SALIDA','VENTA',1,1,'2026-05-27 10:16:32',11,'VENTA',NULL),(59,15,3,1,'SALIDA','VENTA',1,1,'2026-05-27 10:16:32',11,'VENTA',NULL),(60,13,3,1,'SALIDA','VENTA',1,1,'2026-05-27 11:20:30',12,'VENTA',NULL),(61,15,3,1,'SALIDA','VENTA',1,1,'2026-05-27 11:20:30',12,'VENTA',NULL),(62,14,3,1,'SALIDA','VENTA',1,1,'2026-05-27 14:35:51',13,'VENTA',NULL),(63,15,3,1,'SALIDA','VENTA',1,1,'2026-05-27 14:35:51',13,'VENTA',NULL);
/*!40000 ALTER TABLE `movimiento_almacen` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permiso`
--

DROP TABLE IF EXISTS `permiso`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `permiso` (
  `id_permiso` int(11) NOT NULL AUTO_INCREMENT,
  `modulo` varchar(50) NOT NULL,
  `accion` varchar(50) NOT NULL,
  `nombre_clave` varchar(80) NOT NULL,
  `descripcion` text DEFAULT NULL,
  PRIMARY KEY (`id_permiso`),
  UNIQUE KEY `uq_permiso_clave` (`nombre_clave`)
) ENGINE=InnoDB AUTO_INCREMENT=122 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permiso`
--

LOCK TABLES `permiso` WRITE;
/*!40000 ALTER TABLE `permiso` DISABLE KEYS */;
INSERT INTO `permiso` VALUES (1,'roles','ver','roles.ver','Ver listado de roles del sistema'),(2,'roles','crear','roles.crear','Crear nuevos roles'),(3,'roles','editar','roles.editar','Editar nombre de un rol'),(4,'roles','eliminar','roles.eliminar','Eliminar roles del sistema'),(5,'roles','gestionar_permisos','roles.gestionar_permisos','Asignar y quitar permisos a un rol'),(6,'usuarios','ver','usuarios.ver','Ver listado de usuarios del sistema'),(7,'usuarios','ver_detalle','usuarios.ver_detalle','Ver ficha completa de un usuario'),(8,'usuarios','crear','usuarios.crear','Crear nuevos usuarios'),(9,'usuarios','editar','usuarios.editar','Editar datos de un usuario'),(10,'usuarios','eliminar','usuarios.eliminar','Eliminar usuarios del sistema'),(11,'usuarios','activar','usuarios.activar','Activar o desactivar un usuario'),(12,'usuarios','cambiar_rol','usuarios.cambiar_rol','Cambiar el rol asignado a un usuario'),(13,'usuarios','cambiar_sucursal','usuarios.cambiar_sucursal','Reasignar usuario a otra sucursal'),(14,'usuarios','resetear_clave','usuarios.resetear_clave','Restablecer contraseña de un usuario'),(15,'sucursales','ver','sucursales.ver','Ver listado de sucursales'),(16,'sucursales','ver_detalle','sucursales.ver_detalle','Ver ficha completa de una sucursal'),(17,'sucursales','crear','sucursales.crear','Registrar nuevas sucursales'),(18,'sucursales','editar','sucursales.editar','Editar datos de una sucursal'),(19,'sucursales','eliminar','sucursales.eliminar','Eliminar sucursales del sistema'),(20,'sucursales','activar','sucursales.activar','Activar o desactivar una sucursal'),(21,'clasificaciones','ver','clasificaciones.ver','Ver listado de clasificaciones'),(22,'clasificaciones','crear','clasificaciones.crear','Crear clasificaciones de producto'),(23,'clasificaciones','editar','clasificaciones.editar','Editar una clasificación'),(24,'clasificaciones','eliminar','clasificaciones.eliminar','Eliminar una clasificación'),(25,'marcas','ver','marcas.ver','Ver listado de marcas'),(26,'marcas','crear','marcas.crear','Registrar nuevas marcas'),(27,'marcas','editar','marcas.editar','Editar datos de una marca'),(28,'marcas','eliminar','marcas.eliminar','Eliminar marcas del sistema'),(29,'unidades','ver','unidades.ver','Ver listado de unidades de medida'),(30,'unidades','crear','unidades.crear','Crear unidades de medida'),(31,'unidades','editar','unidades.editar','Editar una unidad de medida'),(32,'unidades','eliminar','unidades.eliminar','Eliminar unidades de medida'),(33,'productos','ver','productos.ver','Ver catálogo de productos'),(34,'productos','ver_detalle','productos.ver_detalle','Ver ficha completa de un producto'),(35,'productos','crear','productos.crear','Agregar productos al catálogo'),(36,'productos','editar','productos.editar','Editar datos generales del producto'),(37,'productos','eliminar','productos.eliminar','Eliminar productos del catálogo'),(38,'productos','activar','productos.activar','Activar o desactivar un producto'),(39,'productos','ver_costo','productos.ver_costo','Ver precio de costo (precio_por_caja del lote)'),(40,'productos','ver_precios','productos.ver_precios','Ver precios de venta mayor y menor'),(41,'productos','editar_precios','productos.editar_precios','Modificar precios de venta mayor y menor'),(42,'productos','editar_descuentos','productos.editar_descuentos','Modificar porcentajes de descuento'),(43,'productos','ver_stock','productos.ver_stock','Ver stock disponible de productos'),(44,'productos','gestionar_imagen','productos.gestionar_imagen','Subir o eliminar imagen del producto'),(45,'almacen','ver','almacen.ver','Ver inventario general del almacén'),(46,'almacen','ver_lotes','almacen.ver_lotes','Ver listado detallado de lotes'),(47,'almacen','ver_lote_detalle','almacen.ver_lote_detalle','Ver ficha completa de un lote'),(48,'almacen','ver_costo_lote','almacen.ver_costo_lote','Ver precio de costo de cada lote'),(49,'almacen','ingresar','almacen.ingresar','Registrar entradas de productos al almacén'),(50,'almacen','ajustar','almacen.ajustar','Registrar ajustes de inventario'),(51,'almacen','trasladar','almacen.trasladar','Trasladar stock entre sucursales'),(52,'almacen','ver_movimientos','almacen.ver_movimientos','Ver historial de movimientos (kardex)'),(53,'almacen','ver_vencimientos','almacen.ver_vencimientos','Ver productos próximos a vencer'),(54,'almacen','dar_baja_lote','almacen.dar_baja_lote','Dar de baja un lote (vencido o dañado)'),(55,'proveedores','ver','proveedores.ver','Ver listado de proveedores'),(56,'proveedores','ver_detalle','proveedores.ver_detalle','Ver ficha completa de un proveedor'),(57,'proveedores','crear','proveedores.crear','Registrar nuevos proveedores'),(58,'proveedores','editar','proveedores.editar','Editar datos de un proveedor'),(59,'proveedores','eliminar','proveedores.eliminar','Eliminar proveedores del sistema'),(60,'proveedores','activar','proveedores.activar','Activar o desactivar un proveedor'),(61,'compras','ver','compras.ver','Ver historial de compras'),(62,'compras','ver_detalle','compras.ver_detalle','Ver detalle completo de una compra'),(63,'compras','ver_costo','compras.ver_costo','Ver precios de costo en las compras'),(64,'compras','crear','compras.crear','Registrar nuevas compras'),(65,'compras','editar','compras.editar','Editar compras en estado PENDIENTE'),(66,'compras','confirmar','compras.confirmar','Confirmar y cerrar una compra'),(67,'compras','anular','compras.anular','Anular una compra registrada'),(68,'compras','ver_todas_sucursales','compras.ver_todas_sucursales','Ver compras de todas las sucursales'),(69,'clientes','ver','clientes.ver','Ver listado de clientes'),(70,'clientes','ver_detalle','clientes.ver_detalle','Ver ficha completa de un cliente'),(71,'clientes','crear','clientes.crear','Registrar nuevos clientes'),(72,'clientes','editar','clientes.editar','Editar datos de un cliente'),(73,'clientes','eliminar','clientes.eliminar','Eliminar clientes del sistema'),(74,'clientes','activar','clientes.activar','Activar o desactivar un cliente'),(75,'clientes','ver_historial','clientes.ver_historial','Ver historial de compras de un cliente'),(76,'clientes','cambiar_tipo','clientes.cambiar_tipo','Cambiar tipo de cliente: minorista / mayorista'),(77,'ventas','ver','ventas.ver','Ver historial de ventas propias'),(78,'ventas','ver_detalle','ventas.ver_detalle','Ver detalle completo de una venta'),(79,'ventas','ver_todas','ventas.ver_todas','Ver ventas de todos los vendedores'),(80,'ventas','ver_todas_sucursales','ventas.ver_todas_sucursales','Ver ventas de todas las sucursales'),(81,'ventas','crear','ventas.crear','Registrar nuevas ventas'),(82,'ventas','anular','ventas.anular','Anular una venta realizada'),(83,'ventas','aplicar_descuento','ventas.aplicar_descuento','Aplicar descuento adicional en una venta'),(84,'ventas','descuento_libre','ventas.descuento_libre','Ingresar descuento libre (sin límite de porcentaje)'),(85,'ventas','vender_sin_stock','ventas.vender_sin_stock','Registrar venta aunque el stock sea 0'),(86,'ventas','ver_costo','ventas.ver_costo','Ver el costo y la utilidad de cada venta'),(87,'ventas','cambiar_precio','ventas.cambiar_precio','Modificar el precio en el momento de la venta'),(88,'ventas','reimprimir','ventas.reimprimir','Reimprimir comprobante de una venta'),(89,'traslados','ver','traslados.ver','Ver listado de traslados entre sucursales'),(90,'traslados','crear','traslados.crear','Crear un traslado de stock'),(91,'traslados','confirmar','traslados.confirmar','Confirmar un traslado pendiente'),(92,'traslados','cancelar','traslados.cancelar','Cancelar un traslado pendiente'),(93,'caja','ver','caja.ver','Ver listado de cajas registradas'),(94,'caja','crear','caja.crear','Registrar nuevas cajas'),(95,'caja','editar','caja.editar','Editar datos de una caja'),(96,'caja','activar','caja.activar','Activar o desactivar una caja'),(97,'caja','abrir','caja.abrir','Abrir turno de caja con monto inicial'),(98,'caja','cerrar','caja.cerrar','Cerrar turno de caja y registrar monto final'),(99,'caja','ver_movimientos','caja.ver_movimientos','Ver movimientos de efectivo de una caja'),(100,'caja','ver_todas','caja.ver_todas','Ver cajas de todas las sucursales'),(101,'caja','ver_historial','caja.ver_historial','Ver historial de aperturas y cierres de caja'),(102,'reportes','ventas_diarias','reportes.ventas_diarias','Ver reporte de ventas del día'),(103,'reportes','ventas_rango','reportes.ventas_rango','Ver reporte de ventas por rango de fechas'),(104,'reportes','ventas_vendedor','reportes.ventas_vendedor','Ver reporte de ventas por vendedor'),(105,'reportes','ventas_producto','reportes.ventas_producto','Ver reporte de ventas por producto'),(106,'reportes','ventas_cliente','reportes.ventas_cliente','Ver reporte de ventas por cliente'),(107,'reportes','compras','reportes.compras','Ver reporte de compras realizadas'),(108,'reportes','compras_proveedor','reportes.compras_proveedor','Ver reporte de compras por proveedor'),(109,'reportes','inventario','reportes.inventario','Ver reporte de inventario actual'),(110,'reportes','inventario_valorizado','reportes.inventario_valorizado','Ver inventario con valor de costo total'),(111,'reportes','ganancias','reportes.ganancias','Ver reporte de ganancias y utilidad bruta'),(112,'reportes','ganancias_producto','reportes.ganancias_producto','Ver utilidad desglosada por producto'),(113,'reportes','top_productos','reportes.top_productos','Ver ranking de productos más vendidos'),(114,'reportes','vencimientos','reportes.vencimientos','Ver reporte de productos próximos a vencer'),(115,'reportes','stock_bajo','reportes.stock_bajo','Ver productos por debajo del stock mínimo'),(116,'reportes','kardex','reportes.kardex','Ver kardex (historial de movimientos por lote)'),(117,'reportes','traslados','reportes.traslados','Ver reporte de traslados entre sucursales'),(118,'reportes','comparativo_sucursales','reportes.comparativo_sucursales','Comparar ventas y ganancias entre sucursales'),(119,'reportes','caja','reportes.caja','Ver reporte de arqueos y movimientos de caja'),(120,'configuracion','ver','configuracion.ver','Ver configuración general del sistema'),(121,'configuracion','editar','configuracion.editar','Editar configuración general del sistema');
/*!40000 ALTER TABLE `permiso` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `producto`
--

DROP TABLE IF EXISTS `producto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `producto` (
  `id_producto` int(11) NOT NULL AUTO_INCREMENT,
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
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_producto`),
  UNIQUE KEY `uq_producto_barras` (`codigo_barras`),
  KEY `fk_prod_clasificacion` (`id_clasificacion`),
  KEY `fk_prod_marca` (`id_marca`),
  KEY `fk_prod_unidad` (`id_unidad`),
  CONSTRAINT `fk_prod_clasificacion` FOREIGN KEY (`id_clasificacion`) REFERENCES `clasificacion_producto` (`id_clasificacion`),
  CONSTRAINT `fk_prod_marca` FOREIGN KEY (`id_marca`) REFERENCES `marca` (`id_marca`),
  CONSTRAINT `fk_prod_unidad` FOREIGN KEY (`id_unidad`) REFERENCES `unidad_medida` (`id_unidad`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `producto`
--

LOCK TABLES `producto` WRITE;
/*!40000 ALTER TABLE `producto` DISABLE KEYS */;
INSERT INTO `producto` VALUES (1,1,5,5,'Semilla Maíz Híbrido DK-7088','Maíz híbrido de alto rendimiento, apto para riego y secano','7801234560001',NULL,120.00,135.00,5.00,0.00,20,1,'2026-05-26 15:27:53'),(2,1,1,5,'Semilla Soya NK-S7209','Soya ciclo medio, alta tolerancia a enfermedades','7801234560002',NULL,95.00,110.00,5.00,0.00,15,1,'2026-05-26 15:27:53'),(3,1,5,5,'Semilla Sorgo NK-7829','Sorgo granífero resistente a sequía','7801234560003',NULL,75.00,88.00,4.00,0.00,10,1,'2026-05-26 15:27:53'),(4,1,5,5,'Semilla Girasol SY-4045','Girasol de alto contenido oleico','7801234560004',NULL,85.00,98.00,4.00,0.00,10,1,'2026-05-26 15:27:53'),(5,2,2,4,'Urea 46% Granulada','Nitrógeno al 46%, granulado, para todo tipo de cultivo','7801234560005',NULL,210.00,235.00,8.00,2.00,30,1,'2026-05-26 15:27:53'),(6,2,8,4,'Fertilizante NPK 15-15-15','Fórmula balanceada para inicio de cultivo','7801234560006',NULL,250.00,280.00,8.00,2.00,25,1,'2026-05-26 15:27:53'),(7,2,2,4,'Sulfato de Potasio K2SO4','Potasio de alta pureza, libre de cloro','7801234560007',NULL,320.00,360.00,6.00,0.00,15,1,'2026-05-26 15:27:53'),(8,3,1,2,'Herbicida Roundup 48 SL','Glifosato 48%, control total de malezas, envase 1 lt','7801234560008',NULL,180.00,210.00,10.00,3.00,20,1,'2026-05-26 15:27:53'),(9,3,3,2,'Fungicida Amistar Xtra 280 SC','Control de enfermedades foliares en soya y maíz, 1 lt','7801234560009',NULL,450.00,490.00,8.00,2.00,10,1,'2026-05-26 15:27:53'),(10,3,6,2,'Insecticida Decis Forte 100 EC','Control de insectos masticadores y chupadores, 1 lt','7801234560010',NULL,280.00,310.00,7.00,0.00,10,1,'2026-05-26 15:27:53'),(11,3,7,2,'Herbicida 2,4-D Amina 72%','Control de malezas de hoja ancha, envase 1 lt','7801234560011',NULL,90.00,105.00,5.00,0.00,15,1,'2026-05-26 15:27:53'),(12,4,4,3,'Ivermectina 1% Inyectable 500ml','Antiparasitario de amplio espectro para bovinos y porcinos','7801234560012',NULL,320.00,360.00,6.00,0.00,15,1,'2026-05-26 15:27:53'),(13,4,4,3,'Vacuna Triple Bovina Clostridial 50 dosis','Protección contra clostridiosis en bovinos, frasco x50 dosis','7801234560013',NULL,280.00,310.00,5.00,0.00,10,1,'2026-05-26 15:27:53'),(14,4,4,2,'Oxitetraciclina 20% LA 100ml','Antibiótico de larga acción para bovinos y porcinos','7801234560014',NULL,150.00,175.00,5.00,0.00,12,1,'2026-05-26 15:27:53'),(15,6,7,4,'Balanceado Iniciador Pollos Parrillero','Alimento completo fase inicial 0-21 días, saco 50 kg','7801234560015',NULL,195.00,215.00,7.00,2.00,40,1,'2026-05-26 15:27:53');
/*!40000 ALTER TABLE `producto` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `proveedor`
--

DROP TABLE IF EXISTS `proveedor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `proveedor` (
  `id_proveedor` int(11) NOT NULL AUTO_INCREMENT,
  `empresa` varchar(150) NOT NULL,
  `nit` varchar(30) DEFAULT NULL,
  `contacto` varchar(100) DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `correo` varchar(100) DEFAULT NULL,
  `direccion` varchar(200) DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id_proveedor`),
  UNIQUE KEY `uq_proveedor_nit` (`nit`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `proveedor`
--

LOCK TABLES `proveedor` WRITE;
/*!40000 ALTER TABLE `proveedor` DISABLE KEYS */;
INSERT INTO `proveedor` VALUES (1,'Distribuidora Agro Bolivia S.R.L.','1023456001','Fernando Suárez','33491234','fsuarez@agrobolivia.com','Av. Grigotá N° 1200, Santa Cruz',1),(2,'SeedCo Bolivia','2034567002','Claudia Montaño','33478965','cmontano@seedco.bo','Parque Industrial PI-7, Santa Cruz',1),(3,'Yara Bolivia S.A.','3045678003','Rodrigo Antezana','44567891','rantezana@yara.com.bo','Av. América N° 450, Cochabamba',1),(4,'Laboratorios Zoetis Bolivia','4056789004','Valeria Peña','76345678','vpena@zoetis.com.bo','Calle Comercio N° 300, La Paz',1),(5,'Agroquímicos del Sur Ltda.','5067890005','Marco Vargas','72456789','mvargas@agrosur.com.bo','Barrio Urbari, Santa Cruz',1);
/*!40000 ALTER TABLE `proveedor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rol`
--

DROP TABLE IF EXISTS `rol`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rol` (
  `id_rol` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  PRIMARY KEY (`id_rol`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rol`
--

LOCK TABLES `rol` WRITE;
/*!40000 ALTER TABLE `rol` DISABLE KEYS */;
INSERT INTO `rol` VALUES (1,'Administrador'),(2,'Vendedor'),(3,'Almacenero');
/*!40000 ALTER TABLE `rol` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rol_permiso`
--

DROP TABLE IF EXISTS `rol_permiso`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rol_permiso` (
  `id_rol` int(11) NOT NULL,
  `id_permiso` int(11) NOT NULL,
  PRIMARY KEY (`id_rol`,`id_permiso`),
  KEY `fk_rp_permiso` (`id_permiso`),
  CONSTRAINT `fk_rp_permiso` FOREIGN KEY (`id_permiso`) REFERENCES `permiso` (`id_permiso`) ON DELETE CASCADE,
  CONSTRAINT `fk_rp_rol` FOREIGN KEY (`id_rol`) REFERENCES `rol` (`id_rol`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rol_permiso`
--

LOCK TABLES `rol_permiso` WRITE;
/*!40000 ALTER TABLE `rol_permiso` DISABLE KEYS */;
INSERT INTO `rol_permiso` VALUES (1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(1,7),(1,8),(1,9),(1,10),(1,11),(1,12),(1,13),(1,14),(1,15),(1,16),(1,17),(1,18),(1,19),(1,20),(1,21),(1,22),(1,23),(1,24),(1,25),(1,26),(1,27),(1,28),(1,29),(1,30),(1,31),(1,32),(1,33),(1,34),(1,35),(1,36),(1,37),(1,38),(1,39),(1,40),(1,41),(1,42),(1,43),(1,44),(1,45),(1,46),(1,47),(1,48),(1,49),(1,50),(1,51),(1,52),(1,53),(1,54),(1,55),(1,56),(1,57),(1,58),(1,59),(1,60),(1,61),(1,62),(1,63),(1,64),(1,65),(1,66),(1,67),(1,68),(1,69),(1,70),(1,71),(1,72),(1,73),(1,74),(1,75),(1,76),(1,77),(1,78),(1,79),(1,80),(1,81),(1,82),(1,83),(1,84),(1,85),(1,86),(1,87),(1,88),(1,89),(1,90),(1,91),(1,92),(1,93),(1,94),(1,95),(1,96),(1,97),(1,98),(1,99),(1,100),(1,101),(1,102),(1,103),(1,104),(1,105),(1,106),(1,107),(1,108),(1,109),(1,110),(1,111),(1,112),(1,113),(1,114),(1,115),(1,116),(1,117),(1,118),(1,119),(1,120),(1,121),(2,15),(2,33),(2,34),(2,40),(2,43),(2,45),(2,69),(2,70),(2,71),(2,72),(2,75),(2,76),(2,77),(2,78),(2,79),(2,81),(2,82),(2,83),(2,88),(2,93),(2,97),(2,98),(2,99),(2,100),(2,101),(2,102),(2,103),(2,104),(2,106),(3,33),(3,34),(3,39),(3,43),(3,45),(3,46),(3,47),(3,48),(3,49),(3,50),(3,51),(3,52),(3,53),(3,54),(3,55),(3,56),(3,61),(3,62),(3,63),(3,64),(3,66),(3,89),(3,90),(3,91),(3,92),(3,109),(3,110),(3,114),(3,115),(3,116),(3,117),(3,119);
/*!40000 ALTER TABLE `rol_permiso` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sucursal`
--

DROP TABLE IF EXISTS `sucursal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sucursal` (
  `id_sucursal` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `direccion` varchar(200) NOT NULL,
  `ciudad` varchar(100) NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `correo` varchar(100) DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_sucursal`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sucursal`
--

LOCK TABLES `sucursal` WRITE;
/*!40000 ALTER TABLE `sucursal` DISABLE KEYS */;
INSERT INTO `sucursal` VALUES (1,'Sucursal Central','Av. Cañoto N° 234, entre Warnes y Ñuflo de Chávez','Santa Cruz de la Sierra','33412345','central@agropecuaria.bo',1,'2026-05-26 15:27:53'),(2,'Sucursal Norte','Calle Montero N° 89, Zona Norte','Santa Cruz de la Sierra','33498765','norte@agropecuaria.bo',1,'2026-05-26 15:27:53'),(3,'Sucursal Cochabamba','Av. Blanco Galindo Km 5, Quillacollo','Cochabamba','44523678','cbba@agropecuaria.bo',1,'2026-05-26 15:27:53');
/*!40000 ALTER TABLE `sucursal` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `traslado`
--

DROP TABLE IF EXISTS `traslado`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `traslado` (
  `id_traslado` int(11) NOT NULL AUTO_INCREMENT,
  `id_lote_origen` int(11) NOT NULL,
  `id_sucursal_dest` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `cantidad_cajas` int(11) NOT NULL DEFAULT 0,
  `cantidad_unidades` int(11) NOT NULL DEFAULT 0,
  `fecha_traslado` datetime NOT NULL DEFAULT current_timestamp(),
  `estado` enum('PENDIENTE','CONFIRMADO','CANCELADO') NOT NULL DEFAULT 'PENDIENTE',
  `observaciones` text DEFAULT NULL,
  PRIMARY KEY (`id_traslado`),
  KEY `fk_tras_lote` (`id_lote_origen`),
  KEY `fk_tras_sucursal` (`id_sucursal_dest`),
  KEY `fk_tras_usuario` (`id_usuario`),
  CONSTRAINT `fk_tras_lote` FOREIGN KEY (`id_lote_origen`) REFERENCES `lote` (`id_lote`),
  CONSTRAINT `fk_tras_sucursal` FOREIGN KEY (`id_sucursal_dest`) REFERENCES `sucursal` (`id_sucursal`),
  CONSTRAINT `fk_tras_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `traslado`
--

LOCK TABLES `traslado` WRITE;
/*!40000 ALTER TABLE `traslado` DISABLE KEYS */;
INSERT INTO `traslado` VALUES (1,8,2,6,5,0,'2026-05-15 14:00:00','CONFIRMADO','Traslado de herbicida 2,4-D solicitado por sucursal norte'),(2,10,3,1,20,20,'2026-05-26 17:29:52','CANCELADO',NULL),(3,10,3,1,1,20,'2026-05-26 17:30:33','CONFIRMADO',NULL),(4,12,3,1,20,0,'2026-05-27 08:55:01','CONFIRMADO',NULL);
/*!40000 ALTER TABLE `traslado` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `unidad_medida`
--

DROP TABLE IF EXISTS `unidad_medida`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `unidad_medida` (
  `id_unidad` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `abreviatura` varchar(10) NOT NULL,
  PRIMARY KEY (`id_unidad`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `unidad_medida`
--

LOCK TABLES `unidad_medida` WRITE;
/*!40000 ALTER TABLE `unidad_medida` DISABLE KEYS */;
INSERT INTO `unidad_medida` VALUES (1,'Kilogramo','kg'),(2,'Litro','lt'),(3,'Unidad','und'),(4,'Saco (50 kg)','saco'),(5,'Sobre','sobre'),(6,'Mililitro','ml'),(7,'Gramo','gr'),(8,'Caja','cja');
/*!40000 ALTER TABLE `unidad_medida` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuario`
--

DROP TABLE IF EXISTS `usuario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usuario` (
  `id_usuario` int(11) NOT NULL AUTO_INCREMENT,
  `id_rol` int(11) DEFAULT NULL,
  `id_sucursal` int(11) DEFAULT NULL,
  `ci` varchar(20) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellido` varchar(100) NOT NULL,
  `celular` varchar(20) DEFAULT NULL,
  `correo` varchar(100) DEFAULT NULL,
  `contrasena` varchar(255) NOT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `uq_usuario_ci` (`ci`),
  UNIQUE KEY `uq_usuario_correo` (`correo`),
  KEY `fk_usuario_rol` (`id_rol`),
  KEY `fk_usuario_sucursal` (`id_sucursal`),
  CONSTRAINT `fk_usuario_rol` FOREIGN KEY (`id_rol`) REFERENCES `rol` (`id_rol`),
  CONSTRAINT `fk_usuario_sucursal` FOREIGN KEY (`id_sucursal`) REFERENCES `sucursal` (`id_sucursal`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario`
--

LOCK TABLES `usuario` WRITE;
/*!40000 ALTER TABLE `usuario` DISABLE KEYS */;
INSERT INTO `usuario` VALUES (1,1,3,'7512301','Carlos','Mendoza Vaca','77812301','admin@agropecuaria.bo','$2b$10$0mJZMb0UdWEo.0.4bbmIauwGq6EtZ3sCiQJZkJFL19UZPI68m/xie',1,'2026-05-26 15:27:53'),(2,2,1,'8023402','María','Flores Torrico','76923402','mflores@agropecuaria.bo','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',1,'2026-05-26 15:27:53'),(3,2,1,'6534503','Roberto','Quiroga Pedraza','71534503','rquiroga@agropecuaria.bo','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',1,'2026-05-26 15:27:53'),(4,2,2,'5245604','Lucía','Gutiérrez Molina','79845604','lgutierrez@agropecuaria.bo','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',1,'2026-05-26 15:27:53'),(5,2,1,'4356705','Pablo','Rojas Saavedra','68956705','projas@agropecuaria.bo','$2b$10$Q2Yr413cKkRQLImZTiTs8uDdAJBaIgIVwmTbTLYDi8dOZAOKzKo3a',1,'2026-05-26 15:27:53'),(6,3,1,'9167806','Juan','Mamani Condori','72167806','jmamani@agropecuaria.bo','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',1,'2026-05-26 15:27:53'),(7,3,2,'3278907','Ana','Choque Limachi','67378907','achoque@agropecuaria.bo','$2b$10$nM1exkcz9/rXW/8iSrR.G.swrlyXHg8G3TG1pQxEVDjTVrs5M0fpC',1,'2026-05-26 15:27:53'),(8,3,3,'2389008','Diego','Quispe Huanca','73489008','dquispe@agropecuaria.bo','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',1,'2026-05-26 15:27:53');
/*!40000 ALTER TABLE `usuario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `venta`
--

DROP TABLE IF EXISTS `venta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `venta` (
  `id_venta` int(11) NOT NULL AUTO_INCREMENT,
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
  `observaciones` text DEFAULT NULL,
  PRIMARY KEY (`id_venta`),
  KEY `fk_venta_sucursal` (`id_sucursal`),
  KEY `fk_venta_usuario` (`id_usuario`),
  KEY `fk_venta_cliente` (`id_cliente`),
  KEY `fk_venta_apertura` (`id_apertura`),
  CONSTRAINT `fk_venta_apertura` FOREIGN KEY (`id_apertura`) REFERENCES `apertura_cierre_caja` (`id_apertura`),
  CONSTRAINT `fk_venta_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `cliente` (`id_cliente`),
  CONSTRAINT `fk_venta_sucursal` FOREIGN KEY (`id_sucursal`) REFERENCES `sucursal` (`id_sucursal`),
  CONSTRAINT `fk_venta_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `venta`
--

LOCK TABLES `venta` WRITE;
/*!40000 ALTER TABLE `venta` DISABLE KEYS */;
INSERT INTO `venta` VALUES (1,1,2,2,1,'VTA-0001-2026','2026-05-20 09:30:00','MAYOR',4310.00,344.80,3965.20,3965.20,0.00,'QR','COMPLETADA',NULL),(2,1,2,4,1,'VTA-0002-2026','2026-05-20 11:00:00','MENOR',405.00,0.00,405.00,450.00,45.00,'EFECTIVO','COMPLETADA',NULL),(3,1,3,NULL,2,'VTA-0003-2026','2026-05-26 09:15:00','MENOR',315.00,0.00,315.00,400.00,85.00,'EFECTIVO','COMPLETADA',NULL),(4,1,3,3,2,'VTA-0004-2026','2026-05-26 10:00:00','MAYOR',4580.00,366.40,4213.60,4213.60,0.00,'TRANSFERENCIA','COMPLETADA',NULL),(5,1,3,5,2,'VTA-0005-2026','2026-05-26 11:30:00','MENOR',210.00,0.00,210.00,210.00,0.00,'QR','COMPLETADA',NULL),(6,2,4,2,3,'VTA-0006-2026','2026-05-26 09:00:00','MAYOR',4880.00,292.80,4587.20,4587.20,0.00,'QR','COMPLETADA',NULL),(7,3,1,NULL,NULL,NULL,'2026-05-27 09:00:39','MENOR',430.00,0.00,430.00,500.00,70.00,'EFECTIVO','COMPLETADA',NULL),(8,3,1,NULL,NULL,NULL,'2026-05-27 09:01:37','MENOR',545.00,0.00,545.00,600.00,55.00,'EFECTIVO','COMPLETADA',NULL),(9,3,1,NULL,NULL,NULL,'2026-05-27 09:03:50','MENOR',495.00,0.00,495.00,500.00,5.00,'EFECTIVO','COMPLETADA',NULL),(10,3,1,NULL,NULL,NULL,'2026-05-27 09:04:26','MENOR',905.00,0.00,905.00,920.00,15.00,'EFECTIVO','COMPLETADA',NULL),(11,3,1,NULL,NULL,NULL,'2026-05-27 10:16:32','MENOR',595.00,0.00,595.00,595.00,0.00,'EFECTIVO','COMPLETADA',NULL),(12,3,1,8,NULL,NULL,'2026-05-27 11:20:30','MENOR',595.00,0.00,595.00,595.00,0.00,'EFECTIVO','COMPLETADA',NULL),(13,3,1,NULL,NULL,NULL,'2026-05-27 14:35:51','MENOR',640.00,0.00,640.00,640.00,0.00,'EFECTIVO','COMPLETADA',NULL);
/*!40000 ALTER TABLE `venta` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'bd_agropecuaria'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-27 14:41:31
