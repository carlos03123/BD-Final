-- =====================================================================
--  Archivo 2 de 3: datos de ejemplo
--  Ejecutar después de 01_esquema.sql
-- =====================================================================

USE videojuegos;

INSERT INTO desarrolladoras (nombre, pais, anio_fundacion, sitio_web) VALUES
('Nintendo EPD',        'Japón',          2015, 'https://www.nintendo.com'),
('FromSoftware',        'Japón',          1986, 'https://www.fromsoftware.jp'),
('Rockstar North',      'Reino Unido',    1987, 'https://www.rockstargames.com'),
('CD Projekt Red',      'Polonia',        2002, 'https://www.cdprojektred.com'),
('Santa Monica Studio', 'Estados Unidos', 1999, 'https://sms.playstation.com'),
('Mojang Studios',      'Suecia',         2009, 'https://www.minecraft.net'),
('Supergiant Games',    'Estados Unidos', 2009, 'https://www.supergiantgames.com'),
('Larian Studios',      'Bélgica',        1996, 'https://larian.com'),
('Capcom',              'Japón',          1979, 'https://www.capcom.com'),
('Team Cherry',         'Australia',      2014, 'https://www.teamcherry.com.au');

INSERT INTO distribuidoras (nombre, pais) VALUES
('Nintendo',                       'Japón'),
('Bandai Namco',                   'Japón'),
('Rockstar Games',                 'Estados Unidos'),
('CD Projekt',                     'Polonia'),
('Sony Interactive Entertainment', 'Japón'),
('Xbox Game Studios',              'Estados Unidos'),
('Supergiant Games',               'Estados Unidos'),
('Larian Studios',                 'Bélgica'),
('Capcom',                         'Japón'),
('Team Cherry',                    'Australia');

INSERT INTO plataformas (nombre, fabricante, tipo, anio_lanzamiento) VALUES
('Nintendo Switch', 'Nintendo',  'Híbrida', 2017),
('PlayStation 5',   'Sony',      'Consola', 2020),
('PlayStation 4',   'Sony',      'Consola', 2013),
('Xbox Series X|S', 'Microsoft', 'Consola', 2020),
('Xbox One',        'Microsoft', 'Consola', 2013),
('PC',              'Varios',    'PC',      NULL),
('Móvil',           'Varios',    'Móvil',   NULL),
('Nintendo Switch 2','Nintendo', 'Híbrida', 2025);

INSERT INTO generos (nombre, descripcion) VALUES
('Acción',        'Combate y reflejos rápidos'),
('Aventura',      'Exploración y narrativa'),
('RPG',           'Juego de rol con progresión de personaje'),
('Mundo abierto', 'Mapa grande de libre exploración'),
('Soulslike',     'Combate exigente inspirado en Dark Souls'),
('Roguelike',     'Partidas que se reinician con progreso permanente'),
('Sandbox',       'Construcción y creatividad libre'),
('Metroidvania',  'Exploración 2D con habilidades que abren caminos'),
('Terror',        'Supervivencia y miedo'),
('Estrategia',    'Planeación táctica por turnos o en tiempo real');

INSERT INTO videojuegos (titulo, descripcion, clasificacion, modo_juego, id_desarrolladora, id_distribuidora) VALUES
('The Legend of Zelda: Breath of the Wild', 'Link explora Hyrule en un enorme mundo abierto.',             'E10+', 'Un jugador',  1, 1),
('Elden Ring',                              'RPG de acción en las Tierras Intermedias.',                    'M',    'Ambos',       2, 2),
('Grand Theft Auto V',                      'Crimen en Los Santos con tres protagonistas.',                 'M',    'Ambos',       3, 3),
('The Witcher 3: Wild Hunt',                'Geralt de Rivia busca a Ciri en un mundo de fantasía oscura.', 'M',    'Un jugador',  4, 4),
('God of War Ragnarök',                     'Kratos y Atreus enfrentan el fin de los nueve reinos.',        'M',    'Un jugador',  5, 5),
('Minecraft',                               'Construye, explora y sobrevive en un mundo de bloques.',       'E10+', 'Ambos',       6, 6),
('Hades',                                   'Zagreo intenta escapar del inframundo.',                       'T',    'Un jugador',  7, 7),
('Baldur''s Gate 3',                        'RPG por turnos basado en Dungeons & Dragons.',                 'M',    'Ambos',       8, 8),
('Resident Evil 4',                         'Remake del clásico de terror y acción.',                       'M',    'Un jugador',  9, 9),
('Hollow Knight',                           'Metroidvania en el reino subterráneo de Hallownest.',          'E10+', 'Un jugador', 10, 10),
('Super Mario Odyssey',                     'Mario viaja por reinos con su gorra Cappy.',                   'E10+', 'Ambos',       1, 1),
('Sekiro: Shadows Die Twice',               'Shinobi en el Japón feudal con combate de postura.',           'M',    'Un jugador',  2, 6);

INSERT INTO videojuego_genero (id_videojuego, id_genero) VALUES
(1,1),(1,2),(1,4),
(2,1),(2,3),(2,4),(2,5),
(3,1),(3,4),
(4,3),(4,4),(4,2),
(5,1),(5,2),
(6,7),(6,2),
(7,1),(7,6),
(8,3),(8,10),
(9,1),(9,9),
(10,8),(10,1),
(11,2),(11,1),
(12,1),(12,5);

INSERT INTO videojuego_plataforma (id_videojuego, id_plataforma, fecha_lanzamiento, precio_usd) VALUES
(1, 1, '2017-03-03', 59.99),
(2, 2, '2022-02-25', 59.99), (2, 4, '2022-02-25', 59.99), (2, 6, '2022-02-25', 59.99),
(3, 3, '2014-11-18', 29.99), (3, 2, '2022-03-15', 39.99), (3, 6, '2015-04-14', 29.99),
(4, 3, '2015-05-19', 39.99), (4, 6, '2015-05-19', 39.99), (4, 1, '2019-10-15', 59.99),
(5, 2, '2022-11-09', 69.99), (5, 6, '2024-09-19', 59.99),
(6, 6, '2011-11-18', 29.99), (6, 1, '2018-06-21', 29.99), (6, 7, '2011-11-17',  6.99),
(7, 6, '2020-09-17', 24.99), (7, 1, '2020-09-17', 24.99),
(8, 6, '2023-08-03', 59.99), (8, 2, '2023-09-06', 69.99),
(9, 2, '2023-03-24', 59.99), (9, 6, '2023-03-24', 59.99),
(10,6, '2017-02-24', 14.99), (10,1, '2018-06-12', 14.99),
(11,1, '2017-10-27', 59.99),
(12,3, '2019-03-22', 59.99), (12,6, '2019-03-22', 59.99);

INSERT INTO usuarios (nombre_usuario, correo, pais, fecha_registro) VALUES
('carlos_gamer',  'carlos@example.com', 'México',    '2023-01-15'),
('ana_pixel',     'ana@example.com',    'México',    '2023-03-02'),
('luis_speedrun', 'luis@example.com',   'Colombia',  '2023-06-20'),
('sofia_rpg',     'sofia@example.com',  'Argentina', '2024-02-11'),
('diego_noob',    'diego@example.com',  'España',    '2024-08-30'),
('vale_souls',    'vale@example.com',   'Chile',     '2025-01-05');

INSERT INTO biblioteca (id_usuario, id_videojuego, id_plataforma, fecha_compra, horas_jugadas, completado) VALUES
(1, 2, 6, '2023-02-01', 145.5, TRUE),
(1, 7, 1, '2023-04-10',  60.0, TRUE),
(1, 6, 6, '2023-01-20', 300.0, FALSE),
(2, 1, 1, '2023-03-05', 120.0, TRUE),
(2,11, 1, '2023-03-05',  45.0, TRUE),
(2,10, 1, '2023-05-18',  38.5, FALSE),
(3, 3, 2, '2023-07-01', 210.0, TRUE),
(3,12, 6, '2023-08-12',  55.0, TRUE),
(4, 8, 6, '2024-02-15', 180.0, TRUE),
(4, 4, 6, '2024-03-01',  95.0, FALSE),
(5, 6, 7, '2024-09-01',  25.0, FALSE),
(5, 5, 2, '2024-12-25',  30.0, FALSE),
(6, 2, 2, '2025-01-10', 200.0, TRUE),
(6,12, 6, '2025-02-14',  70.0, TRUE),
(6, 9, 2, '2025-03-03',  22.0, TRUE);

INSERT INTO resenas (id_usuario, id_videojuego, calificacion, comentario, fecha) VALUES
(1, 2, 10, 'Obra maestra, el mundo abierto es increíble.',   '2023-05-01'),
(1, 7,  9, 'Adictivo, cada partida es distinta.',             '2023-06-01'),
(2, 1, 10, 'El mejor Zelda que he jugado.',                   '2023-06-15'),
(2,11,  8, 'Muy divertido y creativo.',                       '2023-04-20'),
(3, 3,  9, 'El modo historia es buenísimo.',                  '2023-09-10'),
(3,12,  9, 'Difícil pero muy satisfactorio.',                 '2023-10-01'),
(4, 8, 10, 'La libertad de decisiones es impresionante.',     '2024-05-05'),
(4, 4,  9, 'Las misiones secundarias son de otro nivel.',     '2024-06-01'),
(5, 6,  7, 'Bueno para jugar con amigos.',                    '2024-10-01'),
(6, 2,  9, 'Jefes durísimos, me encantó.',                    '2025-03-01'),
(6,12, 10, 'El mejor combate de FromSoftware.',               '2025-04-01'),
(6, 9,  8, 'Gran remake, mucha tensión.',                     '2025-03-20');
