SET NAMES utf8mb4;

USE gamestop_usa;

  
-- Procedimiento auxiliar: ejecuta una sentencia y reporta si pasó o
-- con qué mensaje fue rechazada.
  
DROP PROCEDURE IF EXISTS sp_probar;
DELIMITER $$
CREATE PROCEDURE sp_probar(IN p_prueba VARCHAR(200), IN p_sentencia TEXT)
BEGIN
  DECLARE v_msg  TEXT;
  DECLARE v_code INT;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    GET DIAGNOSTICS CONDITION 1 v_code = MYSQL_ERRNO, v_msg = MESSAGE_TEXT;
    SELECT p_prueba AS prueba, 'RECHAZADA' AS resultado, CONCAT('[', v_code, '] ', v_msg) AS mensaje;
  END;

  SET @sentencia_prueba = p_sentencia;
  PREPARE stmt FROM @sentencia_prueba;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;
  SELECT p_prueba AS prueba, 'ACEPTADA' AS resultado, '' AS mensaje;
END$$
DELIMITER ;

-- Datos de apoyo para las pruebas
SELECT id_venta INTO @venta_octubre  FROM ventas WHERE fecha < '2026-10-05' ORDER BY id_venta LIMIT 1;
SELECT id_venta INTO @venta_reciente FROM ventas
 WHERE fecha >= '2026-11-20' AND estado = 'Completada' ORDER BY id_venta LIMIT 1;
SELECT id_producto, cantidad INTO @prod_reciente, @cant_reciente
  FROM detalle_venta WHERE id_venta = @venta_reciente ORDER BY id_producto LIMIT 1;
SELECT id_cliente INTO @cliente_sin_credito FROM clientes WHERE credito_tienda = 0 ORDER BY id_cliente LIMIT 1;

 
-- 1. REGLAS QUE DEBEN RECHAZAR OPERACIONES
 

-- 1.1 Vender más piezas de las que hay en la tienda (trigger)
CALL sp_probar('1.1 Vender 500 PS5 en una tienda',
  'CALL sp_registrar_venta(1, 3, NULL, ''Efectivo'', ''[{"sku":"CON-PS5-SLM","cantidad":500}]'', @x)');

-- 1.2 Vender un producto descontinuado (trigger)
CALL sp_probar('1.2 Vender un producto descontinuado',
  'CALL sp_registrar_venta(1, 3, NULL, ''Efectivo'', ''[{"sku":"VJ-PS4-FIFA23","cantidad":1}]'', @x)');

-- 1.3 Pagar con crédito en tienda sin tener saldo (trigger)
SET @s = CONCAT('CALL sp_registrar_venta(1, 3, ', @cliente_sin_credito,
                ', ''Crédito en tienda'', ''[{"sku":"VJ-PS5-GTA6","cantidad":1}]'', @x)');
CALL sp_probar('1.3 Pagar con crédito en tienda sin saldo', @s);

-- 1.4 Venta con un SKU que no existe: la TRANSACCIÓN se deshace completa
SELECT COUNT(*) INTO @ventas_antes FROM ventas;
CALL sp_probar('1.4 Venta con un SKU inexistente (rollback)',
  'CALL sp_registrar_venta(1, 3, NULL, ''Efectivo'', ''[{"sku":"ACC-PS5-DS","cantidad":1},{"sku":"NO-EXISTE","cantidad":1}]'', @x)');
SELECT @ventas_antes AS ventas_antes, COUNT(*) AS ventas_despues,
       IF(@ventas_antes = COUNT(*), 'Correcto: no quedó ninguna venta a medias', 'ERROR') AS verificacion
  FROM ventas;

-- 1.5 Un empleado vendiendo en una tienda donde no trabaja (procedimiento)
CALL sp_probar('1.5 Empleado de otra tienda',
  'CALL sp_registrar_venta(2, 3, NULL, ''Efectivo'', ''[{"sku":"ACC-PS5-DS","cantidad":1}]'', @x)');

-- 1.6 Devolver más piezas de las compradas (trigger)
INSERT INTO devoluciones (id_venta, fecha, id_empleado, motivo)
SELECT @venta_reciente, '2026-11-23 19:00:00', id_empleado, 'No le gustó' FROM ventas WHERE id_venta = @venta_reciente;
SET @dev_prueba = LAST_INSERT_ID();
SET @s = CONCAT('INSERT INTO detalle_devolucion VALUES (', @dev_prueba, ', ', @prod_reciente, ', ', @cant_reciente + 5, ')');
CALL sp_probar('1.6 Devolver más de lo que se compró', @s);

-- 1.7 Devolver un producto que no estaba en la venta (trigger)
SET @s = CONCAT('INSERT INTO detalle_devolucion VALUES (', @dev_prueba, ', 67, 1)');
CALL sp_probar('1.7 Devolver un producto que no se compró', @s);
DELETE FROM devoluciones WHERE id_devolucion = @dev_prueba;

-- 1.8 Devolución después de 30 días (trigger)
INSERT INTO devoluciones (id_venta, fecha, id_empleado, motivo)
SELECT @venta_octubre, '2026-11-23 19:00:00', id_empleado, 'No le gustó' FROM ventas WHERE id_venta = @venta_octubre;
SET @dev_prueba = LAST_INSERT_ID();
SELECT id_producto INTO @prod_oct FROM detalle_venta WHERE id_venta = @venta_octubre LIMIT 1;
SET @s = CONCAT('INSERT INTO detalle_devolucion VALUES (', @dev_prueba, ', ', @prod_oct, ', 1)');
CALL sp_probar('1.8 Devolución fuera de los 30 días', @s);
DELETE FROM devoluciones WHERE id_devolucion = @dev_prueba;

-- 1.9 Recibir en intercambio un producto NUEVO (trigger)
INSERT INTO intercambios (fecha, id_sucursal, id_empleado, id_cliente, forma_pago)
VALUES ('2026-11-23 19:00:00', 1, 3, 1, 'Efectivo');
SET @int_prueba = LAST_INSERT_ID();
SET @s = CONCAT('INSERT INTO detalle_intercambio VALUES (', @int_prueba,
                ', (SELECT id_producto FROM productos WHERE sku = ''VJ-PS5-GTA6''), 1, NULL)');
CALL sp_probar('1.9 Intercambiar un juego nuevo', @s);
DELETE FROM intercambios WHERE id_intercambio = @int_prueba;

-- 1.10 Poner un precio por debajo del costo (trigger)
CALL sp_probar('1.10 Precio menor al costo',
  'UPDATE productos SET precio_venta = 10 WHERE sku = ''CON-PS5-PRO''');

-- 1.11 Existencia negativa (CHECK)
CALL sp_probar('1.11 Existencia negativa',
  'UPDATE inventario SET existencia = -1 WHERE id_sucursal = 1 AND id_producto = 1');

-- 1.12 Tienda que no existe (FOREIGN KEY)
CALL sp_probar('1.12 Venta en una tienda inexistente',
  'INSERT INTO ventas (id_sucursal, id_empleado, metodo_pago) VALUES (999, 3, ''Efectivo'')');

-- 1.13 Correo de cliente duplicado (UNIQUE)
SET @s = CONCAT('INSERT INTO clientes (nombre, apellido, correo, id_estado, fecha_registro) VALUES (''Test'', ''Test'', ''',
                (SELECT correo FROM clientes WHERE id_cliente = 1), ''', 1, ''2026-11-23'')');
CALL sp_probar('1.13 Correo duplicado', @s);

-- 1.14 Salario por debajo del mínimo federal (CHECK)
CALL sp_probar('1.14 Salario menor a $7.25 la hora',
  'UPDATE empleados SET salario_hora = 5 WHERE id_empleado = 3');

-- 1.15 Borrar una tienda con historial (FOREIGN KEY protege el historial)
CALL sp_probar('1.15 Borrar una tienda con ventas', 'DELETE FROM sucursales WHERE id_sucursal = 1');

-- 1.16 Recibir una orden que ya se recibió (procedimiento)
CALL sp_probar('1.16 Recibir dos veces la misma orden', 'CALL sp_recibir_orden(1, ''2026-11-23'')');

-- 1.17 Transferir más inventario del que hay (procedimiento con transacción)
CALL sp_probar('1.17 Transferir 300 consolas', 'CALL sp_transferir_inventario(1, 2, ''CON-PS5-SLM'', 300)');

 
-- 2. OPERACIONES VÁLIDAS (deben ACEPTARSE y actualizar todo en cadena)
 

-- 2.1 Venta completa con sp_registrar_venta: cliente Pro comprando un juego usado
SELECT c.id_cliente, c.puntos, c.credito_tienda INTO @cli_pro, @puntos_antes, @credito_antes
  FROM clientes c WHERE fn_es_pro(c.id_cliente, CURDATE()) ORDER BY c.id_cliente LIMIT 1;
SELECT existencia INTO @stock_antes FROM inventario
 WHERE id_sucursal = 1 AND id_producto = (SELECT id_producto FROM productos WHERE sku = 'VJ-PS4-GTAV-U');

CALL sp_registrar_venta(1, 3, @cli_pro, 'Tarjeta de crédito',
     '[{"sku":"VJ-PS4-GTAV-U","cantidad":1},{"sku":"COL-PKM-BOOST","cantidad":3}]', @nueva_venta);

SELECT * FROM v_tickets WHERE id_venta = @nueva_venta;
SELECT p.nombre, d.cantidad, d.precio_unitario, d.descuento AS descuento_pro
  FROM detalle_venta d JOIN productos p ON p.id_producto = d.id_producto WHERE d.id_venta = @nueva_venta;
SELECT @stock_antes AS existencia_antes, i.existencia AS existencia_despues,
       @puntos_antes AS puntos_antes, c.puntos AS puntos_despues
  FROM inventario i, clientes c
 WHERE i.id_sucursal = 1 AND i.id_producto = (SELECT id_producto FROM productos WHERE sku = 'VJ-PS4-GTAV-U')
   AND c.id_cliente = @cli_pro;

-- 2.2 Transferencia válida entre tiendas
SELECT i.id_sucursal, i.existencia FROM inventario i JOIN productos p ON p.id_producto = i.id_producto
 WHERE p.sku = 'CON-NS2-STD' AND i.id_sucursal IN (1, 2);
CALL sp_transferir_inventario(1, 2, 'CON-NS2-STD', 1);
SELECT i.id_sucursal, i.existencia FROM inventario i JOIN productos p ON p.id_producto = i.id_producto
 WHERE p.sku = 'CON-NS2-STD' AND i.id_sucursal IN (1, 2);

-- 2.3 Generar órdenes de reabasto automáticas (cursor) para Grapevine Mills
CALL sp_generar_reabasto(1, 3, CURDATE());
SELECT oc.id_orden, pr.nombre AS proveedor, oc.estado, oc.total, COUNT(d.id_producto) AS productos
  FROM ordenes_compra oc
  JOIN proveedores pr ON pr.id_proveedor = oc.id_proveedor
  JOIN detalle_orden_compra d ON d.id_orden = oc.id_orden
 WHERE oc.id_sucursal = 1 AND oc.estado = 'Pendiente'
 GROUP BY oc.id_orden, pr.nombre, oc.estado, oc.total;

-- 2.4 Renovar GameStop Pro a un cliente con la membresía vencida
SELECT id_cliente INTO @cli_vencido FROM clientes
 WHERE id_nivel = 2 AND vencimiento_membresia < CURDATE() ORDER BY id_cliente LIMIT 1;
CALL sp_renovar_pro(@cli_vencido, CURDATE());

-- 2.5 Ofertas: 10% de descuento en todos los accesorios de Xbox (se registran en la bitácora)
CALL sp_ajustar_precios('Accesorio', 'Xbox Series X|S', -10);
SELECT * FROM bitacora_precios ORDER BY id_bitacora DESC LIMIT 3;

 
-- 3. TRANSACCIÓN MANUAL CON ROLLBACK
--    Se suben todos los precios 50% "por error" y se deshace.
 
SELECT SUM(precio_venta) INTO @suma_precios FROM productos;
START TRANSACTION;
  UPDATE productos SET precio_venta = precio_venta * 1.5
   WHERE id_producto > 0;   -- WHERE con llave: requerido por el "Safe Updates" de Workbench
  SELECT SUM(precio_venta) AS suma_dentro_de_la_transaccion FROM productos;
ROLLBACK;
SELECT @suma_precios AS suma_original, SUM(precio_venta) AS suma_despues_del_rollback,
       IF(@suma_precios = SUM(precio_venta), 'Correcto: el ROLLBACK deshizo el cambio', 'ERROR') AS verificacion
  FROM productos;
-- (los registros que el trigger escribió en la bitácora también se deshicieron)
