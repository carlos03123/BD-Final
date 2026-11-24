-- =====================================================================
--  Archivo 4 de 8: datos de ejemplo
--  Ejecutar después de 03_procedimientos.sql
--
--  Periodo simulado: 1 de octubre al 23 de noviembre de 2026.
--  Precios en dólares (USD). Personas, direcciones, teléfonos y correos
--  son FICTICIOS, creados con fines académicos.
--
--  Las ventas, intercambios, devoluciones y recepciones de mercancía
--  se cargan en orden cronológico: los TRIGGERS calculan importes,
--  impuestos, descuentos, puntos, crédito en tienda e inventario.
-- =====================================================================

SET NAMES utf8mb4;

USE gamestop_usa;
SET @fecha_operacion = NULL;

-- ---------------------------------------------------------------------
-- Estados (tasa de impuesto estatal sobre ventas; no incluye impuestos locales)
-- ---------------------------------------------------------------------
INSERT INTO estados (nombre, abreviatura, tasa_impuesto) VALUES
('Texas', 'TX', 0.0625),
('California', 'CA', 0.0725),
('New York', 'NY', 0.0400),
('Florida', 'FL', 0.0600),
('Illinois', 'IL', 0.0625),
('Arizona', 'AZ', 0.0560),
('Washington', 'WA', 0.0650),
('Georgia', 'GA', 0.0400),
('Ohio', 'OH', 0.0575),
('Colorado', 'CO', 0.0290);

-- ---------------------------------------------------------------------
-- Tiendas
-- ---------------------------------------------------------------------
INSERT INTO sucursales (numero_tienda, nombre, direccion, ciudad, id_estado, codigo_postal, telefono, fecha_apertura) VALUES
(4402, 'GameStop Grapevine Mills', '3000 Grapevine Mills Pkwy, Suite 512', 'Grapevine', 1, '76051', '(972) 555-0142', '2004-08-14'),
(5121, 'GameStop Galleria Dallas', '13350 Dallas Pkwy, Suite 2140', 'Dallas', 1, '75240', '(972) 555-0187', '2006-03-02'),
(6033, 'GameStop Houston Galleria', '5085 Westheimer Rd, Suite B3570', 'Houston', 1, '77056', '(713) 555-0119', '2008-11-21'),
(3317, 'GameStop Century City', '10250 Santa Monica Blvd, Suite 1650', 'Los Angeles', 2, '90067', '(310) 555-0164', '2003-05-09'),
(7208, 'GameStop Mission Valley', '1640 Camino Del Rio N, Suite 128', 'San Diego', 2, '92108', '(619) 555-0133', '2011-09-16'),
(2589, 'GameStop Union Square', '32 E 14th St', 'New York', 3, '10003', '(212) 555-0178', '2002-10-25'),
(8140, 'GameStop Dolphin Mall', '11401 NW 12th St, Suite 418', 'Miami', 4, '33172', '(305) 555-0126', '2012-06-08'),
(6671, 'GameStop State Street', '33 N State St', 'Chicago', 5, '60602', '(312) 555-0191', '2009-04-17'),
(9025, 'GameStop Arizona Mills', '5000 S Arizona Mills Cir, Suite 233', 'Tempe', 6, '85282', '(480) 555-0158', '2014-07-11'),
(9310, 'GameStop Northgate', '401 NE Northgate Way, Suite 1104', 'Seattle', 7, '98125', '(206) 555-0147', '2015-02-27');

-- ---------------------------------------------------------------------
-- Empleados (primero gerentes de distrito, luego cada tienda)
-- ---------------------------------------------------------------------
INSERT INTO empleados (id_empleado, nombre, apellido, correo, telefono, puesto, salario_hora, fecha_contratacion, id_sucursal, id_supervisor) VALUES
(1, 'Robert', 'Coleman', 'robert.coleman@gamestop.com', '(287) 555-5694', 'Gerente de distrito', 41.50, '2009-01-12', 1, NULL),
(2, 'Angela', 'Navarro', 'angela.navarro@gamestop.com', '(294) 555-7100', 'Gerente de distrito', 41.50, '2011-06-20', 4, NULL),
(3, 'Emily', 'Nguyen', 'emily.nguyen@gamestop.com', '(507) 555-8242', 'Gerente de tienda', 29.0, '2015-04-02', 1, 1),
(4, 'Jose', 'Rodriguez', 'jose.rodriguez@gamestop.com', '(337) 555-6749', 'Subgerente', 22.5, '2020-12-04', 1, 3),
(5, 'Sofia', 'Rodriguez', 'sofia.rodriguez@gamestop.com', '(745) 555-1579', 'Asesor senior', 17.0, '2019-05-10', 1, 4),
(6, 'Sofia', 'Campbell', 'sofia.campbell@gamestop.com', '(373) 555-2192', 'Asesor', 15.0, '2024-03-19', 1, 4),
(7, 'Matthew', 'Lee', 'matthew.lee@gamestop.com', '(643) 555-7490', 'Asesor', 15.0, '2026-01-16', 1, 4),
(8, 'Tyler', 'Anderson', 'tyler.anderson@gamestop.com', '(361) 555-3725', 'Gerente de tienda', 31.0, '2018-08-14', 2, 1),
(9, 'Camila', 'Robinson', 'camila.robinson@gamestop.com', '(426) 555-9622', 'Subgerente', 22.5, '2017-01-02', 2, 8),
(10, 'Aiden', 'Thompson', 'aiden.thompson@gamestop.com', '(989) 555-2945', 'Asesor senior', 17.0, '2024-05-24', 2, 9),
(11, 'Logan', 'Rivera', 'logan.rivera@gamestop.com', '(480) 555-9009', 'Asesor', 15.0, '2026-03-03', 2, 9),
(12, 'Diego', 'Baker', 'diego.baker@gamestop.com', '(881) 555-1450', 'Gerente de tienda', 28.5, '2016-03-01', 3, 1),
(13, 'Jordan', 'Hernandez', 'jordan.hernandez@gamestop.com', '(583) 555-3448', 'Subgerente', 21.0, '2022-12-14', 3, 12),
(14, 'Jacob', 'Miller', 'jacob.miller@gamestop.com', '(258) 555-9043', 'Asesor senior', 18.25, '2020-01-06', 3, 13),
(15, 'Lauren', 'Allen', 'lauren.allen@gamestop.com', '(545) 555-7312', 'Asesor', 15.5, '2023-12-17', 3, 13),
(16, 'James', 'Hernandez', 'james.hernandez@gamestop.com', '(783) 555-9207', 'Gerente de tienda', 30.25, '2017-07-24', 4, 2),
(17, 'Daniel', 'Walker', 'daniel.walker@gamestop.com', '(300) 555-8987', 'Subgerente', 21.0, '2021-04-07', 4, 16),
(18, 'Emily', 'Brown', 'emily.brown@gamestop.com', '(423) 555-5861', 'Asesor senior', 18.25, '2021-04-07', 4, 17),
(19, 'Taylor', 'Clark', 'taylor.clark@gamestop.com', '(641) 555-1566', 'Asesor', 18.90, '2023-11-05', 4, 17),
(20, 'Matthew', 'Johnson', 'matthew.johnson@gamestop.com', '(937) 555-5238', 'Asesor', 18.40, '2025-03-13', 4, 17),
(21, 'Jacob', 'Adams', 'jacob.adams@gamestop.com', '(273) 555-2272', 'Gerente de tienda', 30.25, '2012-01-16', 5, 2),
(22, 'James', 'Mitchell', 'james.mitchell@gamestop.com', '(827) 555-5701', 'Subgerente', 21.75, '2020-03-15', 5, 21),
(23, 'Jordan', 'Rodriguez', 'jordan.rodriguez@gamestop.com', '(787) 555-8047', 'Asesor senior', 17.90, '2019-03-08', 5, 22),
(24, 'Alexis', 'Nguyen', 'alexis.nguyen@gamestop.com', '(492) 555-6392', 'Asesor', 18.40, '2025-12-27', 5, 22),
(25, 'Megan', 'Lopez', 'megan.lopez@gamestop.com', '(670) 555-5397', 'Gerente de tienda', 28.5, '2012-04-24', 6, 1),
(26, 'Noah', 'Ramirez', 'noah.ramirez@gamestop.com', '(492) 555-9901', 'Subgerente', 21.75, '2017-04-17', 6, 25),
(27, 'Brandon', 'Walker', 'brandon.walker@gamestop.com', '(201) 555-2826', 'Asesor senior', 18.50, '2024-06-13', 6, 26),
(28, 'Luis', 'Harris', 'luis.harris@gamestop.com', '(266) 555-7109', 'Asesor', 18.00, '2024-05-02', 6, 26),
(29, 'Mariana', 'Hernandez', 'mariana.hernandez@gamestop.com', '(465) 555-1476', 'Asesor', 18.00, '2024-02-13', 6, 26),
(30, 'Ethan', 'Adams', 'ethan.adams@gamestop.com', '(724) 555-2174', 'Gerente de tienda', 29.0, '2017-08-22', 7, 1),
(31, 'Anthony', 'Brown', 'anthony.brown@gamestop.com', '(632) 555-2056', 'Subgerente', 21.75, '2022-12-20', 7, 30),
(32, 'Daniel', 'Gonzalez', 'daniel.gonzalez@gamestop.com', '(264) 555-2879', 'Asesor senior', 17.0, '2019-05-25', 7, 31),
(33, 'Gabriela', 'Hall', 'gabriela.hall@gamestop.com', '(930) 555-5681', 'Asesor', 16.0, '2024-11-21', 7, 31),
(34, 'Ashley', 'Moore', 'ashley.moore@gamestop.com', '(588) 555-2058', 'Gerente de tienda', 30.25, '2015-06-18', 8, 1),
(35, 'Camila', 'King', 'camila.king@gamestop.com', '(564) 555-8996', 'Subgerente', 21.75, '2017-02-21', 8, 34),
(36, 'Diego', 'Brown', 'diego.brown@gamestop.com', '(886) 555-5052', 'Asesor senior', 17.5, '2023-03-01', 8, 35),
(37, 'Taylor', 'Campbell', 'taylor.campbell@gamestop.com', '(976) 555-2131', 'Asesor', 16.0, '2023-10-02', 8, 35),
(38, 'Taylor', 'Lewis', 'taylor.lewis@gamestop.com', '(376) 555-6752', 'Gerente de tienda', 28.5, '2018-04-10', 9, 2),
(39, 'Destiny', 'White', 'destiny.white@gamestop.com', '(964) 555-1639', 'Subgerente', 21.75, '2022-05-30', 9, 38),
(40, 'Sarah', 'Ramirez', 'sarah.ramirez@gamestop.com', '(369) 555-2085', 'Asesor senior', 18.25, '2022-06-03', 9, 39),
(41, 'Alexis', 'Thomas', 'alexis.thomas@gamestop.com', '(839) 555-1968', 'Asesor', 16.0, '2025-10-29', 9, 39),
(42, 'Michael', 'Johnson', 'michael.johnson@gamestop.com', '(819) 555-6425', 'Gerente de tienda', 30.25, '2018-06-10', 10, 2),
(43, 'Ethan', 'Hernandez', 'ethan.hernandez@gamestop.com', '(507) 555-3931', 'Subgerente', 21.0, '2016-11-06', 10, 42),
(44, 'Mariana', 'Flores', 'mariana.flores@gamestop.com', '(842) 555-4772', 'Asesor senior', 17.66, '2021-09-21', 10, 43),
(45, 'Destiny', 'Hill', 'destiny.hill@gamestop.com', '(862) 555-8285', 'Asesor', 18.16, '2025-02-22', 10, 43);

-- ---------------------------------------------------------------------
-- Programa de lealtad y clientes
-- ---------------------------------------------------------------------
INSERT INTO niveles_membresia (nombre, costo_anual, descuento_usados_pct, bono_intercambio_pct, puntos_por_dolar) VALUES
('PowerUp Rewards', 0.00, 0.00, 0.00, 1),
('GameStop Pro', 25.00, 10.00, 10.00, 2);

INSERT INTO clientes (id_cliente, nombre, apellido, correo, telefono, fecha_nacimiento, id_estado, id_nivel, vencimiento_membresia, puntos, fecha_registro) VALUES
(1, 'Aiden', 'Robinson', 'aiden.robinson@email.com', '(542) 555-5375', '2002-03-15', 2, 2, '2027-04-18', 800, '2026-01-23'),
(2, 'Ashley', 'Perez', 'ashley.perez@mail.com', '(648) 555-3256', '1989-09-17', 1, 2, '2027-04-25', 275, '2022-02-05'),
(3, 'Noah', 'King', 'noah.king@email.com', '(734) 555-7906', '2006-08-19', 3, 2, '2027-03-11', 325, '2026-08-31'),
(4, 'Camila', 'Perez', 'camila.perez@email.com', '(422) 555-7082', '1997-03-13', 1, 1, NULL, 1250, '2022-06-23'),
(5, 'Jordan', 'Adams', 'jordan.adams@mail.com', '(362) 555-7789', '2004-02-03', 2, 1, NULL, 600, '2025-11-10'),
(6, 'Emily', 'Clark', 'emily.clark@inbox.com', '(515) 555-4425', '1986-01-15', 4, 1, NULL, 100, '2019-05-10'),
(7, 'Aiden', 'Nelson', 'aiden.nelson@mail.com', '(428) 555-1463', '1997-01-23', 2, 1, NULL, 425, '2018-12-01'),
(8, 'Sofia', 'Harris', 'sofia.harris@inbox.com', '(769) 555-9506', '2003-11-13', 2, 1, NULL, 625, '2020-03-07'),
(9, 'Jordan', 'Lopez', 'jordan.lopez@inbox.com', '(913) 555-5450', '1978-05-14', 4, 2, '2027-01-05', 825, '2018-02-15'),
(10, 'Noah', 'Walker', 'noah.walker@inbox.com', '(459) 555-1751', '1994-02-10', 2, 2, '2027-06-30', 975, '2020-08-02'),
(11, 'Anthony', 'Carter', 'anthony.carter@email.com', '(477) 555-4086', '2001-03-02', 4, 1, NULL, 1075, '2020-07-21'),
(12, 'Hannah', 'Martinez', 'hannah.martinez@mail.com', '(978) 555-2813', '1997-12-05', 6, 2, '2027-08-09', 75, '2021-02-03'),
(13, 'Aiden', 'Lee', 'aiden.lee@mail.com', '(649) 555-9707', '1980-01-26', 5, 1, NULL, 1450, '2021-12-04'),
(14, 'Logan', 'Hernandez', 'logan.hernandez@inbox.com', '(598) 555-7546', '1988-04-12', 2, 1, NULL, 100, '2021-02-18'),
(15, 'Aaliyah', 'Gonzalez', 'aaliyah.gonzalez@inbox.com', '(475) 555-9976', '1990-02-11', 1, 2, '2026-11-03', 200, '2018-02-22'),
(16, 'Anthony', 'Johnson', 'anthony.johnson@email.com', '(891) 555-7016', '2003-01-18', 4, 2, '2026-08-12', 725, '2024-03-15'),
(17, 'Anthony', 'Perez', 'anthony.perez@inbox.com', '(266) 555-8967', '1991-12-29', 5, 1, NULL, 825, '2022-12-24'),
(18, 'Michael', 'Brown', 'michael.brown@inbox.com', '(802) 555-7596', '2004-11-26', 3, 1, NULL, 175, '2024-05-30'),
(19, 'Tyler', 'Martin', 'tyler.martin@mail.com', '(525) 555-9032', '1990-03-15', 2, 1, NULL, 650, '2025-04-06'),
(20, 'Christopher', 'Lewis', 'christopher.lewis@mail.com', '(857) 555-9670', '1983-07-26', 2, 1, NULL, 1450, '2022-01-12'),
(21, 'David', 'Smith', 'david.smith@inbox.com', '(922) 555-7732', '1996-11-26', 6, 1, NULL, 75, '2025-11-10'),
(22, 'Anthony', 'Baker', 'anthony.baker@mail.com', '(393) 555-2140', '1992-07-28', 3, 1, NULL, 1425, '2023-08-20'),
(23, 'Zoe', 'Rivera', 'zoe.rivera@mail.com', '(270) 555-9013', '1995-04-23', 1, 1, NULL, 400, '2023-10-26'),
(24, 'Kayla', 'Rodriguez', 'kayla.rodriguez@inbox.com', '(486) 555-1689', '1983-12-19', 3, 1, NULL, 200, '2022-07-26'),
(25, 'Marcus', 'Sanchez', 'marcus.sanchez@email.com', '(342) 555-1895', '1984-03-04', 1, 1, NULL, 1225, '2022-12-20'),
(26, 'Sarah', 'King', 'sarah.king@email.com', '(687) 555-9055', '1995-12-12', 2, 2, '2027-04-29', 800, '2021-07-05'),
(27, 'Aaliyah', 'Harris', 'aaliyah.harris@mail.com', '(562) 555-8782', '2001-04-28', 7, 1, NULL, 125, '2025-10-13'),
(28, 'Tyler', 'Nguyen', 'tyler.nguyen@inbox.com', '(790) 555-3934', '2002-06-03', 1, 1, NULL, 325, '2022-04-27'),
(29, 'Emily', 'Kim', 'emily.kim@email.com', '(657) 555-2457', '1996-08-15', 5, 1, NULL, 1375, '2020-02-22'),
(30, 'Destiny', 'Perez', 'destiny.perez@mail.com', '(417) 555-6235', '1980-05-09', 7, 2, '2027-08-10', 175, '2019-05-23'),
(31, 'Marcus', 'Thompson', 'marcus.thompson@mail.com', '(394) 555-7621', '1993-02-23', 2, 2, '2027-04-21', 750, '2025-02-13'),
(32, 'Diego', 'Wright', 'diego.wright@mail.com', '(278) 555-6027', '1995-12-20', 5, 1, NULL, 300, '2021-06-07'),
(33, 'Brandon', 'Lewis', 'brandon.lewis@mail.com', '(340) 555-8995', '1996-06-21', 1, 2, '2026-12-17', 175, '2026-06-24'),
(34, 'Camila', 'Nelson', 'camila.nelson@mail.com', '(214) 555-5845', '1984-12-29', 1, 1, NULL, 1300, '2021-01-13'),
(35, 'Noah', 'Campbell', 'noah.campbell@email.com', '(733) 555-3618', '1988-11-12', 1, 1, NULL, 1475, '2021-02-15'),
(36, 'Alexis', 'Hernandez', 'alexis.hernandez@email.com', '(402) 555-6517', '2000-11-09', 6, 2, '2027-01-01', 125, '2019-05-16'),
(37, 'Diego', 'Rivera', 'diego.rivera@email.com', '(722) 555-2658', '2003-08-05', 6, 1, NULL, 450, '2026-07-24'),
(38, 'Sofia', 'Garcia', 'sofia.garcia@mail.com', '(972) 555-5787', '1978-04-15', 4, 1, NULL, 1250, '2023-04-28'),
(39, 'Aaliyah', 'Lopez', 'aaliyah.lopez@mail.com', '(374) 555-8723', '1978-05-07', 5, 1, NULL, 200, '2022-04-15'),
(40, 'Logan', 'Thompson', 'logan.thompson@inbox.com', '(927) 555-5883', '2003-06-28', 2, 1, NULL, 225, '2018-04-08'),
(41, 'Kayla', 'White', 'kayla.white@inbox.com', '(898) 555-7353', '1983-01-26', 2, 1, NULL, 625, '2018-11-17'),
(42, 'Ryan', 'Robinson', 'ryan.robinson@inbox.com', '(441) 555-6874', '2002-06-17', 7, 1, NULL, 1450, '2021-10-21'),
(43, 'Kevin', 'Garcia', 'kevin.garcia@email.com', '(930) 555-6912', '1981-07-23', 1, 1, NULL, 850, '2018-11-02'),
(44, 'Justin', 'Johnson', 'justin.johnson@mail.com', '(640) 555-1322', '1989-07-05', 6, 2, '2027-05-25', 550, '2026-04-24'),
(45, 'James', 'Nguyen', 'james.nguyen@email.com', '(253) 555-1289', '2003-03-02', 1, 1, NULL, 50, '2023-09-24'),
(46, 'Michael', 'Scott', 'michael.scott@mail.com', '(537) 555-8364', '1983-01-04', 2, 2, '2027-01-15', 1100, '2022-04-26'),
(47, 'Andrew', 'Wilson', 'andrew.wilson@inbox.com', '(736) 555-4783', '1977-02-28', 1, 1, NULL, 1475, '2023-11-07'),
(48, 'Destiny', 'Clark', 'destiny.clark@mail.com', '(828) 555-1545', '1998-04-20', 5, 2, '2027-01-23', 925, '2026-01-18'),
(49, 'Anthony', 'Adams', 'anthony.adams@mail.com', '(414) 555-1007', '1990-04-10', 3, 2, '2027-09-16', 1350, '2023-08-21'),
(50, 'Jordan', 'Garcia', 'jordan.garcia@inbox.com', '(635) 555-2873', '2002-09-06', 6, 1, NULL, 200, '2018-01-13'),
(51, 'Mariana', 'Harris', 'mariana.harris@email.com', '(538) 555-6101', '2000-02-03', 1, 1, NULL, 1325, '2021-08-24'),
(52, 'Ryan', 'Jackson', 'ryan.jackson@mail.com', '(878) 555-6733', '1978-07-30', 1, 2, '2026-12-16', 950, '2023-08-03'),
(53, 'Hannah', 'Thomas', 'hannah.thomas@mail.com', '(836) 555-4116', '2008-01-03', 7, 1, NULL, 950, '2026-03-08'),
(54, 'Aaliyah', 'Hill', 'aaliyah.hill@email.com', '(676) 555-1743', '2008-04-01', 6, 1, NULL, 300, '2024-01-22'),
(55, 'Marcus', 'Lopez', 'marcus.lopez@inbox.com', '(654) 555-4467', '1975-07-02', 5, 2, '2027-07-20', 1025, '2020-02-20'),
(56, 'Sofia', 'Hall', 'sofia.hall@email.com', '(524) 555-9094', '1998-05-28', 1, 2, '2027-04-19', 1200, '2022-08-20'),
(57, 'Jordan', 'Torres', 'jordan.torres@inbox.com', '(862) 555-4567', '2004-09-02', 2, 2, '2026-09-28', 750, '2026-06-22'),
(58, 'Kayla', 'Lewis', 'kayla.lewis@inbox.com', '(928) 555-4025', '1990-05-19', 2, 2, '2027-05-25', 750, '2020-09-03'),
(59, 'Camila', 'Wright', 'camila.wright@inbox.com', '(683) 555-4148', '1976-03-11', 2, 2, '2027-08-08', 800, '2018-05-27'),
(60, 'Michael', 'Nguyen', 'michael.nguyen@mail.com', '(679) 555-4706', '1980-11-27', 1, 2, '2026-10-20', 650, '2022-04-23');

-- ---------------------------------------------------------------------
-- Catálogos
-- ---------------------------------------------------------------------
INSERT INTO categorias (nombre, descripcion) VALUES
('Videojuego', 'Juegos físicos nuevos y usados'),
('Consola', 'Consolas nuevas, usadas y reacondicionadas'),
('Accesorio', 'Controles, audífonos, almacenamiento'),
('Coleccionable', 'Figuras, Funko Pop!, amiibo, cartas'),
('Tarjeta de regalo', 'Saldo para tiendas digitales');

INSERT INTO plataformas (nombre, fabricante, generacion, fecha_lanzamiento) VALUES
('PlayStation 5', 'Sony', 9, '2020-11-12'),
('PlayStation 4', 'Sony', 8, '2013-11-15'),
('Xbox Series X|S', 'Microsoft', 9, '2020-11-10'),
('Xbox One', 'Microsoft', 8, '2013-11-22'),
('Nintendo Switch 2', 'Nintendo', 9, '2025-06-05'),
('Nintendo Switch', 'Nintendo', 8, '2017-03-03'),
('PC', 'Varios', NULL, NULL);

INSERT INTO generos (nombre) VALUES
('Acción'),
('Aventura'),
('RPG'),
('Shooter'),
('Deportes'),
('Carreras'),
('Plataformas'),
('Mundo abierto'),
('Terror'),
('Lucha'),
('Familiar'),
('Sandbox'),
('Estrategia'),
('Soulslike');

INSERT INTO proveedores (nombre, contacto, telefono, correo, ciudad, id_estado) VALUES
('Sony Interactive Entertainment', 'Laura Bennett', '(650) 555-0101', 'trade@sie.example.com', 'San Mateo', 2),
('Microsoft Gaming', 'Kevin Brooks', '(425) 555-0102', 'retail@xbox.example.com', 'Redmond', 7),
('Nintendo of America', 'Emily Tanaka', '(425) 555-0103', 'retail@noa.example.com', 'Redmond', 7),
('Electronic Arts', 'Paul Rivera', '(650) 555-0104', 'sales@ea.example.com', 'Redwood City', 2),
('Activision Blizzard', 'Megan Ross', '(310) 555-0105', 'sales@activision.example.com', 'Santa Monica', 2),
('Take-Two Interactive', 'Brian Walsh', '(646) 555-0106', 'sales@take2.example.com', 'New York', 3),
('Ubisoft', 'Claire Dubois', '(415) 555-0107', 'sales@ubisoft.example.com', 'San Francisco', 2),
('Capcom USA', 'Ken Ito', '(650) 555-0108', 'sales@capcom.example.com', 'San Mateo', 2),
('Bandai Namco Entertainment America', 'Lisa Park', '(949) 555-0109', 'sales@bandainamco.example.com', 'Irvine', 2),
('Turtle Beach', 'Greg Olsen', '(914) 555-0110', 'sales@turtlebeach.example.com', 'White Plains', 3),
('HP HyperX', 'Sandra Cruz', '(714) 555-0111', 'sales@hyperx.example.com', 'Fountain Valley', 2),
('Funko', 'Jake Miller', '(425) 555-0112', 'sales@funko.example.com', 'Everett', 7),
('The Pokémon Company International', 'Amy Chen', '(425) 555-0113', 'sales@pokemon.example.com', 'Bellevue', 7),
('Blackhawk Network', 'Tom Price', '(925) 555-0114', 'sales@blackhawk.example.com', 'Pleasanton', 2),
('SanDisk', 'Rachel Kim', '(408) 555-0115', 'sales@sandisk.example.com', 'Milpitas', 2);

-- ---------------------------------------------------------------------
-- Productos (67)
-- ---------------------------------------------------------------------
INSERT INTO productos (id_producto, sku, nombre, id_categoria, id_plataforma, id_proveedor, condicion, clasificacion_esrb, precio_venta, costo, fecha_lanzamiento, activo) VALUES
(1, 'CON-PS5-SLM', 'PlayStation 5 Slim (lector de discos)', 2, 1, 1, 'Nuevo', NULL, 549.99, 420.00, '2023-11-10', TRUE),
(2, 'CON-PS5-DIG', 'PlayStation 5 Digital Edition', 2, 1, 1, 'Nuevo', NULL, 499.99, 375.00, '2023-11-10', TRUE),
(3, 'CON-PS5-PRO', 'PlayStation 5 Pro', 2, 1, 1, 'Nuevo', NULL, 749.99, 650.00, '2024-11-07', TRUE),
(4, 'CON-XSX-1TB', 'Xbox Series X 1TB', 2, 3, 2, 'Nuevo', NULL, 649.99, 560.00, '2020-11-10', TRUE),
(5, 'CON-XSS-512', 'Xbox Series S 512GB', 2, 3, 2, 'Nuevo', NULL, 399.99, 310.00, '2020-11-10', TRUE),
(6, 'CON-NS2-STD', 'Nintendo Switch 2', 2, 5, 3, 'Nuevo', NULL, 449.99, 385.00, '2025-06-05', TRUE),
(7, 'CON-NS2-MKW', 'Nintendo Switch 2 + Mario Kart World Bundle', 2, 5, 3, 'Nuevo', NULL, 499.99, 430.00, '2025-06-05', TRUE),
(8, 'CON-NSW-OLED', 'Nintendo Switch OLED', 2, 6, 3, 'Nuevo', NULL, 399.99, 340.00, '2021-10-08', TRUE),
(9, 'CON-NSW-LITE', 'Nintendo Switch Lite', 2, 6, 3, 'Nuevo', NULL, 229.99, 190.00, '2019-09-20', TRUE),
(10, 'CON-PS4-SLM-U', 'PlayStation 4 Slim 1TB (usada)', 2, 2, NULL, 'Usado', NULL, 199.99, 90.00, '2016-09-15', TRUE),
(11, 'CON-XSS-R', 'Xbox Series S (reacondicionada)', 2, 3, NULL, 'Reacondicionado', NULL, 279.99, 150.00, '2020-11-10', TRUE),
(12, 'CON-NSW-R', 'Nintendo Switch V2 (reacondicionada)', 2, 6, NULL, 'Reacondicionado', NULL, 219.99, 120.00, '2019-08-30', TRUE),
(13, 'VJ-PS5-GTA6', 'Grand Theft Auto VI', 1, 1, 6, 'Nuevo', 'M', 69.99, 48.00, '2026-11-19', TRUE),
(14, 'VJ-XSX-GTA6', 'Grand Theft Auto VI (Xbox)', 1, 3, 6, 'Nuevo', 'M', 69.99, 48.00, '2026-11-19', TRUE),
(15, 'VJ-PS5-BO7', 'Call of Duty: Black Ops 7', 1, 1, 5, 'Nuevo', 'M', 69.99, 48.00, '2025-11-14', TRUE),
(16, 'VJ-XSX-BO7', 'Call of Duty: Black Ops 7 (Xbox)', 1, 3, 5, 'Nuevo', 'M', 69.99, 48.00, '2025-11-14', TRUE),
(17, 'VJ-PS5-BF6', 'Battlefield 6', 1, 1, 4, 'Nuevo', 'M', 69.99, 48.00, '2025-10-10', TRUE),
(18, 'VJ-PS5-FC26', 'EA Sports FC 26', 1, 1, 4, 'Nuevo', 'E', 69.99, 48.00, '2025-09-26', TRUE),
(19, 'VJ-PS5-MAD26', 'Madden NFL 26', 1, 1, 4, 'Nuevo', 'E', 69.99, 48.00, '2025-08-14', TRUE),
(20, 'VJ-PS5-2K26', 'NBA 2K26', 1, 1, 6, 'Nuevo', 'E', 69.99, 48.00, '2025-09-05', TRUE),
(21, 'VJ-PS5-GOY', 'Ghost of Yōtei', 1, 1, 1, 'Nuevo', 'M', 69.99, 47.00, '2025-10-02', TRUE),
(22, 'VJ-PS5-SM2', 'Marvel''s Spider-Man 2', 1, 1, 1, 'Nuevo', 'T', 49.99, 24.00, '2023-10-20', TRUE),
(23, 'VJ-PS5-MHW', 'Monster Hunter Wilds', 1, 1, 8, 'Nuevo', 'T', 59.99, 40.00, '2025-02-28', TRUE),
(24, 'VJ-PS5-ERN', 'Elden Ring Nightreign', 1, 1, 9, 'Nuevo', 'M', 39.99, 26.00, '2025-05-30', TRUE),
(25, 'VJ-PS5-ACS', 'Assassin''s Creed Shadows', 1, 1, 7, 'Nuevo', 'M', 59.99, 40.00, '2025-03-20', TRUE),
(26, 'VJ-XSX-FH5', 'Forza Horizon 5', 1, 3, 2, 'Nuevo', 'E', 39.99, 26.00, '2021-11-09', TRUE),
(27, 'VJ-NS2-MKW', 'Mario Kart World', 1, 5, 3, 'Nuevo', 'E', 79.99, 56.00, '2025-06-05', TRUE),
(28, 'VJ-NS2-DKB', 'Donkey Kong Bananza', 1, 5, 3, 'Nuevo', 'E10+', 69.99, 48.00, '2025-07-17', TRUE),
(29, 'VJ-NS2-PLZA', 'Pokémon Legends: Z-A (Switch 2 Edition)', 1, 5, 3, 'Nuevo', 'E10+', 69.99, 48.00, '2025-10-16', TRUE),
(30, 'VJ-NS2-MP4', 'Metroid Prime 4: Beyond', 1, 5, 3, 'Nuevo', 'T', 69.99, 48.00, '2025-12-04', TRUE),
(31, 'VJ-NSW-TOTK', 'The Legend of Zelda: Tears of the Kingdom', 1, 6, 3, 'Nuevo', 'E10+', 69.99, 48.00, '2023-05-12', TRUE),
(32, 'VJ-NSW-SMBW', 'Super Mario Bros. Wonder', 1, 6, 3, 'Nuevo', 'E', 59.99, 40.00, '2023-10-20', TRUE),
(33, 'VJ-NSW-ACNH', 'Animal Crossing: New Horizons', 1, 6, 3, 'Nuevo', 'E', 59.99, 40.00, '2020-03-20', TRUE),
(34, 'VJ-NSW-MINE', 'Minecraft', 1, 6, 2, 'Nuevo', 'E10+', 29.99, 19.00, '2018-06-21', TRUE),
(35, 'VJ-PS5-ER-U', 'Elden Ring (usado)', 1, 1, NULL, 'Usado', 'M', 29.99, 11.00, '2022-02-25', TRUE),
(36, 'VJ-PS4-GTAV-U', 'Grand Theft Auto V (usado)', 1, 2, NULL, 'Usado', 'M', 14.99, 5.00, '2014-11-18', TRUE),
(37, 'VJ-PS4-RDR2-U', 'Red Dead Redemption 2 (usado)', 1, 2, NULL, 'Usado', 'M', 19.99, 7.00, '2018-10-26', TRUE),
(38, 'VJ-PS5-GOWR-U', 'God of War Ragnarök (usado)', 1, 1, NULL, 'Usado', 'M', 29.99, 11.00, '2022-11-09', TRUE),
(39, 'VJ-PS5-SMMM-U', 'Marvel''s Spider-Man: Miles Morales (usado)', 1, 1, NULL, 'Usado', 'T', 19.99, 7.00, '2020-11-12', TRUE),
(40, 'VJ-PS5-HOG-U', 'Hogwarts Legacy (usado)', 1, 1, NULL, 'Usado', 'T', 24.99, 9.00, '2023-02-10', TRUE),
(41, 'VJ-XONE-HALO-U', 'Halo Infinite (usado)', 1, 4, NULL, 'Usado', 'T', 12.99, 4.00, '2021-12-08', TRUE),
(42, 'VJ-NSW-BOTW-U', 'The Legend of Zelda: Breath of the Wild (usado)', 1, 6, NULL, 'Usado', 'E10+', 44.99, 18.00, '2017-03-03', TRUE),
(43, 'VJ-NSW-SMO-U', 'Super Mario Odyssey (usado)', 1, 6, NULL, 'Usado', 'E10+', 39.99, 15.00, '2017-10-27', TRUE),
(44, 'VJ-NSW-MK8-U', 'Mario Kart 8 Deluxe (usado)', 1, 6, NULL, 'Usado', 'E', 39.99, 15.00, '2017-04-28', TRUE),
(45, 'VJ-NSW-SSBU-U', 'Super Smash Bros. Ultimate (usado)', 1, 6, NULL, 'Usado', 'E10+', 44.99, 18.00, '2018-12-07', TRUE),
(46, 'ACC-PS5-DS', 'Control inalámbrico DualSense', 3, 1, 1, 'Nuevo', NULL, 74.99, 52.00, '2020-11-12', TRUE),
(47, 'ACC-PS5-DSE', 'Control DualSense Edge', 3, 1, 1, 'Nuevo', NULL, 199.99, 145.00, '2023-01-26', TRUE),
(48, 'ACC-PS5-PRT', 'PlayStation Portal', 3, 1, 1, 'Nuevo', NULL, 199.99, 150.00, '2023-11-15', TRUE),
(49, 'ACC-XSX-CTL', 'Control inalámbrico Xbox', 3, 3, 2, 'Nuevo', NULL, 64.99, 45.00, '2020-11-10', TRUE),
(50, 'ACC-NS2-PRO', 'Nintendo Switch 2 Pro Controller', 3, 5, 3, 'Nuevo', NULL, 84.99, 60.00, '2025-06-05', TRUE),
(51, 'ACC-NS2-JOY', 'Joy-Con 2 (par)', 3, 5, 3, 'Nuevo', NULL, 94.99, 68.00, '2025-06-05', TRUE),
(52, 'ACC-NS2-SD256', 'SanDisk microSD Express 256GB', 3, 5, 15, 'Nuevo', NULL, 59.99, 38.00, '2025-06-05', TRUE),
(53, 'ACC-TB-S600', 'Audífonos Turtle Beach Stealth 600 Gen 3', 3, NULL, 10, 'Nuevo', NULL, 99.99, 65.00, '2024-03-12', TRUE),
(54, 'ACC-HX-CL3', 'Audífonos HyperX Cloud III', 3, NULL, 11, 'Nuevo', NULL, 99.99, 64.00, '2023-03-01', TRUE),
(55, 'COL-FNK-MARIO', 'Funko Pop! Mario', 4, NULL, 12, 'Nuevo', NULL, 12.99, 6.50, NULL, TRUE),
(56, 'COL-FNK-KRATOS', 'Funko Pop! Kratos', 4, NULL, 12, 'Nuevo', NULL, 12.99, 6.50, NULL, TRUE),
(57, 'COL-FNK-PIKA', 'Funko Pop! Pikachu', 4, NULL, 12, 'Nuevo', NULL, 12.99, 6.50, NULL, TRUE),
(58, 'COL-AMB-LINK', 'amiibo Link (Tears of the Kingdom)', 4, 6, 3, 'Nuevo', NULL, 29.99, 19.00, '2023-05-12', TRUE),
(59, 'COL-PKM-ETB', 'Pokémon TCG: Elite Trainer Box', 4, NULL, 13, 'Nuevo', NULL, 59.99, 40.00, NULL, TRUE),
(60, 'COL-PKM-BOOST', 'Pokémon TCG: sobre de expansión', 4, NULL, 13, 'Nuevo', NULL, 4.99, 3.00, NULL, TRUE),
(61, 'GC-PSN-50', 'Tarjeta PlayStation Store $50', 5, 1, 14, 'Nuevo', NULL, 50.00, 47.50, NULL, TRUE),
(62, 'GC-XBOX-50', 'Tarjeta Xbox $50', 5, 3, 14, 'Nuevo', NULL, 50.00, 47.50, NULL, TRUE),
(63, 'GC-ESHOP-50', 'Tarjeta Nintendo eShop $50', 5, 6, 14, 'Nuevo', NULL, 50.00, 47.50, NULL, TRUE),
(64, 'GC-STEAM-50', 'Tarjeta Steam $50', 5, 7, 14, 'Nuevo', NULL, 50.00, 47.50, NULL, TRUE),
(65, 'ACC-PS5-DSW', 'Control DualSense - Edición Winter Frost', 3, 1, 1, 'Nuevo', NULL, 79.99, 55.00, '2026-12-11', TRUE),
(66, 'CON-NS2-PKM', 'Nintendo Switch 2 - Edición Pokémon', 2, 5, 3, 'Nuevo', NULL, 499.99, 430.00, '2027-02-26', TRUE),
(67, 'VJ-PS4-FIFA23', 'FIFA 23 (descontinuado)', 1, 2, 4, 'Nuevo', 'E', 19.99, 12.00, '2022-09-30', FALSE);

INSERT INTO producto_genero (id_producto, id_genero) VALUES
(13, 1),
(13, 8),
(14, 1),
(14, 8),
(15, 4),
(15, 1),
(16, 4),
(16, 1),
(17, 4),
(17, 1),
(18, 5),
(19, 5),
(20, 5),
(21, 1),
(21, 2),
(21, 8),
(22, 1),
(22, 2),
(22, 8),
(23, 1),
(23, 3),
(24, 1),
(24, 3),
(24, 14),
(25, 1),
(25, 2),
(25, 8),
(26, 6),
(26, 8),
(27, 6),
(27, 11),
(28, 7),
(28, 2),
(28, 11),
(29, 3),
(29, 2),
(29, 11),
(30, 1),
(30, 2),
(30, 4),
(31, 2),
(31, 8),
(31, 1),
(32, 7),
(32, 11),
(33, 11),
(33, 12),
(34, 12),
(34, 11),
(34, 2),
(35, 1),
(35, 3),
(35, 14),
(36, 1),
(36, 8),
(37, 1),
(37, 2),
(37, 8),
(38, 1),
(38, 2),
(39, 1),
(39, 2),
(40, 3),
(40, 2),
(40, 8),
(41, 4),
(41, 1),
(42, 2),
(42, 8),
(43, 7),
(43, 11),
(44, 6),
(44, 11),
(45, 10),
(45, 11),
(67, 5);

-- ---------------------------------------------------------------------
-- Inventario inicial al 1 de octubre de 2026
-- ---------------------------------------------------------------------
INSERT INTO inventario (id_sucursal, id_producto, existencia, stock_minimo) VALUES
(1, 1, 5, 2),
(1, 2, 9, 2),
(1, 3, 5, 2),
(1, 4, 5, 2),
(1, 5, 4, 2),
(1, 6, 6, 2),
(1, 7, 5, 2),
(1, 8, 4, 2),
(1, 9, 6, 2),
(1, 10, 6, 1),
(1, 11, 5, 1),
(1, 12, 1, 1),
(1, 15, 9, 3),
(1, 16, 8, 3),
(1, 17, 6, 3),
(1, 18, 5, 3),
(1, 19, 9, 3),
(1, 20, 16, 3),
(1, 21, 16, 3),
(1, 22, 6, 3),
(1, 23, 12, 3),
(1, 24, 7, 3),
(1, 25, 11, 3),
(1, 26, 6, 3),
(1, 27, 9, 3),
(1, 28, 15, 3),
(1, 29, 15, 3),
(1, 30, 7, 3),
(1, 31, 7, 3),
(1, 32, 10, 3),
(1, 33, 6, 3),
(1, 34, 10, 3),
(1, 35, 2, 1),
(1, 36, 1, 1),
(1, 37, 4, 1),
(1, 38, 6, 1),
(1, 39, 3, 1),
(1, 40, 4, 1),
(1, 41, 4, 1),
(1, 42, 4, 1),
(1, 43, 6, 1),
(1, 44, 3, 1),
(1, 45, 6, 1),
(1, 46, 7, 3),
(1, 47, 11, 3),
(1, 48, 5, 3),
(1, 49, 10, 3),
(1, 50, 13, 3),
(1, 51, 15, 3),
(1, 52, 16, 3),
(1, 53, 6, 3),
(1, 54, 13, 3),
(1, 55, 13, 3),
(1, 56, 16, 3),
(1, 57, 10, 3),
(1, 58, 13, 3),
(1, 59, 14, 3),
(1, 60, 52, 10),
(1, 61, 13, 3),
(1, 62, 8, 3),
(1, 63, 7, 3),
(1, 64, 14, 3),
(1, 67, 2, 0),
(2, 1, 3, 2),
(2, 2, 6, 2),
(2, 3, 6, 2),
(2, 4, 3, 2),
(2, 5, 7, 2),
(2, 6, 3, 2),
(2, 7, 4, 2),
(2, 8, 3, 2),
(2, 9, 6, 2),
(2, 10, 3, 1),
(2, 11, 4, 1),
(2, 12, 1, 1),
(2, 15, 11, 3),
(2, 16, 5, 3),
(2, 17, 6, 3),
(2, 18, 11, 3),
(2, 19, 14, 3),
(2, 20, 11, 3),
(2, 21, 12, 3),
(2, 22, 11, 3),
(2, 23, 9, 3),
(2, 24, 9, 3),
(2, 25, 12, 3),
(2, 26, 14, 3),
(2, 27, 12, 3),
(2, 28, 13, 3),
(2, 29, 8, 3),
(2, 30, 12, 3),
(2, 31, 11, 3),
(2, 32, 13, 3),
(2, 33, 14, 3),
(2, 34, 15, 3),
(2, 35, 1, 1),
(2, 36, 4, 1),
(2, 37, 6, 1),
(2, 38, 4, 1),
(2, 39, 6, 1),
(2, 40, 4, 1),
(2, 41, 6, 1),
(2, 42, 1, 1),
(2, 43, 2, 1),
(2, 44, 3, 1),
(2, 45, 2, 1),
(2, 46, 8, 3),
(2, 47, 11, 3),
(2, 48, 10, 3),
(2, 49, 16, 3),
(2, 50, 14, 3),
(2, 51, 11, 3),
(2, 52, 16, 3),
(2, 53, 11, 3),
(2, 54, 5, 3),
(2, 55, 7, 3),
(2, 56, 11, 3),
(2, 57, 15, 3),
(2, 58, 13, 3),
(2, 59, 8, 3),
(2, 60, 68, 10),
(2, 61, 10, 3),
(2, 62, 9, 3),
(2, 63, 16, 3),
(2, 64, 12, 3),
(2, 67, 0, 0),
(3, 1, 5, 2),
(3, 2, 5, 2),
(3, 3, 6, 2),
(3, 4, 6, 2),
(3, 5, 8, 2),
(3, 6, 4, 2),
(3, 7, 4, 2),
(3, 8, 8, 2),
(3, 9, 4, 2),
(3, 10, 4, 1),
(3, 11, 3, 1),
(3, 12, 6, 1),
(3, 15, 8, 3),
(3, 16, 11, 3),
(3, 17, 15, 3),
(3, 18, 11, 3),
(3, 19, 15, 3),
(3, 20, 8, 3),
(3, 21, 5, 3),
(3, 22, 9, 3),
(3, 23, 9, 3),
(3, 24, 11, 3),
(3, 25, 6, 3),
(3, 26, 13, 3),
(3, 27, 6, 3),
(3, 28, 6, 3),
(3, 29, 13, 3),
(3, 30, 8, 3),
(3, 31, 8, 3),
(3, 32, 6, 3),
(3, 33, 12, 3),
(3, 34, 13, 3),
(3, 35, 2, 1),
(3, 36, 1, 1),
(3, 37, 3, 1),
(3, 38, 3, 1),
(3, 39, 1, 1),
(3, 40, 6, 1),
(3, 41, 6, 1),
(3, 42, 6, 1),
(3, 43, 3, 1),
(3, 44, 5, 1),
(3, 45, 1, 1),
(3, 46, 10, 3),
(3, 47, 8, 3),
(3, 48, 7, 3),
(3, 49, 6, 3),
(3, 50, 11, 3),
(3, 51, 15, 3),
(3, 52, 13, 3),
(3, 53, 12, 3),
(3, 54, 5, 3),
(3, 55, 12, 3),
(3, 56, 13, 3),
(3, 57, 16, 3),
(3, 58, 9, 3),
(3, 59, 9, 3),
(3, 60, 52, 10),
(3, 61, 15, 3),
(3, 62, 16, 3),
(3, 63, 6, 3),
(3, 64, 12, 3),
(3, 67, 1, 0),
(4, 1, 9, 2),
(4, 2, 6, 2),
(4, 3, 5, 2),
(4, 4, 3, 2),
(4, 5, 9, 2),
(4, 6, 4, 2),
(4, 7, 9, 2),
(4, 8, 6, 2),
(4, 9, 8, 2),
(4, 10, 2, 1),
(4, 11, 3, 1),
(4, 12, 3, 1),
(4, 15, 15, 3),
(4, 16, 10, 3),
(4, 17, 16, 3),
(4, 18, 15, 3),
(4, 19, 11, 3),
(4, 20, 10, 3),
(4, 21, 6, 3),
(4, 22, 12, 3),
(4, 23, 9, 3),
(4, 24, 12, 3),
(4, 25, 7, 3),
(4, 26, 16, 3),
(4, 27, 11, 3),
(4, 28, 5, 3),
(4, 29, 5, 3),
(4, 30, 6, 3),
(4, 31, 7, 3),
(4, 32, 5, 3),
(4, 33, 15, 3),
(4, 34, 7, 3),
(4, 35, 4, 1),
(4, 36, 4, 1),
(4, 37, 2, 1),
(4, 38, 4, 1),
(4, 39, 5, 1),
(4, 40, 4, 1),
(4, 41, 2, 1),
(4, 42, 4, 1),
(4, 43, 4, 1),
(4, 44, 6, 1),
(4, 45, 4, 1),
(4, 46, 11, 3),
(4, 47, 11, 3),
(4, 48, 14, 3),
(4, 49, 12, 3),
(4, 50, 6, 3),
(4, 51, 11, 3),
(4, 52, 14, 3),
(4, 53, 15, 3),
(4, 54, 12, 3),
(4, 55, 8, 3),
(4, 56, 6, 3),
(4, 57, 11, 3),
(4, 58, 9, 3),
(4, 59, 13, 3),
(4, 60, 76, 10),
(4, 61, 6, 3),
(4, 62, 14, 3),
(4, 63, 13, 3),
(4, 64, 15, 3),
(4, 67, 0, 0),
(5, 1, 7, 2),
(5, 2, 9, 2),
(5, 3, 7, 2),
(5, 4, 4, 2),
(5, 5, 9, 2),
(5, 6, 8, 2),
(5, 7, 9, 2),
(5, 8, 6, 2),
(5, 9, 7, 2),
(5, 10, 6, 1),
(5, 11, 4, 1),
(5, 12, 3, 1),
(5, 15, 14, 3),
(5, 16, 11, 3),
(5, 17, 7, 3),
(5, 18, 7, 3),
(5, 19, 9, 3),
(5, 20, 10, 3),
(5, 21, 16, 3),
(5, 22, 15, 3),
(5, 23, 14, 3),
(5, 24, 5, 3),
(5, 25, 5, 3),
(5, 26, 9, 3),
(5, 27, 12, 3),
(5, 28, 6, 3),
(5, 29, 13, 3),
(5, 30, 9, 3),
(5, 31, 15, 3),
(5, 32, 16, 3),
(5, 33, 13, 3),
(5, 34, 5, 3),
(5, 35, 4, 1),
(5, 36, 5, 1),
(5, 37, 2, 1),
(5, 38, 4, 1),
(5, 39, 5, 1),
(5, 40, 3, 1),
(5, 41, 3, 1),
(5, 42, 1, 1),
(5, 43, 3, 1),
(5, 44, 2, 1),
(5, 45, 5, 1),
(5, 46, 12, 3),
(5, 47, 9, 3),
(5, 48, 9, 3),
(5, 49, 5, 3),
(5, 50, 7, 3),
(5, 51, 10, 3),
(5, 52, 7, 3),
(5, 53, 6, 3),
(5, 54, 14, 3),
(5, 55, 11, 3),
(5, 56, 5, 3),
(5, 57, 12, 3),
(5, 58, 11, 3),
(5, 59, 8, 3),
(5, 60, 74, 10),
(5, 61, 11, 3),
(5, 62, 10, 3),
(5, 63, 8, 3),
(5, 64, 10, 3),
(5, 67, 2, 0),
(6, 1, 7, 2),
(6, 2, 3, 2),
(6, 3, 5, 2),
(6, 4, 6, 2),
(6, 5, 3, 2),
(6, 6, 7, 2),
(6, 7, 9, 2),
(6, 8, 6, 2),
(6, 9, 6, 2),
(6, 10, 1, 1),
(6, 11, 6, 1),
(6, 12, 2, 1),
(6, 15, 12, 3),
(6, 16, 10, 3),
(6, 17, 5, 3),
(6, 18, 9, 3),
(6, 19, 14, 3),
(6, 20, 15, 3),
(6, 21, 14, 3),
(6, 22, 12, 3),
(6, 23, 16, 3),
(6, 24, 14, 3),
(6, 25, 6, 3),
(6, 26, 11, 3),
(6, 27, 7, 3),
(6, 28, 15, 3),
(6, 29, 7, 3),
(6, 30, 11, 3),
(6, 31, 16, 3),
(6, 32, 7, 3),
(6, 33, 9, 3),
(6, 34, 14, 3),
(6, 35, 2, 1),
(6, 36, 1, 1),
(6, 37, 6, 1),
(6, 38, 4, 1),
(6, 39, 6, 1),
(6, 40, 1, 1),
(6, 41, 4, 1),
(6, 42, 5, 1),
(6, 43, 5, 1),
(6, 44, 6, 1),
(6, 45, 4, 1),
(6, 46, 9, 3),
(6, 47, 10, 3),
(6, 48, 16, 3),
(6, 49, 9, 3),
(6, 50, 14, 3),
(6, 51, 15, 3),
(6, 52, 7, 3),
(6, 53, 13, 3),
(6, 54, 15, 3),
(6, 55, 16, 3),
(6, 56, 15, 3),
(6, 57, 9, 3),
(6, 58, 16, 3),
(6, 59, 10, 3),
(6, 60, 48, 10),
(6, 61, 7, 3),
(6, 62, 7, 3),
(6, 63, 15, 3),
(6, 64, 10, 3),
(6, 67, 2, 0),
(7, 1, 5, 2),
(7, 2, 4, 2),
(7, 3, 9, 2),
(7, 4, 5, 2),
(7, 5, 3, 2),
(7, 6, 7, 2),
(7, 7, 6, 2),
(7, 8, 6, 2),
(7, 9, 9, 2),
(7, 10, 1, 1),
(7, 11, 3, 1),
(7, 12, 2, 1),
(7, 15, 9, 3),
(7, 16, 8, 3),
(7, 17, 13, 3),
(7, 18, 6, 3),
(7, 19, 12, 3),
(7, 20, 7, 3),
(7, 21, 6, 3),
(7, 22, 11, 3),
(7, 23, 13, 3),
(7, 24, 8, 3),
(7, 25, 14, 3),
(7, 26, 14, 3),
(7, 27, 10, 3),
(7, 28, 11, 3),
(7, 29, 13, 3),
(7, 30, 6, 3),
(7, 31, 16, 3),
(7, 32, 11, 3),
(7, 33, 7, 3),
(7, 34, 6, 3),
(7, 35, 1, 1),
(7, 36, 3, 1),
(7, 37, 5, 1),
(7, 38, 1, 1),
(7, 39, 1, 1),
(7, 40, 2, 1),
(7, 41, 3, 1),
(7, 42, 2, 1),
(7, 43, 3, 1),
(7, 44, 4, 1),
(7, 45, 5, 1),
(7, 46, 12, 3),
(7, 47, 10, 3),
(7, 48, 8, 3),
(7, 49, 5, 3),
(7, 50, 5, 3),
(7, 51, 10, 3),
(7, 52, 5, 3),
(7, 53, 7, 3),
(7, 54, 16, 3),
(7, 55, 14, 3),
(7, 56, 12, 3),
(7, 57, 15, 3),
(7, 58, 16, 3),
(7, 59, 12, 3),
(7, 60, 63, 10),
(7, 61, 12, 3),
(7, 62, 9, 3),
(7, 63, 13, 3),
(7, 64, 13, 3),
(7, 67, 2, 0),
(8, 1, 3, 2),
(8, 2, 3, 2),
(8, 3, 8, 2),
(8, 4, 3, 2),
(8, 5, 3, 2),
(8, 6, 7, 2),
(8, 7, 3, 2),
(8, 8, 3, 2),
(8, 9, 4, 2),
(8, 10, 2, 1),
(8, 11, 2, 1),
(8, 12, 1, 1),
(8, 15, 14, 3),
(8, 16, 16, 3),
(8, 17, 8, 3),
(8, 18, 5, 3),
(8, 19, 11, 3),
(8, 20, 10, 3),
(8, 21, 9, 3),
(8, 22, 12, 3),
(8, 23, 12, 3),
(8, 24, 6, 3),
(8, 25, 7, 3),
(8, 26, 8, 3),
(8, 27, 12, 3),
(8, 28, 11, 3),
(8, 29, 7, 3),
(8, 30, 13, 3),
(8, 31, 16, 3),
(8, 32, 12, 3),
(8, 33, 15, 3),
(8, 34, 7, 3),
(8, 35, 1, 1),
(8, 36, 6, 1),
(8, 37, 3, 1),
(8, 38, 3, 1),
(8, 39, 2, 1),
(8, 40, 2, 1),
(8, 41, 1, 1),
(8, 42, 4, 1),
(8, 43, 1, 1),
(8, 44, 5, 1),
(8, 45, 5, 1),
(8, 46, 6, 3),
(8, 47, 9, 3),
(8, 48, 9, 3),
(8, 49, 8, 3),
(8, 50, 8, 3),
(8, 51, 12, 3),
(8, 52, 11, 3),
(8, 53, 5, 3),
(8, 54, 5, 3),
(8, 55, 6, 3),
(8, 56, 7, 3),
(8, 57, 6, 3),
(8, 58, 7, 3),
(8, 59, 15, 3),
(8, 60, 43, 10),
(8, 61, 16, 3),
(8, 62, 11, 3),
(8, 63, 11, 3),
(8, 64, 11, 3),
(8, 67, 0, 0),
(9, 1, 9, 2),
(9, 2, 3, 2),
(9, 3, 8, 2),
(9, 4, 5, 2),
(9, 5, 5, 2),
(9, 6, 7, 2),
(9, 7, 8, 2),
(9, 8, 9, 2),
(9, 9, 9, 2),
(9, 10, 2, 1),
(9, 11, 6, 1),
(9, 12, 2, 1),
(9, 15, 13, 3),
(9, 16, 7, 3),
(9, 17, 10, 3),
(9, 18, 5, 3),
(9, 19, 12, 3),
(9, 20, 15, 3),
(9, 21, 16, 3),
(9, 22, 5, 3),
(9, 23, 6, 3),
(9, 24, 9, 3),
(9, 25, 11, 3),
(9, 26, 10, 3),
(9, 27, 12, 3),
(9, 28, 11, 3),
(9, 29, 6, 3),
(9, 30, 7, 3),
(9, 31, 11, 3),
(9, 32, 10, 3),
(9, 33, 16, 3),
(9, 34, 7, 3),
(9, 35, 3, 1),
(9, 36, 5, 1),
(9, 37, 1, 1),
(9, 38, 2, 1),
(9, 39, 6, 1),
(9, 40, 6, 1),
(9, 41, 5, 1),
(9, 42, 1, 1),
(9, 43, 1, 1),
(9, 44, 3, 1),
(9, 45, 6, 1),
(9, 46, 16, 3),
(9, 47, 11, 3),
(9, 48, 15, 3),
(9, 49, 7, 3),
(9, 50, 5, 3),
(9, 51, 8, 3),
(9, 52, 7, 3),
(9, 53, 10, 3),
(9, 54, 15, 3),
(9, 55, 13, 3),
(9, 56, 13, 3),
(9, 57, 8, 3),
(9, 58, 15, 3),
(9, 59, 7, 3),
(9, 60, 70, 10),
(9, 61, 6, 3),
(9, 62, 11, 3),
(9, 63, 16, 3),
(9, 64, 8, 3),
(9, 67, 2, 0),
(10, 1, 4, 2),
(10, 2, 7, 2),
(10, 3, 5, 2),
(10, 4, 3, 2),
(10, 5, 3, 2),
(10, 6, 3, 2),
(10, 7, 4, 2),
(10, 8, 7, 2),
(10, 9, 5, 2),
(10, 10, 6, 1),
(10, 11, 5, 1),
(10, 12, 2, 1),
(10, 15, 9, 3),
(10, 16, 9, 3),
(10, 17, 7, 3),
(10, 18, 6, 3),
(10, 19, 9, 3),
(10, 20, 8, 3),
(10, 21, 6, 3),
(10, 22, 8, 3),
(10, 23, 10, 3),
(10, 24, 12, 3),
(10, 25, 16, 3),
(10, 26, 12, 3),
(10, 27, 7, 3),
(10, 28, 6, 3),
(10, 29, 5, 3),
(10, 30, 13, 3),
(10, 31, 8, 3),
(10, 32, 16, 3),
(10, 33, 10, 3),
(10, 34, 12, 3),
(10, 35, 6, 1),
(10, 36, 5, 1),
(10, 37, 5, 1),
(10, 38, 5, 1),
(10, 39, 4, 1),
(10, 40, 1, 1),
(10, 41, 5, 1),
(10, 42, 6, 1),
(10, 43, 3, 1),
(10, 44, 2, 1),
(10, 45, 1, 1),
(10, 46, 14, 3),
(10, 47, 10, 3),
(10, 48, 10, 3),
(10, 49, 7, 3),
(10, 50, 6, 3),
(10, 51, 15, 3),
(10, 52, 6, 3),
(10, 53, 6, 3),
(10, 54, 6, 3),
(10, 55, 11, 3),
(10, 56, 13, 3),
(10, 57, 12, 3),
(10, 58, 16, 3),
(10, 59, 7, 3),
(10, 60, 75, 10),
(10, 61, 15, 3),
(10, 62, 10, 3),
(10, 63, 9, 3),
(10, 64, 5, 3),
(10, 67, 2, 0);

-- ---------------------------------------------------------------------
-- Operaciones del periodo en orden cronológico:
--   órdenes de compra y su recepción (sp_recibir_orden),
--   cambios de precio (los registra la bitácora por trigger),
--   intercambios y ventas (los importes los calculan los triggers)
-- ---------------------------------------------------------------------
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (1, '2026-10-01 12:20:00', 4, 20, 26, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (1, 63, 2, NULL), (1, 15, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (2, '2026-10-01 12:30:00', 5, 22, 12, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (2, 28, 1, NULL), (2, 27, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (3, '2026-10-01 12:35:00', 1, 6, 2, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (3, 63, 1, NULL), (3, 15, 1, NULL), (3, 22, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (4, '2026-10-01 18:25:00', 5, 22, 10, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (4, 1, 1, NULL), (4, 54, 1, NULL);
INSERT INTO intercambios (id_intercambio, fecha, id_sucursal, id_empleado, id_cliente, forma_pago) VALUES (1, '2026-10-01 19:25:00', 3, 15, 52, 'Crédito en tienda');
INSERT INTO detalle_intercambio (id_intercambio, id_producto, cantidad, valor_unitario) VALUES (1, 10, 1, NULL), (1, 42, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (5, '2026-10-01 19:30:00', 10, 42, 30, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (5, 15, 1, NULL);
INSERT INTO intercambios (id_intercambio, fecha, id_sucursal, id_empleado, id_cliente, forma_pago) VALUES (2, '2026-10-02 14:00:00', 2, 10, 35, 'Crédito en tienda');
INSERT INTO detalle_intercambio (id_intercambio, id_producto, cantidad, valor_unitario) VALUES (2, 41, 1, NULL), (2, 44, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (6, '2026-10-02 14:50:00', 6, 26, 24, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (6, 32, 1, NULL), (6, 27, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (7, '2026-10-02 14:55:00', 1, 6, 35, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (7, 15, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (8, '2026-10-02 15:40:00', 6, 29, 18, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (8, 46, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (9, '2026-10-02 16:10:00', 10, 42, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (9, 20, 1, NULL), (9, 50, 1, NULL), (9, 55, 1, NULL);
INSERT INTO intercambios (id_intercambio, fecha, id_sucursal, id_empleado, id_cliente, forma_pago) VALUES (3, '2026-10-02 16:15:00', 9, 40, 50, 'Crédito en tienda');
INSERT INTO detalle_intercambio (id_intercambio, id_producto, cantidad, valor_unitario) VALUES (3, 42, 1, NULL), (3, 43, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (10, '2026-10-02 17:05:00', 3, 13, 2, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (10, 5, 1, NULL), (10, 31, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (11, '2026-10-02 19:55:00', 9, 40, 50, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (11, 6, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (12, '2026-10-03 10:00:00', 7, 32, 6, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (12, 53, 1, NULL), (12, 31, 1, NULL), (12, 5, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (13, '2026-10-03 10:35:00', 5, 21, 46, 'Tarjeta de regalo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (13, 5, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (14, '2026-10-03 11:00:00', 6, 29, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (14, 24, 1, NULL);
INSERT INTO intercambios (id_intercambio, fecha, id_sucursal, id_empleado, id_cliente, forma_pago) VALUES (4, '2026-10-03 11:25:00', 8, 37, 13, 'Efectivo');
INSERT INTO detalle_intercambio (id_intercambio, id_producto, cantidad, valor_unitario) VALUES (4, 43, 2, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (15, '2026-10-03 13:30:00', 6, 28, 24, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (15, 15, 1, NULL), (15, 20, 1, NULL);
INSERT INTO intercambios (id_intercambio, fecha, id_sucursal, id_empleado, id_cliente, forma_pago) VALUES (5, '2026-10-03 13:50:00', 2, 10, 23, 'Efectivo');
INSERT INTO detalle_intercambio (id_intercambio, id_producto, cantidad, valor_unitario) VALUES (5, 37, 1, NULL), (5, 12, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (16, '2026-10-03 14:55:00', 3, 13, 23, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (16, 59, 2, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (17, '2026-10-03 15:15:00', 3, 12, 35, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (17, 34, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (18, '2026-10-03 18:05:00', 2, 8, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (18, 19, 1, NULL), (18, 26, 1, NULL), (18, 18, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (19, '2026-10-03 18:15:00', 4, 16, NULL, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (19, 11, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (20, '2026-10-03 20:25:00', 1, 7, 34, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (20, 1, 1, NULL), (20, 50, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (21, '2026-10-04 10:10:00', 6, 28, 22, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (21, 54, 1, NULL), (21, 29, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (22, '2026-10-04 10:25:00', 6, 27, 22, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (22, 15, 1, NULL), (22, 27, 1, NULL);
INSERT INTO intercambios (id_intercambio, fecha, id_sucursal, id_empleado, id_cliente, forma_pago) VALUES (6, '2026-10-04 13:40:00', 4, 20, 20, 'Crédito en tienda');
INSERT INTO detalle_intercambio (id_intercambio, id_producto, cantidad, valor_unitario) VALUES (6, 41, 1, NULL), (6, 42, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (23, '2026-10-04 14:30:00', 2, 11, 4, 'Tarjeta de regalo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (23, 16, 1, NULL), (23, 50, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (24, '2026-10-04 15:45:00', 1, 7, 52, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (24, 16, 1, NULL), (24, 64, 1, NULL), (24, 30, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (25, '2026-10-04 17:40:00', 1, 7, 45, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (25, 46, 1, NULL), (25, 19, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (26, '2026-10-04 18:45:00', 7, 30, 18, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (26, 61, 3, NULL), (26, 52, 1, NULL);
INSERT INTO intercambios (id_intercambio, fecha, id_sucursal, id_empleado, id_cliente, forma_pago) VALUES (7, '2026-10-04 19:15:00', 1, 6, 34, 'Crédito en tienda');
INSERT INTO detalle_intercambio (id_intercambio, id_producto, cantidad, valor_unitario) VALUES (7, 36, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (27, '2026-10-04 20:30:00', 7, 32, 6, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (27, 20, 1, NULL), (27, 30, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (28, '2026-10-05 12:35:00', 8, 34, 55, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (28, 32, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (29, '2026-10-05 13:40:00', 5, 21, NULL, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (29, 62, 1, NULL), (29, 22, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (30, '2026-10-05 14:10:00', 6, 28, 24, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (30, 1, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (31, '2026-10-05 15:35:00', 8, 36, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (31, 7, 1, NULL), (31, 15, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (32, '2026-10-05 17:00:00', 10, 45, 30, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (32, 53, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (33, '2026-10-05 17:15:00', 4, 18, 41, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (33, 37, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (34, '2026-10-05 18:30:00', 9, 38, 44, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (34, 50, 1, NULL), (34, 21, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (35, '2026-10-05 18:30:00', 10, 42, 17, 'Tarjeta de regalo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (35, 30, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (36, '2026-10-05 19:40:00', 10, 45, 30, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (36, 25, 1, NULL), (36, 20, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (37, '2026-10-06 10:35:00', 4, 17, 40, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (37, 30, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (38, '2026-10-06 11:10:00', 10, 45, 30, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (38, 55, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (39, '2026-10-06 11:20:00', 1, 7, 33, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (39, 6, 1, NULL), (39, 50, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (40, '2026-10-06 13:05:00', 8, 37, 13, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (40, 11, 1, NULL), (40, 27, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (41, '2026-10-06 13:20:00', 1, 4, NULL, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (41, 47, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (42, '2026-10-06 15:35:00', 6, 27, NULL, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (42, 55, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (43, '2026-10-06 20:55:00', 1, 4, 56, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (43, 59, 3, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (44, '2026-10-07 10:50:00', 5, 22, NULL, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (44, 7, 1, NULL), (44, 35, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (45, '2026-10-07 11:25:00', 9, 40, 54, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (45, 63, 1, NULL), (45, 56, 2, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (46, '2026-10-07 14:10:00', 3, 14, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (46, 61, 1, NULL), (46, 40, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (47, '2026-10-07 14:25:00', 8, 37, 48, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (47, 37, 1, NULL);
INSERT INTO intercambios (id_intercambio, fecha, id_sucursal, id_empleado, id_cliente, forma_pago) VALUES (8, '2026-10-07 16:25:00', 6, 29, 18, 'Crédito en tienda');
INSERT INTO detalle_intercambio (id_intercambio, id_producto, cantidad, valor_unitario) VALUES (8, 45, 1, NULL), (8, 39, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (48, '2026-10-07 17:45:00', 1, 3, 47, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (48, 40, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (49, '2026-10-07 17:55:00', 5, 23, 59, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (49, 19, 1, NULL), (49, 60, 3, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (50, '2026-10-08 10:05:00', 3, 13, 47, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (50, 7, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (51, '2026-10-08 13:25:00', 8, 34, 13, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (51, 28, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (52, '2026-10-08 13:50:00', 7, 31, NULL, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (52, 61, 3, NULL), (52, 36, 1, NULL), (52, 2, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (53, '2026-10-08 14:50:00', 1, 3, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (53, 20, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (54, '2026-10-08 16:25:00', 2, 9, 45, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (54, 32, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (55, '2026-10-08 17:50:00', 2, 9, 4, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (55, 39, 1, NULL), (55, 37, 1, NULL), (55, 57, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (56, '2026-10-09 10:50:00', 6, 28, 22, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (56, 11, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (57, '2026-10-09 11:30:00', 5, 21, 20, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (57, 48, 1, NULL), (57, 3, 1, NULL), (57, 6, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (58, '2026-10-09 14:15:00', 5, 22, 41, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (58, 55, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (59, '2026-10-09 16:00:00', 1, 6, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (59, 11, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (60, '2026-10-09 16:20:00', 6, 27, 3, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (60, 36, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (61, '2026-10-09 16:20:00', 2, 11, 34, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (61, 15, 1, NULL), (61, 35, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (62, '2026-10-09 18:20:00', 6, 25, 24, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (62, 34, 1, NULL);
INSERT INTO intercambios (id_intercambio, fecha, id_sucursal, id_empleado, id_cliente, forma_pago) VALUES (9, '2026-10-09 20:05:00', 2, 10, 33, 'Crédito en tienda');
INSERT INTO detalle_intercambio (id_intercambio, id_producto, cantidad, valor_unitario) VALUES (9, 38, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (63, '2026-10-10 10:30:00', 6, 26, 3, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (63, 29, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (64, '2026-10-10 11:10:00', 1, 4, 43, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (64, 37, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (65, '2026-10-10 12:45:00', 8, 36, 17, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (65, 2, 1, NULL);
INSERT INTO intercambios (id_intercambio, fecha, id_sucursal, id_empleado, id_cliente, forma_pago) VALUES (10, '2026-10-10 13:45:00', 10, 43, 30, 'Crédito en tienda');
INSERT INTO detalle_intercambio (id_intercambio, id_producto, cantidad, valor_unitario) VALUES (10, 11, 1, NULL);
INSERT INTO intercambios (id_intercambio, fecha, id_sucursal, id_empleado, id_cliente, forma_pago) VALUES (11, '2026-10-10 13:45:00', 10, 44, 53, 'Efectivo');
INSERT INTO detalle_intercambio (id_intercambio, id_producto, cantidad, valor_unitario) VALUES (11, 39, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (66, '2026-10-10 13:55:00', 4, 19, NULL, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (66, 2, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (67, '2026-10-10 14:45:00', 2, 10, 23, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (67, 36, 1, NULL), (67, 32, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (68, '2026-10-10 16:20:00', 8, 37, 13, 'Tarjeta de regalo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (68, 39, 1, NULL);
INSERT INTO intercambios (id_intercambio, fecha, id_sucursal, id_empleado, id_cliente, forma_pago) VALUES (12, '2026-10-10 17:25:00', 1, 5, 4, 'Crédito en tienda');
INSERT INTO detalle_intercambio (id_intercambio, id_producto, cantidad, valor_unitario) VALUES (12, 10, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (69, '2026-10-10 17:40:00', 1, 4, NULL, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (69, 27, 1, NULL), (69, 29, 1, NULL), (69, 43, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (70, '2026-10-10 18:00:00', 6, 28, NULL, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (70, 34, 1, NULL), (70, 18, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (71, '2026-10-11 11:00:00', 5, 21, 59, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (71, 24, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (72, '2026-10-11 11:35:00', 1, 4, 43, 'Tarjeta de regalo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (72, 27, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (73, '2026-10-11 13:10:00', 4, 20, 19, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (73, 52, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (74, '2026-10-11 17:30:00', 4, 19, 26, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (74, 45, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (75, '2026-10-11 18:05:00', 8, 34, 33, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (75, 15, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (76, '2026-10-11 20:40:00', 8, 37, 13, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (76, 46, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (77, '2026-10-11 20:45:00', 3, 14, 56, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (77, 35, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (78, '2026-10-12 10:40:00', 2, 11, 43, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (78, 8, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (79, '2026-10-12 10:55:00', 5, 23, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (79, 27, 1, NULL), (79, 6, 1, NULL), (79, 61, 1, NULL), (79, 60, 9, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (80, '2026-10-12 13:55:00', 4, 19, NULL, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (80, 63, 3, NULL), (80, 7, 1, NULL), (80, 49, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (81, '2026-10-12 16:10:00', 5, 22, NULL, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (81, 52, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (82, '2026-10-12 17:35:00', 10, 42, NULL, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (82, 7, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (83, '2026-10-12 18:30:00', 1, 6, NULL, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (83, 55, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (84, '2026-10-13 11:55:00', 4, 20, 45, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (84, 62, 3, NULL), (84, 15, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (85, '2026-10-13 15:40:00', 8, 36, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (85, 48, 1, NULL), (85, 43, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (86, '2026-10-13 16:15:00', 2, 8, NULL, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (86, 10, 1, NULL), (86, 52, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (87, '2026-10-13 19:20:00', 2, 9, 51, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (87, 45, 1, NULL), (87, 17, 1, NULL), (87, 15, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (88, '2026-10-13 20:25:00', 8, 35, 32, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (88, 62, 1, NULL), (88, 15, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (89, '2026-10-13 20:40:00', 8, 36, 48, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (89, 57, 1, NULL), (89, 56, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (90, '2026-10-14 11:05:00', 10, 45, 53, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (90, 63, 1, NULL), (90, 1, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (91, '2026-10-14 11:25:00', 2, 9, 45, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (91, 6, 1, NULL), (91, 30, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (92, '2026-10-14 12:00:00', 4, 19, NULL, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (92, 4, 1, NULL), (92, 34, 1, NULL), (92, 44, 1, NULL);
INSERT INTO intercambios (id_intercambio, fecha, id_sucursal, id_empleado, id_cliente, forma_pago) VALUES (13, '2026-10-14 12:35:00', 8, 35, 39, 'Efectivo');
INSERT INTO detalle_intercambio (id_intercambio, id_producto, cantidad, valor_unitario) VALUES (13, 10, 1, NULL);
INSERT INTO intercambios (id_intercambio, fecha, id_sucursal, id_empleado, id_cliente, forma_pago) VALUES (14, '2026-10-14 14:45:00', 7, 33, 6, 'Efectivo');
INSERT INTO detalle_intercambio (id_intercambio, id_producto, cantidad, valor_unitario) VALUES (14, 44, 1, NULL), (14, 11, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (93, '2026-10-14 16:00:00', 10, 43, 30, 'Crédito en tienda');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (93, 61, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (94, '2026-10-14 19:15:00', 9, 39, 36, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (94, 21, 1, NULL);
SET @fecha_operacion = '2026-10-15 07:00:00';
UPDATE productos SET precio_venta = 59.99 WHERE id_producto = 19;  -- Madden NFL 26
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (95, '2026-10-15 10:00:00', 6, 25, 3, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (95, 49, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (96, '2026-10-15 12:45:00', 2, 9, 28, 'Tarjeta de regalo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (96, 2, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (97, '2026-10-15 15:20:00', 7, 33, 6, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (97, 1, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (98, '2026-10-15 17:15:00', 6, 26, NULL, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (98, 19, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (99, '2026-10-15 17:35:00', 3, 14, 33, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (99, 19, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (100, '2026-10-15 18:45:00', 5, 23, 14, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (100, 15, 1, NULL), (100, 51, 1, NULL), (100, 16, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (101, '2026-10-16 13:20:00', 3, 12, 15, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (101, 12, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (102, '2026-10-16 13:35:00', 4, 18, 1, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (102, 22, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (103, '2026-10-16 16:40:00', 9, 39, 54, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (103, 30, 1, NULL), (103, 52, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (104, '2026-10-16 17:30:00', 1, 4, 47, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (104, 46, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (105, '2026-10-16 18:35:00', 9, 39, 12, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (105, 22, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (106, '2026-10-16 18:45:00', 10, 45, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (106, 36, 1, NULL), (106, 8, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (107, '2026-10-16 19:15:00', 1, 4, 43, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (107, 21, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (108, '2026-10-17 11:35:00', 7, 30, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (108, 35, 1, NULL), (108, 32, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (109, '2026-10-17 14:00:00', 5, 21, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (109, 17, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (110, '2026-10-17 14:05:00', 6, 27, 9, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (110, 18, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (111, '2026-10-17 14:50:00', 6, 27, NULL, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (111, 1, 1, NULL), (111, 25, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (112, '2026-10-17 15:20:00', 9, 38, 36, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (112, 54, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (113, '2026-10-17 17:20:00', 7, 30, 38, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (113, 50, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (114, '2026-10-17 18:15:00', 3, 14, 35, 'Tarjeta de regalo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (114, 31, 1, NULL), (114, 17, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (115, '2026-10-17 20:45:00', 4, 16, NULL, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (115, 51, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (116, '2026-10-18 10:20:00', 4, 20, 46, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (116, 33, 1, NULL), (116, 31, 1, NULL), (116, 35, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (117, '2026-10-18 12:40:00', 6, 27, NULL, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (117, 60, 9, NULL), (117, 29, 1, NULL), (117, 26, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (118, '2026-10-18 13:40:00', 3, 15, 28, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (118, 7, 1, NULL), (118, 45, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (119, '2026-10-18 14:15:00', 2, 8, 34, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (119, 54, 1, NULL), (119, 24, 1, NULL), (119, 8, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (120, '2026-10-18 15:05:00', 2, 10, 56, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (120, 32, 1, NULL), (120, 26, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (121, '2026-10-18 16:25:00', 9, 40, 21, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (121, 54, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (122, '2026-10-18 17:40:00', 5, 23, 31, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (122, 6, 1, NULL), (122, 46, 1, NULL), (122, 38, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (123, '2026-10-18 19:20:00', 4, 16, 57, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (123, 6, 1, NULL), (123, 4, 1, NULL), (123, 28, 1, NULL), (123, 12, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (124, '2026-10-18 19:25:00', 10, 42, 53, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (124, 4, 1, NULL), (124, 3, 1, NULL);
INSERT INTO intercambios (id_intercambio, fecha, id_sucursal, id_empleado, id_cliente, forma_pago) VALUES (15, '2026-10-18 19:30:00', 1, 6, 47, 'Crédito en tienda');
INSERT INTO detalle_intercambio (id_intercambio, id_producto, cantidad, valor_unitario) VALUES (15, 40, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (125, '2026-10-18 19:30:00', 8, 36, 17, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (125, 63, 2, NULL), (125, 27, 1, NULL), (125, 7, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (126, '2026-10-18 20:45:00', 8, 36, NULL, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (126, 61, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (127, '2026-10-19 12:45:00', 7, 33, 9, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (127, 1, 1, NULL), (127, 54, 1, NULL), (127, 49, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (128, '2026-10-19 15:20:00', 6, 28, 22, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (128, 21, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (129, '2026-10-19 18:25:00', 4, 17, 7, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (129, 7, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (130, '2026-10-19 18:35:00', 8, 37, 13, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (130, 60, 5, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (131, '2026-10-19 18:35:00', 10, 44, 53, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (131, 17, 1, NULL), (131, 9, 1, NULL), (131, 24, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (132, '2026-10-19 19:05:00', 8, 34, 13, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (132, 27, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (133, '2026-10-19 19:45:00', 2, 9, 25, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (133, 18, 1, NULL), (133, 17, 1, NULL);
INSERT INTO ordenes_compra (id_orden, fecha, id_proveedor, id_sucursal, id_empleado, estado) VALUES (11, '2026-10-20', 3, 1, 3, 'Pendiente');
INSERT INTO detalle_orden_compra (id_orden, id_producto, cantidad, costo_unitario) VALUES (11, 6, 6, 385.00), (11, 29, 10, 48.00);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (134, '2026-10-20 11:00:00', 6, 25, 24, 'Tarjeta de regalo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (134, 44, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (135, '2026-10-20 11:15:00', 6, 27, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (135, 60, 3, NULL), (135, 24, 1, NULL), (135, 61, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (136, '2026-10-20 11:40:00', 5, 21, 26, 'Tarjeta de regalo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (136, 41, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (137, '2026-10-20 13:00:00', 2, 10, 23, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (137, 31, 1, NULL);
INSERT INTO intercambios (id_intercambio, fecha, id_sucursal, id_empleado, id_cliente, forma_pago) VALUES (16, '2026-10-20 13:20:00', 9, 39, 21, 'Crédito en tienda');
INSERT INTO detalle_intercambio (id_intercambio, id_producto, cantidad, valor_unitario) VALUES (16, 40, 2, NULL), (16, 37, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (138, '2026-10-20 14:55:00', 4, 19, 41, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (138, 15, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (139, '2026-10-20 15:05:00', 10, 43, 42, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (139, 4, 1, NULL), (139, 46, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (140, '2026-10-20 15:35:00', 1, 3, 25, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (140, 48, 1, NULL), (140, 7, 1, NULL), (140, 28, 1, NULL), (140, 53, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (141, '2026-10-20 17:40:00', 5, 24, 1, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (141, 60, 8, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (142, '2026-10-20 19:35:00', 6, 26, 18, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (142, 35, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (143, '2026-10-21 10:55:00', 1, 6, 45, 'Tarjeta de regalo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (143, 61, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (144, '2026-10-21 12:30:00', 2, 10, 12, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (144, 7, 1, NULL);
INSERT INTO intercambios (id_intercambio, fecha, id_sucursal, id_empleado, id_cliente, forma_pago) VALUES (17, '2026-10-21 12:50:00', 7, 31, 16, 'Crédito en tienda');
INSERT INTO detalle_intercambio (id_intercambio, id_producto, cantidad, valor_unitario) VALUES (17, 45, 1, NULL), (17, 11, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (145, '2026-10-21 12:55:00', 8, 36, 48, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (145, 51, 1, NULL), (145, 27, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (146, '2026-10-21 13:00:00', 7, 32, 11, 'Tarjeta de regalo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (146, 32, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (147, '2026-10-21 13:25:00', 7, 32, 11, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (147, 45, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (148, '2026-10-21 13:35:00', 3, 15, NULL, 'Tarjeta de regalo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (148, 18, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (149, '2026-10-21 13:45:00', 6, 29, 3, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (149, 23, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (150, '2026-10-21 14:15:00', 2, 11, NULL, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (150, 32, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (151, '2026-10-21 17:10:00', 3, 13, 52, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (151, 4, 1, NULL);
INSERT INTO ordenes_compra (id_orden, fecha, id_proveedor, id_sucursal, id_empleado, estado) VALUES (12, '2026-10-22', 1, 4, 16, 'Pendiente');
INSERT INTO detalle_orden_compra (id_orden, id_producto, cantidad, costo_unitario) VALUES (12, 1, 6, 420.00), (12, 46, 10, 52.00);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (152, '2026-10-22 11:25:00', 1, 4, 23, 'Tarjeta de regalo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (152, 28, 1, NULL), (152, 49, 1, NULL), (152, 6, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (153, '2026-10-22 12:00:00', 3, 15, 35, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (153, 29, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (154, '2026-10-22 13:05:00', 8, 34, 17, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (154, 31, 1, NULL), (154, 46, 1, NULL), (154, 28, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (155, '2026-10-22 13:50:00', 1, 3, NULL, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (155, 3, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (156, '2026-10-22 19:00:00', 5, 24, 41, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (156, 18, 1, NULL), (156, 50, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (157, '2026-10-22 20:10:00', 1, 5, 15, 'Tarjeta de regalo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (157, 33, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (158, '2026-10-23 12:00:00', 5, 24, 26, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (158, 21, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (159, '2026-10-23 12:10:00', 3, 12, 47, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (159, 6, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (160, '2026-10-23 12:55:00', 4, 20, 46, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (160, 46, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (161, '2026-10-23 16:15:00', 8, 34, 32, 'Tarjeta de regalo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (161, 22, 1, NULL), (161, 60, 5, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (162, '2026-10-23 17:05:00', 3, 12, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (162, 57, 2, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (163, '2026-10-23 17:55:00', 4, 17, 1, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (163, 59, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (164, '2026-10-23 18:15:00', 3, 13, 4, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (164, 22, 1, NULL), (164, 54, 1, NULL), (164, 21, 1, NULL), (164, 27, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (165, '2026-10-24 11:55:00', 5, 23, 31, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (165, 48, 1, NULL), (165, 1, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (166, '2026-10-24 16:20:00', 5, 24, 7, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (166, 19, 1, NULL), (166, 59, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (167, '2026-10-24 17:00:00', 1, 6, NULL, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (167, 20, 1, NULL), (167, 26, 1, NULL), (167, 9, 1, NULL), (167, 55, 3, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (168, '2026-10-24 18:25:00', 3, 15, 60, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (168, 22, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (169, '2026-10-24 18:55:00', 2, 11, NULL, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (169, 41, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (170, '2026-10-24 19:10:00', 6, 27, 22, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (170, 28, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (171, '2026-10-24 20:15:00', 3, 15, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (171, 24, 1, NULL), (171, 18, 1, NULL), (171, 28, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (172, '2026-10-24 20:45:00', 7, 32, 6, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (172, 54, 1, NULL), (172, 19, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (173, '2026-10-25 13:10:00', 2, 8, NULL, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (173, 61, 3, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (174, '2026-10-25 16:00:00', 1, 7, 2, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (174, 23, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (175, '2026-10-25 16:20:00', 1, 5, NULL, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (175, 27, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (176, '2026-10-25 16:45:00', 4, 18, NULL, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (176, 1, 1, NULL), (176, 6, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (177, '2026-10-25 18:05:00', 2, 10, NULL, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (177, 21, 1, NULL), (177, 30, 1, NULL), (177, 19, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (178, '2026-10-25 19:15:00', 7, 31, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (178, 24, 1, NULL), (178, 57, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (179, '2026-10-25 19:20:00', 3, 13, NULL, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (179, 9, 1, NULL), (179, 17, 1, NULL), (179, 41, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (180, '2026-10-26 10:10:00', 3, 15, NULL, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (180, 21, 1, NULL), (180, 49, 1, NULL), (180, 27, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (181, '2026-10-26 12:10:00', 4, 18, 41, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (181, 18, 1, NULL), (181, 56, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (182, '2026-10-26 14:45:00', 7, 32, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (182, 15, 1, NULL), (182, 7, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (183, '2026-10-26 14:45:00', 3, 13, 45, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (183, 52, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (184, '2026-10-26 16:50:00', 1, 3, 15, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (184, 6, 1, NULL), (184, 18, 1, NULL);
INSERT INTO intercambios (id_intercambio, fecha, id_sucursal, id_empleado, id_cliente, forma_pago) VALUES (18, '2026-10-26 17:30:00', 9, 40, 36, 'Crédito en tienda');
INSERT INTO detalle_intercambio (id_intercambio, id_producto, cantidad, valor_unitario) VALUES (18, 36, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (185, '2026-10-26 18:15:00', 7, 31, 9, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (185, 3, 1, NULL), (185, 38, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (186, '2026-10-26 20:40:00', 6, 28, 21, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (186, 25, 1, NULL);
CALL sp_recibir_orden(11, '2026-10-27');
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (187, '2026-10-27 13:05:00', 9, 38, 54, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (187, 17, 1, NULL), (187, 59, 2, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (188, '2026-10-27 13:50:00', 4, 19, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (188, 7, 1, NULL), (188, 6, 1, NULL), (188, 16, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (189, '2026-10-27 14:25:00', 7, 33, 11, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (189, 55, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (190, '2026-10-27 15:30:00', 4, 18, 57, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (190, 38, 1, NULL), (190, 15, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (191, '2026-10-27 17:20:00', 8, 34, NULL, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (191, 27, 1, NULL), (191, 46, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (192, '2026-10-27 17:25:00', 6, 28, NULL, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (192, 62, 3, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (193, '2026-10-27 17:45:00', 5, 21, 20, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (193, 15, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (194, '2026-10-27 20:40:00', 6, 28, NULL, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (194, 21, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (195, '2026-10-27 20:55:00', 4, 16, 58, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (195, 9, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (196, '2026-10-28 10:05:00', 8, 35, 46, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (196, 40, 1, NULL), (196, 55, 3, NULL), (196, 3, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (197, '2026-10-28 12:55:00', 7, 32, 6, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (197, 3, 1, NULL), (197, 64, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (198, '2026-10-28 15:20:00', 1, 3, 52, 'Crédito en tienda');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (198, 17, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (199, '2026-10-28 16:05:00', 7, 32, 38, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (199, 15, 1, NULL), (199, 31, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (200, '2026-10-28 19:55:00', 7, 33, 9, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (200, 36, 1, NULL), (200, 21, 1, NULL);
CALL sp_recibir_orden(12, '2026-10-29');
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (201, '2026-10-29 10:55:00', 7, 31, NULL, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (201, 57, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (202, '2026-10-29 14:50:00', 6, 25, NULL, 'Tarjeta de regalo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (202, 45, 1, NULL), (202, 19, 1, NULL), (202, 5, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (203, '2026-10-29 15:15:00', 3, 12, 45, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (203, 25, 1, NULL), (203, 26, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (204, '2026-10-29 18:25:00', 3, 15, 2, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (204, 46, 1, NULL), (204, 57, 2, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (205, '2026-10-29 19:10:00', 4, 18, 57, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (205, 17, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (206, '2026-10-29 20:15:00', 5, 23, 57, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (206, 56, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (207, '2026-10-30 11:15:00', 6, 29, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (207, 12, 1, NULL), (207, 35, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (208, '2026-10-30 11:25:00', 1, 7, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (208, 59, 1, NULL), (208, 49, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (209, '2026-10-30 11:30:00', 3, 14, 4, 'Crédito en tienda');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (209, 41, 1, NULL);
INSERT INTO intercambios (id_intercambio, fecha, id_sucursal, id_empleado, id_cliente, forma_pago) VALUES (19, '2026-10-30 11:55:00', 10, 43, 42, 'Crédito en tienda');
INSERT INTO detalle_intercambio (id_intercambio, id_producto, cantidad, valor_unitario) VALUES (19, 12, 1, NULL);
INSERT INTO intercambios (id_intercambio, fecha, id_sucursal, id_empleado, id_cliente, forma_pago) VALUES (20, '2026-10-30 11:55:00', 7, 32, 11, 'Crédito en tienda');
INSERT INTO detalle_intercambio (id_intercambio, id_producto, cantidad, valor_unitario) VALUES (20, 38, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (210, '2026-10-30 12:05:00', 8, 34, 13, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (210, 52, 1, NULL), (210, 45, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (211, '2026-10-30 13:25:00', 4, 18, 19, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (211, 37, 1, NULL), (211, 57, 1, NULL), (211, 36, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (212, '2026-10-30 15:20:00', 10, 42, 30, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (212, 53, 1, NULL), (212, 25, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (213, '2026-10-30 15:25:00', 7, 32, 6, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (213, 6, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (214, '2026-10-30 16:50:00', 1, 5, 45, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (214, 15, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (215, '2026-10-30 17:05:00', 8, 34, 32, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (215, 21, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (216, '2026-10-31 10:10:00', 6, 27, 3, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (216, 29, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (217, '2026-10-31 11:50:00', 8, 34, 48, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (217, 45, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (218, '2026-10-31 12:55:00', 1, 3, 4, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (218, 50, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (219, '2026-10-31 14:05:00', 10, 43, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (219, 31, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (220, '2026-10-31 14:15:00', 1, 4, NULL, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (220, 53, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (221, '2026-10-31 15:35:00', 2, 11, 35, 'Tarjeta de regalo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (221, 64, 2, NULL), (221, 37, 1, NULL), (221, 60, 9, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (222, '2026-10-31 16:25:00', 6, 28, 18, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (222, 1, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (223, '2026-10-31 17:05:00', 1, 6, NULL, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (223, 23, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (224, '2026-10-31 17:40:00', 3, 14, 25, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (224, 20, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (225, '2026-10-31 20:05:00', 1, 3, NULL, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (225, 54, 1, NULL), (225, 58, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (226, '2026-10-31 20:50:00', 7, 33, 11, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (226, 59, 2, NULL), (226, 27, 1, NULL), (226, 42, 1, NULL), (226, 25, 1, NULL);
SET @fecha_operacion = '2026-11-01 07:00:00';
UPDATE productos SET precio_venta = 12.99 WHERE id_producto = 36;  -- Grand Theft Auto V (usado)
SET @fecha_operacion = '2026-11-01 07:00:00';
UPDATE productos SET precio_venta = 24.99 WHERE id_producto = 35;  -- Elden Ring (usado)
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (227, '2026-11-01 10:55:00', 6, 25, 24, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (227, 37, 1, NULL), (227, 19, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (228, '2026-11-01 11:40:00', 1, 6, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (228, 6, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (229, '2026-11-01 13:00:00', 3, 15, 44, 'Tarjeta de regalo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (229, 24, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (230, '2026-11-01 13:50:00', 4, 20, 7, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (230, 15, 1, NULL), (230, 30, 1, NULL), (230, 12, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (231, '2026-11-01 14:00:00', 3, 15, NULL, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (231, 26, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (232, '2026-11-01 15:00:00', 9, 41, 54, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (232, 23, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (233, '2026-11-01 16:25:00', 4, 20, 19, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (233, 30, 1, NULL), (233, 23, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (234, '2026-11-01 19:20:00', 1, 5, 33, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (234, 17, 1, NULL);
INSERT INTO intercambios (id_intercambio, fecha, id_sucursal, id_empleado, id_cliente, forma_pago) VALUES (21, '2026-11-01 20:00:00', 8, 37, 17, 'Efectivo');
INSERT INTO detalle_intercambio (id_intercambio, id_producto, cantidad, valor_unitario) VALUES (21, 45, 1, NULL), (21, 39, 1, NULL);
INSERT INTO ordenes_compra (id_orden, fecha, id_proveedor, id_sucursal, id_empleado, estado) VALUES (18, '2026-11-02', 7, 5, 21, 'Pendiente');
INSERT INTO detalle_orden_compra (id_orden, id_producto, cantidad, costo_unitario) VALUES (18, 25, 6, 40.00);
UPDATE ordenes_compra SET estado = 'Cancelada' WHERE id_orden = 18;
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (235, '2026-11-02 11:35:00', 7, 31, 38, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (235, 18, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (236, '2026-11-02 14:15:00', 8, 35, NULL, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (236, 39, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (237, '2026-11-02 15:15:00', 4, 19, 25, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (237, 16, 1, NULL), (237, 60, 3, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (238, '2026-11-02 15:45:00', 1, 6, NULL, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (238, 9, 1, NULL), (238, 35, 1, NULL), (238, 21, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (239, '2026-11-02 17:05:00', 1, 3, NULL, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (239, 4, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (240, '2026-11-02 18:15:00', 3, 14, 2, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (240, 23, 1, NULL), (240, 54, 1, NULL), (240, 16, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (241, '2026-11-02 18:30:00', 10, 42, 42, 'Crédito en tienda');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (241, 28, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (242, '2026-11-02 20:10:00', 2, 10, 35, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (242, 50, 1, NULL), (242, 16, 1, NULL), (242, 21, 1, NULL);
INSERT INTO ordenes_compra (id_orden, fecha, id_proveedor, id_sucursal, id_empleado, estado) VALUES (1, '2026-11-03', 6, 1, 3, 'Pendiente');
INSERT INTO detalle_orden_compra (id_orden, id_producto, cantidad, costo_unitario) VALUES (1, 13, 40, 48.00), (1, 14, 15, 48.00);
INSERT INTO ordenes_compra (id_orden, fecha, id_proveedor, id_sucursal, id_empleado, estado) VALUES (2, '2026-11-03', 6, 2, 8, 'Pendiente');
INSERT INTO detalle_orden_compra (id_orden, id_producto, cantidad, costo_unitario) VALUES (2, 13, 30, 48.00), (2, 14, 10, 48.00);
INSERT INTO ordenes_compra (id_orden, fecha, id_proveedor, id_sucursal, id_empleado, estado) VALUES (3, '2026-11-03', 6, 3, 12, 'Pendiente');
INSERT INTO detalle_orden_compra (id_orden, id_producto, cantidad, costo_unitario) VALUES (3, 13, 30, 48.00), (3, 14, 10, 48.00);
INSERT INTO ordenes_compra (id_orden, fecha, id_proveedor, id_sucursal, id_empleado, estado) VALUES (4, '2026-11-03', 6, 4, 16, 'Pendiente');
INSERT INTO detalle_orden_compra (id_orden, id_producto, cantidad, costo_unitario) VALUES (4, 13, 40, 48.00), (4, 14, 15, 48.00);
INSERT INTO ordenes_compra (id_orden, fecha, id_proveedor, id_sucursal, id_empleado, estado) VALUES (5, '2026-11-03', 6, 5, 21, 'Pendiente');
INSERT INTO detalle_orden_compra (id_orden, id_producto, cantidad, costo_unitario) VALUES (5, 13, 30, 48.00), (5, 14, 10, 48.00);
INSERT INTO ordenes_compra (id_orden, fecha, id_proveedor, id_sucursal, id_empleado, estado) VALUES (6, '2026-11-03', 6, 6, 25, 'Pendiente');
INSERT INTO detalle_orden_compra (id_orden, id_producto, cantidad, costo_unitario) VALUES (6, 13, 40, 48.00), (6, 14, 15, 48.00);
INSERT INTO ordenes_compra (id_orden, fecha, id_proveedor, id_sucursal, id_empleado, estado) VALUES (7, '2026-11-03', 6, 7, 30, 'Pendiente');
INSERT INTO detalle_orden_compra (id_orden, id_producto, cantidad, costo_unitario) VALUES (7, 13, 30, 48.00), (7, 14, 10, 48.00);
INSERT INTO ordenes_compra (id_orden, fecha, id_proveedor, id_sucursal, id_empleado, estado) VALUES (8, '2026-11-03', 6, 8, 34, 'Pendiente');
INSERT INTO detalle_orden_compra (id_orden, id_producto, cantidad, costo_unitario) VALUES (8, 13, 30, 48.00), (8, 14, 10, 48.00);
INSERT INTO ordenes_compra (id_orden, fecha, id_proveedor, id_sucursal, id_empleado, estado) VALUES (9, '2026-11-03', 6, 9, 38, 'Pendiente');
INSERT INTO detalle_orden_compra (id_orden, id_producto, cantidad, costo_unitario) VALUES (9, 13, 30, 48.00), (9, 14, 10, 48.00);
INSERT INTO ordenes_compra (id_orden, fecha, id_proveedor, id_sucursal, id_empleado, estado) VALUES (10, '2026-11-03', 6, 10, 42, 'Pendiente');
INSERT INTO detalle_orden_compra (id_orden, id_producto, cantidad, costo_unitario) VALUES (10, 13, 30, 48.00), (10, 14, 10, 48.00);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (243, '2026-11-03 12:05:00', 4, 20, NULL, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (243, 1, 1, NULL), (243, 6, 1, NULL), (243, 27, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (244, '2026-11-03 13:20:00', 3, 15, 51, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (244, 22, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (245, '2026-11-03 13:30:00', 2, 11, NULL, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (245, 23, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (246, '2026-11-03 14:35:00', 2, 9, 34, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (246, 59, 2, NULL), (246, 60, 2, NULL), (246, 27, 1, NULL), (246, 62, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (247, '2026-11-03 17:05:00', 6, 29, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (247, 22, 1, NULL), (247, 3, 1, NULL), (247, 20, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (248, '2026-11-03 20:50:00', 7, 30, 11, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (248, 17, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (249, '2026-11-04 10:55:00', 4, 16, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (249, 52, 1, NULL), (249, 32, 1, NULL), (249, 50, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (250, '2026-11-04 12:40:00', 5, 24, 40, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (250, 47, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (251, '2026-11-04 13:20:00', 6, 26, 18, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (251, 15, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (252, '2026-11-04 14:00:00', 1, 5, 45, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (252, 50, 1, NULL), (252, 29, 1, NULL), (252, 40, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (253, '2026-11-04 18:00:00', 1, 4, 43, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (253, 62, 1, NULL);
INSERT INTO ordenes_compra (id_orden, fecha, id_proveedor, id_sucursal, id_empleado, estado) VALUES (13, '2026-11-05', 3, 6, 25, 'Pendiente');
INSERT INTO detalle_orden_compra (id_orden, id_producto, cantidad, costo_unitario) VALUES (13, 7, 6, 430.00), (13, 27, 8, 56.00), (13, 30, 8, 48.00);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (254, '2026-11-05 10:30:00', 9, 39, 50, 'Tarjeta de regalo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (254, 39, 1, NULL), (254, 42, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (255, '2026-11-05 11:05:00', 10, 42, NULL, 'Tarjeta de regalo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (255, 55, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (256, '2026-11-05 11:45:00', 6, 26, 3, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (256, 49, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (257, '2026-11-05 11:55:00', 1, 4, 4, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (257, 63, 3, NULL), (257, 3, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (258, '2026-11-05 13:55:00', 9, 40, NULL, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (258, 18, 1, NULL), (258, 16, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (259, '2026-11-05 14:40:00', 5, 24, 1, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (259, 15, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (260, '2026-11-05 16:05:00', 5, 24, 46, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (260, 40, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (261, '2026-11-05 17:25:00', 4, 16, NULL, 'Tarjeta de regalo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (261, 50, 1, NULL), (261, 20, 1, NULL), (261, 56, 2, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (262, '2026-11-06 10:00:00', 4, 20, NULL, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (262, 27, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (263, '2026-11-06 11:00:00', 6, 29, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (263, 6, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (264, '2026-11-06 11:35:00', 6, 26, 49, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (264, 8, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (265, '2026-11-06 12:45:00', 9, 41, 12, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (265, 60, 10, NULL), (265, 29, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (266, '2026-11-06 13:10:00', 1, 4, 34, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (266, 35, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (267, '2026-11-06 13:25:00', 4, 16, NULL, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (267, 36, 1, NULL), (267, 39, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (268, '2026-11-06 13:30:00', 9, 38, 37, 'Tarjeta de regalo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (268, 21, 1, NULL), (268, 36, 1, NULL), (268, 12, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (269, '2026-11-06 19:40:00', 4, 19, 41, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (269, 49, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (270, '2026-11-06 20:15:00', 4, 19, 5, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (270, 56, 2, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (271, '2026-11-07 11:35:00', 6, 29, 49, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (271, 61, 1, NULL), (271, 21, 1, NULL), (271, 64, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (272, '2026-11-07 13:30:00', 3, 12, 45, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (272, 6, 1, NULL), (272, 20, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (273, '2026-11-07 13:40:00', 8, 36, 29, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (273, 7, 1, NULL), (273, 8, 1, NULL), (273, 53, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (274, '2026-11-07 13:40:00', 9, 41, 44, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (274, 37, 1, NULL), (274, 7, 1, NULL), (274, 5, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (275, '2026-11-07 14:05:00', 4, 20, 41, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (275, 20, 1, NULL), (275, 34, 1, NULL), (275, 36, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (276, '2026-11-07 16:20:00', 9, 41, 54, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (276, 26, 1, NULL), (276, 21, 1, NULL), (276, 51, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (277, '2026-11-07 17:50:00', 3, 12, 2, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (277, 53, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (278, '2026-11-07 19:05:00', 4, 16, 20, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (278, 15, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (279, '2026-11-07 19:15:00', 10, 43, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (279, 35, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (280, '2026-11-07 19:40:00', 5, 23, 26, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (280, 61, 2, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (281, '2026-11-08 11:25:00', 3, 14, 33, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (281, 18, 1, NULL), (281, 8, 1, NULL), (281, 21, 1, NULL), (281, 25, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (282, '2026-11-08 12:55:00', 1, 4, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (282, 54, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (283, '2026-11-08 14:05:00', 5, 24, 31, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (283, 38, 1, NULL), (283, 61, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (284, '2026-11-08 15:40:00', 7, 31, 6, 'Tarjeta de regalo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (284, 3, 1, NULL), (284, 29, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (285, '2026-11-08 16:05:00', 1, 4, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (285, 46, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (286, '2026-11-08 16:25:00', 8, 34, 30, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (286, 20, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (287, '2026-11-08 19:30:00', 10, 43, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (287, 46, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (288, '2026-11-08 20:45:00', 7, 30, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (288, 19, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (289, '2026-11-09 10:35:00', 6, 25, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (289, 18, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (290, '2026-11-09 12:30:00', 6, 26, 3, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (290, 26, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (291, '2026-11-09 14:10:00', 2, 9, 45, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (291, 52, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (292, '2026-11-09 14:55:00', 8, 36, 55, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (292, 15, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (293, '2026-11-09 16:50:00', 8, 36, 55, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (293, 31, 1, NULL), (293, 38, 1, NULL), (293, 48, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (294, '2026-11-09 18:15:00', 9, 40, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (294, 21, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (295, '2026-11-09 19:00:00', 6, 26, 49, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (295, 26, 1, NULL), (295, 38, 1, NULL), (295, 19, 1, NULL);
INSERT INTO intercambios (id_intercambio, fecha, id_sucursal, id_empleado, id_cliente, forma_pago) VALUES (22, '2026-11-09 19:40:00', 6, 27, 24, 'Crédito en tienda');
INSERT INTO detalle_intercambio (id_intercambio, id_producto, cantidad, valor_unitario) VALUES (22, 36, 2, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (296, '2026-11-09 20:40:00', 3, 14, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (296, 18, 1, NULL);
INSERT INTO ordenes_compra (id_orden, fecha, id_proveedor, id_sucursal, id_empleado, estado) VALUES (14, '2026-11-10', 13, 7, 30, 'Pendiente');
INSERT INTO detalle_orden_compra (id_orden, id_producto, cantidad, costo_unitario) VALUES (14, 59, 12, 40.00), (14, 60, 60, 3.00);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (297, '2026-11-10 10:20:00', 2, 10, 28, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (297, 30, 1, NULL), (297, 9, 1, NULL), (297, 38, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (298, '2026-11-10 10:25:00', 4, 16, 10, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (298, 3, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (299, '2026-11-10 11:10:00', 2, 11, 43, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (299, 4, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (300, '2026-11-10 11:45:00', 5, 24, 5, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (300, 2, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (301, '2026-11-10 13:15:00', 8, 34, 32, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (301, 63, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (302, '2026-11-10 17:35:00', 5, 21, NULL, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (302, 57, 2, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (303, '2026-11-11 12:40:00', 7, 31, 41, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (303, 60, 9, NULL), (303, 41, 1, NULL), (303, 1, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (304, '2026-11-11 15:05:00', 4, 16, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (304, 42, 1, NULL), (304, 27, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (305, '2026-11-11 15:25:00', 10, 43, 30, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (305, 7, 1, NULL), (305, 36, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (306, '2026-11-11 15:40:00', 6, 28, 22, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (306, 42, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (307, '2026-11-11 16:55:00', 8, 36, 32, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (307, 6, 1, NULL), (307, 5, 1, NULL), (307, 52, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (308, '2026-11-11 17:25:00', 6, 28, 3, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (308, 36, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (309, '2026-11-11 18:45:00', 8, 34, 13, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (309, 18, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (310, '2026-11-11 20:35:00', 8, 36, 38, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (310, 8, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (311, '2026-11-11 20:35:00', 4, 20, 15, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (311, 17, 1, NULL), (311, 19, 1, NULL), (311, 30, 1, NULL), (311, 58, 3, NULL);
CALL sp_recibir_orden(13, '2026-11-12');
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (312, '2026-11-12 10:50:00', 4, 20, NULL, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (312, 18, 1, NULL), (312, 28, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (313, '2026-11-12 16:10:00', 5, 21, 5, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (313, 20, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (314, '2026-11-12 17:10:00', 9, 41, 54, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (314, 46, 1, NULL), (314, 6, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (315, '2026-11-12 18:30:00', 7, 32, 9, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (315, 50, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (316, '2026-11-12 20:20:00', 8, 37, 48, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (316, 27, 1, NULL), (316, 46, 1, NULL), (316, 2, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (317, '2026-11-13 11:25:00', 7, 32, 38, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (317, 4, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (318, '2026-11-13 14:05:00', 4, 16, 58, 'Tarjeta de regalo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (318, 22, 1, NULL), (318, 49, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (319, '2026-11-13 15:40:00', 10, 45, 46, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (319, 8, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (320, '2026-11-13 18:45:00', 8, 36, 55, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (320, 29, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (321, '2026-11-13 19:10:00', 10, 45, 53, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (321, 28, 1, NULL);
CALL sp_recibir_orden(14, '2026-11-14');
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (322, '2026-11-14 11:45:00', 5, 22, 40, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (322, 6, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (323, '2026-11-14 11:55:00', 1, 4, 28, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (323, 61, 1, NULL), (323, 22, 1, NULL);
INSERT INTO intercambios (id_intercambio, fecha, id_sucursal, id_empleado, id_cliente, forma_pago) VALUES (23, '2026-11-14 12:40:00', 2, 11, 4, 'Crédito en tienda');
INSERT INTO detalle_intercambio (id_intercambio, id_producto, cantidad, valor_unitario) VALUES (23, 43, 1, NULL), (23, 10, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (324, '2026-11-14 13:35:00', 4, 19, NULL, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (324, 43, 1, NULL), (324, 61, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (325, '2026-11-14 13:40:00', 8, 36, 32, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (325, 24, 1, NULL), (325, 18, 1, NULL), (325, 28, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (326, '2026-11-14 18:35:00', 5, 21, 44, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (326, 58, 3, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (327, '2026-11-14 19:00:00', 3, 13, 28, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (327, 19, 1, NULL), (327, 27, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (328, '2026-11-14 20:45:00', 1, 4, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (328, 6, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (329, '2026-11-15 10:20:00', 4, 20, 8, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (329, 15, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (330, '2026-11-15 13:35:00', 1, 7, 33, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (330, 63, 1, NULL), (330, 4, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (331, '2026-11-15 14:00:00', 4, 18, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (331, 15, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (332, '2026-11-15 16:55:00', 1, 5, 28, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (332, 24, 1, NULL), (332, 45, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (333, '2026-11-15 17:10:00', 8, 37, 17, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (333, 22, 1, NULL), (333, 49, 1, NULL), (333, 6, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (334, '2026-11-15 18:45:00', 6, 27, 24, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (334, 42, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (335, '2026-11-15 19:05:00', 10, 45, 42, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (335, 20, 1, NULL), (335, 15, 1, NULL), (335, 27, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (336, '2026-11-15 19:45:00', 10, 42, 53, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (336, 25, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (337, '2026-11-15 20:00:00', 6, 28, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (337, 33, 1, NULL), (337, 28, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (338, '2026-11-16 11:55:00', 4, 17, NULL, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (338, 7, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (339, '2026-11-16 12:20:00', 7, 32, NULL, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (339, 46, 1, NULL), (339, 4, 1, NULL);
INSERT INTO intercambios (id_intercambio, fecha, id_sucursal, id_empleado, id_cliente, forma_pago) VALUES (24, '2026-11-16 13:25:00', 10, 45, 27, 'Efectivo');
INSERT INTO detalle_intercambio (id_intercambio, id_producto, cantidad, valor_unitario) VALUES (24, 37, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (340, '2026-11-16 14:30:00', 3, 13, NULL, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (340, 32, 1, NULL), (340, 8, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (341, '2026-11-16 15:20:00', 8, 36, 19, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (341, 4, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (342, '2026-11-16 17:55:00', 5, 22, 40, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (342, 63, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (343, '2026-11-16 20:00:00', 2, 9, 47, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (343, 32, 1, NULL), (343, 15, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (344, '2026-11-16 20:05:00', 8, 37, 7, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (344, 19, 1, NULL);
CALL sp_recibir_orden(1, '2026-11-17');
CALL sp_recibir_orden(2, '2026-11-17');
CALL sp_recibir_orden(3, '2026-11-17');
CALL sp_recibir_orden(4, '2026-11-17');
CALL sp_recibir_orden(5, '2026-11-17');
CALL sp_recibir_orden(6, '2026-11-17');
CALL sp_recibir_orden(7, '2026-11-17');
CALL sp_recibir_orden(8, '2026-11-17');
CALL sp_recibir_orden(9, '2026-11-17');
CALL sp_recibir_orden(10, '2026-11-17');
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (345, '2026-11-17 11:05:00', 7, 30, 9, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (345, 7, 1, NULL), (345, 44, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (346, '2026-11-17 11:20:00', 3, 15, 25, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (346, 29, 1, NULL), (346, 51, 1, NULL), (346, 37, 1, NULL), (346, 27, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (347, '2026-11-17 12:55:00', 2, 11, 34, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (347, 29, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (348, '2026-11-17 13:20:00', 3, 13, 4, 'Crédito en tienda');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (348, 46, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (349, '2026-11-17 15:20:00', 4, 20, 5, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (349, 39, 1, NULL), (349, 63, 1, NULL), (349, 21, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (350, '2026-11-17 16:10:00', 1, 4, 43, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (350, 28, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (351, '2026-11-17 16:35:00', 1, 6, 35, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (351, 50, 1, NULL), (351, 17, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (352, '2026-11-17 17:45:00', 2, 8, 2, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (352, 29, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (353, '2026-11-17 18:20:00', 5, 22, NULL, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (353, 9, 1, NULL), (353, 16, 1, NULL);
INSERT INTO intercambios (id_intercambio, fecha, id_sucursal, id_empleado, id_cliente, forma_pago) VALUES (25, '2026-11-17 19:00:00', 10, 44, 42, 'Crédito en tienda');
INSERT INTO detalle_intercambio (id_intercambio, id_producto, cantidad, valor_unitario) VALUES (25, 36, 2, NULL), (25, 41, 2, NULL), (25, 11, 1, NULL);
INSERT INTO ordenes_compra (id_orden, fecha, id_proveedor, id_sucursal, id_empleado, estado) VALUES (15, '2026-11-18', 1, 2, 8, 'Pendiente');
INSERT INTO detalle_orden_compra (id_orden, id_producto, cantidad, costo_unitario) VALUES (15, 3, 4, 650.00), (15, 47, 4, 145.00);
INSERT INTO intercambios (id_intercambio, fecha, id_sucursal, id_empleado, id_cliente, forma_pago) VALUES (26, '2026-11-18 10:20:00', 8, 36, 17, 'Crédito en tienda');
INSERT INTO detalle_intercambio (id_intercambio, id_producto, cantidad, valor_unitario) VALUES (26, 45, 2, NULL), (26, 41, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (354, '2026-11-18 11:20:00', 9, 38, 37, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (354, 19, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (355, '2026-11-18 11:30:00', 9, 39, 12, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (355, 27, 1, NULL), (355, 57, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (356, '2026-11-18 11:35:00', 6, 26, 24, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (356, 43, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (357, '2026-11-18 11:50:00', 9, 40, 12, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (357, 37, 1, NULL), (357, 19, 1, NULL), (357, 40, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (358, '2026-11-18 11:55:00', 1, 4, NULL, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (358, 17, 1, NULL), (358, 34, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (359, '2026-11-18 19:55:00', 6, 28, 22, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (359, 50, 1, NULL), (359, 42, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (360, '2026-11-19 10:15:00', 6, 27, 22, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (360, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (361, '2026-11-19 10:15:00', 4, 16, 14, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (361, 3, 1, NULL), (361, 29, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (362, '2026-11-19 12:15:00', 6, 26, NULL, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (362, 53, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (363, '2026-11-19 12:35:00', 10, 43, 53, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (363, 63, 1, NULL), (363, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (364, '2026-11-19 14:35:00', 8, 37, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (364, 34, 1, NULL), (364, 1, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (365, '2026-11-19 15:05:00', 8, 36, 32, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (365, 53, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (366, '2026-11-19 15:15:00', 3, 12, 35, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (366, 21, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (367, '2026-11-19 15:35:00', 7, 30, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (367, 32, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (368, '2026-11-19 15:45:00', 1, 5, 4, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (368, 13, 1, NULL), (368, 14, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (369, '2026-11-19 15:50:00', 10, 44, 42, 'Crédito en tienda');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (369, 17, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (370, '2026-11-19 16:00:00', 9, 38, 37, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (370, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (371, '2026-11-19 16:05:00', 5, 21, 59, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (371, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (372, '2026-11-19 16:25:00', 4, 20, 14, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (372, 63, 2, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (373, '2026-11-19 18:00:00', 4, 19, 10, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (373, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (374, '2026-11-19 18:55:00', 2, 11, NULL, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (374, 14, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (375, '2026-11-19 19:50:00', 5, 24, NULL, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (375, 24, 1, NULL), (375, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (376, '2026-11-19 20:20:00', 1, 7, 28, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (376, 23, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (377, '2026-11-19 20:25:00', 8, 34, 17, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (377, 17, 1, NULL), (377, 33, 1, NULL);
SET @fecha_operacion = '2026-11-20 07:00:00';
UPDATE productos SET precio_venta = 449.99 WHERE id_producto = 1;  -- PlayStation 5 Slim (lector de discos)
SET @fecha_operacion = '2026-11-20 07:00:00';
UPDATE productos SET precio_venta = 399.99 WHERE id_producto = 2;  -- PlayStation 5 Digital Edition
SET @fecha_operacion = '2026-11-20 07:00:00';
UPDATE productos SET precio_venta = 349.99 WHERE id_producto = 5;  -- Xbox Series S 512GB
SET @fecha_operacion = '2026-11-20 07:00:00';
UPDATE productos SET precio_venta = 54.99 WHERE id_producto = 46;  -- Control inalámbrico DualSense
SET @fecha_operacion = '2026-11-20 07:00:00';
UPDATE productos SET precio_venta = 29.99 WHERE id_producto = 22;  -- Marvel's Spider-Man 2
SET @fecha_operacion = '2026-11-20 07:00:00';
UPDATE productos SET precio_venta = 49.99 WHERE id_producto = 17;  -- Battlefield 6
SET @fecha_operacion = '2026-11-20 07:00:00';
UPDATE productos SET precio_venta = 79.99 WHERE id_producto = 53;  -- Audífonos Turtle Beach Stealth 600 Gen 3
INSERT INTO ordenes_compra (id_orden, fecha, id_proveedor, id_sucursal, id_empleado, estado) VALUES (16, '2026-11-20', 2, 8, 34, 'Pendiente');
INSERT INTO detalle_orden_compra (id_orden, id_producto, cantidad, costo_unitario) VALUES (16, 4, 4, 560.00), (16, 49, 8, 45.00);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (378, '2026-11-20 11:00:00', 4, 18, 57, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (378, 29, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (379, '2026-11-20 11:50:00', 3, 14, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (379, 63, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (380, '2026-11-20 12:05:00', 2, 8, 35, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (380, 13, 1, NULL), (380, 17, 1, NULL), (380, 14, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (381, '2026-11-20 12:15:00', 10, 43, 27, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (381, 56, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (382, '2026-11-20 12:50:00', 3, 15, 47, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (382, 14, 1, NULL), (382, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (383, '2026-11-20 14:15:00', 2, 8, 39, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (383, 10, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (384, '2026-11-20 14:15:00', 8, 35, 29, 'Tarjeta de regalo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (384, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (385, '2026-11-20 14:25:00', 7, 31, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (385, 14, 1, NULL), (385, 63, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (386, '2026-11-20 14:25:00', 7, 32, 9, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (386, 52, 1, NULL);
INSERT INTO intercambios (id_intercambio, fecha, id_sucursal, id_empleado, id_cliente, forma_pago) VALUES (27, '2026-11-20 14:50:00', 2, 9, 51, 'Crédito en tienda');
INSERT INTO detalle_intercambio (id_intercambio, id_producto, cantidad, valor_unitario) VALUES (27, 37, 1, NULL), (27, 45, 2, NULL);
INSERT INTO intercambios (id_intercambio, fecha, id_sucursal, id_empleado, id_cliente, forma_pago) VALUES (28, '2026-11-20 15:50:00', 7, 31, 11, 'Efectivo');
INSERT INTO detalle_intercambio (id_intercambio, id_producto, cantidad, valor_unitario) VALUES (28, 42, 1, NULL), (28, 45, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (387, '2026-11-20 15:50:00', 9, 40, 44, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (387, 45, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (388, '2026-11-20 15:55:00', 1, 7, 31, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (388, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (389, '2026-11-20 16:10:00', 9, 41, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (389, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (390, '2026-11-20 16:20:00', 5, 23, 41, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (390, 14, 1, NULL), (390, 9, 1, NULL), (390, 13, 1, NULL), (390, 34, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (391, '2026-11-20 16:20:00', 5, 22, 1, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (391, 51, 1, NULL), (391, 14, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (392, '2026-11-20 16:30:00', 4, 16, 10, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (392, 14, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (393, '2026-11-20 16:55:00', 4, 17, 41, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (393, 38, 1, NULL), (393, 14, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (394, '2026-11-20 16:55:00', 9, 39, 50, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (394, 15, 1, NULL), (394, 14, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (395, '2026-11-20 17:50:00', 9, 41, 54, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (395, 14, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (396, '2026-11-20 18:10:00', 10, 42, 49, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (396, 14, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (397, '2026-11-20 18:45:00', 5, 23, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (397, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (398, '2026-11-20 18:45:00', 7, 33, 9, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (398, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (399, '2026-11-20 18:55:00', 1, 3, 52, 'Tarjeta de regalo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (399, 30, 1, NULL), (399, 1, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (400, '2026-11-20 19:25:00', 3, 13, 45, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (400, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (401, '2026-11-20 20:15:00', 2, 8, 15, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (401, 13, 1, NULL);
INSERT INTO ordenes_compra (id_orden, fecha, id_proveedor, id_sucursal, id_empleado, estado) VALUES (17, '2026-11-21', 12, 3, 12, 'Pendiente');
INSERT INTO detalle_orden_compra (id_orden, id_producto, cantidad, costo_unitario) VALUES (17, 55, 20, 6.50), (17, 57, 20, 6.50);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (402, '2026-11-21 10:05:00', 4, 18, 19, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (402, 14, 1, NULL), (402, 22, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (403, '2026-11-21 10:20:00', 1, 6, NULL, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (403, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (404, '2026-11-21 10:25:00', 2, 10, 43, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (404, 13, 1, NULL), (404, 34, 1, NULL), (404, 14, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (405, '2026-11-21 11:10:00', 6, 26, 22, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (405, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (406, '2026-11-21 11:25:00', 1, 5, 45, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (406, 13, 1, NULL), (406, 49, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (407, '2026-11-21 11:50:00', 10, 43, 53, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (407, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (408, '2026-11-21 12:10:00', 8, 36, 29, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (408, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (409, '2026-11-21 12:55:00', 9, 38, 3, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (409, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (410, '2026-11-21 12:55:00', 5, 21, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (410, 14, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (411, '2026-11-21 13:00:00', 2, 9, 43, 'Tarjeta de regalo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (411, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (412, '2026-11-21 13:55:00', 9, 41, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (412, 14, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (413, '2026-11-21 14:50:00', 3, 15, 28, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (413, 13, 1, NULL), (413, 14, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (414, '2026-11-21 15:10:00', 1, 7, NULL, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (414, 14, 1, NULL), (414, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (415, '2026-11-21 15:35:00', 7, 33, 16, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (415, 14, 1, NULL), (415, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (416, '2026-11-21 15:35:00', 4, 16, 19, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (416, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (417, '2026-11-21 15:45:00', 7, 30, 16, 'Crédito en tienda');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (417, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (418, '2026-11-21 17:10:00', 1, 4, 35, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (418, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (419, '2026-11-21 17:55:00', 6, 29, 22, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (419, 15, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (420, '2026-11-21 18:20:00', 2, 9, 26, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (420, 14, 1, NULL), (420, 59, 1, NULL), (420, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (421, '2026-11-21 18:20:00', 1, 5, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (421, 30, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (422, '2026-11-21 19:00:00', 6, 26, 22, 'Tarjeta de regalo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (422, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (423, '2026-11-21 19:20:00', 10, 45, 30, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (423, 1, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (424, '2026-11-21 19:20:00', 2, 11, 35, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (424, 14, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (425, '2026-11-21 19:50:00', 6, 27, 49, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (425, 63, 1, NULL), (425, 19, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (426, '2026-11-21 20:15:00', 1, 6, 56, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (426, 22, 1, NULL);
INSERT INTO ordenes_compra (id_orden, fecha, id_proveedor, id_sucursal, id_empleado, estado) VALUES (19, '2026-11-22', 1, 1, 3, 'Pendiente');
INSERT INTO detalle_orden_compra (id_orden, id_producto, cantidad, costo_unitario) VALUES (19, 65, 15, 55.00);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (427, '2026-11-22 10:25:00', 1, 3, 35, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (427, 15, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (428, '2026-11-22 11:45:00', 6, 29, 3, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (428, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (429, '2026-11-22 11:55:00', 9, 38, 44, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (429, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (430, '2026-11-22 12:25:00', 8, 37, 32, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (430, 23, 1, NULL), (430, 35, 1, NULL), (430, 22, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (431, '2026-11-22 13:15:00', 9, 38, 50, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (431, 14, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (432, '2026-11-22 13:30:00', 8, 36, 39, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (432, 14, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (433, '2026-11-22 13:45:00', 7, 30, 38, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (433, 14, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (434, '2026-11-22 14:15:00', 3, 15, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (434, 23, 1, NULL), (434, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (435, '2026-11-22 14:20:00', 7, 33, 38, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (435, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (436, '2026-11-22 14:25:00', 3, 13, 51, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (436, 50, 1, NULL);
INSERT INTO intercambios (id_intercambio, fecha, id_sucursal, id_empleado, id_cliente, forma_pago) VALUES (29, '2026-11-22 14:45:00', 8, 36, 29, 'Efectivo');
INSERT INTO detalle_intercambio (id_intercambio, id_producto, cantidad, valor_unitario) VALUES (29, 38, 1, NULL), (29, 10, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (437, '2026-11-22 15:35:00', 9, 39, 50, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (437, 13, 1, NULL), (437, 14, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (438, '2026-11-22 17:15:00', 10, 43, 27, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (438, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (439, '2026-11-22 17:50:00', 5, 24, 7, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (439, 14, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (440, '2026-11-22 17:55:00', 1, 5, 56, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (440, 42, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (441, '2026-11-22 17:55:00', 4, 16, 46, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (441, 45, 1, NULL), (441, 13, 1, NULL), (441, 35, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (442, '2026-11-22 19:10:00', 2, 8, 51, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (442, 13, 1, NULL), (442, 40, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (443, '2026-11-22 20:00:00', 4, 16, 57, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (443, 14, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (444, '2026-11-22 20:10:00', 7, 30, 11, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (444, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (445, '2026-11-22 20:15:00', 4, 16, 10, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (445, 28, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (446, '2026-11-22 20:20:00', 4, 20, 14, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (446, 19, 1, NULL), (446, 14, 1, NULL), (446, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (447, '2026-11-22 20:35:00', 4, 20, NULL, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (447, 31, 1, NULL), (447, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (448, '2026-11-22 20:40:00', 1, 3, 56, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (448, 13, 1, NULL), (448, 14, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (449, '2026-11-22 20:40:00', 4, 18, NULL, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (449, 13, 1, NULL), (449, 57, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (450, '2026-11-23 10:00:00', 3, 14, 4, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (450, 14, 1, NULL), (450, 64, 1, NULL), (450, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (451, '2026-11-23 10:45:00', 1, 6, 31, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (451, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (452, '2026-11-23 11:00:00', 6, 25, 22, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (452, 10, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (453, '2026-11-23 11:40:00', 4, 18, 19, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (453, 14, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (454, '2026-11-23 11:40:00', 4, 16, 8, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (454, 14, 1, NULL), (454, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (455, '2026-11-23 12:25:00', 1, 7, 15, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (455, 15, 1, NULL), (455, 29, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (456, '2026-11-23 12:40:00', 7, 30, NULL, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (456, 46, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (457, '2026-11-23 13:25:00', 4, 20, 20, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (457, 49, 1, NULL), (457, 14, 1, NULL);
INSERT INTO intercambios (id_intercambio, fecha, id_sucursal, id_empleado, id_cliente, forma_pago) VALUES (30, '2026-11-23 15:55:00', 6, 29, 22, 'Crédito en tienda');
INSERT INTO detalle_intercambio (id_intercambio, id_producto, cantidad, valor_unitario) VALUES (30, 42, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (458, '2026-11-23 16:25:00', 4, 19, 1, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (458, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (459, '2026-11-23 16:45:00', 10, 43, 27, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (459, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (460, '2026-11-23 16:45:00', 5, 23, 46, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (460, 32, 1, NULL), (460, 14, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (461, '2026-11-23 17:00:00', 7, 31, 11, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (461, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (462, '2026-11-23 17:00:00', 10, 45, 42, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (462, 14, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (463, '2026-11-23 17:25:00', 4, 17, 57, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (463, 14, 1, NULL), (463, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (464, '2026-11-23 17:25:00', 1, 4, NULL, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (464, 11, 1, NULL), (464, 26, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (465, '2026-11-23 17:35:00', 9, 38, 50, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (465, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (466, '2026-11-23 17:40:00', 1, 4, 51, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (466, 57, 3, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (467, '2026-11-23 18:05:00', 8, 34, 19, 'Tarjeta de débito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (467, 14, 1, NULL), (467, 27, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (468, '2026-11-23 18:10:00', 6, 25, 3, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (468, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (469, '2026-11-23 18:40:00', 7, 30, 16, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (469, 13, 1, NULL), (469, 14, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (470, '2026-11-23 18:40:00', 5, 22, 46, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (470, 13, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (471, '2026-11-23 18:55:00', 1, 3, 51, 'Efectivo');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (471, 15, 1, NULL), (471, 17, 1, NULL), (471, 13, 1, NULL), (471, 26, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (472, '2026-11-23 19:35:00', 9, 40, 50, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (472, 13, 1, NULL), (472, 46, 1, NULL);
INSERT INTO ventas (id_venta, fecha, id_sucursal, id_empleado, id_cliente, metodo_pago) VALUES (473, '2026-11-23 20:40:00', 6, 25, NULL, 'Tarjeta de crédito');
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (473, 13, 1, NULL), (473, 63, 1, NULL);
SET @fecha_operacion = NULL;

-- ---------------------------------------------------------------------
-- Devoluciones (el trigger valida cantidades y plazo, regresa inventario
-- y calcula el reembolso con impuesto)
-- ---------------------------------------------------------------------
INSERT INTO devoluciones (id_devolucion, id_venta, fecha, id_empleado, motivo) VALUES (1, 57, '2026-10-18 13:30:00', 21, 'Regalo duplicado');
INSERT INTO detalle_devolucion (id_devolucion, id_producto, cantidad) VALUES (1, 48, 1), (1, 6, 1);
INSERT INTO devoluciones (id_devolucion, id_venta, fecha, id_empleado, motivo) VALUES (2, 69, '2026-10-22 18:40:00', 4, 'Defectuoso');
INSERT INTO detalle_devolucion (id_devolucion, id_producto, cantidad) VALUES (2, 27, 1), (2, 43, 1);
INSERT INTO devoluciones (id_devolucion, id_venta, fecha, id_empleado, motivo) VALUES (3, 136, '2026-10-23 12:40:00', 21, 'Error de compra');
INSERT INTO detalle_devolucion (id_devolucion, id_producto, cantidad) VALUES (3, 41, 1);
INSERT INTO devoluciones (id_devolucion, id_venta, fecha, id_empleado, motivo) VALUES (4, 178, '2026-10-29 22:15:00', 30, 'No le gustó');
INSERT INTO detalle_devolucion (id_devolucion, id_producto, cantidad) VALUES (4, 57, 1);
INSERT INTO devoluciones (id_devolucion, id_venta, fecha, id_empleado, motivo) VALUES (5, 170, '2026-10-30 19:10:00', 26, 'No le gustó');
INSERT INTO detalle_devolucion (id_devolucion, id_producto, cantidad) VALUES (5, 28, 1);
INSERT INTO devoluciones (id_devolucion, id_venta, fecha, id_empleado, motivo) VALUES (6, 203, '2026-11-02 16:15:00', 12, 'Error de compra');
INSERT INTO detalle_devolucion (id_devolucion, id_producto, cantidad) VALUES (6, 25, 1), (6, 26, 1);
INSERT INTO devoluciones (id_devolucion, id_venta, fecha, id_empleado, motivo) VALUES (7, 197, '2026-11-05 13:55:00', 31, 'Regalo duplicado');
INSERT INTO detalle_devolucion (id_devolucion, id_producto, cantidad) VALUES (7, 64, 1), (7, 3, 1);
INSERT INTO devoluciones (id_devolucion, id_venta, fecha, id_empleado, motivo) VALUES (8, 216, '2026-11-12 10:10:00', 25, 'Regalo duplicado');
INSERT INTO detalle_devolucion (id_devolucion, id_producto, cantidad) VALUES (8, 29, 1);
INSERT INTO devoluciones (id_devolucion, id_venta, fecha, id_empleado, motivo) VALUES (9, 414, '2026-11-23 18:30:00', 4, 'Error de compra');
INSERT INTO detalle_devolucion (id_devolucion, id_producto, cantidad) VALUES (9, 13, 1), (9, 14, 1);
INSERT INTO devoluciones (id_devolucion, id_venta, fecha, id_empleado, motivo) VALUES (10, 359, '2026-11-23 18:30:00', 25, 'No le gustó');
INSERT INTO detalle_devolucion (id_devolucion, id_producto, cantidad) VALUES (10, 42, 1), (10, 50, 1);
INSERT INTO devoluciones (id_devolucion, id_venta, fecha, id_empleado, motivo) VALUES (11, 419, '2026-11-23 18:30:00', 26, 'Defectuoso');
INSERT INTO detalle_devolucion (id_devolucion, id_producto, cantidad) VALUES (11, 15, 1);
INSERT INTO devoluciones (id_devolucion, id_venta, fecha, id_empleado, motivo) VALUES (12, 376, '2026-11-23 18:30:00', 3, 'No le gustó');
INSERT INTO detalle_devolucion (id_devolucion, id_producto, cantidad) VALUES (12, 23, 1);
INSERT INTO devoluciones (id_devolucion, id_venta, fecha, id_empleado, motivo) VALUES (13, 367, '2026-11-23 18:30:00', 31, 'No le gustó');
INSERT INTO detalle_devolucion (id_devolucion, id_producto, cantidad) VALUES (13, 32, 1);
INSERT INTO devoluciones (id_devolucion, id_venta, fecha, id_empleado, motivo) VALUES (14, 343, '2026-11-23 21:00:00', 9, 'Error de compra');
INSERT INTO detalle_devolucion (id_devolucion, id_producto, cantidad) VALUES (14, 15, 1);

-- ---------------------------------------------------------------------
-- Preventas
-- ---------------------------------------------------------------------
INSERT INTO preventas (fecha, id_cliente, id_producto, id_sucursal, anticipo, estado) VALUES
('2026-06-11', 38, 14, 7, 10.00, 'Entregada'),
('2026-06-22', 13, 13, 8, 10.00, 'Entregada'),
('2026-07-08', 46, 14, 4, 10.00, 'Entregada'),
('2026-07-13', 23, 13, 3, 10.00, 'Entregada'),
('2026-07-17', 56, 13, 3, 10.00, 'Entregada'),
('2026-08-01', 16, 13, 7, 10.00, 'Entregada'),
('2026-08-11', 13, 14, 8, 10.00, 'Entregada'),
('2026-08-17', 4, 14, 3, 10.00, 'Cancelada'),
('2026-08-25', 5, 13, 5, 10.00, 'Entregada'),
('2026-10-07', 10, 13, 5, 10.00, 'Entregada'),
('2026-10-16', 7, 14, 4, 10.00, 'Cancelada'),
('2026-11-05', 37, 65, 9, 5.00, 'Pendiente'),
('2026-11-07', 49, 13, 6, 10.00, 'Entregada'),
('2026-11-09', 22, 65, 6, 5.00, 'Pendiente'),
('2026-11-12', 3, 65, 6, 5.00, 'Pendiente'),
('2026-11-13', 17, 66, 8, 50.00, 'Pendiente'),
('2026-11-17', 4, 65, 2, 5.00, 'Pendiente'),
('2026-11-18', 26, 65, 4, 5.00, 'Pendiente'),
('2026-11-20', 5, 65, 5, 5.00, 'Pendiente'),
('2026-11-20', 35, 66, 1, 50.00, 'Pendiente'),
('2026-11-20', 52, 66, 1, 50.00, 'Pendiente'),
('2026-11-21', 53, 66, 10, 50.00, 'Pendiente'),
('2026-11-23', 50, 65, 9, 5.00, 'Pendiente');

-- Productos aún no lanzados: se dan de alta en inventario en 0 para recibir preventas
INSERT INTO inventario (id_sucursal, id_producto, existencia, stock_minimo)
SELECT s.id_sucursal, p.id_producto, 0, 5
  FROM sucursales s CROSS JOIN productos p
 WHERE p.fecha_lanzamiento > '2026-11-23'
   AND NOT EXISTS (SELECT 1 FROM inventario i WHERE i.id_sucursal = s.id_sucursal AND i.id_producto = p.id_producto);
