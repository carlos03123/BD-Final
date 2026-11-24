-- =====================================================================
--  Archivo 5 de 8: vistas
-- =====================================================================

SET NAMES utf8mb4;

USE gamestop_usa;

-- Catálogo con categoría, plataforma, géneros y existencia en toda la cadena
CREATE OR REPLACE VIEW v_catalogo AS
SELECT p.id_producto, p.sku, p.nombre, c.nombre AS categoria,
       IFNULL(pl.nombre, '-') AS plataforma, p.condicion, p.clasificacion_esrb,
       p.precio_venta, p.costo,
       ROUND((p.precio_venta - p.costo) / p.precio_venta * 100, 1) AS margen_pct,
       (SELECT GROUP_CONCAT(g.nombre ORDER BY g.nombre SEPARATOR ', ')
          FROM producto_genero pg JOIN generos g ON g.id_genero = pg.id_genero
         WHERE pg.id_producto = p.id_producto) AS generos,
       (SELECT IFNULL(SUM(i.existencia), 0)
          FROM inventario i WHERE i.id_producto = p.id_producto) AS existencia_total,
       p.activo
  FROM productos p
  JOIN categorias c        ON c.id_categoria   = p.id_categoria
  LEFT JOIN plataformas pl ON pl.id_plataforma = p.id_plataforma;

-- Ticket de cada venta con tienda, estado, vendedor y cliente
CREATE OR REPLACE VIEW v_tickets AS
SELECT v.id_venta, v.fecha, s.numero_tienda, s.nombre AS tienda, e.abreviatura AS estado_eua,
       CONCAT(em.nombre, ' ', em.apellido) AS vendedor,
       IFNULL(CONCAT(c.nombre, ' ', c.apellido), 'Cliente no registrado') AS cliente,
       v.metodo_pago, v.subtotal, v.descuento, v.impuesto, v.total, v.estado
  FROM ventas v
  JOIN sucursales s    ON s.id_sucursal  = v.id_sucursal
  JOIN estados e       ON e.id_estado    = s.id_estado
  JOIN empleados em    ON em.id_empleado = v.id_empleado
  LEFT JOIN clientes c ON c.id_cliente   = v.id_cliente;

-- Unidades e ingreso NETO por producto (descontando devoluciones)
CREATE OR REPLACE VIEW v_ventas_producto AS
SELECT p.id_producto, p.sku, p.nombre, cat.nombre AS categoria, p.condicion,
       SUM(d.cantidad) - IFNULL(dev.devueltas, 0)                       AS unidades_netas,
       ROUND(SUM(d.cantidad * d.precio_unitario - d.descuento)
             - IFNULL(dev.monto_devuelto, 0), 2)                          AS ingreso_neto,
       ROUND(SUM(d.cantidad * d.precio_unitario - d.descuento)
             - IFNULL(dev.monto_devuelto, 0)
             - (SUM(d.cantidad) - IFNULL(dev.devueltas, 0)) * p.costo, 2) AS utilidad_bruta
  FROM detalle_venta d
  JOIN productos  p   ON p.id_producto    = d.id_producto
  JOIN categorias cat ON cat.id_categoria = p.id_categoria
  LEFT JOIN (SELECT dd.id_producto,
                    SUM(dd.cantidad) AS devueltas,
                    SUM(dd.cantidad * dv.precio_unitario - dv.descuento * dd.cantidad / dv.cantidad) AS monto_devuelto
               FROM detalle_devolucion dd
               JOIN devoluciones de  ON de.id_devolucion = dd.id_devolucion
               JOIN detalle_venta dv ON dv.id_venta = de.id_venta AND dv.id_producto = dd.id_producto
              GROUP BY dd.id_producto) dev ON dev.id_producto = p.id_producto
 GROUP BY p.id_producto, p.sku, p.nombre, cat.nombre, p.condicion, p.costo, dev.devueltas, dev.monto_devuelto;

-- Valor del inventario de cada tienda (a costo y a precio de venta)
CREATE OR REPLACE VIEW v_inventario_valorizado AS
SELECT s.numero_tienda, s.nombre AS tienda, e.abreviatura AS estado_eua,
       SUM(i.existencia)                  AS piezas,
       SUM(i.existencia * p.costo)        AS valor_costo,
       SUM(i.existencia * p.precio_venta) AS valor_venta,
       SUM(i.existencia <= i.stock_minimo AND p.activo) AS productos_bajo_minimo
  FROM inventario i
  JOIN sucursales s ON s.id_sucursal = i.id_sucursal
  JOIN estados e    ON e.id_estado   = s.id_estado
  JOIN productos p  ON p.id_producto = i.id_producto
 GROUP BY s.id_sucursal, s.numero_tienda, s.nombre, e.abreviatura;

-- Resumen de cada cliente: compras, gasto, puntos, crédito y si es Pro vigente
CREATE OR REPLACE VIEW v_clientes_resumen AS
SELECT c.id_cliente, CONCAT(c.nombre, ' ', c.apellido) AS cliente, c.correo,
       e.abreviatura AS estado_eua, n.nombre AS nivel,
       fn_es_pro(c.id_cliente, '2026-11-23') AS pro_vigente,
       c.vencimiento_membresia, c.puntos, c.credito_tienda,
       COUNT(v.id_venta)          AS compras,
       IFNULL(SUM(v.total), 0)    AS total_gastado,
       MAX(v.fecha)               AS ultima_compra
  FROM clientes c
  JOIN estados e            ON e.id_estado = c.id_estado
  JOIN niveles_membresia n  ON n.id_nivel  = c.id_nivel
  LEFT JOIN ventas v        ON v.id_cliente = c.id_cliente
 GROUP BY c.id_cliente, cliente, c.correo, e.abreviatura, n.nombre,
          c.vencimiento_membresia, c.puntos, c.credito_tienda;

-- Organigrama: cada empleado con su tienda y su jefe directo (auto-relación)
CREATE OR REPLACE VIEW v_organigrama AS
SELECT e.id_empleado, CONCAT(e.nombre, ' ', e.apellido) AS empleado, e.puesto,
       s.nombre AS tienda, e.salario_hora,
       fn_antiguedad(e.id_empleado, '2026-11-23') AS anios_antiguedad,
       IFNULL(CONCAT(j.nombre, ' ', j.apellido), '-') AS jefe_directo,
       IFNULL(j.puesto, '-') AS puesto_jefe
  FROM empleados e
  JOIN sucursales s     ON s.id_sucursal = e.id_sucursal
  LEFT JOIN empleados j ON j.id_empleado = e.id_supervisor;

-- Ventas diarias de toda la cadena
CREATE OR REPLACE VIEW v_ventas_diarias AS
SELECT DATE(fecha) AS dia, COUNT(*) AS tickets,
       SUM(subtotal - descuento) AS ventas_netas, SUM(impuesto) AS impuesto, SUM(total) AS total
  FROM ventas
 GROUP BY DATE(fecha);
