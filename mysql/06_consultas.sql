-- =====================================================================
--  Archivo 6 de 8: consultas
--  30 consultas organizadas de básicas a avanzadas:
--    A. Básicas (SELECT, WHERE, ORDER BY, LIKE, BETWEEN, IN)
--    B. JOINs (INNER, LEFT, auto-JOIN, varias tablas)
--    C. Agregación (GROUP BY, HAVING)
--    D. Subconsultas (IN, EXISTS, NOT EXISTS, correlacionadas)
--    E. Avanzadas (CTE, funciones de ventana, CASE, UNION)
--    F. Vistas y procedimientos
-- =====================================================================

SET NAMES utf8mb4;

USE gamestop_usa;

-- =====================================================================
-- A. CONSULTAS BÁSICAS
-- =====================================================================

-- A1. Tiendas ordenadas por antigüedad
SELECT numero_tienda, nombre, ciudad, fecha_apertura
  FROM sucursales
 ORDER BY fecha_apertura;

-- A2. Videojuegos para mayores (ESRB M) que cuestan menos de $60
SELECT sku, nombre, precio_venta
  FROM productos
 WHERE clasificacion_esrb = 'M' AND precio_venta < 60
 ORDER BY precio_venta;

-- A3. Productos cuyo nombre contiene "Mario"
SELECT sku, nombre, condicion, precio_venta
  FROM productos
 WHERE nombre LIKE '%Mario%';

-- A4. Ventas hechas durante la semana del lanzamiento de GTA VI
SELECT id_venta, fecha, total
  FROM ventas
 WHERE fecha BETWEEN '2026-11-19 00:00:00' AND '2026-11-23 23:59:59'
 ORDER BY fecha;

-- A5. Clientes que viven en Texas, California o Nueva York
SELECT c.nombre, c.apellido, e.abreviatura
  FROM clientes c JOIN estados e ON e.id_estado = c.id_estado
 WHERE e.abreviatura IN ('TX', 'CA', 'NY')
 ORDER BY e.abreviatura, c.apellido;

-- =====================================================================
-- B. JOINs
-- =====================================================================

-- B1. Detalle completo de un ticket (5 tablas)
SELECT v.id_venta, v.fecha, s.nombre AS tienda,
       CONCAT(em.nombre, ' ', em.apellido) AS vendedor,
       p.nombre AS producto, d.cantidad, d.precio_unitario, d.descuento,
       v.subtotal, v.impuesto, v.total
  FROM ventas v
  JOIN sucursales s    ON s.id_sucursal  = v.id_sucursal
  JOIN empleados em    ON em.id_empleado = v.id_empleado
  JOIN detalle_venta d ON d.id_venta     = v.id_venta
  JOIN productos p     ON p.id_producto  = d.id_producto
 WHERE v.id_venta = 250;

-- B2. Todos los productos con su proveedor (LEFT JOIN: los usados no tienen)
SELECT p.sku, p.nombre, p.condicion, IFNULL(pr.nombre, '— intercambio de clientes —') AS proveedor
  FROM productos p
  LEFT JOIN proveedores pr ON pr.id_proveedor = p.id_proveedor
 ORDER BY proveedor, p.nombre;

-- B3. Auto-JOIN: cada empleado con su jefe directo y cuánto menos gana por hora
SELECT CONCAT(e.nombre, ' ', e.apellido) AS empleado, e.puesto, e.salario_hora,
       CONCAT(j.nombre, ' ', j.apellido) AS jefe_directo, j.puesto AS puesto_jefe,
       j.salario_hora - e.salario_hora AS diferencia_por_hora
  FROM empleados e
  JOIN empleados j ON j.id_empleado = e.id_supervisor
 WHERE e.id_sucursal = 1
 ORDER BY j.salario_hora DESC, e.salario_hora DESC;

-- B4. Videojuegos con sus géneros (relación N:M)
SELECT p.nombre, pl.nombre AS plataforma, g.nombre AS genero
  FROM productos p
  JOIN producto_genero pg ON pg.id_producto  = p.id_producto
  JOIN generos g          ON g.id_genero     = pg.id_genero
  JOIN plataformas pl     ON pl.id_plataforma = p.id_plataforma
 ORDER BY p.nombre, g.nombre;

-- B5. Intercambios con lo que se recibió y lo que se pagó
SELECT i.id_intercambio, DATE(i.fecha) AS fecha, s.nombre AS tienda,
       CONCAT(c.nombre, ' ', c.apellido) AS cliente, p.nombre AS articulo,
       di.cantidad, di.valor_unitario, i.forma_pago
  FROM intercambios i
  JOIN sucursales s           ON s.id_sucursal    = i.id_sucursal
  JOIN clientes c             ON c.id_cliente     = i.id_cliente
  JOIN detalle_intercambio di ON di.id_intercambio = i.id_intercambio
  JOIN productos p            ON p.id_producto    = di.id_producto
 ORDER BY i.fecha;

-- =====================================================================
-- C. AGREGACIÓN
-- =====================================================================

-- C1. Ingresos por categoría
SELECT c.nombre AS categoria, SUM(d.cantidad) AS unidades,
       SUM(d.cantidad * d.precio_unitario - d.descuento) AS ingreso
  FROM detalle_venta d
  JOIN productos p  ON p.id_producto  = d.id_producto
  JOIN categorias c ON c.id_categoria = p.id_categoria
 GROUP BY c.nombre
 ORDER BY ingreso DESC;

-- C2. Ventas e impuesto recaudado por estado
SELECT e.nombre AS estado, e.tasa_impuesto, COUNT(v.id_venta) AS tickets,
       SUM(v.subtotal - v.descuento) AS ventas_netas, SUM(v.impuesto) AS impuesto
  FROM ventas v
  JOIN sucursales s ON s.id_sucursal = v.id_sucursal
  JOIN estados e    ON e.id_estado   = s.id_estado
 GROUP BY e.id_estado, e.nombre, e.tasa_impuesto
 ORDER BY ventas_netas DESC;

-- C3. Ventas por plataforma (solo plataformas con más de $1,000 vendidos)
SELECT pl.nombre AS plataforma, SUM(d.cantidad) AS unidades,
       SUM(d.cantidad * d.precio_unitario - d.descuento) AS ingreso
  FROM detalle_venta d
  JOIN productos p    ON p.id_producto    = d.id_producto
  JOIN plataformas pl ON pl.id_plataforma = p.id_plataforma
 GROUP BY pl.nombre
HAVING ingreso > 1000
 ORDER BY ingreso DESC;

-- C4. Ranking de vendedores: tickets, total vendido y ticket promedio
SELECT CONCAT(e.nombre, ' ', e.apellido) AS vendedor, e.puesto, s.nombre AS tienda,
       COUNT(v.id_venta) AS tickets, SUM(v.total) AS total_vendido,
       ROUND(AVG(v.total), 2) AS ticket_promedio
  FROM ventas v
  JOIN empleados e  ON e.id_empleado = v.id_empleado
  JOIN sucursales s ON s.id_sucursal = e.id_sucursal
 GROUP BY e.id_empleado, vendedor, e.puesto, s.nombre
 ORDER BY total_vendido DESC
 LIMIT 10;

-- C5. Métodos de pago más usados
SELECT metodo_pago, COUNT(*) AS tickets, SUM(total) AS total,
       ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM ventas), 1) AS pct_tickets
  FROM ventas
 GROUP BY metodo_pago
 ORDER BY tickets DESC;

-- C6. GameStop Pro vs PowerUp Rewards: ¿quién gasta más?
SELECT n.nombre AS nivel, COUNT(DISTINCT c.id_cliente) AS clientes_que_compraron,
       COUNT(v.id_venta) AS tickets, SUM(v.total) AS total,
       ROUND(SUM(v.total) / COUNT(DISTINCT c.id_cliente), 2) AS gasto_por_cliente,
       SUM(v.descuento) AS descuentos_otorgados
  FROM ventas v
  JOIN clientes c          ON c.id_cliente = v.id_cliente
  JOIN niveles_membresia n ON n.id_nivel   = c.id_nivel
 GROUP BY n.nombre;

-- =====================================================================
-- D. SUBCONSULTAS
-- =====================================================================

-- D1. Productos que NUNCA se han vendido (NOT EXISTS)
SELECT p.sku, p.nombre, p.condicion
  FROM productos p
 WHERE NOT EXISTS (SELECT 1 FROM detalle_venta d WHERE d.id_producto = p.id_producto)
 ORDER BY p.nombre;

-- D2. Clientes que compraron GTA VI (IN con subconsulta)
SELECT nombre, apellido, correo
  FROM clientes
 WHERE id_cliente IN (SELECT v.id_cliente
                        FROM ventas v
                        JOIN detalle_venta d ON d.id_venta = v.id_venta
                        JOIN productos p     ON p.id_producto = d.id_producto
                       WHERE p.nombre LIKE 'Grand Theft Auto VI%');

-- D3. Los 10 tickets más grandes entre los que superan el triple del promedio de su tienda (correlacionada)
SELECT v.id_venta, s.nombre AS tienda, v.total
  FROM ventas v
  JOIN sucursales s ON s.id_sucursal = v.id_sucursal
 WHERE v.total > (SELECT AVG(v2.total) FROM ventas v2 WHERE v2.id_sucursal = v.id_sucursal) * 3
 ORDER BY v.total DESC
 LIMIT 10;

-- D4. Clientes registrados que no han comprado nada en noviembre
SELECT c.nombre, c.apellido, c.correo
  FROM clientes c
 WHERE NOT EXISTS (SELECT 1 FROM ventas v
                    WHERE v.id_cliente = c.id_cliente
                      AND v.fecha >= '2026-11-01');

-- D5. El producto más caro de cada categoría
SELECT c.nombre AS categoria, p.nombre, p.precio_venta
  FROM productos p
  JOIN categorias c ON c.id_categoria = p.id_categoria
 WHERE p.precio_venta = (SELECT MAX(p2.precio_venta) FROM productos p2
                          WHERE p2.id_categoria = p.id_categoria);

-- =====================================================================
-- E. AVANZADAS: CTE, FUNCIONES DE VENTANA, CASE, UNION
-- =====================================================================

-- E1. Top 3 productos más vendidos de CADA tienda (ROW_NUMBER)
WITH ventas_tienda AS (
  SELECT s.nombre AS tienda, p.nombre AS producto, SUM(d.cantidad) AS unidades
    FROM ventas v
    JOIN detalle_venta d ON d.id_venta    = v.id_venta
    JOIN productos p     ON p.id_producto = d.id_producto
    JOIN sucursales s    ON s.id_sucursal = v.id_sucursal
   GROUP BY s.nombre, p.nombre
)
SELECT tienda, producto, unidades
  FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY tienda ORDER BY unidades DESC, producto) AS lugar
          FROM ventas_tienda) t
 WHERE lugar <= 3
 ORDER BY tienda, lugar;

-- E2. Ventas diarias con acumulado del periodo y promedio móvil de 7 días
SELECT dia, total,
       SUM(total) OVER (ORDER BY dia)                                      AS acumulado,
       ROUND(AVG(total) OVER (ORDER BY dia ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS promedio_7_dias
  FROM v_ventas_diarias
 ORDER BY dia;

-- E3. Ranking de tiendas por ventas y diferencia contra la tienda líder (RANK, FIRST_VALUE)
WITH t AS (
  SELECT s.nombre AS tienda, SUM(v.total) AS total
    FROM ventas v JOIN sucursales s ON s.id_sucursal = v.id_sucursal
   GROUP BY s.nombre
)
SELECT RANK() OVER (ORDER BY total DESC) AS lugar, tienda, total,
       FIRST_VALUE(total) OVER (ORDER BY total DESC) - total AS diferencia_con_lider,
       ROUND(total * 100 / SUM(total) OVER (), 1) AS pct_de_la_cadena
  FROM t;

-- E4. Crecimiento de octubre a noviembre por tienda (LAG)
WITH mensual AS (
  SELECT s.nombre AS tienda, DATE_FORMAT(v.fecha, '%Y-%m') AS mes, SUM(v.total) AS total
    FROM ventas v JOIN sucursales s ON s.id_sucursal = v.id_sucursal
   GROUP BY s.nombre, mes
)
SELECT tienda, mes, total,
       LAG(total) OVER (PARTITION BY tienda ORDER BY mes) AS mes_anterior,
       ROUND((total - LAG(total) OVER (PARTITION BY tienda ORDER BY mes))
             / LAG(total) OVER (PARTITION BY tienda ORDER BY mes) * 100, 1) AS crecimiento_pct
  FROM mensual
 ORDER BY tienda, mes;

-- E5. Segmentación de clientes por gasto (CASE + CTE)
WITH gasto AS (
  SELECT c.id_cliente, CONCAT(c.nombre, ' ', c.apellido) AS cliente, IFNULL(SUM(v.total), 0) AS total
    FROM clientes c LEFT JOIN ventas v ON v.id_cliente = c.id_cliente
   GROUP BY c.id_cliente, cliente
)
SELECT CASE
         WHEN total >= 1000 THEN '1. VIP (≥ $1,000)'
         WHEN total >= 300  THEN '2. Frecuente ($300 – $999)'
         WHEN total >  0    THEN '3. Ocasional (< $300)'
         ELSE                    '4. Sin compras'
       END AS segmento,
       COUNT(*) AS clientes, ROUND(SUM(total), 2) AS gasto_total
  FROM gasto
 GROUP BY segmento
 ORDER BY segmento;

-- E6. Movimientos de inventario de un producto en una tienda (UNION ALL)
--     Entradas: compras e intercambios.  Salidas: ventas.  Devoluciones: regresan.
SET @tienda = 1, @sku = 'CON-NS2-STD';
SELECT 'Compra a proveedor' AS movimiento, oc.fecha_recepcion AS fecha, d.cantidad AS piezas
  FROM ordenes_compra oc JOIN detalle_orden_compra d ON d.id_orden = oc.id_orden
 WHERE oc.estado = 'Recibida' AND oc.id_sucursal = @tienda
   AND d.id_producto = (SELECT id_producto FROM productos WHERE sku = @sku)
UNION ALL
SELECT 'Venta', DATE(v.fecha), -d.cantidad
  FROM ventas v JOIN detalle_venta d ON d.id_venta = v.id_venta
 WHERE v.id_sucursal = @tienda AND d.id_producto = (SELECT id_producto FROM productos WHERE sku = @sku)
UNION ALL
SELECT 'Devolución', DATE(de.fecha), dd.cantidad
  FROM devoluciones de
  JOIN detalle_devolucion dd ON dd.id_devolucion = de.id_devolucion
  JOIN ventas v              ON v.id_venta       = de.id_venta
 WHERE v.id_sucursal = @tienda AND dd.id_producto = (SELECT id_producto FROM productos WHERE sku = @sku)
 ORDER BY fecha;

-- E7. Historial de precios con la bitácora de auditoría
SELECT b.fecha, p.nombre, b.precio_anterior, b.precio_nuevo,
       ROUND((b.precio_nuevo - b.precio_anterior) / b.precio_anterior * 100, 1) AS cambio_pct,
       b.usuario
  FROM bitacora_precios b JOIN productos p ON p.id_producto = b.id_producto
 ORDER BY b.fecha, p.nombre;

-- =====================================================================
-- F. VISTAS Y PROCEDIMIENTOS
-- =====================================================================

-- F1. Top 10 productos por utilidad bruta (vista)
SELECT nombre, categoria, unidades_netas, ingreso_neto, utilidad_bruta
  FROM v_ventas_producto
 ORDER BY utilidad_bruta DESC
 LIMIT 10;

-- F2. Valor del inventario por tienda (vista)
SELECT * FROM v_inventario_valorizado ORDER BY valor_venta DESC;

-- F3. Reporte de ventas de noviembre por tienda (procedimiento)
CALL sp_reporte_ventas('2026-11-01', '2026-11-30');

-- F4. Productos bajo el mínimo en Grapevine Mills (procedimiento)
CALL sp_bajo_stock(1);
