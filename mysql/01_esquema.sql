-- =====================================================================
--  BASE DE DATOS: gamestop  (tienda de videojuegos)
--  Motor: MySQL 8.0.13+   (abrir y ejecutar en MySQL Workbench)
--  Archivo 1 de 3: crea la base de datos y todas las tablas
-- =====================================================================

DROP DATABASE IF EXISTS gamestop;
CREATE DATABASE gamestop
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE gamestop;

-- ---------------------------------------------------------------------
-- SUCURSALES Y EMPLEADOS
-- ---------------------------------------------------------------------

CREATE TABLE sucursales (
  id_sucursal   INT AUTO_INCREMENT PRIMARY KEY,
  nombre        VARCHAR(80)  NOT NULL UNIQUE,
  direccion     VARCHAR(150) NOT NULL,
  ciudad        VARCHAR(60)  NOT NULL,
  estado        VARCHAR(60)  NOT NULL,
  telefono      VARCHAR(20),
  fecha_apertura DATE
) ENGINE=InnoDB;

CREATE TABLE empleados (
  id_empleado        INT AUTO_INCREMENT PRIMARY KEY,
  nombre             VARCHAR(60) NOT NULL,
  apellido           VARCHAR(60) NOT NULL,
  puesto             ENUM('Gerente','Subgerente','Vendedor') NOT NULL,
  correo             VARCHAR(120) UNIQUE,
  salario_mensual    DECIMAL(9,2) NOT NULL CHECK (salario_mensual > 0),
  fecha_contratacion DATE NOT NULL,
  id_sucursal        INT NOT NULL,
  CONSTRAINT fk_emp_sucursal FOREIGN KEY (id_sucursal)
    REFERENCES sucursales(id_sucursal) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- CLIENTES (con membresía tipo "PowerUp Rewards")
-- ---------------------------------------------------------------------

CREATE TABLE clientes (
  id_cliente      INT AUTO_INCREMENT PRIMARY KEY,
  nombre          VARCHAR(60)  NOT NULL,
  apellido        VARCHAR(60)  NOT NULL,
  correo          VARCHAR(120) NOT NULL UNIQUE,
  telefono        VARCHAR(20),
  membresia       ENUM('Básica','Pro') NOT NULL DEFAULT 'Básica', -- Pro = 10% de descuento
  puntos          INT NOT NULL DEFAULT 0 CHECK (puntos >= 0),
  fecha_registro  DATE NOT NULL DEFAULT (CURRENT_DATE)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- CATÁLOGO DE PRODUCTOS
-- ---------------------------------------------------------------------

CREATE TABLE categorias (
  id_categoria  INT AUTO_INCREMENT PRIMARY KEY,
  nombre        VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE plataformas (
  id_plataforma INT AUTO_INCREMENT PRIMARY KEY,
  nombre        VARCHAR(50) NOT NULL UNIQUE,
  fabricante    VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE proveedores (
  id_proveedor  INT AUTO_INCREMENT PRIMARY KEY,
  nombre        VARCHAR(100) NOT NULL UNIQUE,
  contacto      VARCHAR(100),
  telefono      VARCHAR(20),
  correo        VARCHAR(120)
) ENGINE=InnoDB;

CREATE TABLE productos (
  id_producto       INT AUTO_INCREMENT PRIMARY KEY,
  sku               VARCHAR(20)  NOT NULL UNIQUE,
  nombre            VARCHAR(150) NOT NULL,
  id_categoria      INT NOT NULL,
  id_plataforma     INT NULL,              -- NULL para productos sin plataforma (ej. Funko)
  id_proveedor      INT NULL,              -- NULL para usados que llegan por intercambio
  condicion         ENUM('Nuevo','Usado','Reacondicionado') NOT NULL DEFAULT 'Nuevo',
  clasificacion     ENUM('E','E10+','T','M','RP') NULL,  -- ESRB, solo videojuegos
  precio_venta      DECIMAL(9,2) NOT NULL CHECK (precio_venta >= 0),
  costo             DECIMAL(9,2) NOT NULL CHECK (costo >= 0),
  fecha_lanzamiento DATE,
  activo            BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT fk_prod_categoria  FOREIGN KEY (id_categoria)  REFERENCES categorias(id_categoria),
  CONSTRAINT fk_prod_plataforma FOREIGN KEY (id_plataforma) REFERENCES plataformas(id_plataforma),
  CONSTRAINT fk_prod_proveedor  FOREIGN KEY (id_proveedor)  REFERENCES proveedores(id_proveedor),
  INDEX idx_prod_nombre (nombre)
) ENGINE=InnoDB;

-- Existencias de cada producto en cada sucursal
CREATE TABLE inventario (
  id_sucursal   INT NOT NULL,
  id_producto   INT NOT NULL,
  existencia    INT NOT NULL DEFAULT 0 CHECK (existencia >= 0),
  stock_minimo  INT NOT NULL DEFAULT 2,
  PRIMARY KEY (id_sucursal, id_producto),
  CONSTRAINT fk_inv_sucursal FOREIGN KEY (id_sucursal) REFERENCES sucursales(id_sucursal) ON DELETE CASCADE,
  CONSTRAINT fk_inv_producto FOREIGN KEY (id_producto) REFERENCES productos(id_producto) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- VENTAS
-- ---------------------------------------------------------------------

CREATE TABLE ventas (
  id_venta     INT AUTO_INCREMENT PRIMARY KEY,
  fecha        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  id_sucursal  INT NOT NULL,
  id_empleado  INT NOT NULL,
  id_cliente   INT NULL,                   -- NULL = venta a público general
  metodo_pago  ENUM('Efectivo','Tarjeta','Crédito en tienda') NOT NULL,
  subtotal     DECIMAL(10,2) NOT NULL DEFAULT 0,
  descuento    DECIMAL(10,2) NOT NULL DEFAULT 0,
  iva          DECIMAL(10,2) NOT NULL DEFAULT 0,
  total        DECIMAL(10,2) NOT NULL DEFAULT 0,
  CONSTRAINT fk_ven_sucursal FOREIGN KEY (id_sucursal) REFERENCES sucursales(id_sucursal),
  CONSTRAINT fk_ven_empleado FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado),
  CONSTRAINT fk_ven_cliente  FOREIGN KEY (id_cliente)  REFERENCES clientes(id_cliente),
  INDEX idx_ven_fecha (fecha)
) ENGINE=InnoDB;

CREATE TABLE detalle_venta (
  id_venta        INT NOT NULL,
  id_producto     INT NOT NULL,
  cantidad        INT NOT NULL CHECK (cantidad > 0),
  precio_unitario DECIMAL(9,2) NOT NULL,
  PRIMARY KEY (id_venta, id_producto),
  CONSTRAINT fk_dv_venta    FOREIGN KEY (id_venta)    REFERENCES ventas(id_venta) ON DELETE CASCADE,
  CONSTRAINT fk_dv_producto FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- INTERCAMBIOS (el cliente vende sus juegos/consolas usados a la tienda)
-- ---------------------------------------------------------------------

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
) ENGINE=InnoDB;

CREATE TABLE detalle_intercambio (
  id_intercambio  INT NOT NULL,
  id_producto     INT NOT NULL,            -- producto "Usado" que entra al inventario
  cantidad        INT NOT NULL CHECK (cantidad > 0),
  valor_unitario  DECIMAL(9,2) NOT NULL CHECK (valor_unitario >= 0),
  PRIMARY KEY (id_intercambio, id_producto),
  CONSTRAINT fk_di_intercambio FOREIGN KEY (id_intercambio) REFERENCES intercambios(id_intercambio) ON DELETE CASCADE,
  CONSTRAINT fk_di_producto    FOREIGN KEY (id_producto)    REFERENCES productos(id_producto)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- PREVENTAS / APARTADOS
-- ---------------------------------------------------------------------

CREATE TABLE preventas (
  id_preventa   INT AUTO_INCREMENT PRIMARY KEY,
  fecha         DATE NOT NULL DEFAULT (CURRENT_DATE),
  id_cliente    INT NOT NULL,
  id_producto   INT NOT NULL,
  id_sucursal   INT NOT NULL,
  anticipo      DECIMAL(9,2) NOT NULL CHECK (anticipo >= 0),
  estado        ENUM('Pendiente','Entregada','Cancelada') NOT NULL DEFAULT 'Pendiente',
  CONSTRAINT fk_pre_cliente  FOREIGN KEY (id_cliente)  REFERENCES clientes(id_cliente),
  CONSTRAINT fk_pre_producto FOREIGN KEY (id_producto) REFERENCES productos(id_producto),
  CONSTRAINT fk_pre_sucursal FOREIGN KEY (id_sucursal) REFERENCES sucursales(id_sucursal)
) ENGINE=InnoDB;
