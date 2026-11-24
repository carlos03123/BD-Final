-- =====================================================================
--  BASE DE DATOS: videojuegos
--  Motor: MySQL 8.x  (abrir y ejecutar en MySQL Workbench)
--  Archivo 1 de 3: crea la base de datos y todas las tablas
-- =====================================================================

DROP DATABASE IF EXISTS videojuegos;
CREATE DATABASE videojuegos
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE videojuegos;

-- ---------------------------------------------------------------------
-- Catálogos
-- ---------------------------------------------------------------------

CREATE TABLE desarrolladoras (
  id_desarrolladora INT AUTO_INCREMENT PRIMARY KEY,
  nombre            VARCHAR(100) NOT NULL UNIQUE,
  pais              VARCHAR(60),
  anio_fundacion    SMALLINT,
  sitio_web         VARCHAR(150)
) ENGINE=InnoDB;

CREATE TABLE distribuidoras (
  id_distribuidora  INT AUTO_INCREMENT PRIMARY KEY,
  nombre            VARCHAR(100) NOT NULL UNIQUE,
  pais              VARCHAR(60)
) ENGINE=InnoDB;

CREATE TABLE plataformas (
  id_plataforma     INT AUTO_INCREMENT PRIMARY KEY,
  nombre            VARCHAR(60)  NOT NULL UNIQUE,
  fabricante        VARCHAR(60),
  tipo              ENUM('Consola','Portátil','PC','Móvil','Híbrida') NOT NULL,
  anio_lanzamiento  SMALLINT
) ENGINE=InnoDB;

CREATE TABLE generos (
  id_genero         INT AUTO_INCREMENT PRIMARY KEY,
  nombre            VARCHAR(50) NOT NULL UNIQUE,
  descripcion       VARCHAR(255)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Tabla principal
-- ---------------------------------------------------------------------

CREATE TABLE videojuegos (
  id_videojuego     INT AUTO_INCREMENT PRIMARY KEY,
  titulo            VARCHAR(150) NOT NULL,
  descripcion       TEXT,
  clasificacion     ENUM('E','E10+','T','M','AO','RP') NOT NULL DEFAULT 'RP', -- ESRB
  modo_juego        ENUM('Un jugador','Multijugador','Ambos') NOT NULL DEFAULT 'Un jugador',
  id_desarrolladora INT NOT NULL,
  id_distribuidora  INT NOT NULL,
  CONSTRAINT fk_vj_desarrolladora FOREIGN KEY (id_desarrolladora)
    REFERENCES desarrolladoras(id_desarrolladora)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_vj_distribuidora FOREIGN KEY (id_distribuidora)
    REFERENCES distribuidoras(id_distribuidora)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_vj_titulo (titulo)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Relaciones muchos a muchos
-- ---------------------------------------------------------------------

-- Un juego puede tener varios géneros y un género varios juegos
CREATE TABLE videojuego_genero (
  id_videojuego INT NOT NULL,
  id_genero     INT NOT NULL,
  PRIMARY KEY (id_videojuego, id_genero),
  CONSTRAINT fk_vg_videojuego FOREIGN KEY (id_videojuego)
    REFERENCES videojuegos(id_videojuego) ON DELETE CASCADE,
  CONSTRAINT fk_vg_genero FOREIGN KEY (id_genero)
    REFERENCES generos(id_genero) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Un juego sale en varias plataformas, con fecha y precio por plataforma
CREATE TABLE videojuego_plataforma (
  id_videojuego     INT NOT NULL,
  id_plataforma     INT NOT NULL,
  fecha_lanzamiento DATE,
  precio_usd        DECIMAL(6,2) CHECK (precio_usd >= 0),
  PRIMARY KEY (id_videojuego, id_plataforma),
  CONSTRAINT fk_vp_videojuego FOREIGN KEY (id_videojuego)
    REFERENCES videojuegos(id_videojuego) ON DELETE CASCADE,
  CONSTRAINT fk_vp_plataforma FOREIGN KEY (id_plataforma)
    REFERENCES plataformas(id_plataforma) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Usuarios, su biblioteca de juegos y sus reseñas
-- ---------------------------------------------------------------------

CREATE TABLE usuarios (
  id_usuario      INT AUTO_INCREMENT PRIMARY KEY,
  nombre_usuario  VARCHAR(50)  NOT NULL UNIQUE,
  correo          VARCHAR(120) NOT NULL UNIQUE,
  pais            VARCHAR(60),
  fecha_registro  DATE NOT NULL DEFAULT (CURRENT_DATE)
) ENGINE=InnoDB;

CREATE TABLE biblioteca (
  id_usuario      INT NOT NULL,
  id_videojuego   INT NOT NULL,
  id_plataforma   INT NOT NULL,
  fecha_compra    DATE NOT NULL,
  horas_jugadas   DECIMAL(7,1) NOT NULL DEFAULT 0 CHECK (horas_jugadas >= 0),
  completado      BOOLEAN NOT NULL DEFAULT FALSE,
  PRIMARY KEY (id_usuario, id_videojuego, id_plataforma),
  CONSTRAINT fk_bi_usuario FOREIGN KEY (id_usuario)
    REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
  CONSTRAINT fk_bi_vj_plat FOREIGN KEY (id_videojuego, id_plataforma)
    REFERENCES videojuego_plataforma(id_videojuego, id_plataforma) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE resenas (
  id_resena       INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario      INT NOT NULL,
  id_videojuego   INT NOT NULL,
  calificacion    TINYINT NOT NULL CHECK (calificacion BETWEEN 1 AND 10),
  comentario      TEXT,
  fecha           DATE NOT NULL DEFAULT (CURRENT_DATE),
  UNIQUE KEY uq_resena_usuario_juego (id_usuario, id_videojuego),
  CONSTRAINT fk_re_usuario FOREIGN KEY (id_usuario)
    REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
  CONSTRAINT fk_re_videojuego FOREIGN KEY (id_videojuego)
    REFERENCES videojuegos(id_videojuego) ON DELETE CASCADE
) ENGINE=InnoDB;
