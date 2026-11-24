-- =====================================================================
--  Archivo 3 de 3: vistas, procedimiento, trigger y consultas de ejemplo
--  Ejecutar después de 02_datos.sql
-- =====================================================================

USE videojuegos;

-- ---------------------------------------------------------------------
-- VISTAS
-- ---------------------------------------------------------------------

-- Catálogo completo: juego, estudio, distribuidora, géneros y plataformas
CREATE OR REPLACE VIEW v_catalogo AS
SELECT v.id_videojuego,
       v.titulo,
       d.nombre  AS desarrolladora,
       di.nombre AS distribuidora,
       v.clasificacion,
       (SELECT GROUP_CONCAT(g.nombre ORDER BY g.nombre SEPARATOR ', ')
          FROM videojuego_genero vg JOIN generos g ON g.id_genero = vg.id_genero
         WHERE vg.id_videojuego = v.id_videojuego) AS generos,
       (SELECT GROUP_CONCAT(p.nombre ORDER BY p.nombre SEPARATOR ', ')
          FROM videojuego_plataforma vp JOIN plataformas p ON p.id_plataforma = vp.id_plataforma
         WHERE vp.id_videojuego = v.id_videojuego) AS plataformas,
       (SELECT MIN(vp.fecha_lanzamiento)
          FROM videojuego_plataforma vp
         WHERE vp.id_videojuego = v.id_videojuego) AS primer_lanzamiento
FROM videojuegos v
JOIN desarrolladoras d  ON d.id_desarrolladora = v.id_desarrolladora
JOIN distribuidoras  di ON di.id_distribuidora = v.id_distribuidora;

-- Ranking por calificación promedio de los usuarios
CREATE OR REPLACE VIEW v_ranking AS
SELECT v.titulo,
       ROUND(AVG(r.calificacion), 2) AS promedio,
       COUNT(r.id_resena)            AS num_resenas
FROM videojuegos v
LEFT JOIN resenas r ON r.id_videojuego = v.id_videojuego
GROUP BY v.id_videojuego, v.titulo;

-- ---------------------------------------------------------------------
-- PROCEDIMIENTO ALMACENADO: juegos de un usuario
-- Uso: CALL sp_biblioteca_usuario('carlos_gamer');
-- ---------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_biblioteca_usuario;
DELIMITER $$
CREATE PROCEDURE sp_biblioteca_usuario(IN p_usuario VARCHAR(50))
BEGIN
  SELECT v.titulo, p.nombre AS plataforma, b.fecha_compra,
         b.horas_jugadas, IF(b.completado, 'Sí', 'No') AS completado
  FROM biblioteca b
  JOIN usuarios    u ON u.id_usuario    = b.id_usuario
  JOIN videojuegos v ON v.id_videojuego = b.id_videojuego
  JOIN plataformas p ON p.id_plataforma = b.id_plataforma
  WHERE u.nombre_usuario = p_usuario
  ORDER BY b.horas_jugadas DESC;
END$$
DELIMITER ;

-- ---------------------------------------------------------------------
-- TRIGGER: solo se puede reseñar un juego que el usuario tiene
-- ---------------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_resena_requiere_juego;
DELIMITER $$
CREATE TRIGGER trg_resena_requiere_juego
BEFORE INSERT ON resenas
FOR EACH ROW
BEGIN
  IF NOT EXISTS (SELECT 1 FROM biblioteca
                  WHERE id_usuario = NEW.id_usuario
                    AND id_videojuego = NEW.id_videojuego) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'El usuario no tiene este juego en su biblioteca';
  END IF;
END$$
DELIMITER ;

-- ---------------------------------------------------------------------
-- CONSULTAS DE EJEMPLO
-- ---------------------------------------------------------------------

-- 1. Catálogo completo
SELECT * FROM v_catalogo ORDER BY primer_lanzamiento;

-- 2. Top 5 juegos mejor calificados (con al menos 1 reseña)
SELECT * FROM v_ranking WHERE num_resenas > 0
ORDER BY promedio DESC, num_resenas DESC LIMIT 5;

-- 3. Juegos por género
SELECT g.nombre AS genero, COUNT(*) AS total_juegos
FROM videojuego_genero vg JOIN generos g ON g.id_genero = vg.id_genero
GROUP BY g.nombre ORDER BY total_juegos DESC;

-- 4. Cuántos juegos tiene cada plataforma y precio promedio
SELECT p.nombre AS plataforma, COUNT(*) AS juegos, ROUND(AVG(vp.precio_usd), 2) AS precio_promedio
FROM videojuego_plataforma vp JOIN plataformas p ON p.id_plataforma = vp.id_plataforma
GROUP BY p.nombre ORDER BY juegos DESC;

-- 5. Horas totales jugadas por usuario
SELECT u.nombre_usuario, SUM(b.horas_jugadas) AS horas_totales,
       SUM(b.completado) AS juegos_completados
FROM usuarios u JOIN biblioteca b ON b.id_usuario = u.id_usuario
GROUP BY u.nombre_usuario ORDER BY horas_totales DESC;

-- 6. Juegos "Soulslike" disponibles en PC
SELECT v.titulo, vp.precio_usd
FROM videojuegos v
JOIN videojuego_genero vg     ON vg.id_videojuego = v.id_videojuego
JOIN generos g                ON g.id_genero = vg.id_genero AND g.nombre = 'Soulslike'
JOIN videojuego_plataforma vp ON vp.id_videojuego = v.id_videojuego
JOIN plataformas p            ON p.id_plataforma = vp.id_plataforma AND p.nombre = 'PC';

-- 7. Biblioteca de un usuario (procedimiento)
CALL sp_biblioteca_usuario('carlos_gamer');
