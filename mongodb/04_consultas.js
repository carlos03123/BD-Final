// =====================================================================
//  BASE DE DATOS: gamestop_usa (MongoDB)
//  Archivo 4 de 4: consultas (equivalentes a mysql/06_consultas.sql)
//
//  Ejecutar después de 02_datos.js:   mongosh mongodb/04_consultas.js
//    A. find() con filtros, proyección y orden
//    B. $lookup (el "JOIN" de MongoDB)
//    C. Agregación: $group, $unwind, $match después de agrupar (HAVING)
//    D. Equivalentes a subconsultas
//    E. Avanzadas: $setWindowFields (funciones de ventana), $facet, $bucket
//    F. Vistas
// =====================================================================

db = db.getSiblingDB("gamestop_usa");
const D = (s) => new Date(s.length === 10 ? s + "T00:00:00Z" : s + "Z");
function show(titulo, cursor) {
  print("\n=== " + titulo + " ===");
  const docs = cursor.toArray();
  docs.forEach(d => print(JSON.stringify(d)));
  print("(" + docs.length + " documentos)");
}

// =====================================================================
// A. find()
// =====================================================================

show("A1. Tiendas ordenadas por antigüedad",
  db.sucursales.find({}, { _id: 0, numero_tienda: 1, nombre: 1, ciudad: 1, fecha_apertura: 1 }).sort({ fecha_apertura: 1 }));

show("A2. Juegos ESRB M de menos de $60",
  db.productos.find({ clasificacion_esrb: "M", precio_venta: { $lt: 60 } }, { nombre: 1, precio_venta: 1 }).sort({ precio_venta: 1 }));

show("A3. Productos cuyo nombre contiene 'Mario' (expresión regular)",
  db.productos.find({ nombre: /Mario/ }, { nombre: 1, condicion: 1, precio_venta: 1 }));

show("A4. Ventas de la semana del lanzamiento de GTA VI",
  db.ventas.find({ fecha: { $gte: D("2026-11-19"), $lt: D("2026-11-24") } }, { fecha: 1, total: 1 }).sort({ fecha: 1 }).limit(10));

show("A5. Clientes de TX, CA o NY con GameStop Pro",
  db.clientes.find({ estado: { $in: ["TX", "CA", "NY"] }, "membresia.nivel": "GameStop Pro" },
                   { _id: 0, nombre: 1, apellido: 1, estado: 1, "membresia.vencimiento": 1 }).sort({ estado: 1, apellido: 1 }));

show("A6. Juegos de Acción Y Mundo abierto ($all sobre un arreglo)",
  db.productos.find({ generos: { $all: ["Acción", "Mundo abierto"] } }, { nombre: 1, generos: 1 }));

// =====================================================================
// B. $lookup
// =====================================================================

show("B1. Detalle de un ticket con los datos del cliente",
  db.ventas.aggregate([
    { $match: { _id: 250 } },
    { $lookup: { from: "clientes", localField: "cliente", foreignField: "_id", as: "c" } },
    { $project: { fecha: 1, tienda: "$sucursal.nombre", vendedor: "$empleado.nombre",
                  cliente: { $ifNull: [{ $concat: [{ $first: "$c.nombre" }, " ", { $first: "$c.apellido" }] }, "Cliente no registrado"] },
                  articulos: { sku: 1, cantidad: 1, precio_unitario: 1, descuento: 1 }, subtotal: 1, impuesto: 1, total: 1 } }
  ]));

show("B2. Productos con el nombre de su proveedor",
  db.productos.aggregate([
    { $lookup: { from: "proveedores", localField: "proveedor", foreignField: "_id", as: "p" } },
    { $project: { nombre: 1, condicion: 1, proveedor: { $ifNull: [{ $first: "$p.nombre" }, "— intercambio de clientes —"] } } },
    { $sort: { proveedor: 1, nombre: 1 } }, { $limit: 15 }
  ]));

show("B3. Cada empleado de Grapevine Mills con su jefe directo (auto-relación dentro del arreglo)",
  db.sucursales.aggregate([
    { $unwind: "$empleados" },
    { $match: { _id: 1 } },
    { $replaceWith: "$empleados" },
    { $lookup: { from: "sucursales", let: { jefe: "$id_supervisor" }, as: "j", pipeline: [
        { $unwind: "$empleados" }, { $match: { $expr: { $eq: ["$empleados._id", "$$jefe"] } } },
        { $replaceWith: "$empleados" } ] } },
    { $unwind: "$j" },
    { $project: { _id: 0, empleado: { $concat: ["$nombre", " ", "$apellido"] }, puesto: 1, salario_hora: 1,
                  jefe_directo: { $concat: ["$j.nombre", " ", "$j.apellido"] }, puesto_jefe: "$j.puesto",
                  diferencia_por_hora: { $round: [{ $subtract: ["$j.salario_hora", "$salario_hora"] }, 2] } } },
    { $sort: { diferencia_por_hora: 1 } }
  ]));

show("B4. Intercambios con el nombre del cliente",
  db.intercambios.aggregate([
    { $lookup: { from: "clientes", localField: "cliente", foreignField: "_id", as: "c" } },
    { $project: { fecha: 1, cliente: { $concat: [{ $first: "$c.nombre" }, " ", { $first: "$c.apellido" }] },
                  forma_pago: 1, articulos: "$articulos.nombre", total_pagado: 1 } },
    { $sort: { fecha: 1 } }, { $limit: 10 }
  ]));

// =====================================================================
// C. AGREGACIÓN
// =====================================================================

show("C1. Ingresos por categoría",
  db.ventas.aggregate([
    { $unwind: "$articulos" },
    { $group: { _id: "$articulos.categoria", unidades: { $sum: "$articulos.cantidad" },
                ingreso: { $sum: { $subtract: [{ $multiply: ["$articulos.cantidad", "$articulos.precio_unitario"] }, "$articulos.descuento"] } } } },
    { $set: { ingreso: { $round: ["$ingreso", 2] } } },
    { $sort: { ingreso: -1 } }
  ]));

show("C2. Ventas e impuesto por estado",
  db.ventas.aggregate([
    { $group: { _id: "$sucursal.estado", tickets: { $sum: 1 },
                ventas_netas: { $sum: { $subtract: ["$subtotal", "$descuento"] } }, impuesto: { $sum: "$impuesto" } } },
    { $set: { ventas_netas: { $round: ["$ventas_netas", 2] }, impuesto: { $round: ["$impuesto", 2] } } },
    { $sort: { ventas_netas: -1 } }
  ]));

show("C3. Plataformas con más de $1,000 vendidos (equivalente a HAVING)",
  db.ventas.aggregate([
    { $unwind: "$articulos" },
    { $lookup: { from: "productos", localField: "articulos.sku", foreignField: "_id", as: "p" } },
    { $match: { "p.plataforma": { $exists: true } } },
    { $group: { _id: { $first: "$p.plataforma.nombre" }, unidades: { $sum: "$articulos.cantidad" },
                ingreso: { $sum: { $subtract: [{ $multiply: ["$articulos.cantidad", "$articulos.precio_unitario"] }, "$articulos.descuento"] } } } },
    { $match: { ingreso: { $gt: 1000 } } },
    { $set: { ingreso: { $round: ["$ingreso", 2] } } },
    { $sort: { ingreso: -1 } }
  ]));

show("C4. Top 10 vendedores",
  db.ventas.aggregate([
    { $group: { _id: "$empleado._id", vendedor: { $first: "$empleado.nombre" }, tienda: { $first: "$sucursal.nombre" },
                tickets: { $sum: 1 }, total: { $sum: "$total" }, promedio: { $avg: "$total" } } },
    { $set: { total: { $round: ["$total", 2] }, promedio: { $round: ["$promedio", 2] } } },
    { $sort: { total: -1 } }, { $limit: 10 }
  ]));

show("C5. Métodos de pago",
  db.ventas.aggregate([
    { $group: { _id: "$metodo_pago", tickets: { $sum: 1 }, total: { $sum: "$total" } } },
    { $set: { total: { $round: ["$total", 2] } } }, { $sort: { tickets: -1 } }
  ]));

show("C6. GameStop Pro vs PowerUp Rewards",
  db.ventas.aggregate([
    { $match: { cliente: { $ne: null } } },
    { $lookup: { from: "clientes", localField: "cliente", foreignField: "_id", as: "c" } },
    { $group: { _id: { $first: "$c.membresia.nivel" }, clientes: { $addToSet: "$cliente" },
                tickets: { $sum: 1 }, total: { $sum: "$total" }, descuentos: { $sum: "$descuento" } } },
    { $project: { clientes_que_compraron: { $size: "$clientes" }, tickets: 1, total: { $round: ["$total", 2] },
                  gasto_por_cliente: { $round: [{ $divide: ["$total", { $size: "$clientes" }] }, 2] },
                  descuentos: { $round: ["$descuentos", 2] } } }
  ]));

// =====================================================================
// D. EQUIVALENTES A SUBCONSULTAS
// =====================================================================

const vendidos = db.ventas.distinct("articulos.sku");
show("D1. Productos que nunca se han vendido (NOT IN)",
  db.productos.find({ _id: { $nin: vendidos } }, { nombre: 1, condicion: 1 }));

show("D2. Clientes que compraron GTA VI",
  db.clientes.find({ _id: { $in: db.ventas.distinct("cliente", { "articulos.sku": /GTA6/ }) } },
                   { _id: 0, nombre: 1, apellido: 1, correo: 1 }));

show("D3. Los 10 tickets más grandes entre los que superan el triple del promedio de su tienda",
  db.ventas.aggregate([
    { $lookup: { from: "ventas", localField: "sucursal._id", foreignField: "sucursal._id", as: "misma_tienda",
                 pipeline: [{ $group: { _id: null, prom: { $avg: "$total" } } }] } },
    { $match: { $expr: { $gt: ["$total", { $multiply: [{ $first: "$misma_tienda.prom" }, 3] }] } } },
    { $project: { tienda: "$sucursal.nombre", total: 1 } }, { $sort: { total: -1 } }, { $limit: 10 }
  ]));

show("D4. Clientes sin compras en noviembre",
  db.clientes.find({ _id: { $nin: db.ventas.distinct("cliente", { fecha: { $gte: D("2026-11-01") } }) } },
                   { _id: 0, nombre: 1, apellido: 1, correo: 1 }));

show("D5. El producto más caro de cada categoría",
  db.productos.aggregate([
    { $sort: { precio_venta: -1 } },
    { $group: { _id: "$categoria", producto: { $first: "$nombre" }, precio: { $first: "$precio_venta" } } },
    { $sort: { _id: 1 } }
  ]));

// =====================================================================
// E. AVANZADAS
// =====================================================================

show("E1. Top 3 productos de CADA tienda ($setWindowFields = ROW_NUMBER)",
  db.ventas.aggregate([
    { $unwind: "$articulos" },
    { $group: { _id: { tienda: "$sucursal.nombre", producto: "$articulos.nombre" }, unidades: { $sum: "$articulos.cantidad" } } },
    { $setWindowFields: { partitionBy: "$_id.tienda", sortBy: { unidades: -1, "_id.producto": 1 },
                          output: { lugar: { $documentNumber: {} } } } },
    { $match: { lugar: { $lte: 3 } } },
    { $project: { _id: 0, tienda: "$_id.tienda", producto: "$_id.producto", unidades: 1, lugar: 1 } },
    { $sort: { tienda: 1, lugar: 1 } }
  ]));

show("E2. Ventas diarias con acumulado y promedio móvil de 7 días",
  db.ventas.aggregate([
    { $group: { _id: { $dateToString: { format: "%Y-%m-%d", date: "$fecha" } }, total: { $sum: "$total" } } },
    { $setWindowFields: { sortBy: { _id: 1 }, output: {
        acumulado:       { $sum: "$total", window: { documents: ["unbounded", "current"] } },
        promedio_7_dias: { $avg: "$total", window: { documents: [-6, "current"] } } } } },
    { $project: { total: { $round: ["$total", 2] }, acumulado: { $round: ["$acumulado", 2] },
                  promedio_7_dias: { $round: ["$promedio_7_dias", 2] } } },
    { $sort: { _id: 1 } }
  ]));

show("E3. Ranking de tiendas ($rank) y % de la cadena",
  db.ventas.aggregate([
    { $group: { _id: "$sucursal.nombre", total: { $sum: "$total" } } },
    { $setWindowFields: { sortBy: { total: -1 }, output: {
        lugar: { $rank: {} },
        total_cadena: { $sum: "$total", window: { documents: ["unbounded", "unbounded"] } } } } },
    { $project: { lugar: 1, total: { $round: ["$total", 2] },
                  pct_de_la_cadena: { $round: [{ $multiply: [{ $divide: ["$total", "$total_cadena"] }, 100] }, 1] } } }
  ]));

show("E4. Segmentación de clientes por gasto ($bucket)",
  db.clientes.aggregate([
    { $lookup: { from: "ventas", localField: "_id", foreignField: "cliente", as: "v" } },
    { $project: { gasto: { $sum: "$v.total" } } },
    { $bucket: { groupBy: "$gasto", boundaries: [0, 0.01, 300, 1000, 1000000], default: "otro",
                 output: { clientes: { $sum: 1 }, gasto_total: { $sum: "$gasto" } } } },
    { $set: { segmento: { $switch: { branches: [
        { case: { $eq: ["$_id", 0] },    then: "Sin compras" },
        { case: { $eq: ["$_id", 0.01] }, then: "Ocasional (< $300)" },
        { case: { $eq: ["$_id", 300] },  then: "Frecuente ($300 – $999)" },
        { case: { $eq: ["$_id", 1000] }, then: "VIP (≥ $1,000)" } ], default: "otro" } },
              gasto_total: { $round: ["$gasto_total", 2] } } }
  ]));

show("E5. Tablero en una sola consulta ($facet)",
  db.ventas.aggregate([
    { $facet: {
        resumen:      [{ $group: { _id: null, tickets: { $sum: 1 }, total: { $sum: "$total" }, impuesto: { $sum: "$impuesto" } } },
                       { $set: { total: { $round: ["$total", 2] }, impuesto: { $round: ["$impuesto", 2] } } }],
        por_metodo:   [{ $sortByCount: "$metodo_pago" }],
        devoluciones: [{ $unwind: "$devoluciones" },
                       { $group: { _id: "$devoluciones.motivo", cuantas: { $sum: 1 }, reembolsado: { $sum: "$devoluciones.monto_reembolsado" } } },
                       { $set: { reembolsado: { $round: ["$reembolsado", 2] } } }]
    } }
  ]));

show("E6. Búsqueda de texto: 'pokemon' (índice de texto)",
  db.productos.find({ $text: { $search: "Pokémon" } }, { nombre: 1, score: { $meta: "textScore" } }).sort({ score: { $meta: "textScore" } }));

show("E7. Historial de precios (bitácora)",
  db.bitacora_precios.aggregate([
    { $lookup: { from: "productos", localField: "producto", foreignField: "_id", as: "p" } },
    { $project: { _id: 0, fecha: 1, producto: { $first: "$p.nombre" }, precio_anterior: 1, precio_nuevo: 1,
                  cambio_pct: { $round: [{ $multiply: [{ $divide: [{ $subtract: ["$precio_nuevo", "$precio_anterior"] }, "$precio_anterior"] }, 100] }, 1] } } },
    { $sort: { fecha: 1 } }
  ]));

show("E8. Productos bajo el stock mínimo en Grapevine Mills",
  db.productos.aggregate([
    { $match: { activo: true } },
    { $unwind: "$inventario" },
    { $match: { "inventario.sucursal": 1, $expr: { $lte: ["$inventario.existencia", "$inventario.stock_minimo"] } } },
    { $project: { nombre: 1, existencia: "$inventario.existencia", minimo: "$inventario.stock_minimo" } },
    { $sort: { existencia: 1, nombre: 1 } }
  ]));

// =====================================================================
// F. VISTAS
// =====================================================================
show("F1. Vista v_ventas_tienda", db.v_ventas_tienda.find());
show("F2. Vista v_inventario_valorizado", db.v_inventario_valorizado.find());
show("F3. Vista v_catalogo (5 con mayor margen)", db.v_catalogo.find({ activo: true }).sort({ margen_pct: -1 }).limit(5));
