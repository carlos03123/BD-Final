SET NAMES utf8mb4;

USE gamestop_usa;

   
-- 1. Registrar una venta completa en una sola transacción.
--    Los artículos se mandan como JSON. Si un artículo falla (sin
--    existencia, sin crédito...), se deshace toda la venta.
--
--    CALL sp_registrar_venta(1, 3, 5, 'Tarjeta de crédito',
--         '[{"sku":"VJ-PS5-GTA6","cantidad":1},{"sku":"ACC-PS5-DS","cantidad":2}]', @id);
--    SELECT @id;
   
DROP PROCEDURE IF EXISTS sp_registrar_venta;
DELIMITER $$
CREATE PROCEDURE sp_registrar_venta(
  IN  p_id_sucursal INT,
  IN  p_id_empleado INT,
  IN  p_id_cliente  INT,
  IN  p_metodo_pago VARCHAR(20),
  IN  p_articulos   JSON,
  OUT p_id_venta    INT)
BEGIN
  DECLARE v_esperados INT;
  DECLARE v_insertados INT;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  IF NOT EXISTS (SELECT 1 FROM empleados
                  WHERE id_empleado = p_id_empleado AND id_sucursal = p_id_sucursal AND activo) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El empleado no trabaja en esa tienda';
  END IF;

  START TRANSACTION;

  INSERT INTO ventas (fecha, id_sucursal, id_empleado, id_cliente, metodo_pago)
  VALUES (NOW(), p_id_sucursal, p_id_empleado, p_id_cliente, p_metodo_pago);
  SET p_id_venta = LAST_INSERT_ID();

  SET v_esperados = JSON_LENGTH(p_articulos);

  INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario)
  SELECT p_id_venta, p.id_producto, j.cantidad, NULL
    FROM JSON_TABLE(p_articulos, '$[*]' COLUMNS (
           sku      VARCHAR(20) PATH '$.sku',
           cantidad INT         PATH '$.cantidad')) AS j
    JOIN productos p ON p.sku = j.sku;

  SET v_insertados = ROW_COUNT();
  IF v_insertados <> v_esperados THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Uno o más SKU no existen en el catálogo';
  END IF;

  COMMIT;
END$$
DELIMITER ;

   
-- 2. Recibir una orden de compra: suma la mercancía al inventario
--    de la tienda y actualiza el costo del producto (transacción).
--    CALL sp_recibir_orden(5, '2026-11-20');
   
DROP PROCEDURE IF EXISTS sp_recibir_orden;
DELIMITER $$
CREATE PROCEDURE sp_recibir_orden(IN p_id_orden INT, IN p_fecha DATE)
BEGIN
  DECLARE v_estado   VARCHAR(20);
  DECLARE v_sucursal INT;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;

  SELECT estado, id_sucursal INTO v_estado, v_sucursal
    FROM ordenes_compra WHERE id_orden = p_id_orden FOR UPDATE;

  IF v_estado IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La orden no existe';
  ELSEIF v_estado <> 'Pendiente' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo se pueden recibir órdenes pendientes';
  END IF;

  INSERT INTO inventario (id_sucursal, id_producto, existencia)
  SELECT * FROM (SELECT v_sucursal AS suc, id_producto AS prod, cantidad AS cant
                   FROM detalle_orden_compra WHERE id_orden = p_id_orden) AS d
  ON DUPLICATE KEY UPDATE existencia = existencia + d.cant;

  UPDATE productos p
    JOIN detalle_orden_compra d ON d.id_producto = p.id_producto
     SET p.costo = d.costo_unitario
   WHERE d.id_orden = p_id_orden AND d.costo_unitario <= p.precio_venta;

  UPDATE ordenes_compra
     SET estado = 'Recibida', fecha_recepcion = IFNULL(p_fecha, CURDATE())
   WHERE id_orden = p_id_orden;

  COMMIT;
END$$
DELIMITER ;

   
-- 3. Generar órdenes de reabasto automáticas para una tienda:
--    recorre (CURSOR) los proveedores con productos bajo el mínimo y
--    crea una orden por proveedor pidiendo lo necesario para llegar
--    al doble del stock mínimo.
--    CALL sp_generar_reabasto(1, 1, '2026-11-23');
   
DROP PROCEDURE IF EXISTS sp_generar_reabasto;
DELIMITER $$
CREATE PROCEDURE sp_generar_reabasto(IN p_id_sucursal INT, IN p_id_empleado INT, IN p_fecha DATE)
BEGIN
  DECLARE v_fin        BOOLEAN DEFAULT FALSE;
  DECLARE v_proveedor  INT;
  DECLARE v_orden      INT;
  DECLARE v_creadas    INT DEFAULT 0;

  DECLARE cur_proveedores CURSOR FOR
    SELECT DISTINCT p.id_proveedor
      FROM inventario i JOIN productos p ON p.id_producto = i.id_producto
     WHERE i.id_sucursal = p_id_sucursal
       AND i.existencia <= i.stock_minimo
       AND p.id_proveedor IS NOT NULL
       AND p.activo
       AND NOT EXISTS (SELECT 1 FROM ordenes_compra oc
                         JOIN detalle_orden_compra d ON d.id_orden = oc.id_orden
                        WHERE oc.id_sucursal = p_id_sucursal AND oc.estado = 'Pendiente'
                          AND d.id_producto = p.id_producto);

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_fin = TRUE;

  OPEN cur_proveedores;
  ciclo: LOOP
    FETCH cur_proveedores INTO v_proveedor;
    IF v_fin THEN LEAVE ciclo; END IF;

    INSERT INTO ordenes_compra (fecha, id_proveedor, id_sucursal, id_empleado)
    VALUES (p_fecha, v_proveedor, p_id_sucursal, p_id_empleado);
    SET v_orden = LAST_INSERT_ID();

    INSERT INTO detalle_orden_compra (id_orden, id_producto, cantidad, costo_unitario)
    SELECT v_orden, p.id_producto, i.stock_minimo * 2 - i.existencia, p.costo
      FROM inventario i JOIN productos p ON p.id_producto = i.id_producto
     WHERE i.id_sucursal = p_id_sucursal
       AND i.existencia <= i.stock_minimo
       AND p.id_proveedor = v_proveedor
       AND p.activo;

    SET v_creadas = v_creadas + 1;
  END LOOP;
  CLOSE cur_proveedores;

  SELECT v_creadas AS ordenes_creadas;
END$$
DELIMITER ;

   
-- 4. Transferir mercancía entre tiendas (transacción con bloqueo)
--    CALL sp_transferir_inventario(1, 2, 'CON-PS5-SLM', 2);
   
DROP PROCEDURE IF EXISTS sp_transferir_inventario;
DELIMITER $$
CREATE PROCEDURE sp_transferir_inventario(IN p_origen INT, IN p_destino INT,
                                          IN p_sku VARCHAR(20), IN p_cantidad INT)
BEGIN
  DECLARE v_producto INT;
  DECLARE v_stock    INT;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  IF p_origen = p_destino OR p_cantidad <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transferencia inválida';
  END IF;

  SELECT id_producto INTO v_producto FROM productos WHERE sku = p_sku;
  IF v_producto IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El SKU no existe';
  END IF;

  START TRANSACTION;

  SELECT existencia INTO v_stock FROM inventario
   WHERE id_sucursal = p_origen AND id_producto = v_producto FOR UPDATE;

  IF IFNULL(v_stock, 0) < p_cantidad THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La tienda de origen no tiene suficiente existencia';
  END IF;

  UPDATE inventario SET existencia = existencia - p_cantidad
   WHERE id_sucursal = p_origen AND id_producto = v_producto;

  INSERT INTO inventario (id_sucursal, id_producto, existencia)
  VALUES (p_destino, v_producto, p_cantidad)
  ON DUPLICATE KEY UPDATE existencia = existencia + p_cantidad;

  COMMIT;
END$$
DELIMITER ;

   
-- 5. Contratar o renovar GameStop Pro por un año
--    CALL sp_renovar_pro(12, '2026-11-23');
   
DROP PROCEDURE IF EXISTS sp_renovar_pro;
DELIMITER $$
CREATE PROCEDURE sp_renovar_pro(IN p_id_cliente INT, IN p_fecha DATE)
BEGIN
  DECLARE v_nivel_pro INT;
  SELECT id_nivel INTO v_nivel_pro FROM niveles_membresia WHERE nombre = 'GameStop Pro';

  UPDATE clientes
     SET id_nivel = v_nivel_pro,
         -- si aún está vigente se suma un año al vencimiento; si no, un año desde hoy
         vencimiento_membresia = DATE_ADD(GREATEST(IFNULL(vencimiento_membresia, p_fecha), p_fecha),
                                          INTERVAL 1 YEAR)
   WHERE id_cliente = p_id_cliente;

  IF ROW_COUNT() = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El cliente no existe';
  END IF;

  SELECT id_cliente, nombre, apellido, vencimiento_membresia
    FROM clientes WHERE id_cliente = p_id_cliente;
END$$
DELIMITER ;

   
-- 6. Cambiar precios de una categoría/plataforma por porcentaje
--    (ej. ofertas de Black Friday). La bitácora se llena por trigger.
--    CALL sp_ajustar_precios('Videojuego', 'PlayStation 5', -20);
   
DROP PROCEDURE IF EXISTS sp_ajustar_precios;
DELIMITER $$
CREATE PROCEDURE sp_ajustar_precios(IN p_categoria VARCHAR(40), IN p_plataforma VARCHAR(40),
                                    IN p_porcentaje DECIMAL(5,2))
BEGIN
  UPDATE productos p
    JOIN categorias c        ON c.id_categoria  = p.id_categoria
    LEFT JOIN plataformas pl ON pl.id_plataforma = p.id_plataforma
     SET p.precio_venta = ROUND(p.precio_venta * (1 + p_porcentaje / 100), 2)
   WHERE c.nombre = p_categoria
     AND (p_plataforma IS NULL OR pl.nombre = p_plataforma)
     AND p.activo
     AND ROUND(p.precio_venta * (1 + p_porcentaje / 100), 2) >= p.costo;

  SELECT ROW_COUNT() AS productos_actualizados;
END$$
DELIMITER ;

   
-- 7. Reporte de ventas por tienda en un rango de fechas
--    CALL sp_reporte_ventas('2026-11-01', '2026-11-30');
   
DROP PROCEDURE IF EXISTS sp_reporte_ventas;
DELIMITER $$
CREATE PROCEDURE sp_reporte_ventas(IN p_inicio DATE, IN p_fin DATE)
BEGIN
  SELECT s.numero_tienda, s.nombre AS tienda, e.abreviatura AS estado,
         COUNT(v.id_venta)                 AS num_ventas,
         IFNULL(SUM(v.subtotal - v.descuento), 0) AS ventas_netas,
         IFNULL(SUM(v.impuesto), 0)        AS impuesto,
         IFNULL(SUM(v.total), 0)           AS total_cobrado,
         IFNULL(ROUND(AVG(v.total), 2), 0) AS ticket_promedio
    FROM sucursales s
    JOIN estados e     ON e.id_estado   = s.id_estado
    LEFT JOIN ventas v ON v.id_sucursal = s.id_sucursal
                      AND v.fecha >= p_inicio AND v.fecha < DATE_ADD(p_fin, INTERVAL 1 DAY)
   GROUP BY s.id_sucursal, s.numero_tienda, s.nombre, e.abreviatura
   ORDER BY total_cobrado DESC;
END$$
DELIMITER ;

   
-- 8. Productos en o debajo del stock mínimo de una tienda
--    CALL sp_bajo_stock(1);
   
DROP PROCEDURE IF EXISTS sp_bajo_stock;
DELIMITER $$
CREATE PROCEDURE sp_bajo_stock(IN p_id_sucursal INT)
BEGIN
  SELECT p.sku, p.nombre, p.condicion, i.existencia, i.stock_minimo,
         IFNULL(pr.nombre, 'Intercambios') AS surtido_por
    FROM inventario i
    JOIN productos p        ON p.id_producto  = i.id_producto
    LEFT JOIN proveedores pr ON pr.id_proveedor = p.id_proveedor
   WHERE i.id_sucursal = p_id_sucursal
     AND i.existencia <= i.stock_minimo
     AND p.activo
   ORDER BY i.existencia, p.nombre;
END$$
DELIMITER ;

   
-- 9. Historial de compras de un cliente
--    CALL sp_historial_cliente('olivia.johnson@email.com');
   
DROP PROCEDURE IF EXISTS sp_historial_cliente;
DELIMITER $$
CREATE PROCEDURE sp_historial_cliente(IN p_correo VARCHAR(120))
BEGIN
  SELECT v.id_venta, v.fecha, s.nombre AS tienda, p.nombre AS producto,
         d.cantidad, d.precio_unitario, d.descuento, v.total AS total_ticket, v.estado
    FROM clientes c
    JOIN ventas v        ON v.id_cliente  = c.id_cliente
    JOIN sucursales s    ON s.id_sucursal = v.id_sucursal
    JOIN detalle_venta d ON d.id_venta    = v.id_venta
    JOIN productos p     ON p.id_producto = d.id_producto
   WHERE c.correo = p_correo
   ORDER BY v.fecha DESC, p.nombre;
END$$
DELIMITER ;
