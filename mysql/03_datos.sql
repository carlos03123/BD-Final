-- =====================================================================
--  Archivo 3 de 4: datos de ejemplo
--  Ejecutar después de 02_triggers_procedimientos.sql
--  (precios en pesos mexicanos, con IVA incluido)
-- =====================================================================

USE gamestop;

-- ---------------------------------------------------------------------
-- Sucursales y empleados
-- ---------------------------------------------------------------------
INSERT INTO sucursales (nombre, direccion, ciudad, estado, telefono, fecha_apertura) VALUES
('GameStop Plaza Río',      'Paseo de los Héroes 96, Zona Río',     'Tijuana',  'Baja California', '664-100-2001', '2015-06-12'),
('GameStop Macroplaza',     'Blvd. Insurgentes 17017, Otay',       'Tijuana',  'Baja California', '664-100-2002', '2018-03-20'),
('GameStop Plaza La Cachanilla', 'Blvd. López Mateos 1306',        'Mexicali', 'Baja California', '686-200-3001', '2016-09-01'),
('GameStop Ensenada Centro', 'Av. Reforma 1025',                    'Ensenada', 'Baja California', '646-300-4001', '2019-11-15');

INSERT INTO empleados (nombre, apellido, puesto, correo, salario_mensual, fecha_contratacion, id_sucursal) VALUES
('Roberto',  'Sánchez',  'Gerente',    'roberto.sanchez@gamestop.mx',  22000, '2015-06-01', 1),
('Fernanda', 'Ruiz',     'Vendedor',   'fernanda.ruiz@gamestop.mx',    11500, '2022-01-10', 1),
('Kevin',    'Morales',  'Vendedor',   'kevin.morales@gamestop.mx',    11500, '2023-05-15', 1),
('Patricia', 'Gómez',    'Gerente',    'patricia.gomez@gamestop.mx',   22000, '2018-03-01', 2),
('Iván',     'Castro',   'Vendedor',   'ivan.castro@gamestop.mx',      11500, '2024-02-05', 2),
('Jorge',    'Hernández','Gerente',    'jorge.hernandez@gamestop.mx',  21000, '2016-08-15', 3),
('Daniela',  'Ortiz',    'Vendedor',   'daniela.ortiz@gamestop.mx',    11000, '2023-10-01', 3),
('Ricardo',  'Flores',   'Gerente',    'ricardo.flores@gamestop.mx',   21000, '2019-11-01', 4),
('Andrea',   'Vargas',   'Vendedor',   'andrea.vargas@gamestop.mx',    11000, '2025-01-20', 4),
('Miguel',   'Torres',   'Subgerente', 'miguel.torres@gamestop.mx',    16000, '2020-07-01', 1);

-- ---------------------------------------------------------------------
-- Clientes
-- ---------------------------------------------------------------------
INSERT INTO clientes (nombre, apellido, correo, telefono, membresia, puntos, fecha_registro) VALUES
('Carlos',   'Ramírez', 'carlos.ramirez@correo.com', '664-555-0101', 'Pro',    1200, '2022-04-10'),
('Mariana',  'López',   'mariana.lopez@correo.com',  '664-555-0102', 'Pro',     850, '2023-01-22'),
('Luis',     'Martínez','luis.martinez@correo.com',  '686-555-0103', 'Básica',  150, '2023-07-03'),
('Sofía',    'García',  'sofia.garcia@correo.com',   '646-555-0104', 'Básica',  300, '2024-02-14'),
('Diego',    'Pérez',   'diego.perez@correo.com',    '664-555-0105', 'Básica',    0, '2024-11-29'),
('Valeria',  'Jiménez', 'valeria.jimenez@correo.com','664-555-0106', 'Pro',    2100, '2021-12-01'),
('Emilio',   'Navarro', 'emilio.navarro@correo.com', '646-555-0107', 'Básica',   40, '2025-06-18'),
('Ximena',   'Rojas',   'ximena.rojas@correo.com',   '664-555-0108', 'Básica',   90, '2025-09-09');

-- ---------------------------------------------------------------------
-- Catálogos
-- ---------------------------------------------------------------------
INSERT INTO categorias (nombre) VALUES
('Videojuego'), ('Consola'), ('Accesorio'), ('Coleccionable'), ('Tarjeta de regalo');

INSERT INTO plataformas (nombre, fabricante) VALUES
('PlayStation 5',     'Sony'),
('Xbox Series X|S',   'Microsoft'),
('Nintendo Switch',   'Nintendo'),
('Nintendo Switch 2', 'Nintendo'),
('PC',                'Varios');

INSERT INTO proveedores (nombre, contacto, telefono, correo) VALUES
('Sony Interactive Entertainment', 'Laura Méndez',   '55-1000-0001', 'ventas@sie.example.com'),
('Microsoft Xbox',                 'Andrés Salinas', '55-1000-0002', 'ventas@xbox.example.com'),
('Nintendo',                       'Kenji Watanabe', '55-1000-0003', 'ventas@nintendo.example.com'),
('Electronic Arts',                'Paola Ríos',     '55-1000-0004', 'ventas@ea.example.com'),
('Activision',                     'Tom Harris',     '55-1000-0005', 'ventas@activision.example.com'),
('Funko',                          'Sara Lee',       '55-1000-0006', 'ventas@funko.example.com'),
('HyperX',                         'Óscar Peña',     '55-1000-0007', 'ventas@hyperx.example.com');

-- ---------------------------------------------------------------------
-- Productos   (categoria: 1 Videojuego, 2 Consola, 3 Accesorio, 4 Coleccionable, 5 Tarjeta)
--             (plataforma: 1 PS5, 2 Xbox, 3 Switch, 4 Switch 2, 5 PC)
-- ---------------------------------------------------------------------
INSERT INTO productos (sku, nombre, id_categoria, id_plataforma, id_proveedor, condicion, clasificacion, precio_venta, costo, fecha_lanzamiento) VALUES
('CON-PS5-SLM', 'Consola PlayStation 5 Slim 1TB',             2, 1, 1,    'Nuevo',           NULL,  9999.00, 8200.00, '2023-11-10'),
('CON-XSX-1TB', 'Consola Xbox Series X 1TB',                  2, 2, 2,    'Nuevo',           NULL, 11999.00, 9900.00, '2020-11-10'),
('CON-NS2-STD', 'Consola Nintendo Switch 2',                  2, 4, 3,    'Nuevo',           NULL,  9499.00, 7900.00, '2025-06-05'),
('CON-NSW-OLR', 'Consola Nintendo Switch OLED (reacondicionada)', 2, 3, NULL, 'Reacondicionado', NULL,  4999.00, 2600.00, '2021-10-08'),
('VJ-PS5-FC26', 'EA Sports FC 26',                            1, 1, 4,    'Nuevo',           'E',   1399.00,  950.00, '2025-09-26'),
('VJ-NS2-MKW',  'Mario Kart World',                           1, 4, 3,    'Nuevo',           'E',   1699.00, 1200.00, '2025-06-05'),
('VJ-PS5-BO7',  'Call of Duty: Black Ops 7',                  1, 1, 5,    'Nuevo',           'M',   1599.00, 1100.00, '2025-11-14'),
('VJ-PS5-ELR-U','Elden Ring (usado)',                         1, 1, NULL, 'Usado',           'M',    649.00,  220.00, '2022-02-25'),
('VJ-NSW-TOTK', 'The Legend of Zelda: Tears of the Kingdom',  1, 3, 3,    'Nuevo',           'E10+',1299.00,  900.00, '2023-05-12'),
('VJ-NSW-MINE', 'Minecraft',                                  1, 3, 2,    'Nuevo',           'E10+', 599.00,  380.00, '2018-06-21'),
('VJ-PS5-GTA-U','Grand Theft Auto V (usado)',                 1, 1, NULL, 'Usado',           'M',    399.00,  120.00, '2022-03-15'),
('VJ-NS2-PLZA', 'Pokémon Legends: Z-A',                       1, 4, 3,    'Nuevo',           'E10+',1299.00,  900.00, '2025-10-16'),
('VJ-XSX-HAL-U','Halo Infinite (usado)',                      1, 2, NULL, 'Usado',           'T',    299.00,   90.00, '2021-12-08'),
('VJ-PS5-SM2',  'Marvel''s Spider-Man 2',                     1, 1, 1,    'Nuevo',           'T',   1199.00,  800.00, '2023-10-20'),
('ACC-PS5-DS',  'Control inalámbrico DualSense',              3, 1, 1,    'Nuevo',           NULL,  1599.00, 1100.00, '2020-11-12'),
('ACC-XSX-CTL', 'Control inalámbrico Xbox',                   3, 2, 2,    'Nuevo',           NULL,  1399.00,  950.00, '2020-11-10'),
('ACC-NS2-PRO', 'Control Pro para Nintendo Switch 2',         3, 4, 3,    'Nuevo',           NULL,  1799.00, 1250.00, '2025-06-05'),
('ACC-HX-CL3',  'Audífonos HyperX Cloud III',                 3, NULL, 7, 'Nuevo',           NULL,  1999.00, 1300.00, '2023-03-01'),
('TAR-PSN-500', 'Tarjeta PlayStation Store $500',             5, 1, 1,    'Nuevo',           NULL,   500.00,  475.00, NULL),
('TAR-ESH-500', 'Tarjeta Nintendo eShop $500',                5, 3, 3,    'Nuevo',           NULL,   500.00,  475.00, NULL),
('COL-FNK-MAR', 'Funko Pop! Mario',                           4, NULL, 6, 'Nuevo',           NULL,   349.00,  180.00, NULL),
('COL-FNK-KRA', 'Funko Pop! Kratos',                          4, NULL, 6, 'Nuevo',           NULL,   349.00,  180.00, NULL),
('COL-AMI-LNK', 'Amiibo Link',                                4, 3, 3,    'Nuevo',           NULL,   399.00,  250.00, '2023-05-12'),
('VJ-PS5-GOY',  'Ghost of Yōtei',                             1, 1, 1,    'Nuevo',           'M',   1599.00, 1100.00, '2025-10-02'),
('VJ-NS2-MP4',  'Metroid Prime 4: Beyond',                    1, 4, 3,    'Nuevo',           'T',   1499.00, 1050.00, '2025-12-04'),
('ACC-PS5-DSE', 'Control DualSense Edición Especial',         3, 1, 1,    'Nuevo',           NULL,  1899.00, 1300.00, '2026-12-12');

-- ---------------------------------------------------------------------
-- Inventario: todos los productos ya lanzados en todas las sucursales
-- (existencia entre 3 y 12, calculada para que varíe por sucursal)
-- ---------------------------------------------------------------------
INSERT INTO inventario (id_sucursal, id_producto, existencia, stock_minimo)
SELECT s.id_sucursal,
       p.id_producto,
       3 + (p.id_producto * 7 + s.id_sucursal * 3) % 10,
       IF(p.id_categoria = 2, 2, 3)
  FROM sucursales s
 CROSS JOIN productos p
 WHERE p.fecha_lanzamiento IS NULL OR p.fecha_lanzamiento <= '2026-11-23';

-- ---------------------------------------------------------------------
-- Ventas  (los triggers calculan subtotal, descuento Pro, IVA, total,
--          descuentan inventario y suman puntos)
-- ---------------------------------------------------------------------
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES
( 1, '2026-11-02 11:15:00', 1,  2, 1,    'Tarjeta'),
( 2, '2026-11-03 17:40:00', 1,  3, NULL, 'Efectivo'),
( 3, '2026-11-05 13:05:00', 2,  5, 2,    'Tarjeta'),
( 4, '2026-11-07 18:20:00', 3,  7, 3,    'Crédito en tienda'),
( 5, '2026-11-08 12:00:00', 4,  9, 4,    'Tarjeta'),
( 6, '2026-11-10 16:45:00', 1,  2, 5,    'Efectivo'),
( 7, '2026-11-12 19:10:00', 2,  5, NULL, 'Tarjeta'),
( 8, '2026-11-14 15:30:00', 1, 10, 6,    'Tarjeta'),
( 9, '2026-11-15 11:50:00', 3,  7, 1,    'Tarjeta'),
(10, '2026-11-18 20:05:00', 4,  9, 7,    'Efectivo'),
(11, '2026-11-20 14:25:00', 1,  3, 8,    'Tarjeta'),
(12, '2026-11-21 17:00:00', 2,  4, 2,    'Crédito en tienda'),
(13, '2026-11-22 12:35:00', 1,  2, NULL, 'Efectivo'),
(14, '2026-11-22 18:55:00', 3,  6, 3,    'Tarjeta');

-- El precio unitario se toma del catálogo al momento de la venta
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario)
SELECT t.id_venta, t.id_producto, t.cantidad, p.precio_venta
  FROM (
        SELECT  1 AS id_venta,  1 AS id_producto, 1 AS cantidad UNION ALL
        SELECT  1, 15, 1 UNION ALL
        SELECT  2, 10, 1 UNION ALL
        SELECT  3,  3, 1 UNION ALL
        SELECT  3,  6, 1 UNION ALL
        SELECT  4,  8, 1 UNION ALL
        SELECT  4, 11, 1 UNION ALL
        SELECT  5,  7, 1 UNION ALL
        SELECT  5, 16, 1 UNION ALL
        SELECT  6, 21, 2 UNION ALL
        SELECT  6, 23, 1 UNION ALL
        SELECT  7, 19, 1 UNION ALL
        SELECT  8, 24, 1 UNION ALL
        SELECT  8, 14, 1 UNION ALL
        SELECT  9, 18, 1 UNION ALL
        SELECT 10,  2, 1 UNION ALL
        SELECT 10, 13, 1 UNION ALL
        SELECT 11, 12, 1 UNION ALL
        SELECT 11, 17, 1 UNION ALL
        SELECT 12, 25, 1 UNION ALL
        SELECT 12, 20, 1 UNION ALL
        SELECT 13,  5, 2 UNION ALL
        SELECT 14,  4, 1 UNION ALL
        SELECT 14,  9, 1
       ) AS t
  JOIN productos p ON p.id_producto = t.id_producto;

-- ---------------------------------------------------------------------
-- Intercambios (el trigger suma los usados al inventario y el total)
-- ---------------------------------------------------------------------
INSERT INTO intercambios (id_intercambio, fecha, id_sucursal, id_empleado, id_cliente, forma_pago) VALUES
(1, '2026-11-04 16:00:00', 1, 2, 5, 'Crédito en tienda'),
(2, '2026-11-09 13:30:00', 3, 7, 3, 'Efectivo'),
(3, '2026-11-16 18:15:00', 2, 5, 2, 'Crédito en tienda');

INSERT INTO detalle_intercambio (id_intercambio, id_producto, cantidad, valor_unitario)
SELECT t.id_intercambio, t.id_producto, t.cantidad, fn_valor_intercambio(t.id_producto, t.forma_pago)
  FROM (
        SELECT 1 AS id_intercambio,  8 AS id_producto, 1 AS cantidad, 'Crédito en tienda' AS forma_pago UNION ALL
        SELECT 1, 11, 1, 'Crédito en tienda' UNION ALL
        SELECT 2, 13, 2, 'Efectivo'          UNION ALL
        SELECT 3,  4, 1, 'Crédito en tienda'
       ) AS t;

-- ---------------------------------------------------------------------
-- Preventas / apartados
-- ---------------------------------------------------------------------
INSERT INTO preventas (fecha, id_cliente, id_producto, id_sucursal, anticipo, estado) VALUES
('2025-10-20', 2, 25, 2, 300.00, 'Entregada'),
('2025-09-15', 8, 12, 1, 300.00, 'Entregada'),
('2026-11-01', 1, 26, 1, 500.00, 'Pendiente'),
('2026-11-11', 6, 26, 1, 500.00, 'Pendiente'),
('2026-11-13', 4, 26, 4, 200.00, 'Pendiente'),
('2026-10-05', 7,  1, 4, 1000.00,'Cancelada');
