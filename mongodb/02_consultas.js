// =====================================================================
//  Consultas de ejemplo (MongoDB) - gamestop
//  Ejecutar con:  mongosh mongodb/02_consultas.js
// =====================================================================

db = db.getSiblingDB("gamestop");
const show = (titulo, cursor) => { print("\n=== " + titulo + " ==="); printjson(cursor.toArray()); };

// 1. Juegos de PlayStation 5 nuevos, del más barato al más caro
show("Juegos PS5 nuevos",
  db.productos.find(
    { categoria: "Videojuego", plataforma: "PlayStation 5", condicion: "Nuevo" },
    { _id: 1, nombre: 1, precio_venta: 1 }
  ).sort({ precio_venta: 1 }));

// 2. Existencia total de cada producto en la cadena
show("Existencia total",
  db.productos.aggregate([
    { $project: { nombre: 1, categoria: 1, existencia_total: { $sum: "$inventario.existencia" } } },
    { $sort: { categoria: 1, nombre: 1 } }
  ]));

// 3. Ventas por sucursal en noviembre 2026
show("Ventas por sucursal",
  db.ventas.aggregate([
    { $match: { fecha: { $gte: new Date("2026-11-01"), $lt: new Date("2026-12-01") } } },
    { $group: { _id: "$sucursal", num_ventas: { $sum: 1 }, total_vendido: { $sum: "$total" },
                ticket_promedio: { $avg: "$total" } } },
    { $lookup: { from: "sucursales", localField: "_id", foreignField: "_id", as: "s" } },
    { $project: { _id: 0, sucursal: { $first: "$s.nombre" }, num_ventas: 1, total_vendido: 1,
                  ticket_promedio: { $round: ["$ticket_promedio", 2] } } },
    { $sort: { total_vendido: -1 } }
  ]));

// 4. Top 5 productos más vendidos
show("Top 5 más vendidos",
  db.ventas.aggregate([
    { $unwind: "$articulos" },
    { $group: { _id: "$articulos.nombre", unidades: { $sum: "$articulos.cantidad" },
                ingreso: { $sum: { $multiply: ["$articulos.cantidad", "$articulos.precio_unitario"] } } } },
    { $sort: { unidades: -1, ingreso: -1 } },
    { $limit: 5 }
  ]));

// 5. Ranking de vendedores (empleado embebido en sucursales)
show("Ranking de vendedores",
  db.ventas.aggregate([
    { $group: { _id: "$empleado", ventas: { $sum: 1 }, total_vendido: { $sum: "$total" } } },
    { $lookup: { from: "sucursales", localField: "_id", foreignField: "empleados._id", as: "s" } },
    { $unwind: "$s" },
    { $project: { _id: 0, ventas: 1, total_vendido: 1, sucursal: "$s.nombre",
        empleado: { $first: { $map: {
          input: { $filter: { input: "$s.empleados", cond: { $eq: ["$$this._id", "$_id"] } } },
          in: "$$this.nombre" } } } } },
    { $sort: { total_vendido: -1 } }
  ]));

// 6. Clientes Pro vs Básica
show("Pro vs Básica",
  db.ventas.aggregate([
    { $match: { cliente: { $ne: null } } },
    { $lookup: { from: "clientes", localField: "cliente", foreignField: "_id", as: "c" } },
    { $group: { _id: { $first: "$c.membresia" }, compras: { $sum: 1 },
                total_gastado: { $sum: "$total" }, descuentos: { $sum: "$descuento" } } }
  ]));

// 7. Productos con stock bajo en Plaza Río (sucursal 1)
show("Stock bajo en Plaza Río",
  db.productos.aggregate([
    { $unwind: "$inventario" },
    { $match: { "inventario.sucursal": 1,
                $expr: { $lte: ["$inventario.existencia", "$inventario.stock_minimo"] } } },
    { $project: { nombre: 1, existencia: "$inventario.existencia", minimo: "$inventario.stock_minimo" } },
    { $sort: { existencia: 1 } }
  ]));

// 8. Historial de compras de un cliente
show("Historial de Mariana López",
  db.clientes.aggregate([
    { $match: { correo: "mariana.lopez@correo.com" } },
    { $lookup: { from: "ventas", localField: "_id", foreignField: "cliente", as: "compras" } },
    { $unwind: "$compras" },
    { $project: { _id: 0, fecha: "$compras.fecha", articulos: "$compras.articulos.nombre", total: "$compras.total" } },
    { $sort: { fecha: -1 } }
  ]));

// 9. Preventas pendientes por producto
show("Preventas pendientes",
  db.preventas.aggregate([
    { $match: { estado: "Pendiente" } },
    { $group: { _id: "$producto", apartados: { $sum: 1 }, anticipos: { $sum: "$anticipo" } } },
    { $lookup: { from: "productos", localField: "_id", foreignField: "_id", as: "p" } },
    { $project: { producto: { $first: "$p.nombre" }, apartados: 1, anticipos: 1 } }
  ]));

// 10. Ejemplos de CRUD
print("\n=== CRUD ===");
// Subir de precio un producto
db.productos.updateOne({ _id: "VJ-PS5-FC26" }, { $set: { precio_venta: 1499 } });
// Reabastecer 5 consolas PS5 en Ensenada
db.productos.updateOne({ _id: "CON-PS5-SLM", "inventario.sucursal": 4 }, { $inc: { "inventario.$.existencia": 5 } });
// Convertir a un cliente en Pro
db.clientes.updateOne({ _id: 3 }, { $set: { membresia: "Pro" } });
// Marcar una preventa como entregada
db.preventas.updateOne({ cliente: 1, producto: "ACC-PS5-DSE" }, { $set: { estado: "Entregada" } });
printjson(db.productos.findOne({ _id: "CON-PS5-SLM" }, { nombre: 1, inventario: 1 }));
