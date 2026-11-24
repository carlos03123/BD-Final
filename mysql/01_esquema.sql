-- =====================================================================
--  BASE DE DATOS: gamestop_usa
--  Cadena de tiendas de videojuegos GameStop en Estados Unidos
--  Motor: MySQL 8.0.13 o superior  (MySQL Workbench)
--
--  Archivo 1 de 8: crea la base de datos y sus 22 tablas
-- =====================================================================

SET NAMES utf8mb4;

DROP DATABASE IF EXISTS gamestop_usa;
CREATE DATABASE gamestop_usa
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;   -- intercalación por defecto de MySQL 8 (la misma que usa Workbench)

USE gamestop_usa;

-- =====================================================================
-- 1. UBICACIÓN, TIENDAS Y PERSONAL
-- =====================================================================

CREATE TABLE estados (
  id_estado       INT AUTO_INCREMENT PRIMARY KEY,
  nombre          VARCHAR(40)  NOT NULL UNIQUE,
  abreviatura     CHAR(2)      NOT NULL UNIQUE,
  tasa_impuesto   DECIMAL(5,4) NOT NULL CHECK (tasa_impuesto BETWEEN 0 AND 0.2)
) ENGINE=InnoDB COMMENT='Estados de EE.UU. y su impuesto estatal sobre ventas (sales tax)';

CREATE TABLE sucursales (
  id_sucursal     INT AUTO_INCREMENT PRIMARY KEY,
  numero_tienda   SMALLINT     NOT NULL UNIQUE,
  nombre          VARCHAR(80)  NOT NULL,
  direccion       VARCHAR(150) NOT NULL,
  ciudad          VARCHAR(60)  NOT NULL,
  id_estado       INT          NOT NULL,
  codigo_postal   CHAR(5)      NOT NULL,
  telefono        VARCHAR(20),
  fecha_apertura  DATE         NOT NULL,
  activa          BOOLEAN      NOT NULL DEFAULT TRUE,
  CONSTRAINT fk_suc_estado FOREIGN KEY (id_estado) REFERENCES estados(id_estado)
) ENGINE=InnoDB COMMENT='Tiendas físicas de la cadena';

CREATE TABLE empleados (
  id_empleado        INT AUTO_INCREMENT PRIMARY KEY,
  nombre             VARCHAR(50)  NOT NULL,
  apellido           VARCHAR(50)  NOT NULL,
  correo             VARCHAR(120) NOT NULL UNIQUE,
  telefono           VARCHAR(20),
  puesto             ENUM('Gerente de distrito','Gerente de tienda','Subgerente','Asesor senior','Asesor') NOT NULL,
  salario_hora       DECIMAL(6,2) NOT NULL CHECK (salario_hora >= 7.25),   -- salario mínimo federal
  fecha_contratacion DATE         NOT NULL,
  id_sucursal        INT          NOT NULL,
  id_supervisor      INT          NULL,
  activo             BOOLEAN      NOT NULL DEFAULT TRUE,
  CONSTRAINT fk_emp_sucursal   FOREIGN KEY (id_sucursal)   REFERENCES sucursales(id_sucursal),
  CONSTRAINT fk_emp_supervisor FOREIGN KEY (id_supervisor) REFERENCES empleados(id_empleado)
) ENGINE=InnoDB COMMENT='Personal de tienda; id_supervisor es una relación recursiva';

-- =====================================================================
-- 2. CLIENTES Y PROGRAMA DE LEALTAD
-- =====================================================================

CREATE TABLE niveles_membresia (
  id_nivel              INT AUTO_INCREMENT PRIMARY KEY,
  nombre                VARCHAR(40)  NOT NULL UNIQUE,
  costo_anual           DECIMAL(6,2) NOT NULL DEFAULT 0,
  descuento_usados_pct  DECIMAL(4,2) NOT NULL DEFAULT 0,  -- descuento en productos usados/reacondicionados
  bono_intercambio_pct  DECIMAL(4,2) NOT NULL DEFAULT 0,  -- bono extra al cambiar juegos por crédito
  puntos_por_dolar      TINYINT      NOT NULL DEFAULT 1 
) ENGINE=InnoDB COMMENT='Niveles del programa de lealtad (PowerUp Rewards / GameStop Pro)';

CREATE TABLE clientes (
  id_cliente            INT AUTO_INCREMENT PRIMARY KEY,
  nombre                VARCHAR(50)  NOT NULL,
  apellido              VARCHAR(50)  NOT NULL,
  correo                VARCHAR(120) NOT NULL UNIQUE,
  telefono              VARCHAR(20),
  fecha_nacimiento      DATE,
  id_estado             INT          NOT NULL,
  id_nivel              INT          NOT NULL DEFAULT 1,
  vencimiento_membresia DATE         NULL,                  -- solo aplica a niveles de pago
  puntos                INT          NOT NULL DEFAULT 0 CHECK (puntos >= 0),
  credito_tienda        DECIMAL(9,2) NOT NULL DEFAULT 0 CHECK (credito_tienda >= 0),
  fecha_registro        DATE         NOT NULL,
  CONSTRAINT fk_cli_estado FOREIGN KEY (id_estado) REFERENCES estados(id_estado),
  CONSTRAINT fk_cli_nivel  FOREIGN KEY (id_nivel)  REFERENCES niveles_membresia(id_nivel)
) ENGINE=InnoDB COMMENT='Clientes registrados en el programa de lealtad';

-- =====================================================================
-- 3. CATÁLOGO DE PRODUCTOS
-- =====================================================================

CREATE TABLE categorias (
  id_categoria  INT AUTO_INCREMENT PRIMARY KEY,
  nombre        VARCHAR(40) NOT NULL UNIQUE,
  descripcion   VARCHAR(150)
) ENGINE=InnoDB;

CREATE TABLE plataformas (
  id_plataforma     INT AUTO_INCREMENT PRIMARY KEY,
  nombre            VARCHAR(40) NOT NULL UNIQUE,
  fabricante        VARCHAR(40) NOT NULL,
  generacion        TINYINT,
  fecha_lanzamiento DATE
) ENGINE=InnoDB;

CREATE TABLE generos (
  id_genero   INT AUTO_INCREMENT PRIMARY KEY,
  nombre      VARCHAR(40) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE proveedores (
  id_proveedor  INT AUTO_INCREMENT PRIMARY KEY,
  nombre        VARCHAR(80)  NOT NULL UNIQUE,
  contacto      VARCHAR(80),
  telefono      VARCHAR(20),
  correo        VARCHAR(120),
  ciudad        VARCHAR(60),
  id_estado     INT,
  CONSTRAINT fk_prov_estado FOREIGN KEY (id_estado) REFERENCES estados(id_estado)
) ENGINE=InnoDB COMMENT='Fabricantes y distribuidores que surten a la cadena';

CREATE TABLE productos (
  id_producto        INT AUTO_INCREMENT PRIMARY KEY,
  sku                VARCHAR(20)  NOT NULL UNIQUE,
  nombre             VARCHAR(120) NOT NULL,
  id_categoria       INT          NOT NULL,
  id_plataforma      INT          NULL,      -- NULL: no depende de una consola (Funko, audífonos...)
  id_proveedor       INT          NULL,      -- NULL: usados que entran por intercambio
  condicion          ENUM('Nuevo','Usado','Reacondicionado') NOT NULL DEFAULT 'Nuevo',
  clasificacion_esrb ENUM('E','E10+','T','M','RP') NULL,
  precio_venta       DECIMAL(8,2) NOT NULL CHECK (precio_venta > 0),
  costo              DECIMAL(8,2) NOT NULL CHECK (costo >= 0),
  fecha_lanzamiento  DATE         NULL,
  activo             BOOLEAN      NOT NULL DEFAULT TRUE,
  CONSTRAINT chk_prod_margen CHECK (precio_venta >= costo),
  CONSTRAINT fk_prod_categoria  FOREIGN KEY (id_categoria)  REFERENCES categorias(id_categoria),
  CONSTRAINT fk_prod_plataforma FOREIGN KEY (id_plataforma) REFERENCES plataformas(id_plataforma),
  CONSTRAINT fk_prod_proveedor  FOREIGN KEY (id_proveedor)  REFERENCES proveedores(id_proveedor),
  INDEX idx_prod_nombre (nombre),
  INDEX idx_prod_cat_plat (id_categoria, id_plataforma)
) ENGINE=InnoDB COMMENT='Catálogo: juegos, consolas, accesorios, coleccionables y tarjetas';

CREATE TABLE producto_genero (
  id_producto INT NOT NULL,
  id_genero   INT NOT NULL,
  PRIMARY KEY (id_producto, id_genero),
  CONSTRAINT fk_pg_producto FOREIGN KEY (id_producto) REFERENCES productos(id_producto) ON DELETE CASCADE,
  CONSTRAINT fk_pg_genero   FOREIGN KEY (id_genero)   REFERENCES generos(id_genero)     ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Relación N:M entre videojuegos y géneros';

CREATE TABLE inventario (
  id_sucursal          INT NOT NULL,
  id_producto          INT NOT NULL,
  existencia           INT NOT NULL DEFAULT 0 CHECK (existencia >= 0),
  stock_minimo         INT NOT NULL DEFAULT 3 CHECK (stock_minimo >= 0),
  ultima_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_sucursal, id_producto),
  CONSTRAINT fk_inv_sucursal FOREIGN KEY (id_sucursal) REFERENCES sucursales(id_sucursal),
  CONSTRAINT fk_inv_producto FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
) ENGINE=InnoDB COMMENT='Existencias de cada producto en cada tienda (N:M sucursales-productos)';

-- =====================================================================
-- 4. VENTAS Y DEVOLUCIONES
-- =====================================================================

CREATE TABLE ventas (
  id_venta     INT AUTO_INCREMENT PRIMARY KEY,
  fecha        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  id_sucursal  INT NOT NULL,
  id_empleado  INT NOT NULL,
  id_cliente   INT NULL,                                -- NULL = cliente no registrado
  metodo_pago  ENUM('Efectivo','Tarjeta de crédito','Tarjeta de débito','Crédito en tienda','Tarjeta de regalo') NOT NULL,
  subtotal     DECIMAL(10,2) NOT NULL DEFAULT 0,
  descuento    DECIMAL(10,2) NOT NULL DEFAULT 0,
  impuesto     DECIMAL(10,2) NOT NULL DEFAULT 0,
  total        DECIMAL(10,2) NOT NULL DEFAULT 0,
  estado       ENUM('Completada','Devuelta parcial','Devuelta') NOT NULL DEFAULT 'Completada',
  CONSTRAINT fk_ven_sucursal FOREIGN KEY (id_sucursal) REFERENCES sucursales(id_sucursal),
  CONSTRAINT fk_ven_empleado FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado),
  CONSTRAINT fk_ven_cliente  FOREIGN KEY (id_cliente)  REFERENCES clientes(id_cliente),
  INDEX idx_ven_fecha (fecha),
  INDEX idx_ven_suc_fecha (id_sucursal, fecha)
) ENGINE=InnoDB COMMENT='Encabezado del ticket; los importes los calculan los triggers';

CREATE TABLE detalle_venta (
  id_venta        INT NOT NULL,
  id_producto     INT NOT NULL,
  cantidad        INT NOT NULL CHECK (cantidad > 0),
  precio_unitario DECIMAL(8,2) NOT NULL,                -- si se manda NULL, el trigger pone el precio del catálogo
  descuento       DECIMAL(8,2) NOT NULL DEFAULT 0,      -- lo calcula el trigger (GameStop Pro)
  PRIMARY KEY (id_venta, id_producto),
  CONSTRAINT fk_dv_venta    FOREIGN KEY (id_venta)    REFERENCES ventas(id_venta) ON DELETE CASCADE,
  CONSTRAINT fk_dv_producto FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
) ENGINE=InnoDB COMMENT='Renglones de cada venta';

CREATE TABLE devoluciones (
  id_devolucion     INT AUTO_INCREMENT PRIMARY KEY,
  id_venta          INT NOT NULL,
  fecha             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  id_empleado       INT NOT NULL,
  motivo            ENUM('Defectuoso','No le gustó','Regalo duplicado','Error de compra') NOT NULL,
  monto_reembolsado DECIMAL(10,2) NOT NULL DEFAULT 0,
  CONSTRAINT fk_dev_venta    FOREIGN KEY (id_venta)    REFERENCES ventas(id_venta),
  CONSTRAINT fk_dev_empleado FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado)
) ENGINE=InnoDB COMMENT='Devoluciones sobre una venta (máximo 30 días)';

CREATE TABLE detalle_devolucion (
  id_devolucion INT NOT NULL,
  id_producto   INT NOT NULL,
  cantidad      INT NOT NULL CHECK (cantidad > 0),
  PRIMARY KEY (id_devolucion, id_producto),
  CONSTRAINT fk_ddev_devolucion FOREIGN KEY (id_devolucion) REFERENCES devoluciones(id_devolucion) ON DELETE CASCADE,
  CONSTRAINT fk_ddev_producto   FOREIGN KEY (id_producto)   REFERENCES productos(id_producto)
) ENGINE=InnoDB;

-- =====================================================================
-- 5. INTERCAMBIOS (TRADE-INS) Y PREVENTAS
-- =====================================================================

CREATE TABLE intercambios (
  id_intercambio INT AUTO_INCREMENT PRIMARY KEY,
  fecha          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  id_sucursal    INT NOT NULL,
  id_empleado    INT NOT NULL,
  id_cliente     INT NOT NULL,
  forma_pago     ENUM('Efectivo','Crédito en tienda') NOT NULL,
  total_pagado   DECIMAL(10,2) NOT NULL DEFAULT 0,
  CONSTRAINT fk_int_sucursal FOREIGN KEY (id_sucursal) REFERENCES sucursales(id_sucursal),
  CONSTRAINT fk_int_empleado FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado),
  CONSTRAINT fk_int_cliente  FOREIGN KEY (id_cliente)  REFERENCES clientes(id_cliente)
) ENGINE=InnoDB COMMENT='El cliente vende juegos/consolas usados a la tienda';

CREATE TABLE detalle_intercambio (
  id_intercambio INT NOT NULL,
  id_producto    INT NOT NULL,                           -- producto Usado/Reacondicionado
  cantidad       INT NOT NULL CHECK (cantidad > 0),
  valor_unitario DECIMAL(8,2) NOT NULL,                  -- si se manda NULL lo calcula fn_valor_intercambio
  PRIMARY KEY (id_intercambio, id_producto),
  CONSTRAINT fk_di_intercambio FOREIGN KEY (id_intercambio) REFERENCES intercambios(id_intercambio) ON DELETE CASCADE,
  CONSTRAINT fk_di_producto    FOREIGN KEY (id_producto)    REFERENCES productos(id_producto)
) ENGINE=InnoDB;

CREATE TABLE preventas (
  id_preventa  INT AUTO_INCREMENT PRIMARY KEY,
  fecha        DATE NOT NULL,
  id_cliente   INT NOT NULL,
  id_producto  INT NOT NULL,
  id_sucursal  INT NOT NULL,
  anticipo     DECIMAL(8,2) NOT NULL CHECK (anticipo >= 0),
  estado       ENUM('Pendiente','Entregada','Cancelada') NOT NULL DEFAULT 'Pendiente',
  CONSTRAINT fk_pre_cliente  FOREIGN KEY (id_cliente)  REFERENCES clientes(id_cliente),
  CONSTRAINT fk_pre_producto FOREIGN KEY (id_producto) REFERENCES productos(id_producto),
  CONSTRAINT fk_pre_sucursal FOREIGN KEY (id_sucursal) REFERENCES sucursales(id_sucursal),
  UNIQUE KEY uq_preventa (id_cliente, id_producto, estado)
) ENGINE=InnoDB COMMENT='Apartados de productos antes de su lanzamiento';

-- =====================================================================
-- 6. COMPRAS A PROVEEDORES Y AUDITORÍA
-- =====================================================================

CREATE TABLE ordenes_compra (
  id_orden         INT AUTO_INCREMENT PRIMARY KEY,
  fecha            DATE NOT NULL,
  id_proveedor     INT NOT NULL,
  id_sucursal      INT NOT NULL,
  id_empleado      INT NOT NULL,
  estado           ENUM('Pendiente','Recibida','Cancelada') NOT NULL DEFAULT 'Pendiente',
  fecha_recepcion  DATE NULL,
  total            DECIMAL(10,2) NOT NULL DEFAULT 0,
  CONSTRAINT fk_oc_proveedor FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor),
  CONSTRAINT fk_oc_sucursal  FOREIGN KEY (id_sucursal)  REFERENCES sucursales(id_sucursal),
  CONSTRAINT fk_oc_empleado  FOREIGN KEY (id_empleado)  REFERENCES empleados(id_empleado),
  CONSTRAINT chk_oc_recepcion CHECK (fecha_recepcion IS NULL OR fecha_recepcion >= fecha)
) ENGINE=InnoDB COMMENT='Pedidos de mercancía a proveedores';

CREATE TABLE detalle_orden_compra (
  id_orden        INT NOT NULL,
  id_producto     INT NOT NULL,
  cantidad        INT NOT NULL CHECK (cantidad > 0),
  costo_unitario  DECIMAL(8,2) NOT NULL CHECK (costo_unitario >= 0),
  PRIMARY KEY (id_orden, id_producto),
  CONSTRAINT fk_doc_orden    FOREIGN KEY (id_orden)    REFERENCES ordenes_compra(id_orden) ON DELETE CASCADE,
  CONSTRAINT fk_doc_producto FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
) ENGINE=InnoDB;

CREATE TABLE bitacora_precios (
  id_bitacora     INT AUTO_INCREMENT PRIMARY KEY,
  id_producto     INT NOT NULL,
  precio_anterior DECIMAL(8,2) NOT NULL,
  precio_nuevo    DECIMAL(8,2) NOT NULL,
  fecha           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  usuario         VARCHAR(100) NOT NULL,
  CONSTRAINT fk_bit_producto FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
) ENGINE=InnoDB COMMENT='Auditoría: la llena un trigger cada vez que cambia un precio';
