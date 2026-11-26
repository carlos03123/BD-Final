

SET NAMES utf8mb4;

USE gamestop_usa;


-- SUCURSALES: tiendas


DROP PROCEDURE IF EXISTS sp_sucursales_crear;
DELIMITER $$
CREATE PROCEDURE sp_sucursales_crear(
  IN p_numero_tienda SMALLINT,
  IN p_nombre VARCHAR(80),
  IN p_direccion VARCHAR(150),
  IN p_ciudad VARCHAR(60),
  IN p_id_estado INT,
  IN p_codigo_postal CHAR(5),
  IN p_telefono VARCHAR(20),
  IN p_fecha_apertura DATE,
  OUT p_id_sucursal INT)
BEGIN
  DECLARE EXIT HANDLER FOR 1062
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un registro con ese valor único (correo, nombre, SKU o número)';
  DECLARE EXIT HANDLER FOR 3819
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un valor no cumple las reglas (por ejemplo: salario menor a $7.25 o precio menor al costo)';
  DECLARE EXIT HANDLER FOR 1265
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Valor no permitido en un campo de opciones (puesto, condición o clasificación)';
  DECLARE EXIT HANDLER FOR 1452
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El estado indicado no existe';
  INSERT INTO sucursales (numero_tienda, nombre, direccion, ciudad, id_estado, codigo_postal, telefono, fecha_apertura)
  VALUES (p_numero_tienda, p_nombre, p_direccion, p_ciudad, p_id_estado, p_codigo_postal, p_telefono, p_fecha_apertura);
  SET p_id_sucursal = LAST_INSERT_ID();
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_sucursales_consultar;
DELIMITER $$
CREATE PROCEDURE sp_sucursales_consultar(IN p_id_sucursal INT)
BEGIN
  SELECT * FROM sucursales
   WHERE p_id_sucursal IS NULL OR id_sucursal = p_id_sucursal
   ORDER BY id_sucursal;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_sucursales_actualizar;
DELIMITER $$
CREATE PROCEDURE sp_sucursales_actualizar(
  IN p_id_sucursal INT,
  IN p_numero_tienda SMALLINT,
  IN p_nombre VARCHAR(80),
  IN p_direccion VARCHAR(150),
  IN p_ciudad VARCHAR(60),
  IN p_id_estado INT,
  IN p_codigo_postal CHAR(5),
  IN p_telefono VARCHAR(20),
  IN p_fecha_apertura DATE)
BEGIN
  DECLARE EXIT HANDLER FOR 1062
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un registro con ese valor único (correo, nombre, SKU o número)';
  DECLARE EXIT HANDLER FOR 3819
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un valor no cumple las reglas (por ejemplo: salario menor a $7.25 o precio menor al costo)';
  DECLARE EXIT HANDLER FOR 1265
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Valor no permitido en un campo de opciones (puesto, condición o clasificación)';
  DECLARE EXIT HANDLER FOR 1452
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El estado indicado no existe';
  IF NOT EXISTS (SELECT 1 FROM sucursales WHERE id_sucursal = p_id_sucursal) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe el registro indicado';
  END IF;
  UPDATE sucursales
     SET numero_tienda = p_numero_tienda,
         nombre = p_nombre,
         direccion = p_direccion,
         ciudad = p_ciudad,
         id_estado = p_id_estado,
         codigo_postal = p_codigo_postal,
         telefono = p_telefono,
         fecha_apertura = p_fecha_apertura
   WHERE id_sucursal = p_id_sucursal;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_sucursales_eliminar;
DELIMITER $$
CREATE PROCEDURE sp_sucursales_eliminar(IN p_id_sucursal INT)
BEGIN
  -- Baja lógica: el registro se conserva para no perder el historial
  IF NOT EXISTS (SELECT 1 FROM sucursales WHERE id_sucursal = p_id_sucursal) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe el registro indicado';
  END IF;
  UPDATE sucursales SET activa = FALSE WHERE id_sucursal = p_id_sucursal;
END$$
DELIMITER ;


-- EMPLEADOS: personal


DROP PROCEDURE IF EXISTS sp_empleados_crear;
DELIMITER $$
CREATE PROCEDURE sp_empleados_crear(
  IN p_nombre VARCHAR(50),
  IN p_apellido VARCHAR(50),
  IN p_correo VARCHAR(120),
  IN p_telefono VARCHAR(20),
  IN p_puesto VARCHAR(30),
  IN p_salario_hora DECIMAL(6,2),
  IN p_fecha_contratacion DATE,
  IN p_id_sucursal INT,
  IN p_id_supervisor INT,
  OUT p_id_empleado INT)
BEGIN
  DECLARE EXIT HANDLER FOR 1062
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un registro con ese valor único (correo, nombre, SKU o número)';
  DECLARE EXIT HANDLER FOR 3819
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un valor no cumple las reglas (por ejemplo: salario menor a $7.25 o precio menor al costo)';
  DECLARE EXIT HANDLER FOR 1265
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Valor no permitido en un campo de opciones (puesto, condición o clasificación)';
  DECLARE EXIT HANDLER FOR 1452
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La tienda o el supervisor indicado no existe';
  INSERT INTO empleados (nombre, apellido, correo, telefono, puesto, salario_hora, fecha_contratacion, id_sucursal, id_supervisor)
  VALUES (p_nombre, p_apellido, p_correo, p_telefono, p_puesto, p_salario_hora, p_fecha_contratacion, p_id_sucursal, p_id_supervisor);
  SET p_id_empleado = LAST_INSERT_ID();
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_empleados_consultar;
DELIMITER $$
CREATE PROCEDURE sp_empleados_consultar(IN p_id_empleado INT)
BEGIN
  SELECT * FROM empleados
   WHERE p_id_empleado IS NULL OR id_empleado = p_id_empleado
   ORDER BY id_empleado;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_empleados_actualizar;
DELIMITER $$
CREATE PROCEDURE sp_empleados_actualizar(
  IN p_id_empleado INT,
  IN p_nombre VARCHAR(50),
  IN p_apellido VARCHAR(50),
  IN p_correo VARCHAR(120),
  IN p_telefono VARCHAR(20),
  IN p_puesto VARCHAR(30),
  IN p_salario_hora DECIMAL(6,2),
  IN p_fecha_contratacion DATE,
  IN p_id_sucursal INT,
  IN p_id_supervisor INT)
BEGIN
  DECLARE EXIT HANDLER FOR 1062
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un registro con ese valor único (correo, nombre, SKU o número)';
  DECLARE EXIT HANDLER FOR 3819
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un valor no cumple las reglas (por ejemplo: salario menor a $7.25 o precio menor al costo)';
  DECLARE EXIT HANDLER FOR 1265
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Valor no permitido en un campo de opciones (puesto, condición o clasificación)';
  DECLARE EXIT HANDLER FOR 1452
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La tienda o el supervisor indicado no existe';
  IF NOT EXISTS (SELECT 1 FROM empleados WHERE id_empleado = p_id_empleado) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe el registro indicado';
  END IF;
  UPDATE empleados
     SET nombre = p_nombre,
         apellido = p_apellido,
         correo = p_correo,
         telefono = p_telefono,
         puesto = p_puesto,
         salario_hora = p_salario_hora,
         fecha_contratacion = p_fecha_contratacion,
         id_sucursal = p_id_sucursal,
         id_supervisor = p_id_supervisor
   WHERE id_empleado = p_id_empleado;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_empleados_eliminar;
DELIMITER $$
CREATE PROCEDURE sp_empleados_eliminar(IN p_id_empleado INT)
BEGIN
  -- Baja lógica: el registro se conserva para no perder el historial
  IF NOT EXISTS (SELECT 1 FROM empleados WHERE id_empleado = p_id_empleado) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe el registro indicado';
  END IF;
  UPDATE empleados SET activo = FALSE WHERE id_empleado = p_id_empleado;
END$$
DELIMITER ;


-- CLIENTES: clientes


DROP PROCEDURE IF EXISTS sp_clientes_crear;
DELIMITER $$
CREATE PROCEDURE sp_clientes_crear(
  IN p_nombre VARCHAR(50),
  IN p_apellido VARCHAR(50),
  IN p_correo VARCHAR(120),
  IN p_telefono VARCHAR(20),
  IN p_fecha_nacimiento DATE,
  IN p_id_estado INT,
  OUT p_id_cliente INT)
BEGIN
  DECLARE EXIT HANDLER FOR 1062
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un registro con ese valor único (correo, nombre, SKU o número)';
  DECLARE EXIT HANDLER FOR 3819
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un valor no cumple las reglas (por ejemplo: salario menor a $7.25 o precio menor al costo)';
  DECLARE EXIT HANDLER FOR 1265
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Valor no permitido en un campo de opciones (puesto, condición o clasificación)';
  DECLARE EXIT HANDLER FOR 1452
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El estado indicado no existe';
  INSERT INTO clientes (nombre, apellido, correo, telefono, fecha_nacimiento, id_estado, fecha_registro, id_nivel)
  VALUES (p_nombre, p_apellido, p_correo, p_telefono, p_fecha_nacimiento, p_id_estado, CURDATE(), 1);
  SET p_id_cliente = LAST_INSERT_ID();
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_clientes_consultar;
DELIMITER $$
CREATE PROCEDURE sp_clientes_consultar(IN p_id_cliente INT)
BEGIN
  SELECT * FROM clientes
   WHERE p_id_cliente IS NULL OR id_cliente = p_id_cliente
   ORDER BY id_cliente;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_clientes_actualizar;
DELIMITER $$
CREATE PROCEDURE sp_clientes_actualizar(
  IN p_id_cliente INT,
  IN p_nombre VARCHAR(50),
  IN p_apellido VARCHAR(50),
  IN p_correo VARCHAR(120),
  IN p_telefono VARCHAR(20),
  IN p_fecha_nacimiento DATE,
  IN p_id_estado INT)
BEGIN
  DECLARE EXIT HANDLER FOR 1062
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un registro con ese valor único (correo, nombre, SKU o número)';
  DECLARE EXIT HANDLER FOR 3819
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un valor no cumple las reglas (por ejemplo: salario menor a $7.25 o precio menor al costo)';
  DECLARE EXIT HANDLER FOR 1265
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Valor no permitido en un campo de opciones (puesto, condición o clasificación)';
  DECLARE EXIT HANDLER FOR 1452
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El estado indicado no existe';
  IF NOT EXISTS (SELECT 1 FROM clientes WHERE id_cliente = p_id_cliente) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe el registro indicado';
  END IF;
  UPDATE clientes
     SET nombre = p_nombre,
         apellido = p_apellido,
         correo = p_correo,
         telefono = p_telefono,
         fecha_nacimiento = p_fecha_nacimiento,
         id_estado = p_id_estado
   WHERE id_cliente = p_id_cliente;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_clientes_eliminar;
DELIMITER $$
CREATE PROCEDURE sp_clientes_eliminar(IN p_id_cliente INT)
BEGIN
  DECLARE EXIT HANDLER FOR 1451
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar: tiene registros relacionados';
  IF NOT EXISTS (SELECT 1 FROM clientes WHERE id_cliente = p_id_cliente) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe el registro indicado';
  END IF;
  DELETE FROM clientes WHERE id_cliente = p_id_cliente;
END$$
DELIMITER ;


-- CATEGORIAS: categorías de producto


DROP PROCEDURE IF EXISTS sp_categorias_crear;
DELIMITER $$
CREATE PROCEDURE sp_categorias_crear(
  IN p_nombre VARCHAR(40),
  IN p_descripcion VARCHAR(150),
  OUT p_id_categoria INT)
BEGIN
  DECLARE EXIT HANDLER FOR 1062
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un registro con ese valor único (correo, nombre, SKU o número)';
  DECLARE EXIT HANDLER FOR 3819
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un valor no cumple las reglas (por ejemplo: salario menor a $7.25 o precio menor al costo)';
  DECLARE EXIT HANDLER FOR 1265
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Valor no permitido en un campo de opciones (puesto, condición o clasificación)';
  INSERT INTO categorias (nombre, descripcion)
  VALUES (p_nombre, p_descripcion);
  SET p_id_categoria = LAST_INSERT_ID();
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_categorias_consultar;
DELIMITER $$
CREATE PROCEDURE sp_categorias_consultar(IN p_id_categoria INT)
BEGIN
  SELECT * FROM categorias
   WHERE p_id_categoria IS NULL OR id_categoria = p_id_categoria
   ORDER BY id_categoria;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_categorias_actualizar;
DELIMITER $$
CREATE PROCEDURE sp_categorias_actualizar(
  IN p_id_categoria INT,
  IN p_nombre VARCHAR(40),
  IN p_descripcion VARCHAR(150))
BEGIN
  DECLARE EXIT HANDLER FOR 1062
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un registro con ese valor único (correo, nombre, SKU o número)';
  DECLARE EXIT HANDLER FOR 3819
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un valor no cumple las reglas (por ejemplo: salario menor a $7.25 o precio menor al costo)';
  DECLARE EXIT HANDLER FOR 1265
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Valor no permitido en un campo de opciones (puesto, condición o clasificación)';
  IF NOT EXISTS (SELECT 1 FROM categorias WHERE id_categoria = p_id_categoria) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe el registro indicado';
  END IF;
  UPDATE categorias
     SET nombre = p_nombre,
         descripcion = p_descripcion
   WHERE id_categoria = p_id_categoria;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_categorias_eliminar;
DELIMITER $$
CREATE PROCEDURE sp_categorias_eliminar(IN p_id_categoria INT)
BEGIN
  DECLARE EXIT HANDLER FOR 1451
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar: tiene registros relacionados';
  IF NOT EXISTS (SELECT 1 FROM categorias WHERE id_categoria = p_id_categoria) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe el registro indicado';
  END IF;
  DELETE FROM categorias WHERE id_categoria = p_id_categoria;
END$$
DELIMITER ;


-- PLATAFORMAS: plataformas (consolas)


DROP PROCEDURE IF EXISTS sp_plataformas_crear;
DELIMITER $$
CREATE PROCEDURE sp_plataformas_crear(
  IN p_nombre VARCHAR(40),
  IN p_fabricante VARCHAR(40),
  IN p_generacion TINYINT,
  IN p_fecha_lanzamiento DATE,
  OUT p_id_plataforma INT)
BEGIN
  DECLARE EXIT HANDLER FOR 1062
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un registro con ese valor único (correo, nombre, SKU o número)';
  DECLARE EXIT HANDLER FOR 3819
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un valor no cumple las reglas (por ejemplo: salario menor a $7.25 o precio menor al costo)';
  DECLARE EXIT HANDLER FOR 1265
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Valor no permitido en un campo de opciones (puesto, condición o clasificación)';
  INSERT INTO plataformas (nombre, fabricante, generacion, fecha_lanzamiento)
  VALUES (p_nombre, p_fabricante, p_generacion, p_fecha_lanzamiento);
  SET p_id_plataforma = LAST_INSERT_ID();
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_plataformas_consultar;
DELIMITER $$
CREATE PROCEDURE sp_plataformas_consultar(IN p_id_plataforma INT)
BEGIN
  SELECT * FROM plataformas
   WHERE p_id_plataforma IS NULL OR id_plataforma = p_id_plataforma
   ORDER BY id_plataforma;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_plataformas_actualizar;
DELIMITER $$
CREATE PROCEDURE sp_plataformas_actualizar(
  IN p_id_plataforma INT,
  IN p_nombre VARCHAR(40),
  IN p_fabricante VARCHAR(40),
  IN p_generacion TINYINT,
  IN p_fecha_lanzamiento DATE)
BEGIN
  DECLARE EXIT HANDLER FOR 1062
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un registro con ese valor único (correo, nombre, SKU o número)';
  DECLARE EXIT HANDLER FOR 3819
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un valor no cumple las reglas (por ejemplo: salario menor a $7.25 o precio menor al costo)';
  DECLARE EXIT HANDLER FOR 1265
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Valor no permitido en un campo de opciones (puesto, condición o clasificación)';
  IF NOT EXISTS (SELECT 1 FROM plataformas WHERE id_plataforma = p_id_plataforma) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe el registro indicado';
  END IF;
  UPDATE plataformas
     SET nombre = p_nombre,
         fabricante = p_fabricante,
         generacion = p_generacion,
         fecha_lanzamiento = p_fecha_lanzamiento
   WHERE id_plataforma = p_id_plataforma;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_plataformas_eliminar;
DELIMITER $$
CREATE PROCEDURE sp_plataformas_eliminar(IN p_id_plataforma INT)
BEGIN
  DECLARE EXIT HANDLER FOR 1451
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar: tiene registros relacionados';
  IF NOT EXISTS (SELECT 1 FROM plataformas WHERE id_plataforma = p_id_plataforma) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe el registro indicado';
  END IF;
  DELETE FROM plataformas WHERE id_plataforma = p_id_plataforma;
END$$
DELIMITER ;


-- PROVEEDORES: proveedores


DROP PROCEDURE IF EXISTS sp_proveedores_crear;
DELIMITER $$
CREATE PROCEDURE sp_proveedores_crear(
  IN p_nombre VARCHAR(80),
  IN p_contacto VARCHAR(80),
  IN p_telefono VARCHAR(20),
  IN p_correo VARCHAR(120),
  IN p_ciudad VARCHAR(60),
  IN p_id_estado INT,
  OUT p_id_proveedor INT)
BEGIN
  DECLARE EXIT HANDLER FOR 1062
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un registro con ese valor único (correo, nombre, SKU o número)';
  DECLARE EXIT HANDLER FOR 3819
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un valor no cumple las reglas (por ejemplo: salario menor a $7.25 o precio menor al costo)';
  DECLARE EXIT HANDLER FOR 1265
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Valor no permitido en un campo de opciones (puesto, condición o clasificación)';
  DECLARE EXIT HANDLER FOR 1452
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El estado indicado no existe';
  INSERT INTO proveedores (nombre, contacto, telefono, correo, ciudad, id_estado)
  VALUES (p_nombre, p_contacto, p_telefono, p_correo, p_ciudad, p_id_estado);
  SET p_id_proveedor = LAST_INSERT_ID();
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_proveedores_consultar;
DELIMITER $$
CREATE PROCEDURE sp_proveedores_consultar(IN p_id_proveedor INT)
BEGIN
  SELECT * FROM proveedores
   WHERE p_id_proveedor IS NULL OR id_proveedor = p_id_proveedor
   ORDER BY id_proveedor;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_proveedores_actualizar;
DELIMITER $$
CREATE PROCEDURE sp_proveedores_actualizar(
  IN p_id_proveedor INT,
  IN p_nombre VARCHAR(80),
  IN p_contacto VARCHAR(80),
  IN p_telefono VARCHAR(20),
  IN p_correo VARCHAR(120),
  IN p_ciudad VARCHAR(60),
  IN p_id_estado INT)
BEGIN
  DECLARE EXIT HANDLER FOR 1062
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un registro con ese valor único (correo, nombre, SKU o número)';
  DECLARE EXIT HANDLER FOR 3819
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un valor no cumple las reglas (por ejemplo: salario menor a $7.25 o precio menor al costo)';
  DECLARE EXIT HANDLER FOR 1265
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Valor no permitido en un campo de opciones (puesto, condición o clasificación)';
  DECLARE EXIT HANDLER FOR 1452
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El estado indicado no existe';
  IF NOT EXISTS (SELECT 1 FROM proveedores WHERE id_proveedor = p_id_proveedor) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe el registro indicado';
  END IF;
  UPDATE proveedores
     SET nombre = p_nombre,
         contacto = p_contacto,
         telefono = p_telefono,
         correo = p_correo,
         ciudad = p_ciudad,
         id_estado = p_id_estado
   WHERE id_proveedor = p_id_proveedor;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_proveedores_eliminar;
DELIMITER $$
CREATE PROCEDURE sp_proveedores_eliminar(IN p_id_proveedor INT)
BEGIN
  DECLARE EXIT HANDLER FOR 1451
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar: tiene registros relacionados';
  IF NOT EXISTS (SELECT 1 FROM proveedores WHERE id_proveedor = p_id_proveedor) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe el registro indicado';
  END IF;
  DELETE FROM proveedores WHERE id_proveedor = p_id_proveedor;
END$$
DELIMITER ;


-- PRODUCTOS: catálogo de productos


DROP PROCEDURE IF EXISTS sp_productos_crear;
DELIMITER $$
CREATE PROCEDURE sp_productos_crear(
  IN p_sku VARCHAR(20),
  IN p_nombre VARCHAR(120),
  IN p_id_categoria INT,
  IN p_id_plataforma INT,
  IN p_id_proveedor INT,
  IN p_condicion VARCHAR(20),
  IN p_clasificacion_esrb VARCHAR(5),
  IN p_precio_venta DECIMAL(8,2),
  IN p_costo DECIMAL(8,2),
  IN p_fecha_lanzamiento DATE,
  OUT p_id_producto INT)
BEGIN
  DECLARE EXIT HANDLER FOR 1062
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un registro con ese valor único (correo, nombre, SKU o número)';
  DECLARE EXIT HANDLER FOR 3819
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un valor no cumple las reglas (por ejemplo: salario menor a $7.25 o precio menor al costo)';
  DECLARE EXIT HANDLER FOR 1265
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Valor no permitido en un campo de opciones (puesto, condición o clasificación)';
  DECLARE EXIT HANDLER FOR 1452
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La categoría, plataforma o proveedor indicado no existe';
  INSERT INTO productos (sku, nombre, id_categoria, id_plataforma, id_proveedor, condicion, clasificacion_esrb, precio_venta, costo, fecha_lanzamiento)
  VALUES (p_sku, p_nombre, p_id_categoria, p_id_plataforma, p_id_proveedor, p_condicion, p_clasificacion_esrb, p_precio_venta, p_costo, p_fecha_lanzamiento);
  SET p_id_producto = LAST_INSERT_ID();
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_productos_consultar;
DELIMITER $$
CREATE PROCEDURE sp_productos_consultar(IN p_id_producto INT)
BEGIN
  SELECT * FROM productos
   WHERE p_id_producto IS NULL OR id_producto = p_id_producto
   ORDER BY id_producto;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_productos_actualizar;
DELIMITER $$
CREATE PROCEDURE sp_productos_actualizar(
  IN p_id_producto INT,
  IN p_sku VARCHAR(20),
  IN p_nombre VARCHAR(120),
  IN p_id_categoria INT,
  IN p_id_plataforma INT,
  IN p_id_proveedor INT,
  IN p_condicion VARCHAR(20),
  IN p_clasificacion_esrb VARCHAR(5),
  IN p_precio_venta DECIMAL(8,2),
  IN p_costo DECIMAL(8,2),
  IN p_fecha_lanzamiento DATE)
BEGIN
  DECLARE EXIT HANDLER FOR 1062
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un registro con ese valor único (correo, nombre, SKU o número)';
  DECLARE EXIT HANDLER FOR 3819
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un valor no cumple las reglas (por ejemplo: salario menor a $7.25 o precio menor al costo)';
  DECLARE EXIT HANDLER FOR 1265
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Valor no permitido en un campo de opciones (puesto, condición o clasificación)';
  DECLARE EXIT HANDLER FOR 1452
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La categoría, plataforma o proveedor indicado no existe';
  IF NOT EXISTS (SELECT 1 FROM productos WHERE id_producto = p_id_producto) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe el registro indicado';
  END IF;
  UPDATE productos
     SET sku = p_sku,
         nombre = p_nombre,
         id_categoria = p_id_categoria,
         id_plataforma = p_id_plataforma,
         id_proveedor = p_id_proveedor,
         condicion = p_condicion,
         clasificacion_esrb = p_clasificacion_esrb,
         precio_venta = p_precio_venta,
         costo = p_costo,
         fecha_lanzamiento = p_fecha_lanzamiento
   WHERE id_producto = p_id_producto;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_productos_eliminar;
DELIMITER $$
CREATE PROCEDURE sp_productos_eliminar(IN p_id_producto INT)
BEGIN
  -- Baja lógica: el registro se conserva para no perder el historial
  IF NOT EXISTS (SELECT 1 FROM productos WHERE id_producto = p_id_producto) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe el registro indicado';
  END IF;
  UPDATE productos SET activo = FALSE WHERE id_producto = p_id_producto;
END$$
DELIMITER ;


-- Permisos por rol
--   administrador: todo (ya lo tiene por rol_admin)
--   gerente:       todo el CRUD
--   vendedor (usuario): consultar y dar de alta/actualizar clientes; consultar catálogo
--   analista:      solo consultar

GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_sucursales_crear TO 'rol_gerente';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_sucursales_consultar TO 'rol_gerente';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_sucursales_actualizar TO 'rol_gerente';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_sucursales_eliminar TO 'rol_gerente';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_empleados_crear TO 'rol_gerente';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_empleados_consultar TO 'rol_gerente';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_empleados_actualizar TO 'rol_gerente';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_empleados_eliminar TO 'rol_gerente';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_clientes_crear TO 'rol_gerente';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_clientes_consultar TO 'rol_gerente';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_clientes_actualizar TO 'rol_gerente';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_clientes_eliminar TO 'rol_gerente';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_categorias_crear TO 'rol_gerente';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_categorias_consultar TO 'rol_gerente';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_categorias_actualizar TO 'rol_gerente';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_categorias_eliminar TO 'rol_gerente';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_plataformas_crear TO 'rol_gerente';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_plataformas_consultar TO 'rol_gerente';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_plataformas_actualizar TO 'rol_gerente';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_plataformas_eliminar TO 'rol_gerente';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_proveedores_crear TO 'rol_gerente';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_proveedores_consultar TO 'rol_gerente';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_proveedores_actualizar TO 'rol_gerente';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_proveedores_eliminar TO 'rol_gerente';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_productos_crear TO 'rol_gerente';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_productos_consultar TO 'rol_gerente';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_productos_actualizar TO 'rol_gerente';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_productos_eliminar TO 'rol_gerente';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_clientes_crear TO 'rol_vendedor';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_clientes_consultar TO 'rol_vendedor';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_clientes_actualizar TO 'rol_vendedor';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_productos_consultar TO 'rol_vendedor';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_categorias_consultar TO 'rol_vendedor';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_plataformas_consultar TO 'rol_vendedor';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_sucursales_consultar TO 'rol_vendedor';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_sucursales_consultar TO 'rol_analista';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_empleados_consultar TO 'rol_analista';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_clientes_consultar TO 'rol_analista';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_categorias_consultar TO 'rol_analista';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_plataformas_consultar TO 'rol_analista';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_proveedores_consultar TO 'rol_analista';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_productos_consultar TO 'rol_analista';


-- Ejemplo completo con clientes: crear -> consultar -> actualizar -> eliminar
-- (al final se revisa lo que quedó en la auditoría)

CALL sp_clientes_crear('Ana', 'Prueba', 'ana.prueba@email.com', '(214) 555-0199', '2001-05-20', 1, @nuevo);
SELECT @nuevo AS id_cliente_creado;

CALL sp_clientes_consultar(@nuevo);

CALL sp_clientes_actualizar(@nuevo, 'Ana', 'Prueba', 'ana.prueba@email.com', '(214) 555-0100', '2001-05-20', 1);
CALL sp_clientes_consultar(@nuevo);

CALL sp_clientes_eliminar(@nuevo);

SELECT operacion, llave,
       JSON_EXTRACT(datos_anteriores, '$.telefono') AS telefono_antes,
       JSON_EXTRACT(datos_nuevos, '$.telefono')     AS telefono_despues,
       usuario, fecha
  FROM aud_clientes
 WHERE llave = CAST(@nuevo AS CHAR)
 ORDER BY id_auditoria;

-- Baja lógica de un producto: sigue existiendo, pero ya no se puede vender
-- CALL sp_productos_eliminar(1);
-- Intentar borrar un cliente con compras: la llave foránea lo impide
-- CALL sp_clientes_eliminar(1);   -> 'No se puede eliminar: tiene registros relacionados'
