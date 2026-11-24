// =====================================================================
//  Consultas de ejemplo (MongoDB)
//  Ejecutar con:  mongosh mongodb/02_consultas.js
// =====================================================================

db = db.getSiblingDB("videojuegos");
const show = (titulo, cursor) => { print("\n=== " + titulo + " ==="); printjson(cursor.toArray()); };

// 1. Juegos Soulslike disponibles en PC
show("Soulslike en PC",
  db.videojuegos.find(
    { generos: "Soulslike", "plataformas.nombre": "PC" },
    { _id: 0, titulo: 1, "desarrolladora.nombre": 1 }
  ));

// 2. Top 5 juegos mejor calificados (une resenas con videojuegos)
show("Top 5 por calificación",
  db.resenas.aggregate([
    { $group: { _id: "$juego", promedio: { $avg: "$calificacion" }, num_resenas: { $sum: 1 } } },
    { $lookup: { from: "videojuegos", localField: "_id", foreignField: "_id", as: "juego" } },
    { $unwind: "$juego" },
    { $project: { _id: 0, titulo: "$juego.titulo", promedio: { $round: ["$promedio", 2] }, num_resenas: 1 } },
    { $sort: { promedio: -1, num_resenas: -1 } },
    { $limit: 5 }
  ]));

// 3. Cantidad de juegos por género
show("Juegos por género",
  db.videojuegos.aggregate([
    { $unwind: "$generos" },
    { $group: { _id: "$generos", total: { $sum: 1 } } },
    { $sort: { total: -1 } }
  ]));

// 4. Juegos y precio promedio por plataforma
show("Por plataforma",
  db.videojuegos.aggregate([
    { $unwind: "$plataformas" },
    { $group: { _id: "$plataformas.nombre", juegos: { $sum: 1 }, precio_promedio: { $avg: "$plataformas.precio_usd" } } },
    { $project: { juegos: 1, precio_promedio: { $round: ["$precio_promedio", 2] } } },
    { $sort: { juegos: -1 } }
  ]));

// 5. Horas totales jugadas por usuario
show("Horas por usuario",
  db.usuarios.aggregate([
    { $project: {
        horas_totales: { $sum: "$biblioteca.horas_jugadas" },
        completados: { $size: { $filter: { input: "$biblioteca", cond: "$$this.completado" } } } } },
    { $sort: { horas_totales: -1 } }
  ]));

// 6. Biblioteca de un usuario con el título de cada juego
show("Biblioteca de carlos_gamer",
  db.usuarios.aggregate([
    { $match: { _id: "carlos_gamer" } },
    { $unwind: "$biblioteca" },
    { $lookup: { from: "videojuegos", localField: "biblioteca.juego", foreignField: "_id", as: "j" } },
    { $project: { _id: 0, titulo: { $first: "$j.titulo" }, plataforma: "$biblioteca.plataforma",
                  horas: "$biblioteca.horas_jugadas", completado: "$biblioteca.completado" } },
    { $sort: { horas: -1 } }
  ]));

// 7. Ejemplos de CRUD
print("\n=== CRUD ===");
db.usuarios.updateOne({ _id: "diego_noob" }, { $inc: { "biblioteca.$[b].horas_jugadas": 5 } },
                      { arrayFilters: [{ "b.juego": "minecraft" }] });
db.videojuegos.updateOne({ _id: "hollow-knight" }, { $addToSet: { generos: "Aventura" } });
printjson(db.videojuegos.findOne({ _id: "hollow-knight" }, { titulo: 1, generos: 1 }));
