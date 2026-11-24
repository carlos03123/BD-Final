-- =====================================================================
--  Archivo 2 de 8: funciones y triggers
--  Se crean ANTES de cargar los datos para que cada venta, devolución
--  e intercambio de ejemplo actualice inventario, importes y puntos.
-- =====================================================================

SET NAMES utf8mb4;

USE gamestop_usa;

-- =====================================================================
-- FUNCIONES
-- =====================================================================

-- Tasa de impuesto del estado donde está la tienda
DROP FUNCTION IF EXISTS fn_tasa_impuesto;
DELIMITER $$
CREATE FUNCTION fn_tasa_impuesto(p_id_sucursal INT)
RETURNS DECIMAL(5,4)
READS SQL DATA
BEGIN
  DECLARE v_tasa DECIMAL(5,4);
  SELECT e.tasa_impuesto INTO v_tasa
    FROM sucursales s JOIN estados e ON e.id_estado = s.id_estado
   WHERE s.id_sucursal = p_id_sucursal;
  RETURN IFNULL(v_tasa, 0);
END$$
DELIMITER ;

-- ¿El cliente tiene membresía de pago vigente en esa fecha?
DROP FUNCTION IF EXISTS fn_es_pro;
DELIMITER $$
CREATE FUNCTION fn_es_pro(p_id_cliente INT, p_fecha DATE)
RETURNS BOOLEAN
READS SQL DATA
BEGIN
  DECLARE v_resultado BOOLEAN DEFAULT FALSE;
  SELECT (n.costo_anual > 0 AND c.vencimiento_membresia >= p_fecha) INTO v_resultado
    FROM clientes c JOIN niveles_membresia n ON n.id_nivel = c.id_nivel
   WHERE c.id_cliente = p_id_cliente;
  RETURN IFNULL(v_resultado, FALSE);
END$$
DELIMITER ;

-- Cuánto paga la tienda por un artículo usado:
-- 25% del precio de venta en efectivo, 35% en crédito en tienda,
-- y los miembros Pro reciben un bono extra cuando eligen crédito.
DROP FUNCTION IF EXISTS fn_valor_intercambio;
DELIMITER $$
CREATE FUNCTION fn_valor_intercambio(p_id_producto INT, p_forma_pago VARCHAR(20),
                                     p_id_cliente INT, p_fecha DATE)
RETURNS DECIMAL(8,2)
READS SQL DATA
BEGIN
  DECLARE v_precio DECIMAL(8,2);
  DECLARE v_pct    DECIMAL(6,4);
  DECLARE v_bono   DECIMAL(4,2) DEFAULT 0;

  SELECT precio_venta INTO v_precio FROM productos WHERE id_producto = p_id_producto;
  SET v_pct = IF(p_forma_pago = 'Crédito en tienda', 0.35, 0.25);

  IF p_forma_pago = 'Crédito en tienda' AND fn_es_pro(p_id_cliente, p_fecha) THEN
    SELECT n.bono_intercambio_pct INTO v_bono
      FROM clientes c JOIN niveles_membresia n ON n.id_nivel = c.id_nivel
     WHERE c.id_cliente = p_id_cliente;
  END IF;

  RETURN ROUND(v_precio * v_pct * (1 + v_bono / 100), 2);
END$$
DELIMITER ;

-- Años completos que lleva trabajando un empleado
DROP FUNCTION IF EXISTS fn_antiguedad;
DELIMITER $$
CREATE FUNCTION fn_antiguedad(p_id_empleado INT, p_fecha DATE)
RETURNS INT
READS SQL DATA
BEGIN
  DECLARE v_contratacion DATE;
  SELECT fecha_contratacion INTO v_contratacion FROM empleados WHERE id_empleado = p_id_empleado;
  RETURN TIMESTAMPDIFF(YEAR, v_contratacion, p_fecha);
END$$
DELIMITER ;

-- =====================================================================
-- TRIGGERS DE VENTAS
-- =====================================================================

-- Antes de agregar un renglón: precio del catálogo, descuento Pro,
-- y validaciones de existencia y crédito en tienda.
DROP TRIGGER IF EXISTS trg_detalle_venta_bi;
DELIMITER $$
CREATE TRIGGER trg_detalle_venta_bi
BEFORE INSERT ON detalle_venta
FOR EACH ROW
BEGIN
  DECLARE v_sucursal  INT;
  DECLARE v_cliente   INT;
  DECLARE v_fecha     DATE;
  DECLARE v_metodo    VARCHAR(20);
  DECLARE v_stock     INT;
  DECLARE v_condicion VARCHAR(20);
  DECLARE v_precio    DECIMAL(8,2);
  DECLARE v_activo    BOOLEAN;
  DECLARE v_desc_pct  DECIMAL(4,2) DEFAULT 0;
  DECLARE v_credito   DECIMAL(9,2);

  SELECT id_sucursal, id_cliente, DATE(fecha), metodo_pago
    INTO v_sucursal, v_cliente, v_fecha, v_metodo
    FROM ventas WHERE id_venta = NEW.id_venta;

  SELECT condicion, precio_venta, activo INTO v_condicion, v_precio, v_activo
    FROM productos WHERE id_producto = NEW.id_producto;

  IF NOT v_activo THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El producto está descontinuado';
  END IF;

  SELECT existencia INTO v_stock
    FROM inventario WHERE id_sucursal = v_sucursal AND id_producto = NEW.id_producto;
  IF v_stock IS NULL OR v_stock < NEW.cantidad THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay existencia suficiente en la tienda';
  END IF;

  IF NEW.precio_unitario IS NULL THEN
    SET NEW.precio_unitario = v_precio;
  END IF;

  -- GameStop Pro: descuento en artículos usados o reacondicionados
  IF v_cliente IS NOT NULL AND v_condicion <> 'Nuevo' AND fn_es_pro(v_cliente, v_fecha) THEN
    SELECT n.descuento_usados_pct INTO v_desc_pct
      FROM clientes c JOIN niveles_membresia n ON n.id_nivel = c.id_nivel
     WHERE c.id_cliente = v_cliente;
  END IF;
  SET NEW.descuento = ROUND(NEW.cantidad * NEW.precio_unitario * v_desc_pct / 100, 2);

  -- Pago con crédito en tienda: debe alcanzar el saldo
  IF v_metodo = 'Crédito en tienda' THEN
    IF v_cliente IS NULL THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El crédito en tienda requiere un cliente registrado';
    END IF;
    SELECT credito_tienda INTO v_credito FROM clientes WHERE id_cliente = v_cliente;
    IF v_credito < ROUND((NEW.cantidad * NEW.precio_unitario - NEW.descuento)
                         * (1 + fn_tasa_impuesto(v_sucursal)), 2) THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Crédito en tienda insuficiente';
    END IF;
  END IF;
END$$
DELIMITER ;

-- Después de agregar un renglón: descuenta inventario, recalcula
-- el ticket, suma puntos y cobra el crédito en tienda si aplica.
DROP TRIGGER IF EXISTS trg_detalle_venta_ai;
DELIMITER $$
CREATE TRIGGER trg_detalle_venta_ai
AFTER INSERT ON detalle_venta
FOR EACH ROW
BEGIN
  DECLARE v_sucursal INT;
  DECLARE v_cliente  INT;
  DECLARE v_metodo   VARCHAR(20);
  DECLARE v_tasa     DECIMAL(5,4);
  DECLARE v_neto     DECIMAL(10,2);

  SELECT id_sucursal, id_cliente, metodo_pago INTO v_sucursal, v_cliente, v_metodo
    FROM ventas WHERE id_venta = NEW.id_venta;
  SET v_tasa = fn_tasa_impuesto(v_sucursal);
  SET v_neto = NEW.cantidad * NEW.precio_unitario - NEW.descuento;

  UPDATE inventario
     SET existencia = existencia - NEW.cantidad
   WHERE id_sucursal = v_sucursal AND id_producto = NEW.id_producto;

  UPDATE ventas v
    JOIN (SELECT SUM(cantidad * precio_unitario) AS sub, SUM(descuento) AS des
            FROM detalle_venta WHERE id_venta = NEW.id_venta) d
     SET v.subtotal  = d.sub,
         v.descuento = d.des,
         v.impuesto  = ROUND((d.sub - d.des) * v_tasa, 2),
         v.total     = d.sub - d.des + ROUND((d.sub - d.des) * v_tasa, 2)
   WHERE v.id_venta = NEW.id_venta;

  IF v_cliente IS NOT NULL THEN
    UPDATE clientes c
      JOIN niveles_membresia n ON n.id_nivel = c.id_nivel
       SET c.puntos = c.puntos + FLOOR(v_neto * n.puntos_por_dolar),
           c.credito_tienda = c.credito_tienda
                              - IF(v_metodo = 'Crédito en tienda', ROUND(v_neto * (1 + v_tasa), 2), 0)
     WHERE c.id_cliente = v_cliente;
  END IF;
END$$
DELIMITER ;

-- =====================================================================
-- TRIGGERS DE DEVOLUCIONES
-- =====================================================================

-- No se puede devolver más de lo que se compró, ni después de 30 días
DROP TRIGGER IF EXISTS trg_detalle_devolucion_bi;
DELIMITER $$
CREATE TRIGGER trg_detalle_devolucion_bi
BEFORE INSERT ON detalle_devolucion
FOR EACH ROW
BEGIN
  DECLARE v_id_venta  INT;
  DECLARE v_fecha_dev DATETIME;
  DECLARE v_fecha_ven DATETIME;
  DECLARE v_vendido   INT DEFAULT 0;
  DECLARE v_devuelto  INT DEFAULT 0;

  SELECT d.id_venta, d.fecha, v.fecha INTO v_id_venta, v_fecha_dev, v_fecha_ven
    FROM devoluciones d JOIN ventas v ON v.id_venta = d.id_venta
   WHERE d.id_devolucion = NEW.id_devolucion;

  IF DATEDIFF(v_fecha_dev, v_fecha_ven) > 30 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pasaron más de 30 días desde la compra';
  END IF;

  SELECT IFNULL(SUM(cantidad), 0) INTO v_vendido
    FROM detalle_venta WHERE id_venta = v_id_venta AND id_producto = NEW.id_producto;

  SELECT IFNULL(SUM(dd.cantidad), 0) INTO v_devuelto
    FROM detalle_devolucion dd JOIN devoluciones d ON d.id_devolucion = dd.id_devolucion
   WHERE d.id_venta = v_id_venta AND dd.id_producto = NEW.id_producto;

  IF v_vendido = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ese producto no está en la venta';
  END IF;
  IF v_devuelto + NEW.cantidad > v_vendido THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Se intenta devolver más de lo que se compró';
  END IF;
END$$
DELIMITER ;

-- Regresa el producto al inventario, calcula el reembolso (con impuesto),
-- quita los puntos ganados y actualiza el estado de la venta.
DROP TRIGGER IF EXISTS trg_detalle_devolucion_ai;
DELIMITER $$
CREATE TRIGGER trg_detalle_devolucion_ai
AFTER INSERT ON detalle_devolucion
FOR EACH ROW
BEGIN
  DECLARE v_id_venta  INT;
  DECLARE v_sucursal  INT;
  DECLARE v_cliente   INT;
  DECLARE v_metodo    VARCHAR(20);
  DECLARE v_precio    DECIMAL(8,2);
  DECLARE v_desc      DECIMAL(8,2);
  DECLARE v_cant      INT;
  DECLARE v_neto      DECIMAL(10,2);
  DECLARE v_reembolso DECIMAL(10,2);
  DECLARE v_vendidos  INT;
  DECLARE v_devueltos INT;

  SELECT v.id_venta, v.id_sucursal, v.id_cliente, v.metodo_pago
    INTO v_id_venta, v_sucursal, v_cliente, v_metodo
    FROM devoluciones d JOIN ventas v ON v.id_venta = d.id_venta
   WHERE d.id_devolucion = NEW.id_devolucion;

  SELECT precio_unitario, descuento, cantidad INTO v_precio, v_desc, v_cant
    FROM detalle_venta WHERE id_venta = v_id_venta AND id_producto = NEW.id_producto;

  SET v_neto      = ROUND(NEW.cantidad * v_precio - v_desc * NEW.cantidad / v_cant, 2);
  SET v_reembolso = ROUND(v_neto * (1 + fn_tasa_impuesto(v_sucursal)), 2);

  UPDATE inventario SET existencia = existencia + NEW.cantidad
   WHERE id_sucursal = v_sucursal AND id_producto = NEW.id_producto;

  UPDATE devoluciones SET monto_reembolsado = monto_reembolsado + v_reembolso
   WHERE id_devolucion = NEW.id_devolucion;

  IF v_cliente IS NOT NULL THEN
    UPDATE clientes c
      JOIN niveles_membresia n ON n.id_nivel = c.id_nivel
       SET c.puntos = GREATEST(0, c.puntos - FLOOR(v_neto * n.puntos_por_dolar)),
           c.credito_tienda = c.credito_tienda + IF(v_metodo = 'Crédito en tienda', v_reembolso, 0)
     WHERE c.id_cliente = v_cliente;
  END IF;

  SELECT SUM(cantidad) INTO v_vendidos FROM detalle_venta WHERE id_venta = v_id_venta;
  SELECT SUM(dd.cantidad) INTO v_devueltos
    FROM detalle_devolucion dd JOIN devoluciones d ON d.id_devolucion = dd.id_devolucion
   WHERE d.id_venta = v_id_venta;

  UPDATE ventas SET estado = IF(v_devueltos >= v_vendidos, 'Devuelta', 'Devuelta parcial')
   WHERE id_venta = v_id_venta;
END$$
DELIMITER ;

-- =====================================================================
-- TRIGGERS DE INTERCAMBIOS
-- =====================================================================

-- Solo se reciben artículos usados/reacondicionados; si no se manda
-- el valor, se calcula con fn_valor_intercambio.
DROP TRIGGER IF EXISTS trg_detalle_intercambio_bi;
DELIMITER $$
CREATE TRIGGER trg_detalle_intercambio_bi
BEFORE INSERT ON detalle_intercambio
FOR EACH ROW
BEGIN
  DECLARE v_condicion VARCHAR(20);
  DECLARE v_forma     VARCHAR(20);
  DECLARE v_cliente   INT;
  DECLARE v_fecha     DATE;

  SELECT condicion INTO v_condicion FROM productos WHERE id_producto = NEW.id_producto;
  IF v_condicion = 'Nuevo' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'En un intercambio solo entran productos usados o reacondicionados';
  END IF;

  IF NEW.valor_unitario IS NULL THEN
    SELECT forma_pago, id_cliente, DATE(fecha) INTO v_forma, v_cliente, v_fecha
      FROM intercambios WHERE id_intercambio = NEW.id_intercambio;
    SET NEW.valor_unitario = fn_valor_intercambio(NEW.id_producto, v_forma, v_cliente, v_fecha);
  END IF;
END$$
DELIMITER ;

-- Suma el artículo al inventario, acumula el total pagado y, si fue
-- con crédito en tienda, lo abona al saldo del cliente.
DROP TRIGGER IF EXISTS trg_detalle_intercambio_ai;
DELIMITER $$
CREATE TRIGGER trg_detalle_intercambio_ai
AFTER INSERT ON detalle_intercambio
FOR EACH ROW
BEGIN
  DECLARE v_sucursal INT;
  DECLARE v_cliente  INT;
  DECLARE v_forma    VARCHAR(20);
  DECLARE v_monto    DECIMAL(10,2);

  SELECT id_sucursal, id_cliente, forma_pago INTO v_sucursal, v_cliente, v_forma
    FROM intercambios WHERE id_intercambio = NEW.id_intercambio;
  SET v_monto = NEW.cantidad * NEW.valor_unitario;

  INSERT INTO inventario (id_sucursal, id_producto, existencia, stock_minimo)
  VALUES (v_sucursal, NEW.id_producto, NEW.cantidad, 1)
  ON DUPLICATE KEY UPDATE existencia = existencia + NEW.cantidad;

  UPDATE intercambios SET total_pagado = total_pagado + v_monto
   WHERE id_intercambio = NEW.id_intercambio;

  IF v_forma = 'Crédito en tienda' THEN
    UPDATE clientes SET credito_tienda = credito_tienda + v_monto WHERE id_cliente = v_cliente;
  END IF;
END$$
DELIMITER ;

-- =====================================================================
-- TRIGGERS DE COMPRAS Y AUDITORÍA
-- =====================================================================

-- Mantiene el total de la orden de compra
DROP TRIGGER IF EXISTS trg_detalle_orden_ai;
DELIMITER $$
CREATE TRIGGER trg_detalle_orden_ai
AFTER INSERT ON detalle_orden_compra
FOR EACH ROW
BEGIN
  UPDATE ordenes_compra
     SET total = total + NEW.cantidad * NEW.costo_unitario
   WHERE id_orden = NEW.id_orden;
END$$
DELIMITER ;

-- Registra en la bitácora cada cambio de precio.
-- (@fecha_operacion permite fechar cambios históricos al cargar datos)
DROP TRIGGER IF EXISTS trg_productos_au;
DELIMITER $$
CREATE TRIGGER trg_productos_au
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
  IF NEW.precio_venta <> OLD.precio_venta THEN
    INSERT INTO bitacora_precios (id_producto, precio_anterior, precio_nuevo, fecha, usuario)
    VALUES (NEW.id_producto, OLD.precio_venta, NEW.precio_venta,
            IFNULL(@fecha_operacion, NOW()), CURRENT_USER());
  END IF;
END$$
DELIMITER ;

-- Un precio no puede quedar por debajo del costo
DROP TRIGGER IF EXISTS trg_productos_bu;
DELIMITER $$
CREATE TRIGGER trg_productos_bu
BEFORE UPDATE ON productos
FOR EACH ROW
BEGIN
  IF NEW.precio_venta < NEW.costo THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El precio de venta no puede ser menor al costo';
  END IF;
END$$
DELIMITER ;
