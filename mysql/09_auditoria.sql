SET NAMES utf8mb4;

USE gamestop_usa;

  
-- estados  (llave: id_estado)
  
DROP TABLE IF EXISTS aud_estados;
CREATE TABLE aud_estados (
  id_auditoria     BIGINT AUTO_INCREMENT PRIMARY KEY,
  operacion        ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  llave            VARCHAR(60)  NOT NULL,
  datos_anteriores JSON NULL,
  datos_nuevos     JSON NULL,
  usuario          VARCHAR(100) NOT NULL,
  fecha            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_aud_estados_llave (llave),
  INDEX idx_aud_estados_fecha (fecha)
) ENGINE=InnoDB COMMENT='Auditoría de la tabla estados';

DROP TRIGGER IF EXISTS trg_aud_estados_ins;
CREATE TRIGGER trg_aud_estados_ins AFTER INSERT ON estados FOR EACH ROW
  INSERT INTO aud_estados (operacion, llave, datos_nuevos, usuario)
  VALUES ('INSERT', NEW.id_estado, JSON_OBJECT('id_estado', NEW.id_estado, 'nombre', NEW.nombre, 'abreviatura', NEW.abreviatura, 'tasa_impuesto', NEW.tasa_impuesto), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_estados_upd;
CREATE TRIGGER trg_aud_estados_upd AFTER UPDATE ON estados FOR EACH ROW
  INSERT INTO aud_estados (operacion, llave, datos_anteriores, datos_nuevos, usuario)
  VALUES ('UPDATE', NEW.id_estado, JSON_OBJECT('id_estado', OLD.id_estado, 'nombre', OLD.nombre, 'abreviatura', OLD.abreviatura, 'tasa_impuesto', OLD.tasa_impuesto), JSON_OBJECT('id_estado', NEW.id_estado, 'nombre', NEW.nombre, 'abreviatura', NEW.abreviatura, 'tasa_impuesto', NEW.tasa_impuesto), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_estados_del;
CREATE TRIGGER trg_aud_estados_del AFTER DELETE ON estados FOR EACH ROW
  INSERT INTO aud_estados (operacion, llave, datos_anteriores, usuario)
  VALUES ('DELETE', OLD.id_estado, JSON_OBJECT('id_estado', OLD.id_estado, 'nombre', OLD.nombre, 'abreviatura', OLD.abreviatura, 'tasa_impuesto', OLD.tasa_impuesto), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_estados_no_modificar;
CREATE TRIGGER trg_aud_estados_no_modificar BEFORE UPDATE ON aud_estados FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden modificar';

DROP TRIGGER IF EXISTS trg_aud_estados_no_borrar;
CREATE TRIGGER trg_aud_estados_no_borrar BEFORE DELETE ON aud_estados FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden borrar';

  
-- sucursales  (llave: id_sucursal)
  
DROP TABLE IF EXISTS aud_sucursales;
CREATE TABLE aud_sucursales (
  id_auditoria     BIGINT AUTO_INCREMENT PRIMARY KEY,
  operacion        ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  llave            VARCHAR(60)  NOT NULL,
  datos_anteriores JSON NULL,
  datos_nuevos     JSON NULL,
  usuario          VARCHAR(100) NOT NULL,
  fecha            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_aud_sucursales_llave (llave),
  INDEX idx_aud_sucursales_fecha (fecha)
) ENGINE=InnoDB COMMENT='Auditoría de la tabla sucursales';

DROP TRIGGER IF EXISTS trg_aud_sucursales_ins;
CREATE TRIGGER trg_aud_sucursales_ins AFTER INSERT ON sucursales FOR EACH ROW
  INSERT INTO aud_sucursales (operacion, llave, datos_nuevos, usuario)
  VALUES ('INSERT', NEW.id_sucursal, JSON_OBJECT('id_sucursal', NEW.id_sucursal, 'numero_tienda', NEW.numero_tienda, 'nombre', NEW.nombre, 'direccion', NEW.direccion, 'ciudad', NEW.ciudad, 'id_estado', NEW.id_estado, 'codigo_postal', NEW.codigo_postal, 'telefono', NEW.telefono, 'fecha_apertura', NEW.fecha_apertura, 'activa', NEW.activa), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_sucursales_upd;
CREATE TRIGGER trg_aud_sucursales_upd AFTER UPDATE ON sucursales FOR EACH ROW
  INSERT INTO aud_sucursales (operacion, llave, datos_anteriores, datos_nuevos, usuario)
  VALUES ('UPDATE', NEW.id_sucursal, JSON_OBJECT('id_sucursal', OLD.id_sucursal, 'numero_tienda', OLD.numero_tienda, 'nombre', OLD.nombre, 'direccion', OLD.direccion, 'ciudad', OLD.ciudad, 'id_estado', OLD.id_estado, 'codigo_postal', OLD.codigo_postal, 'telefono', OLD.telefono, 'fecha_apertura', OLD.fecha_apertura, 'activa', OLD.activa), JSON_OBJECT('id_sucursal', NEW.id_sucursal, 'numero_tienda', NEW.numero_tienda, 'nombre', NEW.nombre, 'direccion', NEW.direccion, 'ciudad', NEW.ciudad, 'id_estado', NEW.id_estado, 'codigo_postal', NEW.codigo_postal, 'telefono', NEW.telefono, 'fecha_apertura', NEW.fecha_apertura, 'activa', NEW.activa), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_sucursales_del;
CREATE TRIGGER trg_aud_sucursales_del AFTER DELETE ON sucursales FOR EACH ROW
  INSERT INTO aud_sucursales (operacion, llave, datos_anteriores, usuario)
  VALUES ('DELETE', OLD.id_sucursal, JSON_OBJECT('id_sucursal', OLD.id_sucursal, 'numero_tienda', OLD.numero_tienda, 'nombre', OLD.nombre, 'direccion', OLD.direccion, 'ciudad', OLD.ciudad, 'id_estado', OLD.id_estado, 'codigo_postal', OLD.codigo_postal, 'telefono', OLD.telefono, 'fecha_apertura', OLD.fecha_apertura, 'activa', OLD.activa), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_sucursales_no_modificar;
CREATE TRIGGER trg_aud_sucursales_no_modificar BEFORE UPDATE ON aud_sucursales FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden modificar';

DROP TRIGGER IF EXISTS trg_aud_sucursales_no_borrar;
CREATE TRIGGER trg_aud_sucursales_no_borrar BEFORE DELETE ON aud_sucursales FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden borrar';

  
-- empleados  (llave: id_empleado)
  
DROP TABLE IF EXISTS aud_empleados;
CREATE TABLE aud_empleados (
  id_auditoria     BIGINT AUTO_INCREMENT PRIMARY KEY,
  operacion        ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  llave            VARCHAR(60)  NOT NULL,
  datos_anteriores JSON NULL,
  datos_nuevos     JSON NULL,
  usuario          VARCHAR(100) NOT NULL,
  fecha            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_aud_empleados_llave (llave),
  INDEX idx_aud_empleados_fecha (fecha)
) ENGINE=InnoDB COMMENT='Auditoría de la tabla empleados';

DROP TRIGGER IF EXISTS trg_aud_empleados_ins;
CREATE TRIGGER trg_aud_empleados_ins AFTER INSERT ON empleados FOR EACH ROW
  INSERT INTO aud_empleados (operacion, llave, datos_nuevos, usuario)
  VALUES ('INSERT', NEW.id_empleado, JSON_OBJECT('id_empleado', NEW.id_empleado, 'nombre', NEW.nombre, 'apellido', NEW.apellido, 'correo', NEW.correo, 'telefono', NEW.telefono, 'puesto', NEW.puesto, 'salario_hora', NEW.salario_hora, 'fecha_contratacion', NEW.fecha_contratacion, 'id_sucursal', NEW.id_sucursal, 'id_supervisor', NEW.id_supervisor, 'activo', NEW.activo), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_empleados_upd;
CREATE TRIGGER trg_aud_empleados_upd AFTER UPDATE ON empleados FOR EACH ROW
  INSERT INTO aud_empleados (operacion, llave, datos_anteriores, datos_nuevos, usuario)
  VALUES ('UPDATE', NEW.id_empleado, JSON_OBJECT('id_empleado', OLD.id_empleado, 'nombre', OLD.nombre, 'apellido', OLD.apellido, 'correo', OLD.correo, 'telefono', OLD.telefono, 'puesto', OLD.puesto, 'salario_hora', OLD.salario_hora, 'fecha_contratacion', OLD.fecha_contratacion, 'id_sucursal', OLD.id_sucursal, 'id_supervisor', OLD.id_supervisor, 'activo', OLD.activo), JSON_OBJECT('id_empleado', NEW.id_empleado, 'nombre', NEW.nombre, 'apellido', NEW.apellido, 'correo', NEW.correo, 'telefono', NEW.telefono, 'puesto', NEW.puesto, 'salario_hora', NEW.salario_hora, 'fecha_contratacion', NEW.fecha_contratacion, 'id_sucursal', NEW.id_sucursal, 'id_supervisor', NEW.id_supervisor, 'activo', NEW.activo), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_empleados_del;
CREATE TRIGGER trg_aud_empleados_del AFTER DELETE ON empleados FOR EACH ROW
  INSERT INTO aud_empleados (operacion, llave, datos_anteriores, usuario)
  VALUES ('DELETE', OLD.id_empleado, JSON_OBJECT('id_empleado', OLD.id_empleado, 'nombre', OLD.nombre, 'apellido', OLD.apellido, 'correo', OLD.correo, 'telefono', OLD.telefono, 'puesto', OLD.puesto, 'salario_hora', OLD.salario_hora, 'fecha_contratacion', OLD.fecha_contratacion, 'id_sucursal', OLD.id_sucursal, 'id_supervisor', OLD.id_supervisor, 'activo', OLD.activo), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_empleados_no_modificar;
CREATE TRIGGER trg_aud_empleados_no_modificar BEFORE UPDATE ON aud_empleados FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden modificar';

DROP TRIGGER IF EXISTS trg_aud_empleados_no_borrar;
CREATE TRIGGER trg_aud_empleados_no_borrar BEFORE DELETE ON aud_empleados FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden borrar';

  
-- niveles_membresia  (llave: id_nivel)
  
DROP TABLE IF EXISTS aud_niveles_membresia;
CREATE TABLE aud_niveles_membresia (
  id_auditoria     BIGINT AUTO_INCREMENT PRIMARY KEY,
  operacion        ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  llave            VARCHAR(60)  NOT NULL,
  datos_anteriores JSON NULL,
  datos_nuevos     JSON NULL,
  usuario          VARCHAR(100) NOT NULL,
  fecha            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_aud_niveles_membresia_llave (llave),
  INDEX idx_aud_niveles_membresia_fecha (fecha)
) ENGINE=InnoDB COMMENT='Auditoría de la tabla niveles_membresia';

DROP TRIGGER IF EXISTS trg_aud_niveles_membresia_ins;
CREATE TRIGGER trg_aud_niveles_membresia_ins AFTER INSERT ON niveles_membresia FOR EACH ROW
  INSERT INTO aud_niveles_membresia (operacion, llave, datos_nuevos, usuario)
  VALUES ('INSERT', NEW.id_nivel, JSON_OBJECT('id_nivel', NEW.id_nivel, 'nombre', NEW.nombre, 'costo_anual', NEW.costo_anual, 'descuento_usados_pct', NEW.descuento_usados_pct, 'bono_intercambio_pct', NEW.bono_intercambio_pct, 'puntos_por_dolar', NEW.puntos_por_dolar), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_niveles_membresia_upd;
CREATE TRIGGER trg_aud_niveles_membresia_upd AFTER UPDATE ON niveles_membresia FOR EACH ROW
  INSERT INTO aud_niveles_membresia (operacion, llave, datos_anteriores, datos_nuevos, usuario)
  VALUES ('UPDATE', NEW.id_nivel, JSON_OBJECT('id_nivel', OLD.id_nivel, 'nombre', OLD.nombre, 'costo_anual', OLD.costo_anual, 'descuento_usados_pct', OLD.descuento_usados_pct, 'bono_intercambio_pct', OLD.bono_intercambio_pct, 'puntos_por_dolar', OLD.puntos_por_dolar), JSON_OBJECT('id_nivel', NEW.id_nivel, 'nombre', NEW.nombre, 'costo_anual', NEW.costo_anual, 'descuento_usados_pct', NEW.descuento_usados_pct, 'bono_intercambio_pct', NEW.bono_intercambio_pct, 'puntos_por_dolar', NEW.puntos_por_dolar), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_niveles_membresia_del;
CREATE TRIGGER trg_aud_niveles_membresia_del AFTER DELETE ON niveles_membresia FOR EACH ROW
  INSERT INTO aud_niveles_membresia (operacion, llave, datos_anteriores, usuario)
  VALUES ('DELETE', OLD.id_nivel, JSON_OBJECT('id_nivel', OLD.id_nivel, 'nombre', OLD.nombre, 'costo_anual', OLD.costo_anual, 'descuento_usados_pct', OLD.descuento_usados_pct, 'bono_intercambio_pct', OLD.bono_intercambio_pct, 'puntos_por_dolar', OLD.puntos_por_dolar), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_niveles_membresia_no_modificar;
CREATE TRIGGER trg_aud_niveles_membresia_no_modificar BEFORE UPDATE ON aud_niveles_membresia FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden modificar';

DROP TRIGGER IF EXISTS trg_aud_niveles_membresia_no_borrar;
CREATE TRIGGER trg_aud_niveles_membresia_no_borrar BEFORE DELETE ON aud_niveles_membresia FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden borrar';

  
-- clientes  (llave: id_cliente)
  
DROP TABLE IF EXISTS aud_clientes;
CREATE TABLE aud_clientes (
  id_auditoria     BIGINT AUTO_INCREMENT PRIMARY KEY,
  operacion        ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  llave            VARCHAR(60)  NOT NULL,
  datos_anteriores JSON NULL,
  datos_nuevos     JSON NULL,
  usuario          VARCHAR(100) NOT NULL,
  fecha            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_aud_clientes_llave (llave),
  INDEX idx_aud_clientes_fecha (fecha)
) ENGINE=InnoDB COMMENT='Auditoría de la tabla clientes';

DROP TRIGGER IF EXISTS trg_aud_clientes_ins;
CREATE TRIGGER trg_aud_clientes_ins AFTER INSERT ON clientes FOR EACH ROW
  INSERT INTO aud_clientes (operacion, llave, datos_nuevos, usuario)
  VALUES ('INSERT', NEW.id_cliente, JSON_OBJECT('id_cliente', NEW.id_cliente, 'nombre', NEW.nombre, 'apellido', NEW.apellido, 'correo', NEW.correo, 'telefono', NEW.telefono, 'fecha_nacimiento', NEW.fecha_nacimiento, 'id_estado', NEW.id_estado, 'id_nivel', NEW.id_nivel, 'vencimiento_membresia', NEW.vencimiento_membresia, 'puntos', NEW.puntos, 'credito_tienda', NEW.credito_tienda, 'fecha_registro', NEW.fecha_registro), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_clientes_upd;
CREATE TRIGGER trg_aud_clientes_upd AFTER UPDATE ON clientes FOR EACH ROW
  INSERT INTO aud_clientes (operacion, llave, datos_anteriores, datos_nuevos, usuario)
  VALUES ('UPDATE', NEW.id_cliente, JSON_OBJECT('id_cliente', OLD.id_cliente, 'nombre', OLD.nombre, 'apellido', OLD.apellido, 'correo', OLD.correo, 'telefono', OLD.telefono, 'fecha_nacimiento', OLD.fecha_nacimiento, 'id_estado', OLD.id_estado, 'id_nivel', OLD.id_nivel, 'vencimiento_membresia', OLD.vencimiento_membresia, 'puntos', OLD.puntos, 'credito_tienda', OLD.credito_tienda, 'fecha_registro', OLD.fecha_registro), JSON_OBJECT('id_cliente', NEW.id_cliente, 'nombre', NEW.nombre, 'apellido', NEW.apellido, 'correo', NEW.correo, 'telefono', NEW.telefono, 'fecha_nacimiento', NEW.fecha_nacimiento, 'id_estado', NEW.id_estado, 'id_nivel', NEW.id_nivel, 'vencimiento_membresia', NEW.vencimiento_membresia, 'puntos', NEW.puntos, 'credito_tienda', NEW.credito_tienda, 'fecha_registro', NEW.fecha_registro), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_clientes_del;
CREATE TRIGGER trg_aud_clientes_del AFTER DELETE ON clientes FOR EACH ROW
  INSERT INTO aud_clientes (operacion, llave, datos_anteriores, usuario)
  VALUES ('DELETE', OLD.id_cliente, JSON_OBJECT('id_cliente', OLD.id_cliente, 'nombre', OLD.nombre, 'apellido', OLD.apellido, 'correo', OLD.correo, 'telefono', OLD.telefono, 'fecha_nacimiento', OLD.fecha_nacimiento, 'id_estado', OLD.id_estado, 'id_nivel', OLD.id_nivel, 'vencimiento_membresia', OLD.vencimiento_membresia, 'puntos', OLD.puntos, 'credito_tienda', OLD.credito_tienda, 'fecha_registro', OLD.fecha_registro), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_clientes_no_modificar;
CREATE TRIGGER trg_aud_clientes_no_modificar BEFORE UPDATE ON aud_clientes FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden modificar';

DROP TRIGGER IF EXISTS trg_aud_clientes_no_borrar;
CREATE TRIGGER trg_aud_clientes_no_borrar BEFORE DELETE ON aud_clientes FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden borrar';

  
-- categorias  (llave: id_categoria)
  
DROP TABLE IF EXISTS aud_categorias;
CREATE TABLE aud_categorias (
  id_auditoria     BIGINT AUTO_INCREMENT PRIMARY KEY,
  operacion        ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  llave            VARCHAR(60)  NOT NULL,
  datos_anteriores JSON NULL,
  datos_nuevos     JSON NULL,
  usuario          VARCHAR(100) NOT NULL,
  fecha            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_aud_categorias_llave (llave),
  INDEX idx_aud_categorias_fecha (fecha)
) ENGINE=InnoDB COMMENT='Auditoría de la tabla categorias';

DROP TRIGGER IF EXISTS trg_aud_categorias_ins;
CREATE TRIGGER trg_aud_categorias_ins AFTER INSERT ON categorias FOR EACH ROW
  INSERT INTO aud_categorias (operacion, llave, datos_nuevos, usuario)
  VALUES ('INSERT', NEW.id_categoria, JSON_OBJECT('id_categoria', NEW.id_categoria, 'nombre', NEW.nombre, 'descripcion', NEW.descripcion), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_categorias_upd;
CREATE TRIGGER trg_aud_categorias_upd AFTER UPDATE ON categorias FOR EACH ROW
  INSERT INTO aud_categorias (operacion, llave, datos_anteriores, datos_nuevos, usuario)
  VALUES ('UPDATE', NEW.id_categoria, JSON_OBJECT('id_categoria', OLD.id_categoria, 'nombre', OLD.nombre, 'descripcion', OLD.descripcion), JSON_OBJECT('id_categoria', NEW.id_categoria, 'nombre', NEW.nombre, 'descripcion', NEW.descripcion), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_categorias_del;
CREATE TRIGGER trg_aud_categorias_del AFTER DELETE ON categorias FOR EACH ROW
  INSERT INTO aud_categorias (operacion, llave, datos_anteriores, usuario)
  VALUES ('DELETE', OLD.id_categoria, JSON_OBJECT('id_categoria', OLD.id_categoria, 'nombre', OLD.nombre, 'descripcion', OLD.descripcion), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_categorias_no_modificar;
CREATE TRIGGER trg_aud_categorias_no_modificar BEFORE UPDATE ON aud_categorias FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden modificar';

DROP TRIGGER IF EXISTS trg_aud_categorias_no_borrar;
CREATE TRIGGER trg_aud_categorias_no_borrar BEFORE DELETE ON aud_categorias FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden borrar';

  
-- plataformas  (llave: id_plataforma)
  
DROP TABLE IF EXISTS aud_plataformas;
CREATE TABLE aud_plataformas (
  id_auditoria     BIGINT AUTO_INCREMENT PRIMARY KEY,
  operacion        ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  llave            VARCHAR(60)  NOT NULL,
  datos_anteriores JSON NULL,
  datos_nuevos     JSON NULL,
  usuario          VARCHAR(100) NOT NULL,
  fecha            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_aud_plataformas_llave (llave),
  INDEX idx_aud_plataformas_fecha (fecha)
) ENGINE=InnoDB COMMENT='Auditoría de la tabla plataformas';

DROP TRIGGER IF EXISTS trg_aud_plataformas_ins;
CREATE TRIGGER trg_aud_plataformas_ins AFTER INSERT ON plataformas FOR EACH ROW
  INSERT INTO aud_plataformas (operacion, llave, datos_nuevos, usuario)
  VALUES ('INSERT', NEW.id_plataforma, JSON_OBJECT('id_plataforma', NEW.id_plataforma, 'nombre', NEW.nombre, 'fabricante', NEW.fabricante, 'generacion', NEW.generacion, 'fecha_lanzamiento', NEW.fecha_lanzamiento), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_plataformas_upd;
CREATE TRIGGER trg_aud_plataformas_upd AFTER UPDATE ON plataformas FOR EACH ROW
  INSERT INTO aud_plataformas (operacion, llave, datos_anteriores, datos_nuevos, usuario)
  VALUES ('UPDATE', NEW.id_plataforma, JSON_OBJECT('id_plataforma', OLD.id_plataforma, 'nombre', OLD.nombre, 'fabricante', OLD.fabricante, 'generacion', OLD.generacion, 'fecha_lanzamiento', OLD.fecha_lanzamiento), JSON_OBJECT('id_plataforma', NEW.id_plataforma, 'nombre', NEW.nombre, 'fabricante', NEW.fabricante, 'generacion', NEW.generacion, 'fecha_lanzamiento', NEW.fecha_lanzamiento), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_plataformas_del;
CREATE TRIGGER trg_aud_plataformas_del AFTER DELETE ON plataformas FOR EACH ROW
  INSERT INTO aud_plataformas (operacion, llave, datos_anteriores, usuario)
  VALUES ('DELETE', OLD.id_plataforma, JSON_OBJECT('id_plataforma', OLD.id_plataforma, 'nombre', OLD.nombre, 'fabricante', OLD.fabricante, 'generacion', OLD.generacion, 'fecha_lanzamiento', OLD.fecha_lanzamiento), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_plataformas_no_modificar;
CREATE TRIGGER trg_aud_plataformas_no_modificar BEFORE UPDATE ON aud_plataformas FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden modificar';

DROP TRIGGER IF EXISTS trg_aud_plataformas_no_borrar;
CREATE TRIGGER trg_aud_plataformas_no_borrar BEFORE DELETE ON aud_plataformas FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden borrar';

  
-- generos  (llave: id_genero)
  
DROP TABLE IF EXISTS aud_generos;
CREATE TABLE aud_generos (
  id_auditoria     BIGINT AUTO_INCREMENT PRIMARY KEY,
  operacion        ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  llave            VARCHAR(60)  NOT NULL,
  datos_anteriores JSON NULL,
  datos_nuevos     JSON NULL,
  usuario          VARCHAR(100) NOT NULL,
  fecha            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_aud_generos_llave (llave),
  INDEX idx_aud_generos_fecha (fecha)
) ENGINE=InnoDB COMMENT='Auditoría de la tabla generos';

DROP TRIGGER IF EXISTS trg_aud_generos_ins;
CREATE TRIGGER trg_aud_generos_ins AFTER INSERT ON generos FOR EACH ROW
  INSERT INTO aud_generos (operacion, llave, datos_nuevos, usuario)
  VALUES ('INSERT', NEW.id_genero, JSON_OBJECT('id_genero', NEW.id_genero, 'nombre', NEW.nombre), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_generos_upd;
CREATE TRIGGER trg_aud_generos_upd AFTER UPDATE ON generos FOR EACH ROW
  INSERT INTO aud_generos (operacion, llave, datos_anteriores, datos_nuevos, usuario)
  VALUES ('UPDATE', NEW.id_genero, JSON_OBJECT('id_genero', OLD.id_genero, 'nombre', OLD.nombre), JSON_OBJECT('id_genero', NEW.id_genero, 'nombre', NEW.nombre), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_generos_del;
CREATE TRIGGER trg_aud_generos_del AFTER DELETE ON generos FOR EACH ROW
  INSERT INTO aud_generos (operacion, llave, datos_anteriores, usuario)
  VALUES ('DELETE', OLD.id_genero, JSON_OBJECT('id_genero', OLD.id_genero, 'nombre', OLD.nombre), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_generos_no_modificar;
CREATE TRIGGER trg_aud_generos_no_modificar BEFORE UPDATE ON aud_generos FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden modificar';

DROP TRIGGER IF EXISTS trg_aud_generos_no_borrar;
CREATE TRIGGER trg_aud_generos_no_borrar BEFORE DELETE ON aud_generos FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden borrar';

  
-- proveedores  (llave: id_proveedor)
  
DROP TABLE IF EXISTS aud_proveedores;
CREATE TABLE aud_proveedores (
  id_auditoria     BIGINT AUTO_INCREMENT PRIMARY KEY,
  operacion        ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  llave            VARCHAR(60)  NOT NULL,
  datos_anteriores JSON NULL,
  datos_nuevos     JSON NULL,
  usuario          VARCHAR(100) NOT NULL,
  fecha            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_aud_proveedores_llave (llave),
  INDEX idx_aud_proveedores_fecha (fecha)
) ENGINE=InnoDB COMMENT='Auditoría de la tabla proveedores';

DROP TRIGGER IF EXISTS trg_aud_proveedores_ins;
CREATE TRIGGER trg_aud_proveedores_ins AFTER INSERT ON proveedores FOR EACH ROW
  INSERT INTO aud_proveedores (operacion, llave, datos_nuevos, usuario)
  VALUES ('INSERT', NEW.id_proveedor, JSON_OBJECT('id_proveedor', NEW.id_proveedor, 'nombre', NEW.nombre, 'contacto', NEW.contacto, 'telefono', NEW.telefono, 'correo', NEW.correo, 'ciudad', NEW.ciudad, 'id_estado', NEW.id_estado), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_proveedores_upd;
CREATE TRIGGER trg_aud_proveedores_upd AFTER UPDATE ON proveedores FOR EACH ROW
  INSERT INTO aud_proveedores (operacion, llave, datos_anteriores, datos_nuevos, usuario)
  VALUES ('UPDATE', NEW.id_proveedor, JSON_OBJECT('id_proveedor', OLD.id_proveedor, 'nombre', OLD.nombre, 'contacto', OLD.contacto, 'telefono', OLD.telefono, 'correo', OLD.correo, 'ciudad', OLD.ciudad, 'id_estado', OLD.id_estado), JSON_OBJECT('id_proveedor', NEW.id_proveedor, 'nombre', NEW.nombre, 'contacto', NEW.contacto, 'telefono', NEW.telefono, 'correo', NEW.correo, 'ciudad', NEW.ciudad, 'id_estado', NEW.id_estado), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_proveedores_del;
CREATE TRIGGER trg_aud_proveedores_del AFTER DELETE ON proveedores FOR EACH ROW
  INSERT INTO aud_proveedores (operacion, llave, datos_anteriores, usuario)
  VALUES ('DELETE', OLD.id_proveedor, JSON_OBJECT('id_proveedor', OLD.id_proveedor, 'nombre', OLD.nombre, 'contacto', OLD.contacto, 'telefono', OLD.telefono, 'correo', OLD.correo, 'ciudad', OLD.ciudad, 'id_estado', OLD.id_estado), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_proveedores_no_modificar;
CREATE TRIGGER trg_aud_proveedores_no_modificar BEFORE UPDATE ON aud_proveedores FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden modificar';

DROP TRIGGER IF EXISTS trg_aud_proveedores_no_borrar;
CREATE TRIGGER trg_aud_proveedores_no_borrar BEFORE DELETE ON aud_proveedores FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden borrar';

  
-- productos  (llave: id_producto)
  
DROP TABLE IF EXISTS aud_productos;
CREATE TABLE aud_productos (
  id_auditoria     BIGINT AUTO_INCREMENT PRIMARY KEY,
  operacion        ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  llave            VARCHAR(60)  NOT NULL,
  datos_anteriores JSON NULL,
  datos_nuevos     JSON NULL,
  usuario          VARCHAR(100) NOT NULL,
  fecha            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_aud_productos_llave (llave),
  INDEX idx_aud_productos_fecha (fecha)
) ENGINE=InnoDB COMMENT='Auditoría de la tabla productos';

DROP TRIGGER IF EXISTS trg_aud_productos_ins;
CREATE TRIGGER trg_aud_productos_ins AFTER INSERT ON productos FOR EACH ROW
  INSERT INTO aud_productos (operacion, llave, datos_nuevos, usuario)
  VALUES ('INSERT', NEW.id_producto, JSON_OBJECT('id_producto', NEW.id_producto, 'sku', NEW.sku, 'nombre', NEW.nombre, 'id_categoria', NEW.id_categoria, 'id_plataforma', NEW.id_plataforma, 'id_proveedor', NEW.id_proveedor, 'condicion', NEW.condicion, 'clasificacion_esrb', NEW.clasificacion_esrb, 'precio_venta', NEW.precio_venta, 'costo', NEW.costo, 'fecha_lanzamiento', NEW.fecha_lanzamiento, 'activo', NEW.activo), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_productos_upd;
CREATE TRIGGER trg_aud_productos_upd AFTER UPDATE ON productos FOR EACH ROW
  INSERT INTO aud_productos (operacion, llave, datos_anteriores, datos_nuevos, usuario)
  VALUES ('UPDATE', NEW.id_producto, JSON_OBJECT('id_producto', OLD.id_producto, 'sku', OLD.sku, 'nombre', OLD.nombre, 'id_categoria', OLD.id_categoria, 'id_plataforma', OLD.id_plataforma, 'id_proveedor', OLD.id_proveedor, 'condicion', OLD.condicion, 'clasificacion_esrb', OLD.clasificacion_esrb, 'precio_venta', OLD.precio_venta, 'costo', OLD.costo, 'fecha_lanzamiento', OLD.fecha_lanzamiento, 'activo', OLD.activo), JSON_OBJECT('id_producto', NEW.id_producto, 'sku', NEW.sku, 'nombre', NEW.nombre, 'id_categoria', NEW.id_categoria, 'id_plataforma', NEW.id_plataforma, 'id_proveedor', NEW.id_proveedor, 'condicion', NEW.condicion, 'clasificacion_esrb', NEW.clasificacion_esrb, 'precio_venta', NEW.precio_venta, 'costo', NEW.costo, 'fecha_lanzamiento', NEW.fecha_lanzamiento, 'activo', NEW.activo), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_productos_del;
CREATE TRIGGER trg_aud_productos_del AFTER DELETE ON productos FOR EACH ROW
  INSERT INTO aud_productos (operacion, llave, datos_anteriores, usuario)
  VALUES ('DELETE', OLD.id_producto, JSON_OBJECT('id_producto', OLD.id_producto, 'sku', OLD.sku, 'nombre', OLD.nombre, 'id_categoria', OLD.id_categoria, 'id_plataforma', OLD.id_plataforma, 'id_proveedor', OLD.id_proveedor, 'condicion', OLD.condicion, 'clasificacion_esrb', OLD.clasificacion_esrb, 'precio_venta', OLD.precio_venta, 'costo', OLD.costo, 'fecha_lanzamiento', OLD.fecha_lanzamiento, 'activo', OLD.activo), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_productos_no_modificar;
CREATE TRIGGER trg_aud_productos_no_modificar BEFORE UPDATE ON aud_productos FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden modificar';

DROP TRIGGER IF EXISTS trg_aud_productos_no_borrar;
CREATE TRIGGER trg_aud_productos_no_borrar BEFORE DELETE ON aud_productos FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden borrar';

  
-- producto_genero  (llave: id_producto, id_genero)
  
DROP TABLE IF EXISTS aud_producto_genero;
CREATE TABLE aud_producto_genero (
  id_auditoria     BIGINT AUTO_INCREMENT PRIMARY KEY,
  operacion        ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  llave            VARCHAR(60)  NOT NULL,
  datos_anteriores JSON NULL,
  datos_nuevos     JSON NULL,
  usuario          VARCHAR(100) NOT NULL,
  fecha            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_aud_producto_genero_llave (llave),
  INDEX idx_aud_producto_genero_fecha (fecha)
) ENGINE=InnoDB COMMENT='Auditoría de la tabla producto_genero';

DROP TRIGGER IF EXISTS trg_aud_producto_genero_ins;
CREATE TRIGGER trg_aud_producto_genero_ins AFTER INSERT ON producto_genero FOR EACH ROW
  INSERT INTO aud_producto_genero (operacion, llave, datos_nuevos, usuario)
  VALUES ('INSERT', CONCAT_WS('-', NEW.id_producto, NEW.id_genero), JSON_OBJECT('id_producto', NEW.id_producto, 'id_genero', NEW.id_genero), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_producto_genero_upd;
CREATE TRIGGER trg_aud_producto_genero_upd AFTER UPDATE ON producto_genero FOR EACH ROW
  INSERT INTO aud_producto_genero (operacion, llave, datos_anteriores, datos_nuevos, usuario)
  VALUES ('UPDATE', CONCAT_WS('-', NEW.id_producto, NEW.id_genero), JSON_OBJECT('id_producto', OLD.id_producto, 'id_genero', OLD.id_genero), JSON_OBJECT('id_producto', NEW.id_producto, 'id_genero', NEW.id_genero), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_producto_genero_del;
CREATE TRIGGER trg_aud_producto_genero_del AFTER DELETE ON producto_genero FOR EACH ROW
  INSERT INTO aud_producto_genero (operacion, llave, datos_anteriores, usuario)
  VALUES ('DELETE', CONCAT_WS('-', OLD.id_producto, OLD.id_genero), JSON_OBJECT('id_producto', OLD.id_producto, 'id_genero', OLD.id_genero), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_producto_genero_no_modificar;
CREATE TRIGGER trg_aud_producto_genero_no_modificar BEFORE UPDATE ON aud_producto_genero FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden modificar';

DROP TRIGGER IF EXISTS trg_aud_producto_genero_no_borrar;
CREATE TRIGGER trg_aud_producto_genero_no_borrar BEFORE DELETE ON aud_producto_genero FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden borrar';

  
-- inventario  (llave: id_sucursal, id_producto)
  
DROP TABLE IF EXISTS aud_inventario;
CREATE TABLE aud_inventario (
  id_auditoria     BIGINT AUTO_INCREMENT PRIMARY KEY,
  operacion        ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  llave            VARCHAR(60)  NOT NULL,
  datos_anteriores JSON NULL,
  datos_nuevos     JSON NULL,
  usuario          VARCHAR(100) NOT NULL,
  fecha            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_aud_inventario_llave (llave),
  INDEX idx_aud_inventario_fecha (fecha)
) ENGINE=InnoDB COMMENT='Auditoría de la tabla inventario';

DROP TRIGGER IF EXISTS trg_aud_inventario_ins;
CREATE TRIGGER trg_aud_inventario_ins AFTER INSERT ON inventario FOR EACH ROW
  INSERT INTO aud_inventario (operacion, llave, datos_nuevos, usuario)
  VALUES ('INSERT', CONCAT_WS('-', NEW.id_sucursal, NEW.id_producto), JSON_OBJECT('id_sucursal', NEW.id_sucursal, 'id_producto', NEW.id_producto, 'existencia', NEW.existencia, 'stock_minimo', NEW.stock_minimo, 'ultima_actualizacion', NEW.ultima_actualizacion), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_inventario_upd;
CREATE TRIGGER trg_aud_inventario_upd AFTER UPDATE ON inventario FOR EACH ROW
  INSERT INTO aud_inventario (operacion, llave, datos_anteriores, datos_nuevos, usuario)
  VALUES ('UPDATE', CONCAT_WS('-', NEW.id_sucursal, NEW.id_producto), JSON_OBJECT('id_sucursal', OLD.id_sucursal, 'id_producto', OLD.id_producto, 'existencia', OLD.existencia, 'stock_minimo', OLD.stock_minimo, 'ultima_actualizacion', OLD.ultima_actualizacion), JSON_OBJECT('id_sucursal', NEW.id_sucursal, 'id_producto', NEW.id_producto, 'existencia', NEW.existencia, 'stock_minimo', NEW.stock_minimo, 'ultima_actualizacion', NEW.ultima_actualizacion), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_inventario_del;
CREATE TRIGGER trg_aud_inventario_del AFTER DELETE ON inventario FOR EACH ROW
  INSERT INTO aud_inventario (operacion, llave, datos_anteriores, usuario)
  VALUES ('DELETE', CONCAT_WS('-', OLD.id_sucursal, OLD.id_producto), JSON_OBJECT('id_sucursal', OLD.id_sucursal, 'id_producto', OLD.id_producto, 'existencia', OLD.existencia, 'stock_minimo', OLD.stock_minimo, 'ultima_actualizacion', OLD.ultima_actualizacion), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_inventario_no_modificar;
CREATE TRIGGER trg_aud_inventario_no_modificar BEFORE UPDATE ON aud_inventario FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden modificar';

DROP TRIGGER IF EXISTS trg_aud_inventario_no_borrar;
CREATE TRIGGER trg_aud_inventario_no_borrar BEFORE DELETE ON aud_inventario FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden borrar';

  
-- ventas  (llave: id_venta)
  
DROP TABLE IF EXISTS aud_ventas;
CREATE TABLE aud_ventas (
  id_auditoria     BIGINT AUTO_INCREMENT PRIMARY KEY,
  operacion        ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  llave            VARCHAR(60)  NOT NULL,
  datos_anteriores JSON NULL,
  datos_nuevos     JSON NULL,
  usuario          VARCHAR(100) NOT NULL,
  fecha            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_aud_ventas_llave (llave),
  INDEX idx_aud_ventas_fecha (fecha)
) ENGINE=InnoDB COMMENT='Auditoría de la tabla ventas';

DROP TRIGGER IF EXISTS trg_aud_ventas_ins;
CREATE TRIGGER trg_aud_ventas_ins AFTER INSERT ON ventas FOR EACH ROW
  INSERT INTO aud_ventas (operacion, llave, datos_nuevos, usuario)
  VALUES ('INSERT', NEW.id_venta, JSON_OBJECT('id_venta', NEW.id_venta, 'fecha', NEW.fecha, 'id_sucursal', NEW.id_sucursal, 'id_empleado', NEW.id_empleado, 'id_cliente', NEW.id_cliente, 'metodo_pago', NEW.metodo_pago, 'subtotal', NEW.subtotal, 'descuento', NEW.descuento, 'impuesto', NEW.impuesto, 'total', NEW.total, 'estado', NEW.estado), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_ventas_upd;
CREATE TRIGGER trg_aud_ventas_upd AFTER UPDATE ON ventas FOR EACH ROW
  INSERT INTO aud_ventas (operacion, llave, datos_anteriores, datos_nuevos, usuario)
  VALUES ('UPDATE', NEW.id_venta, JSON_OBJECT('id_venta', OLD.id_venta, 'fecha', OLD.fecha, 'id_sucursal', OLD.id_sucursal, 'id_empleado', OLD.id_empleado, 'id_cliente', OLD.id_cliente, 'metodo_pago', OLD.metodo_pago, 'subtotal', OLD.subtotal, 'descuento', OLD.descuento, 'impuesto', OLD.impuesto, 'total', OLD.total, 'estado', OLD.estado), JSON_OBJECT('id_venta', NEW.id_venta, 'fecha', NEW.fecha, 'id_sucursal', NEW.id_sucursal, 'id_empleado', NEW.id_empleado, 'id_cliente', NEW.id_cliente, 'metodo_pago', NEW.metodo_pago, 'subtotal', NEW.subtotal, 'descuento', NEW.descuento, 'impuesto', NEW.impuesto, 'total', NEW.total, 'estado', NEW.estado), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_ventas_del;
CREATE TRIGGER trg_aud_ventas_del AFTER DELETE ON ventas FOR EACH ROW
  INSERT INTO aud_ventas (operacion, llave, datos_anteriores, usuario)
  VALUES ('DELETE', OLD.id_venta, JSON_OBJECT('id_venta', OLD.id_venta, 'fecha', OLD.fecha, 'id_sucursal', OLD.id_sucursal, 'id_empleado', OLD.id_empleado, 'id_cliente', OLD.id_cliente, 'metodo_pago', OLD.metodo_pago, 'subtotal', OLD.subtotal, 'descuento', OLD.descuento, 'impuesto', OLD.impuesto, 'total', OLD.total, 'estado', OLD.estado), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_ventas_no_modificar;
CREATE TRIGGER trg_aud_ventas_no_modificar BEFORE UPDATE ON aud_ventas FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden modificar';

DROP TRIGGER IF EXISTS trg_aud_ventas_no_borrar;
CREATE TRIGGER trg_aud_ventas_no_borrar BEFORE DELETE ON aud_ventas FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden borrar';

  
-- detalle_venta  (llave: id_venta, id_producto)
  
DROP TABLE IF EXISTS aud_detalle_venta;
CREATE TABLE aud_detalle_venta (
  id_auditoria     BIGINT AUTO_INCREMENT PRIMARY KEY,
  operacion        ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  llave            VARCHAR(60)  NOT NULL,
  datos_anteriores JSON NULL,
  datos_nuevos     JSON NULL,
  usuario          VARCHAR(100) NOT NULL,
  fecha            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_aud_detalle_venta_llave (llave),
  INDEX idx_aud_detalle_venta_fecha (fecha)
) ENGINE=InnoDB COMMENT='Auditoría de la tabla detalle_venta';

DROP TRIGGER IF EXISTS trg_aud_detalle_venta_ins;
CREATE TRIGGER trg_aud_detalle_venta_ins AFTER INSERT ON detalle_venta FOR EACH ROW
  INSERT INTO aud_detalle_venta (operacion, llave, datos_nuevos, usuario)
  VALUES ('INSERT', CONCAT_WS('-', NEW.id_venta, NEW.id_producto), JSON_OBJECT('id_venta', NEW.id_venta, 'id_producto', NEW.id_producto, 'cantidad', NEW.cantidad, 'precio_unitario', NEW.precio_unitario, 'descuento', NEW.descuento), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_detalle_venta_upd;
CREATE TRIGGER trg_aud_detalle_venta_upd AFTER UPDATE ON detalle_venta FOR EACH ROW
  INSERT INTO aud_detalle_venta (operacion, llave, datos_anteriores, datos_nuevos, usuario)
  VALUES ('UPDATE', CONCAT_WS('-', NEW.id_venta, NEW.id_producto), JSON_OBJECT('id_venta', OLD.id_venta, 'id_producto', OLD.id_producto, 'cantidad', OLD.cantidad, 'precio_unitario', OLD.precio_unitario, 'descuento', OLD.descuento), JSON_OBJECT('id_venta', NEW.id_venta, 'id_producto', NEW.id_producto, 'cantidad', NEW.cantidad, 'precio_unitario', NEW.precio_unitario, 'descuento', NEW.descuento), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_detalle_venta_del;
CREATE TRIGGER trg_aud_detalle_venta_del AFTER DELETE ON detalle_venta FOR EACH ROW
  INSERT INTO aud_detalle_venta (operacion, llave, datos_anteriores, usuario)
  VALUES ('DELETE', CONCAT_WS('-', OLD.id_venta, OLD.id_producto), JSON_OBJECT('id_venta', OLD.id_venta, 'id_producto', OLD.id_producto, 'cantidad', OLD.cantidad, 'precio_unitario', OLD.precio_unitario, 'descuento', OLD.descuento), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_detalle_venta_no_modificar;
CREATE TRIGGER trg_aud_detalle_venta_no_modificar BEFORE UPDATE ON aud_detalle_venta FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden modificar';

DROP TRIGGER IF EXISTS trg_aud_detalle_venta_no_borrar;
CREATE TRIGGER trg_aud_detalle_venta_no_borrar BEFORE DELETE ON aud_detalle_venta FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden borrar';

  
-- devoluciones  (llave: id_devolucion)
  
DROP TABLE IF EXISTS aud_devoluciones;
CREATE TABLE aud_devoluciones (
  id_auditoria     BIGINT AUTO_INCREMENT PRIMARY KEY,
  operacion        ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  llave            VARCHAR(60)  NOT NULL,
  datos_anteriores JSON NULL,
  datos_nuevos     JSON NULL,
  usuario          VARCHAR(100) NOT NULL,
  fecha            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_aud_devoluciones_llave (llave),
  INDEX idx_aud_devoluciones_fecha (fecha)
) ENGINE=InnoDB COMMENT='Auditoría de la tabla devoluciones';

DROP TRIGGER IF EXISTS trg_aud_devoluciones_ins;
CREATE TRIGGER trg_aud_devoluciones_ins AFTER INSERT ON devoluciones FOR EACH ROW
  INSERT INTO aud_devoluciones (operacion, llave, datos_nuevos, usuario)
  VALUES ('INSERT', NEW.id_devolucion, JSON_OBJECT('id_devolucion', NEW.id_devolucion, 'id_venta', NEW.id_venta, 'fecha', NEW.fecha, 'id_empleado', NEW.id_empleado, 'motivo', NEW.motivo, 'monto_reembolsado', NEW.monto_reembolsado), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_devoluciones_upd;
CREATE TRIGGER trg_aud_devoluciones_upd AFTER UPDATE ON devoluciones FOR EACH ROW
  INSERT INTO aud_devoluciones (operacion, llave, datos_anteriores, datos_nuevos, usuario)
  VALUES ('UPDATE', NEW.id_devolucion, JSON_OBJECT('id_devolucion', OLD.id_devolucion, 'id_venta', OLD.id_venta, 'fecha', OLD.fecha, 'id_empleado', OLD.id_empleado, 'motivo', OLD.motivo, 'monto_reembolsado', OLD.monto_reembolsado), JSON_OBJECT('id_devolucion', NEW.id_devolucion, 'id_venta', NEW.id_venta, 'fecha', NEW.fecha, 'id_empleado', NEW.id_empleado, 'motivo', NEW.motivo, 'monto_reembolsado', NEW.monto_reembolsado), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_devoluciones_del;
CREATE TRIGGER trg_aud_devoluciones_del AFTER DELETE ON devoluciones FOR EACH ROW
  INSERT INTO aud_devoluciones (operacion, llave, datos_anteriores, usuario)
  VALUES ('DELETE', OLD.id_devolucion, JSON_OBJECT('id_devolucion', OLD.id_devolucion, 'id_venta', OLD.id_venta, 'fecha', OLD.fecha, 'id_empleado', OLD.id_empleado, 'motivo', OLD.motivo, 'monto_reembolsado', OLD.monto_reembolsado), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_devoluciones_no_modificar;
CREATE TRIGGER trg_aud_devoluciones_no_modificar BEFORE UPDATE ON aud_devoluciones FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden modificar';

DROP TRIGGER IF EXISTS trg_aud_devoluciones_no_borrar;
CREATE TRIGGER trg_aud_devoluciones_no_borrar BEFORE DELETE ON aud_devoluciones FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden borrar';

  
-- detalle_devolucion  (llave: id_devolucion, id_producto)
  
DROP TABLE IF EXISTS aud_detalle_devolucion;
CREATE TABLE aud_detalle_devolucion (
  id_auditoria     BIGINT AUTO_INCREMENT PRIMARY KEY,
  operacion        ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  llave            VARCHAR(60)  NOT NULL,
  datos_anteriores JSON NULL,
  datos_nuevos     JSON NULL,
  usuario          VARCHAR(100) NOT NULL,
  fecha            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_aud_detalle_devolucion_llave (llave),
  INDEX idx_aud_detalle_devolucion_fecha (fecha)
) ENGINE=InnoDB COMMENT='Auditoría de la tabla detalle_devolucion';

DROP TRIGGER IF EXISTS trg_aud_detalle_devolucion_ins;
CREATE TRIGGER trg_aud_detalle_devolucion_ins AFTER INSERT ON detalle_devolucion FOR EACH ROW
  INSERT INTO aud_detalle_devolucion (operacion, llave, datos_nuevos, usuario)
  VALUES ('INSERT', CONCAT_WS('-', NEW.id_devolucion, NEW.id_producto), JSON_OBJECT('id_devolucion', NEW.id_devolucion, 'id_producto', NEW.id_producto, 'cantidad', NEW.cantidad), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_detalle_devolucion_upd;
CREATE TRIGGER trg_aud_detalle_devolucion_upd AFTER UPDATE ON detalle_devolucion FOR EACH ROW
  INSERT INTO aud_detalle_devolucion (operacion, llave, datos_anteriores, datos_nuevos, usuario)
  VALUES ('UPDATE', CONCAT_WS('-', NEW.id_devolucion, NEW.id_producto), JSON_OBJECT('id_devolucion', OLD.id_devolucion, 'id_producto', OLD.id_producto, 'cantidad', OLD.cantidad), JSON_OBJECT('id_devolucion', NEW.id_devolucion, 'id_producto', NEW.id_producto, 'cantidad', NEW.cantidad), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_detalle_devolucion_del;
CREATE TRIGGER trg_aud_detalle_devolucion_del AFTER DELETE ON detalle_devolucion FOR EACH ROW
  INSERT INTO aud_detalle_devolucion (operacion, llave, datos_anteriores, usuario)
  VALUES ('DELETE', CONCAT_WS('-', OLD.id_devolucion, OLD.id_producto), JSON_OBJECT('id_devolucion', OLD.id_devolucion, 'id_producto', OLD.id_producto, 'cantidad', OLD.cantidad), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_detalle_devolucion_no_modificar;
CREATE TRIGGER trg_aud_detalle_devolucion_no_modificar BEFORE UPDATE ON aud_detalle_devolucion FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden modificar';

DROP TRIGGER IF EXISTS trg_aud_detalle_devolucion_no_borrar;
CREATE TRIGGER trg_aud_detalle_devolucion_no_borrar BEFORE DELETE ON aud_detalle_devolucion FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden borrar';

  
-- intercambios  (llave: id_intercambio)
  
DROP TABLE IF EXISTS aud_intercambios;
CREATE TABLE aud_intercambios (
  id_auditoria     BIGINT AUTO_INCREMENT PRIMARY KEY,
  operacion        ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  llave            VARCHAR(60)  NOT NULL,
  datos_anteriores JSON NULL,
  datos_nuevos     JSON NULL,
  usuario          VARCHAR(100) NOT NULL,
  fecha            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_aud_intercambios_llave (llave),
  INDEX idx_aud_intercambios_fecha (fecha)
) ENGINE=InnoDB COMMENT='Auditoría de la tabla intercambios';

DROP TRIGGER IF EXISTS trg_aud_intercambios_ins;
CREATE TRIGGER trg_aud_intercambios_ins AFTER INSERT ON intercambios FOR EACH ROW
  INSERT INTO aud_intercambios (operacion, llave, datos_nuevos, usuario)
  VALUES ('INSERT', NEW.id_intercambio, JSON_OBJECT('id_intercambio', NEW.id_intercambio, 'fecha', NEW.fecha, 'id_sucursal', NEW.id_sucursal, 'id_empleado', NEW.id_empleado, 'id_cliente', NEW.id_cliente, 'forma_pago', NEW.forma_pago, 'total_pagado', NEW.total_pagado), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_intercambios_upd;
CREATE TRIGGER trg_aud_intercambios_upd AFTER UPDATE ON intercambios FOR EACH ROW
  INSERT INTO aud_intercambios (operacion, llave, datos_anteriores, datos_nuevos, usuario)
  VALUES ('UPDATE', NEW.id_intercambio, JSON_OBJECT('id_intercambio', OLD.id_intercambio, 'fecha', OLD.fecha, 'id_sucursal', OLD.id_sucursal, 'id_empleado', OLD.id_empleado, 'id_cliente', OLD.id_cliente, 'forma_pago', OLD.forma_pago, 'total_pagado', OLD.total_pagado), JSON_OBJECT('id_intercambio', NEW.id_intercambio, 'fecha', NEW.fecha, 'id_sucursal', NEW.id_sucursal, 'id_empleado', NEW.id_empleado, 'id_cliente', NEW.id_cliente, 'forma_pago', NEW.forma_pago, 'total_pagado', NEW.total_pagado), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_intercambios_del;
CREATE TRIGGER trg_aud_intercambios_del AFTER DELETE ON intercambios FOR EACH ROW
  INSERT INTO aud_intercambios (operacion, llave, datos_anteriores, usuario)
  VALUES ('DELETE', OLD.id_intercambio, JSON_OBJECT('id_intercambio', OLD.id_intercambio, 'fecha', OLD.fecha, 'id_sucursal', OLD.id_sucursal, 'id_empleado', OLD.id_empleado, 'id_cliente', OLD.id_cliente, 'forma_pago', OLD.forma_pago, 'total_pagado', OLD.total_pagado), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_intercambios_no_modificar;
CREATE TRIGGER trg_aud_intercambios_no_modificar BEFORE UPDATE ON aud_intercambios FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden modificar';

DROP TRIGGER IF EXISTS trg_aud_intercambios_no_borrar;
CREATE TRIGGER trg_aud_intercambios_no_borrar BEFORE DELETE ON aud_intercambios FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden borrar';

  
-- detalle_intercambio  (llave: id_intercambio, id_producto)
  
DROP TABLE IF EXISTS aud_detalle_intercambio;
CREATE TABLE aud_detalle_intercambio (
  id_auditoria     BIGINT AUTO_INCREMENT PRIMARY KEY,
  operacion        ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  llave            VARCHAR(60)  NOT NULL,
  datos_anteriores JSON NULL,
  datos_nuevos     JSON NULL,
  usuario          VARCHAR(100) NOT NULL,
  fecha            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_aud_detalle_intercambio_llave (llave),
  INDEX idx_aud_detalle_intercambio_fecha (fecha)
) ENGINE=InnoDB COMMENT='Auditoría de la tabla detalle_intercambio';

DROP TRIGGER IF EXISTS trg_aud_detalle_intercambio_ins;
CREATE TRIGGER trg_aud_detalle_intercambio_ins AFTER INSERT ON detalle_intercambio FOR EACH ROW
  INSERT INTO aud_detalle_intercambio (operacion, llave, datos_nuevos, usuario)
  VALUES ('INSERT', CONCAT_WS('-', NEW.id_intercambio, NEW.id_producto), JSON_OBJECT('id_intercambio', NEW.id_intercambio, 'id_producto', NEW.id_producto, 'cantidad', NEW.cantidad, 'valor_unitario', NEW.valor_unitario), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_detalle_intercambio_upd;
CREATE TRIGGER trg_aud_detalle_intercambio_upd AFTER UPDATE ON detalle_intercambio FOR EACH ROW
  INSERT INTO aud_detalle_intercambio (operacion, llave, datos_anteriores, datos_nuevos, usuario)
  VALUES ('UPDATE', CONCAT_WS('-', NEW.id_intercambio, NEW.id_producto), JSON_OBJECT('id_intercambio', OLD.id_intercambio, 'id_producto', OLD.id_producto, 'cantidad', OLD.cantidad, 'valor_unitario', OLD.valor_unitario), JSON_OBJECT('id_intercambio', NEW.id_intercambio, 'id_producto', NEW.id_producto, 'cantidad', NEW.cantidad, 'valor_unitario', NEW.valor_unitario), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_detalle_intercambio_del;
CREATE TRIGGER trg_aud_detalle_intercambio_del AFTER DELETE ON detalle_intercambio FOR EACH ROW
  INSERT INTO aud_detalle_intercambio (operacion, llave, datos_anteriores, usuario)
  VALUES ('DELETE', CONCAT_WS('-', OLD.id_intercambio, OLD.id_producto), JSON_OBJECT('id_intercambio', OLD.id_intercambio, 'id_producto', OLD.id_producto, 'cantidad', OLD.cantidad, 'valor_unitario', OLD.valor_unitario), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_detalle_intercambio_no_modificar;
CREATE TRIGGER trg_aud_detalle_intercambio_no_modificar BEFORE UPDATE ON aud_detalle_intercambio FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden modificar';

DROP TRIGGER IF EXISTS trg_aud_detalle_intercambio_no_borrar;
CREATE TRIGGER trg_aud_detalle_intercambio_no_borrar BEFORE DELETE ON aud_detalle_intercambio FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden borrar';

  
-- preventas  (llave: id_preventa)
  
DROP TABLE IF EXISTS aud_preventas;
CREATE TABLE aud_preventas (
  id_auditoria     BIGINT AUTO_INCREMENT PRIMARY KEY,
  operacion        ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  llave            VARCHAR(60)  NOT NULL,
  datos_anteriores JSON NULL,
  datos_nuevos     JSON NULL,
  usuario          VARCHAR(100) NOT NULL,
  fecha            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_aud_preventas_llave (llave),
  INDEX idx_aud_preventas_fecha (fecha)
) ENGINE=InnoDB COMMENT='Auditoría de la tabla preventas';

DROP TRIGGER IF EXISTS trg_aud_preventas_ins;
CREATE TRIGGER trg_aud_preventas_ins AFTER INSERT ON preventas FOR EACH ROW
  INSERT INTO aud_preventas (operacion, llave, datos_nuevos, usuario)
  VALUES ('INSERT', NEW.id_preventa, JSON_OBJECT('id_preventa', NEW.id_preventa, 'fecha', NEW.fecha, 'id_cliente', NEW.id_cliente, 'id_producto', NEW.id_producto, 'id_sucursal', NEW.id_sucursal, 'anticipo', NEW.anticipo, 'estado', NEW.estado), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_preventas_upd;
CREATE TRIGGER trg_aud_preventas_upd AFTER UPDATE ON preventas FOR EACH ROW
  INSERT INTO aud_preventas (operacion, llave, datos_anteriores, datos_nuevos, usuario)
  VALUES ('UPDATE', NEW.id_preventa, JSON_OBJECT('id_preventa', OLD.id_preventa, 'fecha', OLD.fecha, 'id_cliente', OLD.id_cliente, 'id_producto', OLD.id_producto, 'id_sucursal', OLD.id_sucursal, 'anticipo', OLD.anticipo, 'estado', OLD.estado), JSON_OBJECT('id_preventa', NEW.id_preventa, 'fecha', NEW.fecha, 'id_cliente', NEW.id_cliente, 'id_producto', NEW.id_producto, 'id_sucursal', NEW.id_sucursal, 'anticipo', NEW.anticipo, 'estado', NEW.estado), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_preventas_del;
CREATE TRIGGER trg_aud_preventas_del AFTER DELETE ON preventas FOR EACH ROW
  INSERT INTO aud_preventas (operacion, llave, datos_anteriores, usuario)
  VALUES ('DELETE', OLD.id_preventa, JSON_OBJECT('id_preventa', OLD.id_preventa, 'fecha', OLD.fecha, 'id_cliente', OLD.id_cliente, 'id_producto', OLD.id_producto, 'id_sucursal', OLD.id_sucursal, 'anticipo', OLD.anticipo, 'estado', OLD.estado), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_preventas_no_modificar;
CREATE TRIGGER trg_aud_preventas_no_modificar BEFORE UPDATE ON aud_preventas FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden modificar';

DROP TRIGGER IF EXISTS trg_aud_preventas_no_borrar;
CREATE TRIGGER trg_aud_preventas_no_borrar BEFORE DELETE ON aud_preventas FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden borrar';

  
-- ordenes_compra  (llave: id_orden)
  
DROP TABLE IF EXISTS aud_ordenes_compra;
CREATE TABLE aud_ordenes_compra (
  id_auditoria     BIGINT AUTO_INCREMENT PRIMARY KEY,
  operacion        ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  llave            VARCHAR(60)  NOT NULL,
  datos_anteriores JSON NULL,
  datos_nuevos     JSON NULL,
  usuario          VARCHAR(100) NOT NULL,
  fecha            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_aud_ordenes_compra_llave (llave),
  INDEX idx_aud_ordenes_compra_fecha (fecha)
) ENGINE=InnoDB COMMENT='Auditoría de la tabla ordenes_compra';

DROP TRIGGER IF EXISTS trg_aud_ordenes_compra_ins;
CREATE TRIGGER trg_aud_ordenes_compra_ins AFTER INSERT ON ordenes_compra FOR EACH ROW
  INSERT INTO aud_ordenes_compra (operacion, llave, datos_nuevos, usuario)
  VALUES ('INSERT', NEW.id_orden, JSON_OBJECT('id_orden', NEW.id_orden, 'fecha', NEW.fecha, 'id_proveedor', NEW.id_proveedor, 'id_sucursal', NEW.id_sucursal, 'id_empleado', NEW.id_empleado, 'estado', NEW.estado, 'fecha_recepcion', NEW.fecha_recepcion, 'total', NEW.total), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_ordenes_compra_upd;
CREATE TRIGGER trg_aud_ordenes_compra_upd AFTER UPDATE ON ordenes_compra FOR EACH ROW
  INSERT INTO aud_ordenes_compra (operacion, llave, datos_anteriores, datos_nuevos, usuario)
  VALUES ('UPDATE', NEW.id_orden, JSON_OBJECT('id_orden', OLD.id_orden, 'fecha', OLD.fecha, 'id_proveedor', OLD.id_proveedor, 'id_sucursal', OLD.id_sucursal, 'id_empleado', OLD.id_empleado, 'estado', OLD.estado, 'fecha_recepcion', OLD.fecha_recepcion, 'total', OLD.total), JSON_OBJECT('id_orden', NEW.id_orden, 'fecha', NEW.fecha, 'id_proveedor', NEW.id_proveedor, 'id_sucursal', NEW.id_sucursal, 'id_empleado', NEW.id_empleado, 'estado', NEW.estado, 'fecha_recepcion', NEW.fecha_recepcion, 'total', NEW.total), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_ordenes_compra_del;
CREATE TRIGGER trg_aud_ordenes_compra_del AFTER DELETE ON ordenes_compra FOR EACH ROW
  INSERT INTO aud_ordenes_compra (operacion, llave, datos_anteriores, usuario)
  VALUES ('DELETE', OLD.id_orden, JSON_OBJECT('id_orden', OLD.id_orden, 'fecha', OLD.fecha, 'id_proveedor', OLD.id_proveedor, 'id_sucursal', OLD.id_sucursal, 'id_empleado', OLD.id_empleado, 'estado', OLD.estado, 'fecha_recepcion', OLD.fecha_recepcion, 'total', OLD.total), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_ordenes_compra_no_modificar;
CREATE TRIGGER trg_aud_ordenes_compra_no_modificar BEFORE UPDATE ON aud_ordenes_compra FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden modificar';

DROP TRIGGER IF EXISTS trg_aud_ordenes_compra_no_borrar;
CREATE TRIGGER trg_aud_ordenes_compra_no_borrar BEFORE DELETE ON aud_ordenes_compra FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden borrar';

  
-- detalle_orden_compra  (llave: id_orden, id_producto)
  
DROP TABLE IF EXISTS aud_detalle_orden_compra;
CREATE TABLE aud_detalle_orden_compra (
  id_auditoria     BIGINT AUTO_INCREMENT PRIMARY KEY,
  operacion        ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  llave            VARCHAR(60)  NOT NULL,
  datos_anteriores JSON NULL,
  datos_nuevos     JSON NULL,
  usuario          VARCHAR(100) NOT NULL,
  fecha            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_aud_detalle_orden_compra_llave (llave),
  INDEX idx_aud_detalle_orden_compra_fecha (fecha)
) ENGINE=InnoDB COMMENT='Auditoría de la tabla detalle_orden_compra';

DROP TRIGGER IF EXISTS trg_aud_detalle_orden_compra_ins;
CREATE TRIGGER trg_aud_detalle_orden_compra_ins AFTER INSERT ON detalle_orden_compra FOR EACH ROW
  INSERT INTO aud_detalle_orden_compra (operacion, llave, datos_nuevos, usuario)
  VALUES ('INSERT', CONCAT_WS('-', NEW.id_orden, NEW.id_producto), JSON_OBJECT('id_orden', NEW.id_orden, 'id_producto', NEW.id_producto, 'cantidad', NEW.cantidad, 'costo_unitario', NEW.costo_unitario), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_detalle_orden_compra_upd;
CREATE TRIGGER trg_aud_detalle_orden_compra_upd AFTER UPDATE ON detalle_orden_compra FOR EACH ROW
  INSERT INTO aud_detalle_orden_compra (operacion, llave, datos_anteriores, datos_nuevos, usuario)
  VALUES ('UPDATE', CONCAT_WS('-', NEW.id_orden, NEW.id_producto), JSON_OBJECT('id_orden', OLD.id_orden, 'id_producto', OLD.id_producto, 'cantidad', OLD.cantidad, 'costo_unitario', OLD.costo_unitario), JSON_OBJECT('id_orden', NEW.id_orden, 'id_producto', NEW.id_producto, 'cantidad', NEW.cantidad, 'costo_unitario', NEW.costo_unitario), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_detalle_orden_compra_del;
CREATE TRIGGER trg_aud_detalle_orden_compra_del AFTER DELETE ON detalle_orden_compra FOR EACH ROW
  INSERT INTO aud_detalle_orden_compra (operacion, llave, datos_anteriores, usuario)
  VALUES ('DELETE', CONCAT_WS('-', OLD.id_orden, OLD.id_producto), JSON_OBJECT('id_orden', OLD.id_orden, 'id_producto', OLD.id_producto, 'cantidad', OLD.cantidad, 'costo_unitario', OLD.costo_unitario), CURRENT_USER());

DROP TRIGGER IF EXISTS trg_aud_detalle_orden_compra_no_modificar;
CREATE TRIGGER trg_aud_detalle_orden_compra_no_modificar BEFORE UPDATE ON aud_detalle_orden_compra FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden modificar';

DROP TRIGGER IF EXISTS trg_aud_detalle_orden_compra_no_borrar;
CREATE TRIGGER trg_aud_detalle_orden_compra_no_borrar BEFORE DELETE ON aud_detalle_orden_compra FOR EACH ROW
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los registros de auditoría no se pueden borrar';

 
-- Vista v_auditoria: todos los movimientos de todas las tablas en un solo lugar
 
CREATE OR REPLACE VIEW v_auditoria AS
SELECT 'estados' AS tabla, id_auditoria, operacion, llave, datos_anteriores, datos_nuevos, usuario, fecha FROM aud_estados
UNION ALL
SELECT 'sucursales' AS tabla, id_auditoria, operacion, llave, datos_anteriores, datos_nuevos, usuario, fecha FROM aud_sucursales
UNION ALL
SELECT 'empleados' AS tabla, id_auditoria, operacion, llave, datos_anteriores, datos_nuevos, usuario, fecha FROM aud_empleados
UNION ALL
SELECT 'niveles_membresia' AS tabla, id_auditoria, operacion, llave, datos_anteriores, datos_nuevos, usuario, fecha FROM aud_niveles_membresia
UNION ALL
SELECT 'clientes' AS tabla, id_auditoria, operacion, llave, datos_anteriores, datos_nuevos, usuario, fecha FROM aud_clientes
UNION ALL
SELECT 'categorias' AS tabla, id_auditoria, operacion, llave, datos_anteriores, datos_nuevos, usuario, fecha FROM aud_categorias
UNION ALL
SELECT 'plataformas' AS tabla, id_auditoria, operacion, llave, datos_anteriores, datos_nuevos, usuario, fecha FROM aud_plataformas
UNION ALL
SELECT 'generos' AS tabla, id_auditoria, operacion, llave, datos_anteriores, datos_nuevos, usuario, fecha FROM aud_generos
UNION ALL
SELECT 'proveedores' AS tabla, id_auditoria, operacion, llave, datos_anteriores, datos_nuevos, usuario, fecha FROM aud_proveedores
UNION ALL
SELECT 'productos' AS tabla, id_auditoria, operacion, llave, datos_anteriores, datos_nuevos, usuario, fecha FROM aud_productos
UNION ALL
SELECT 'producto_genero' AS tabla, id_auditoria, operacion, llave, datos_anteriores, datos_nuevos, usuario, fecha FROM aud_producto_genero
UNION ALL
SELECT 'inventario' AS tabla, id_auditoria, operacion, llave, datos_anteriores, datos_nuevos, usuario, fecha FROM aud_inventario
UNION ALL
SELECT 'ventas' AS tabla, id_auditoria, operacion, llave, datos_anteriores, datos_nuevos, usuario, fecha FROM aud_ventas
UNION ALL
SELECT 'detalle_venta' AS tabla, id_auditoria, operacion, llave, datos_anteriores, datos_nuevos, usuario, fecha FROM aud_detalle_venta
UNION ALL
SELECT 'devoluciones' AS tabla, id_auditoria, operacion, llave, datos_anteriores, datos_nuevos, usuario, fecha FROM aud_devoluciones
UNION ALL
SELECT 'detalle_devolucion' AS tabla, id_auditoria, operacion, llave, datos_anteriores, datos_nuevos, usuario, fecha FROM aud_detalle_devolucion
UNION ALL
SELECT 'intercambios' AS tabla, id_auditoria, operacion, llave, datos_anteriores, datos_nuevos, usuario, fecha FROM aud_intercambios
UNION ALL
SELECT 'detalle_intercambio' AS tabla, id_auditoria, operacion, llave, datos_anteriores, datos_nuevos, usuario, fecha FROM aud_detalle_intercambio
UNION ALL
SELECT 'preventas' AS tabla, id_auditoria, operacion, llave, datos_anteriores, datos_nuevos, usuario, fecha FROM aud_preventas
UNION ALL
SELECT 'ordenes_compra' AS tabla, id_auditoria, operacion, llave, datos_anteriores, datos_nuevos, usuario, fecha FROM aud_ordenes_compra
UNION ALL
SELECT 'detalle_orden_compra' AS tabla, id_auditoria, operacion, llave, datos_anteriores, datos_nuevos, usuario, fecha FROM aud_detalle_orden_compra;

-- Resumen: cuántos movimientos hubo por tabla y operación
CREATE OR REPLACE VIEW v_auditoria_resumen AS
SELECT tabla,
       SUM(operacion = 'INSERT') AS altas,
       SUM(operacion = 'UPDATE') AS cambios,
       SUM(operacion = 'DELETE') AS bajas,
       COUNT(*)                  AS total,
       MAX(fecha)                AS ultimo_movimiento
  FROM v_auditoria
 GROUP BY tabla;

 
-- Permisos: solo el administrador y el analista consultan la auditoría
 
GRANT SELECT ON gamestop_usa.v_auditoria         TO 'rol_analista';
GRANT SELECT ON gamestop_usa.v_auditoria_resumen TO 'rol_analista';

-- El gerente tenía permisos sobre todo el esquema (gamestop_usa.*), lo que
-- incluiría escribir en las tablas de auditoría. Se cambian por permisos
-- tabla por tabla: puede leer la auditoría, pero no escribir en ella.
-- (Los triggers sí pueden escribir: se ejecutan con los permisos de su creador.)
REVOKE SELECT, INSERT, UPDATE ON gamestop_usa.* FROM 'rol_gerente';
GRANT SELECT, INSERT, UPDATE ON gamestop_usa.estados TO 'rol_gerente';
GRANT SELECT, INSERT, UPDATE ON gamestop_usa.sucursales TO 'rol_gerente';
GRANT SELECT, INSERT, UPDATE ON gamestop_usa.empleados TO 'rol_gerente';
GRANT SELECT, INSERT, UPDATE ON gamestop_usa.niveles_membresia TO 'rol_gerente';
GRANT SELECT, INSERT, UPDATE ON gamestop_usa.clientes TO 'rol_gerente';
GRANT SELECT, INSERT, UPDATE ON gamestop_usa.categorias TO 'rol_gerente';
GRANT SELECT, INSERT, UPDATE ON gamestop_usa.plataformas TO 'rol_gerente';
GRANT SELECT, INSERT, UPDATE ON gamestop_usa.generos TO 'rol_gerente';
GRANT SELECT, INSERT, UPDATE ON gamestop_usa.proveedores TO 'rol_gerente';
GRANT SELECT, INSERT, UPDATE ON gamestop_usa.productos TO 'rol_gerente';
GRANT SELECT, INSERT, UPDATE ON gamestop_usa.producto_genero TO 'rol_gerente';
GRANT SELECT, INSERT, UPDATE ON gamestop_usa.inventario TO 'rol_gerente';
GRANT SELECT, INSERT, UPDATE ON gamestop_usa.ventas TO 'rol_gerente';
GRANT SELECT, INSERT, UPDATE ON gamestop_usa.detalle_venta TO 'rol_gerente';
GRANT SELECT, INSERT, UPDATE ON gamestop_usa.devoluciones TO 'rol_gerente';
GRANT SELECT, INSERT, UPDATE ON gamestop_usa.detalle_devolucion TO 'rol_gerente';
GRANT SELECT, INSERT, UPDATE ON gamestop_usa.intercambios TO 'rol_gerente';
GRANT SELECT, INSERT, UPDATE ON gamestop_usa.detalle_intercambio TO 'rol_gerente';
GRANT SELECT, INSERT, UPDATE ON gamestop_usa.preventas TO 'rol_gerente';
GRANT SELECT, INSERT, UPDATE ON gamestop_usa.ordenes_compra TO 'rol_gerente';
GRANT SELECT, INSERT, UPDATE ON gamestop_usa.detalle_orden_compra TO 'rol_gerente';
GRANT SELECT, INSERT, UPDATE ON gamestop_usa.bitacora_precios TO 'rol_gerente';
GRANT SELECT ON gamestop_usa.aud_estados TO 'rol_gerente';
GRANT SELECT ON gamestop_usa.aud_sucursales TO 'rol_gerente';
GRANT SELECT ON gamestop_usa.aud_empleados TO 'rol_gerente';
GRANT SELECT ON gamestop_usa.aud_niveles_membresia TO 'rol_gerente';
GRANT SELECT ON gamestop_usa.aud_clientes TO 'rol_gerente';
GRANT SELECT ON gamestop_usa.aud_categorias TO 'rol_gerente';
GRANT SELECT ON gamestop_usa.aud_plataformas TO 'rol_gerente';
GRANT SELECT ON gamestop_usa.aud_generos TO 'rol_gerente';
GRANT SELECT ON gamestop_usa.aud_proveedores TO 'rol_gerente';
GRANT SELECT ON gamestop_usa.aud_productos TO 'rol_gerente';
GRANT SELECT ON gamestop_usa.aud_producto_genero TO 'rol_gerente';
GRANT SELECT ON gamestop_usa.aud_inventario TO 'rol_gerente';
GRANT SELECT ON gamestop_usa.aud_ventas TO 'rol_gerente';
GRANT SELECT ON gamestop_usa.aud_detalle_venta TO 'rol_gerente';
GRANT SELECT ON gamestop_usa.aud_devoluciones TO 'rol_gerente';
GRANT SELECT ON gamestop_usa.aud_detalle_devolucion TO 'rol_gerente';
GRANT SELECT ON gamestop_usa.aud_intercambios TO 'rol_gerente';
GRANT SELECT ON gamestop_usa.aud_detalle_intercambio TO 'rol_gerente';
GRANT SELECT ON gamestop_usa.aud_preventas TO 'rol_gerente';
GRANT SELECT ON gamestop_usa.aud_ordenes_compra TO 'rol_gerente';
GRANT SELECT ON gamestop_usa.aud_detalle_orden_compra TO 'rol_gerente';
GRANT SELECT ON gamestop_usa.v_catalogo TO 'rol_gerente';
GRANT SELECT ON gamestop_usa.v_tickets TO 'rol_gerente';
GRANT SELECT ON gamestop_usa.v_ventas_producto TO 'rol_gerente';
GRANT SELECT ON gamestop_usa.v_inventario_valorizado TO 'rol_gerente';
GRANT SELECT ON gamestop_usa.v_clientes_resumen TO 'rol_gerente';
GRANT SELECT ON gamestop_usa.v_organigrama TO 'rol_gerente';
GRANT SELECT ON gamestop_usa.v_ventas_diarias TO 'rol_gerente';
GRANT SELECT ON gamestop_usa.v_auditoria TO 'rol_gerente';
GRANT SELECT ON gamestop_usa.v_auditoria_resumen TO 'rol_gerente';

 
-- Ejemplos de consulta
 

-- Movimientos por tabla
SELECT * FROM v_auditoria_resumen ORDER BY total DESC;

-- Últimos 20 movimientos de todo el sistema
SELECT tabla, operacion, llave, usuario, fecha FROM v_auditoria ORDER BY fecha DESC, id_auditoria DESC LIMIT 20;

-- Qué campo cambió en un UPDATE (ejemplo con clientes: puntos antes y después)
SELECT llave AS id_cliente,
       JSON_EXTRACT(datos_anteriores, '$.puntos') AS puntos_antes,
       JSON_EXTRACT(datos_nuevos, '$.puntos')     AS puntos_despues,
       usuario, fecha
  FROM aud_clientes
 WHERE operacion = 'UPDATE'
 ORDER BY fecha DESC LIMIT 10;
