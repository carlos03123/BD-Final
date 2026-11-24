-- =====================================================================
--  Archivo 2 de 4: triggers, función y procedimientos almacenados
--  Se crean ANTES de los datos para que las ventas e intercambios de
--  ejemplo actualicen el inventario, totales y puntos automáticamente.
-- =====================================================================

USE gamestop;

-- ---------------------------------------------------------------------
-- FUNCIÓN: cuánto paga la tienda por un producto usado en intercambio
-- (30% del precio de venta en efectivo; 40% si es crédito en tienda)
-- ---------------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_valor_intercambio;
DELIMITER $$
CREATE FUNCTION fn_valor_intercambio(p_id_producto INT, p_forma_pago VARCHAR(20))
RETURNS DECIMAL(9,2)
READS SQL DATA
BEGIN
  DECLARE v_precio DECIMAL(9,2);
  SELECT precio_venta INTO v_precio FROM productos WHERE id_producto = p_id_producto;
  RETURN ROUND(v_precio * IF(p_forma_pago = 'Crédito en tienda', 0.40, 0.30), 2);
END$$
DELIMITER ;

-- ---------------------------------------------------------------------
-- TRIGGER 1: no se puede vender más de lo que hay en la sucursal
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_dv_validar_stock;
DELIMITER $$
CREATE TRIGGER trg_dv_validar_stock
BEFORE INSERT ON detalle_venta
FOR EACH ROW
BEGIN
  DECLARE v_stock INT DEFAULT 0;
  SELECT i.existencia INTO v_stock
    FROM inventario i
    JOIN ventas v ON v.id_sucursal = i.id_sucursal
   WHERE v.id_venta = NEW.id_venta AND i.id_producto = NEW.id_producto;
  IF v_stock IS NULL OR v_stock < NEW.cantidad THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay existencia suficiente en la sucursal';
  END IF;
END$$
DELIMITER ;

-- ---------------------------------------------------------------------
-- TRIGGER 2: al vender -> descuenta inventario, recalcula totales
--            de la venta y suma puntos al cliente (1 punto por cada $10)
-- Los precios incluyen IVA (16%); Pro tiene 10% de descuento.
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_dv_despues_insertar;
DELIMITER $$
CREATE TRIGGER trg_dv_despues_insertar
AFTER INSERT ON detalle_venta
FOR EACH ROW
BEGIN
  DECLARE v_sucursal INT;
  DECLARE v_cliente  INT;
  DECLARE v_subtotal DECIMAL(10,2);
  DECLARE v_desc_pct DECIMAL(4,2) DEFAULT 0;

  SELECT id_sucursal, id_cliente INTO v_sucursal, v_cliente
    FROM ventas WHERE id_venta = NEW.id_venta;

  UPDATE inventario
     SET existencia = existencia - NEW.cantidad
   WHERE id_sucursal = v_sucursal AND id_producto = NEW.id_producto;

  SELECT SUM(cantidad * precio_unitario) INTO v_subtotal
    FROM detalle_venta WHERE id_venta = NEW.id_venta;

  IF v_cliente IS NOT NULL THEN
    SELECT IF(membresia = 'Pro', 0.10, 0) INTO v_desc_pct
      FROM clientes WHERE id_cliente = v_cliente;
  END IF;

  UPDATE ventas
     SET subtotal  = v_subtotal,
         descuento = ROUND(v_subtotal * v_desc_pct, 2),
         total     = v_subtotal - ROUND(v_subtotal * v_desc_pct, 2),
         iva       = ROUND((v_subtotal - ROUND(v_subtotal * v_desc_pct, 2)) / 1.16 * 0.16, 2)
   WHERE id_venta = NEW.id_venta;

  IF v_cliente IS NOT NULL THEN
    UPDATE clientes
       SET puntos = puntos + FLOOR(NEW.cantidad * NEW.precio_unitario / 10)
     WHERE id_cliente = v_cliente;
  END IF;
END$$
DELIMITER ;

-- ---------------------------------------------------------------------
-- TRIGGER 3: al recibir un intercambio -> suma el usado al inventario
--            y actualiza lo que se le pagó al cliente
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_di_despues_insertar;
DELIMITER $$
CREATE TRIGGER trg_di_despues_insertar
AFTER INSERT ON detalle_intercambio
FOR EACH ROW
BEGIN
  DECLARE v_sucursal INT;
  SELECT id_sucursal INTO v_sucursal FROM intercambios WHERE id_intercambio = NEW.id_intercambio;

  INSERT INTO inventario (id_sucursal, id_producto, existencia)
  VALUES (v_sucursal, NEW.id_producto, NEW.cantidad)
  ON DUPLICATE KEY UPDATE existencia = existencia + NEW.cantidad;

  UPDATE intercambios
     SET total_pagado = (SELECT SUM(cantidad * valor_unitario)
                           FROM detalle_intercambio WHERE id_intercambio = NEW.id_intercambio)
   WHERE id_intercambio = NEW.id_intercambio;
END$$
DELIMITER ;

-- ---------------------------------------------------------------------
-- PROCEDIMIENTO 1: reporte de ventas por sucursal en un rango de fechas
-- Uso: CALL sp_reporte_ventas('2026-11-01', '2026-11-30');
-- ---------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_reporte_ventas;
DELIMITER $$
CREATE PROCEDURE sp_reporte_ventas(IN p_inicio DATE, IN p_fin DATE)
BEGIN
  SELECT s.nombre AS sucursal,
         COUNT(v.id_venta)          AS num_ventas,
         IFNULL(SUM(v.total), 0)    AS total_vendido,
         IFNULL(ROUND(AVG(v.total), 2), 0) AS ticket_promedio
    FROM sucursales s
    LEFT JOIN ventas v ON v.id_sucursal = s.id_sucursal
                      AND DATE(v.fecha) BETWEEN p_inicio AND p_fin
   GROUP BY s.id_sucursal, s.nombre
   ORDER BY total_vendido DESC;
END$$
DELIMITER ;

-- ---------------------------------------------------------------------
-- PROCEDIMIENTO 2: productos por debajo del stock mínimo en una sucursal
-- Uso: CALL sp_bajo_stock(1);
-- ---------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_bajo_stock;
DELIMITER $$
CREATE PROCEDURE sp_bajo_stock(IN p_id_sucursal INT)
BEGIN
  SELECT p.sku, p.nombre, p.condicion, i.existencia, i.stock_minimo
    FROM inventario i
    JOIN productos p ON p.id_producto = i.id_producto
   WHERE i.id_sucursal = p_id_sucursal
     AND i.existencia <= i.stock_minimo
   ORDER BY i.existencia;
END$$
DELIMITER ;

-- ---------------------------------------------------------------------
-- PROCEDIMIENTO 3: historial de compras de un cliente
-- Uso: CALL sp_historial_cliente('mariana.lopez@correo.com');
-- ---------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_historial_cliente;
DELIMITER $$
CREATE PROCEDURE sp_historial_cliente(IN p_correo VARCHAR(120))
BEGIN
  SELECT v.id_venta, v.fecha, s.nombre AS sucursal, p.nombre AS producto,
         d.cantidad, d.precio_unitario, v.total AS total_ticket
    FROM clientes c
    JOIN ventas v        ON v.id_cliente  = c.id_cliente
    JOIN sucursales s    ON s.id_sucursal = v.id_sucursal
    JOIN detalle_venta d ON d.id_venta    = v.id_venta
    JOIN productos p     ON p.id_producto = d.id_producto
   WHERE c.correo = p_correo
   ORDER BY v.fecha DESC;
END$$
DELIMITER ;
