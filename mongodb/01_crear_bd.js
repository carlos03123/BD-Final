// =====================================================================
//  BASE DE DATOS: videojuegos  (MongoDB)
//  Ejecutar con:  mongosh mongodb/01_crear_bd.js
//  o pegarlo en la pestaña "Mongosh" de MongoDB Compass.
//
//  Diseño documental (a diferencia de MySQL, se "embeben" datos):
//    - videojuegos : desarrolladora, distribuidora, géneros y plataformas
//                    van DENTRO de cada documento.
//    - usuarios    : su biblioteca de juegos va DENTRO del usuario.
//    - resenas     : colección aparte que REFERENCIA usuario y juego.
// =====================================================================

db = db.getSiblingDB("videojuegos");
db.dropDatabase();

// ---------------------------------------------------------------------
// Colección videojuegos (con validación de esquema)
// ---------------------------------------------------------------------
db.createCollection("videojuegos", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["_id", "titulo", "clasificacion", "desarrolladora", "distribuidora", "generos", "plataformas"],
      properties: {
        titulo:        { bsonType: "string" },
        clasificacion: { enum: ["E", "E10+", "T", "M", "AO", "RP"] },
        modo_juego:    { enum: ["Un jugador", "Multijugador", "Ambos"] },
        desarrolladora: {
          bsonType: "object",
          required: ["nombre"],
          properties: { nombre: { bsonType: "string" }, pais: { bsonType: "string" } }
        },
        distribuidora: { bsonType: "string" },
        generos:       { bsonType: "array", minItems: 1, items: { bsonType: "string" } },
        plataformas: {
          bsonType: "array",
          minItems: 1,
          items: {
            bsonType: "object",
            required: ["nombre"],
            properties: {
              nombre:            { bsonType: "string" },
              fecha_lanzamiento: { bsonType: "date" },
              precio_usd:        { bsonType: ["double", "int", "decimal"], minimum: 0 }
            }
          }
        }
      }
    }
  }
});

const fs = "FromSoftware", nin = { nombre: "Nintendo EPD", pais: "Japón" };
const D = (s) => new Date(s);

db.videojuegos.insertMany([
  { _id: "zelda-botw", titulo: "The Legend of Zelda: Breath of the Wild", clasificacion: "E10+", modo_juego: "Un jugador",
    desarrolladora: nin, distribuidora: "Nintendo", generos: ["Acción", "Aventura", "Mundo abierto"],
    plataformas: [{ nombre: "Nintendo Switch", fecha_lanzamiento: D("2017-03-03"), precio_usd: 59.99 }] },

  { _id: "elden-ring", titulo: "Elden Ring", clasificacion: "M", modo_juego: "Ambos",
    desarrolladora: { nombre: fs, pais: "Japón" }, distribuidora: "Bandai Namco",
    generos: ["Acción", "RPG", "Mundo abierto", "Soulslike"],
    plataformas: [
      { nombre: "PlayStation 5",   fecha_lanzamiento: D("2022-02-25"), precio_usd: 59.99 },
      { nombre: "Xbox Series X|S", fecha_lanzamiento: D("2022-02-25"), precio_usd: 59.99 },
      { nombre: "PC",              fecha_lanzamiento: D("2022-02-25"), precio_usd: 59.99 }] },

  { _id: "gta-v", titulo: "Grand Theft Auto V", clasificacion: "M", modo_juego: "Ambos",
    desarrolladora: { nombre: "Rockstar North", pais: "Reino Unido" }, distribuidora: "Rockstar Games",
    generos: ["Acción", "Mundo abierto"],
    plataformas: [
      { nombre: "PlayStation 4", fecha_lanzamiento: D("2014-11-18"), precio_usd: 29.99 },
      { nombre: "PlayStation 5", fecha_lanzamiento: D("2022-03-15"), precio_usd: 39.99 },
      { nombre: "PC",            fecha_lanzamiento: D("2015-04-14"), precio_usd: 29.99 }] },

  { _id: "witcher-3", titulo: "The Witcher 3: Wild Hunt", clasificacion: "M", modo_juego: "Un jugador",
    desarrolladora: { nombre: "CD Projekt Red", pais: "Polonia" }, distribuidora: "CD Projekt",
    generos: ["RPG", "Mundo abierto", "Aventura"],
    plataformas: [
      { nombre: "PlayStation 4",   fecha_lanzamiento: D("2015-05-19"), precio_usd: 39.99 },
      { nombre: "PC",              fecha_lanzamiento: D("2015-05-19"), precio_usd: 39.99 },
      { nombre: "Nintendo Switch", fecha_lanzamiento: D("2019-10-15"), precio_usd: 59.99 }] },

  { _id: "gow-ragnarok", titulo: "God of War Ragnarök", clasificacion: "M", modo_juego: "Un jugador",
    desarrolladora: { nombre: "Santa Monica Studio", pais: "Estados Unidos" }, distribuidora: "Sony Interactive Entertainment",
    generos: ["Acción", "Aventura"],
    plataformas: [
      { nombre: "PlayStation 5", fecha_lanzamiento: D("2022-11-09"), precio_usd: 69.99 },
      { nombre: "PC",            fecha_lanzamiento: D("2024-09-19"), precio_usd: 59.99 }] },

  { _id: "minecraft", titulo: "Minecraft", clasificacion: "E10+", modo_juego: "Ambos",
    desarrolladora: { nombre: "Mojang Studios", pais: "Suecia" }, distribuidora: "Xbox Game Studios",
    generos: ["Sandbox", "Aventura"],
    plataformas: [
      { nombre: "PC",              fecha_lanzamiento: D("2011-11-18"), precio_usd: 29.99 },
      { nombre: "Nintendo Switch", fecha_lanzamiento: D("2018-06-21"), precio_usd: 29.99 },
      { nombre: "Móvil",           fecha_lanzamiento: D("2011-11-17"), precio_usd: 6.99 }] },

  { _id: "hades", titulo: "Hades", clasificacion: "T", modo_juego: "Un jugador",
    desarrolladora: { nombre: "Supergiant Games", pais: "Estados Unidos" }, distribuidora: "Supergiant Games",
    generos: ["Acción", "Roguelike"],
    plataformas: [
      { nombre: "PC",              fecha_lanzamiento: D("2020-09-17"), precio_usd: 24.99 },
      { nombre: "Nintendo Switch", fecha_lanzamiento: D("2020-09-17"), precio_usd: 24.99 }] },

  { _id: "baldurs-gate-3", titulo: "Baldur's Gate 3", clasificacion: "M", modo_juego: "Ambos",
    desarrolladora: { nombre: "Larian Studios", pais: "Bélgica" }, distribuidora: "Larian Studios",
    generos: ["RPG", "Estrategia"],
    plataformas: [
      { nombre: "PC",            fecha_lanzamiento: D("2023-08-03"), precio_usd: 59.99 },
      { nombre: "PlayStation 5", fecha_lanzamiento: D("2023-09-06"), precio_usd: 69.99 }] },

  { _id: "re4", titulo: "Resident Evil 4", clasificacion: "M", modo_juego: "Un jugador",
    desarrolladora: { nombre: "Capcom", pais: "Japón" }, distribuidora: "Capcom",
    generos: ["Acción", "Terror"],
    plataformas: [
      { nombre: "PlayStation 5", fecha_lanzamiento: D("2023-03-24"), precio_usd: 59.99 },
      { nombre: "PC",            fecha_lanzamiento: D("2023-03-24"), precio_usd: 59.99 }] },

  { _id: "hollow-knight", titulo: "Hollow Knight", clasificacion: "E10+", modo_juego: "Un jugador",
    desarrolladora: { nombre: "Team Cherry", pais: "Australia" }, distribuidora: "Team Cherry",
    generos: ["Metroidvania", "Acción"],
    plataformas: [
      { nombre: "PC",              fecha_lanzamiento: D("2017-02-24"), precio_usd: 14.99 },
      { nombre: "Nintendo Switch", fecha_lanzamiento: D("2018-06-12"), precio_usd: 14.99 }] },

  { _id: "mario-odyssey", titulo: "Super Mario Odyssey", clasificacion: "E10+", modo_juego: "Ambos",
    desarrolladora: nin, distribuidora: "Nintendo", generos: ["Aventura", "Acción"],
    plataformas: [{ nombre: "Nintendo Switch", fecha_lanzamiento: D("2017-10-27"), precio_usd: 59.99 }] },

  { _id: "sekiro", titulo: "Sekiro: Shadows Die Twice", clasificacion: "M", modo_juego: "Un jugador",
    desarrolladora: { nombre: fs, pais: "Japón" }, distribuidora: "Xbox Game Studios",
    generos: ["Acción", "Soulslike"],
    plataformas: [
      { nombre: "PlayStation 4", fecha_lanzamiento: D("2019-03-22"), precio_usd: 59.99 },
      { nombre: "PC",            fecha_lanzamiento: D("2019-03-22"), precio_usd: 59.99 }] }
]);

// ---------------------------------------------------------------------
// Colección usuarios (biblioteca embebida)
// ---------------------------------------------------------------------
db.usuarios.insertMany([
  { _id: "carlos_gamer", correo: "carlos@example.com", pais: "México", fecha_registro: D("2023-01-15"),
    biblioteca: [
      { juego: "elden-ring", plataforma: "PC",              fecha_compra: D("2023-02-01"), horas_jugadas: 145.5, completado: true },
      { juego: "hades",      plataforma: "Nintendo Switch", fecha_compra: D("2023-04-10"), horas_jugadas: 60,    completado: true },
      { juego: "minecraft",  plataforma: "PC",              fecha_compra: D("2023-01-20"), horas_jugadas: 300,   completado: false }] },
  { _id: "ana_pixel", correo: "ana@example.com", pais: "México", fecha_registro: D("2023-03-02"),
    biblioteca: [
      { juego: "zelda-botw",    plataforma: "Nintendo Switch", fecha_compra: D("2023-03-05"), horas_jugadas: 120,  completado: true },
      { juego: "mario-odyssey", plataforma: "Nintendo Switch", fecha_compra: D("2023-03-05"), horas_jugadas: 45,   completado: true },
      { juego: "hollow-knight", plataforma: "Nintendo Switch", fecha_compra: D("2023-05-18"), horas_jugadas: 38.5, completado: false }] },
  { _id: "luis_speedrun", correo: "luis@example.com", pais: "Colombia", fecha_registro: D("2023-06-20"),
    biblioteca: [
      { juego: "gta-v",  plataforma: "PlayStation 5", fecha_compra: D("2023-07-01"), horas_jugadas: 210, completado: true },
      { juego: "sekiro", plataforma: "PC",            fecha_compra: D("2023-08-12"), horas_jugadas: 55,  completado: true }] },
  { _id: "sofia_rpg", correo: "sofia@example.com", pais: "Argentina", fecha_registro: D("2024-02-11"),
    biblioteca: [
      { juego: "baldurs-gate-3", plataforma: "PC", fecha_compra: D("2024-02-15"), horas_jugadas: 180, completado: true },
      { juego: "witcher-3",      plataforma: "PC", fecha_compra: D("2024-03-01"), horas_jugadas: 95,  completado: false }] },
  { _id: "diego_noob", correo: "diego@example.com", pais: "España", fecha_registro: D("2024-08-30"),
    biblioteca: [
      { juego: "minecraft",    plataforma: "Móvil",         fecha_compra: D("2024-09-01"), horas_jugadas: 25, completado: false },
      { juego: "gow-ragnarok", plataforma: "PlayStation 5", fecha_compra: D("2024-12-25"), horas_jugadas: 30, completado: false }] },
  { _id: "vale_souls", correo: "vale@example.com", pais: "Chile", fecha_registro: D("2025-01-05"),
    biblioteca: [
      { juego: "elden-ring", plataforma: "PlayStation 5", fecha_compra: D("2025-01-10"), horas_jugadas: 200, completado: true },
      { juego: "sekiro",     plataforma: "PC",            fecha_compra: D("2025-02-14"), horas_jugadas: 70,  completado: true },
      { juego: "re4",        plataforma: "PlayStation 5", fecha_compra: D("2025-03-03"), horas_jugadas: 22,  completado: true }] }
]);

// ---------------------------------------------------------------------
// Colección resenas (referencias a usuario y juego)
// ---------------------------------------------------------------------
db.resenas.insertMany([
  { usuario: "carlos_gamer",  juego: "elden-ring",     calificacion: 10, comentario: "Obra maestra, el mundo abierto es increíble.", fecha: D("2023-05-01") },
  { usuario: "carlos_gamer",  juego: "hades",          calificacion: 9,  comentario: "Adictivo, cada partida es distinta.",          fecha: D("2023-06-01") },
  { usuario: "ana_pixel",     juego: "zelda-botw",     calificacion: 10, comentario: "El mejor Zelda que he jugado.",                fecha: D("2023-06-15") },
  { usuario: "ana_pixel",     juego: "mario-odyssey",  calificacion: 8,  comentario: "Muy divertido y creativo.",                    fecha: D("2023-04-20") },
  { usuario: "luis_speedrun", juego: "gta-v",          calificacion: 9,  comentario: "El modo historia es buenísimo.",               fecha: D("2023-09-10") },
  { usuario: "luis_speedrun", juego: "sekiro",         calificacion: 9,  comentario: "Difícil pero muy satisfactorio.",              fecha: D("2023-10-01") },
  { usuario: "sofia_rpg",     juego: "baldurs-gate-3", calificacion: 10, comentario: "La libertad de decisiones es impresionante.",  fecha: D("2024-05-05") },
  { usuario: "sofia_rpg",     juego: "witcher-3",      calificacion: 9,  comentario: "Las misiones secundarias son de otro nivel.",  fecha: D("2024-06-01") },
  { usuario: "diego_noob",    juego: "minecraft",      calificacion: 7,  comentario: "Bueno para jugar con amigos.",                 fecha: D("2024-10-01") },
  { usuario: "vale_souls",    juego: "elden-ring",     calificacion: 9,  comentario: "Jefes durísimos, me encantó.",                 fecha: D("2025-03-01") },
  { usuario: "vale_souls",    juego: "sekiro",         calificacion: 10, comentario: "El mejor combate de FromSoftware.",            fecha: D("2025-04-01") },
  { usuario: "vale_souls",    juego: "re4",            calificacion: 8,  comentario: "Gran remake, mucha tensión.",                  fecha: D("2025-03-20") }
]);

// ---------------------------------------------------------------------
// Índices
// ---------------------------------------------------------------------
db.videojuegos.createIndex({ titulo: 1 });
db.videojuegos.createIndex({ generos: 1 });
db.videojuegos.createIndex({ "plataformas.nombre": 1 });
db.usuarios.createIndex({ correo: 1 }, { unique: true });
db.resenas.createIndex({ usuario: 1, juego: 1 }, { unique: true });
db.resenas.createIndex({ juego: 1 });

print("Base de datos 'videojuegos' creada:");
print("  videojuegos: " + db.videojuegos.countDocuments());
print("  usuarios:    " + db.usuarios.countDocuments());
print("  resenas:     " + db.resenas.countDocuments());
