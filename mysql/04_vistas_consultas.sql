-- =====================================================================
--  Archivo 4 de 4: vistas y consultas de ejemplo
--  Ejecutar después de 03_datos.sql
-- =====================================================================

USE gamestop;

-- ---------------------------------------------------------------------
-- VISTAS
-- ---------------------------------------------------------------------

-- Catálogo con categoría, plataforma y existencia total en la cadena
CREATE OR REPLACE VIEW v_catalogo AS
SELECT p.sku, p.nombre, c.nombre AS categoria,
       IFNULL(pl.nombre, '-') AS plataforma,
       p.condicion, p.precio_venta,
       IFNULL(SUM(i.existencia), 0) AS existencia_total
  FROM productos p
  JOIN categorias c        ON c.id_categoria   = p.id_categoria
  LEFT JOIN plataformas pl ON pl.id_plataforma = p.id_plataforma
  LEFT JOIN inventario i   ON i.id_producto    = p.id_producto
 GROUP BY p.id_producto, p.sku, p.nombre, c.nombre, pl.nombre, p.condicion, p.precio_venta;

-- Ticket de cada venta con sucursal, vendedor y cliente
CREATE OR REPLACE VIEW v_tickets AS
SELECT v.id_venta, v.fecha, s.nombre AS sucursal,
       CONCAT(e.nombre, ' ', e.apellido) AS vendedor,
       IFNULL(CONCAT(c.nombre, ' ', c.apellido), 'Público general') AS cliente,
       v.metodo_pago, v.subtotal, v.descuento, v.iva, v.total
  FROM ventas v
  JOIN sucursales s     ON s.id_sucursal = v.id_sucursal
  JOIN empleados e      ON e.id_empleado = v.id_empleado
  LEFT JOIN clientes c  ON c.id_cliente  = v.id_cliente;

-- Productos más vendidos con su ganancia
CREATE OR REPLACE VIEW v_mas_vendidos AS
SELECT p.nombre, p.condicion,
       SUM(d.cantidad)                                    AS unidades,
       SUM(d.cantidad * d.precio_unitario)                AS ingreso,
       SUM(d.cantidad * (d.precio_unitario - p.costo))    AS ganancia_bruta
  FROM detalle_venta d
  JOIN productos p ON p.id_producto = d.id_producto
 GROUP BY p.id_producto, p.nombre, p.condicion;

-- ---------------------------------------------------------------------
-- CONSULTAS DE EJEMPLO
-- ---------------------------------------------------------------------

-- 1. Catálogo completo
SELECT * FROM v_catalogo ORDER BY categoria, nombre;

-- 2. Todos los tickets del mes
SELECT * FROM v_tickets ORDER BY fecha;

-- 3. Top 5 productos más vendidos
SELECT * FROM v_mas_vendidos ORDER BY unidades DESC, ingreso DESC LIMIT 5;

-- 4. Ventas por sucursal en noviembre 2026 (procedimiento)
CALL sp_reporte_ventas('2026-11-01', '2026-11-30');

-- 5. Ventas por empleado (ranking de vendedores)
SELECT CONCAT(e.nombre, ' ', e.apellido) AS empleado, s.nombre AS sucursal,
       COUNT(v.id_venta) AS ventas, IFNULL(SUM(v.total), 0) AS total_vendido
  FROM empleados e
  JOIN sucursales s  ON s.id_sucursal = e.id_sucursal
  LEFT JOIN ventas v ON v.id_empleado = e.id_empleado
 GROUP BY e.id_empleado, empleado, sucursal
 ORDER BY total_vendido DESC;

-- 6. Ingresos por categoría
SELECT c.nombre AS categoria, SUM(d.cantidad) AS unidades,
       SUM(d.cantidad * d.precio_unitario) AS ingreso
  FROM detalle_venta d
  JOIN productos p  ON p.id_producto  = d.id_producto
  JOIN categorias c ON c.id_categoria = p.id_categoria
 GROUP BY c.nombre ORDER BY ingreso DESC;

-- 7. Clientes Pro vs Básica: cuánto compran
SELECT c.membresia, COUNT(DISTINCT c.id_cliente) AS clientes,
       COUNT(v.id_venta) AS compras, IFNULL(SUM(v.total), 0) AS total_gastado,
       IFNULL(SUM(v.descuento), 0) AS descuentos_otorgados
  FROM clientes c
  LEFT JOIN ventas v ON v.id_cliente = c.id_cliente
 GROUP BY c.membresia;

-- 8. Top clientes por puntos
SELECT CONCAT(nombre, ' ', apellido) AS cliente, membresia, puntos
  FROM clientes ORDER BY puntos DESC LIMIT 5;

-- 9. Intercambios: qué se recibió y cuánto se pagó
SELECT i.id_intercambio, i.fecha, s.nombre AS sucursal,
       CONCAT(c.nombre, ' ', c.apellido) AS cliente, p.nombre AS producto,
       d.cantidad, d.valor_unitario, i.forma_pago, i.total_pagado
  FROM intercambios i
  JOIN sucursales s           ON s.id_sucursal    = i.id_sucursal
  JOIN clientes c             ON c.id_cliente     = i.id_cliente
  JOIN detalle_intercambio d  ON d.id_intercambio = i.id_intercambio
  JOIN productos p            ON p.id_producto    = d.id_producto
 ORDER BY i.fecha;

-- 10. Preventas pendientes y anticipo acumulado
SELECT p.nombre AS producto, p.fecha_lanzamiento, COUNT(*) AS apartados,
       SUM(pr.anticipo) AS anticipos
  FROM preventas pr JOIN productos p ON p.id_producto = pr.id_producto
 WHERE pr.estado = 'Pendiente'
 GROUP BY p.id_producto, p.nombre, p.fecha_lanzamiento;

-- 11. Productos con stock bajo en Plaza Río (procedimiento)
CALL sp_bajo_stock(1);

-- 12. Historial de un cliente (procedimiento)
CALL sp_historial_cliente('mariana.lopez@correo.com');

-- 13. Prueba del trigger de stock: esta venta debe FALLAR
--     (no hay 50 consolas en la sucursal). Descomenta para probar:
-- INSERT INTO ventas (id_sucursal, id_empleado, metodo_pago) VALUES (1, 2, 'Efectivo');
-- INSERT INTO detalle_venta VALUES (LAST_INSERT_ID(), 1, 50, 9999.00);
