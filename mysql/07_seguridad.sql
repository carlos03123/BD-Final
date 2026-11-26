SET NAMES utf8mb4;

USE gamestop_usa;

  
-- Limpieza (para poder ejecutar el script varias veces)
  
DROP USER IF EXISTS 'gs_admin'@'localhost', 'gs_gerente_tx'@'localhost',
                    'gs_vendedor_tx'@'localhost', 'gs_vendedor_ca'@'localhost',
                    'gs_analista'@'localhost';
DROP ROLE IF EXISTS 'rol_admin', 'rol_gerente', 'rol_vendedor', 'rol_analista';

  
-- Roles
  
CREATE ROLE 'rol_admin', 'rol_gerente', 'rol_vendedor', 'rol_analista';

-- Administrador
GRANT ALL PRIVILEGES ON gamestop_usa.* TO 'rol_admin';

-- Gerente: lee todo, da de alta y modifica, pero NO borra
GRANT SELECT, INSERT, UPDATE, EXECUTE ON gamestop_usa.* TO 'rol_gerente';

-- Vendedor: lectura del catálogo y clientes
GRANT SELECT ON gamestop_usa.productos          TO 'rol_vendedor';
GRANT SELECT ON gamestop_usa.categorias         TO 'rol_vendedor';
GRANT SELECT ON gamestop_usa.plataformas        TO 'rol_vendedor';
GRANT SELECT ON gamestop_usa.inventario         TO 'rol_vendedor';
GRANT SELECT ON gamestop_usa.clientes           TO 'rol_vendedor';
GRANT SELECT ON gamestop_usa.niveles_membresia  TO 'rol_vendedor';
GRANT SELECT ON gamestop_usa.v_catalogo         TO 'rol_vendedor';
GRANT SELECT ON gamestop_usa.v_tickets          TO 'rol_vendedor';
GRANT SELECT ON gamestop_usa.ventas             TO 'rol_vendedor';
GRANT SELECT ON gamestop_usa.detalle_venta      TO 'rol_vendedor';
--   ...puede registrar operaciones de mostrador
GRANT INSERT ON gamestop_usa.ventas              TO 'rol_vendedor';
GRANT INSERT ON gamestop_usa.detalle_venta       TO 'rol_vendedor';
GRANT INSERT ON gamestop_usa.intercambios        TO 'rol_vendedor';
GRANT INSERT ON gamestop_usa.detalle_intercambio TO 'rol_vendedor';
GRANT INSERT ON gamestop_usa.devoluciones        TO 'rol_vendedor';
GRANT INSERT ON gamestop_usa.detalle_devolucion  TO 'rol_vendedor';
GRANT INSERT ON gamestop_usa.preventas           TO 'rol_vendedor';
--   ...registrar clientes nuevos y corregir SOLO su teléfono y correo (privilegio por columna)
GRANT INSERT                    ON gamestop_usa.clientes TO 'rol_vendedor';
GRANT UPDATE (telefono, correo) ON gamestop_usa.clientes TO 'rol_vendedor';
--   ...y usar los procedimientos de mostrador
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_registrar_venta   TO 'rol_vendedor';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_historial_cliente TO 'rol_vendedor';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_bajo_stock        TO 'rol_vendedor';

-- Analista: solo vistas y reportes (no ve tablas con datos personales completos)
GRANT SELECT ON gamestop_usa.v_catalogo              TO 'rol_analista';
GRANT SELECT ON gamestop_usa.v_tickets               TO 'rol_analista';
GRANT SELECT ON gamestop_usa.v_ventas_producto       TO 'rol_analista';
GRANT SELECT ON gamestop_usa.v_inventario_valorizado TO 'rol_analista';
GRANT SELECT ON gamestop_usa.v_ventas_diarias        TO 'rol_analista';
GRANT EXECUTE ON PROCEDURE gamestop_usa.sp_reporte_ventas TO 'rol_analista';

  
-- Usuarios
  
CREATE USER 'gs_admin'@'localhost'       IDENTIFIED BY 'Admin#GS2026!';
CREATE USER 'gs_gerente_tx'@'localhost'  IDENTIFIED BY 'Gerente#TX2026!';
CREATE USER 'gs_vendedor_tx'@'localhost' IDENTIFIED BY 'Vendedor#TX2026!';
CREATE USER 'gs_vendedor_ca'@'localhost' IDENTIFIED BY 'Vendedor#CA2026!'
  PASSWORD EXPIRE INTERVAL 90 DAY        -- debe cambiar su contraseña cada 90 días
  FAILED_LOGIN_ATTEMPTS 5 PASSWORD_LOCK_TIME 1;  -- se bloquea 1 día tras 5 intentos fallidos
CREATE USER 'gs_analista'@'localhost'    IDENTIFIED BY 'Analista#2026!';

GRANT 'rol_admin'    TO 'gs_admin'@'localhost';
GRANT 'rol_gerente'  TO 'gs_gerente_tx'@'localhost';
GRANT 'rol_vendedor' TO 'gs_vendedor_tx'@'localhost', 'gs_vendedor_ca'@'localhost';
GRANT 'rol_analista' TO 'gs_analista'@'localhost';

-- Que cada usuario tenga su rol activo al iniciar sesión
SET DEFAULT ROLE ALL TO 'gs_admin'@'localhost', 'gs_gerente_tx'@'localhost',
                        'gs_vendedor_tx'@'localhost', 'gs_vendedor_ca'@'localhost',
                        'gs_analista'@'localhost';

  
-- Verificación
  
SHOW GRANTS FOR 'rol_vendedor';
SHOW GRANTS FOR 'gs_vendedor_tx'@'localhost' USING 'rol_vendedor';
SHOW GRANTS FOR 'gs_analista'@'localhost' USING 'rol_analista';

-- Para probarlo, en MySQL Workbench crea una conexión nueva con el usuario
-- gs_vendedor_tx y verás que:
--   SELECT * FROM productos;                         -> funciona
--   UPDATE productos SET precio_venta = 1;           -> ERROR 1142 (sin permiso)
--   UPDATE clientes SET puntos = 99999;              -> ERROR 1143 (columna no permitida)
--   UPDATE clientes SET telefono = '...' WHERE ...;  -> funciona
--   DELETE FROM ventas;                              -> ERROR 1142 (sin permiso)
