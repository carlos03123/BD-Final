// =====================================================================
//  BASE DE DATOS: gamestop_usa (MongoDB)
//  Archivo 1 de 4: colecciones con validación ($jsonSchema), índices y vistas
//
//  Ejecutar:  mongosh mongodb/01_colecciones.js
//  (o pegar en la pestaña "Mongosh" de MongoDB Compass)
//
//  DISEÑO DOCUMENTAL — qué se embebe y qué se referencia:
//
//    sucursales      -> empleados EMBEBIDOS (siempre se consultan con su tienda)
//                       y el estado con su tasa de impuesto
//    productos       -> géneros e inventario por tienda EMBEBIDOS; _id = SKU
//    clientes        -> membresía EMBEBIDA
//    ventas          -> artículos y devoluciones EMBEBIDOS. Del producto se COPIA
//                       nombre, categoría y precio al momento de vender (así el
//                       ticket no cambia aunque luego cambie el catálogo)
//    intercambios, ordenes_compra -> artículos EMBEBIDOS
//    cliente, proveedor, empleado y sucursal se REFERENCIAN por _id
//    (se unen con $lookup cuando hace falta)
// =====================================================================

db = db.getSiblingDB("gamestop_usa");
db.dropDatabase();

var dinero = { bsonType: ["double", "int", "long", "decimal"], minimum: 0 };
var fecha  = { bsonType: "date" };

// ---------------------------------------------------------------------
// niveles_membresia
// ---------------------------------------------------------------------
db.createCollection("niveles_membresia", { validator: { $jsonSchema: {
  bsonType: "object",
  required: ["_id", "nombre", "costo_anual", "puntos_por_dolar"],
  properties: {
    nombre: { bsonType: "string" },
    costo_anual: dinero,
    descuento_usados_pct: { bsonType: ["double", "int"], minimum: 0, maximum: 100 },
    bono_intercambio_pct: { bsonType: ["double", "int"], minimum: 0, maximum: 100 },
    puntos_por_dolar: { bsonType: "int", minimum: 0 }
  } } } });

// ---------------------------------------------------------------------
// sucursales (con empleados embebidos)
// ---------------------------------------------------------------------
db.createCollection("sucursales", { validator: { $jsonSchema: {
  bsonType: "object",
  required: ["_id", "numero_tienda", "nombre", "direccion", "ciudad", "estado", "codigo_postal", "empleados"],
  properties: {
    numero_tienda: { bsonType: "int" },
    codigo_postal: { bsonType: "string", pattern: "^[0-9]{5}$" },
    estado: { bsonType: "object", required: ["abreviatura", "tasa_impuesto"],
              properties: { abreviatura: { bsonType: "string", minLength: 2, maxLength: 2 },
                            tasa_impuesto: { bsonType: ["double", "int"], minimum: 0, maximum: 0.2 } } },
    fecha_apertura: fecha,
    empleados: { bsonType: "array", items: {
      bsonType: "object",
      required: ["_id", "nombre", "apellido", "correo", "puesto", "salario_hora"],
      properties: {
        puesto: { enum: ["Gerente de distrito", "Gerente de tienda", "Subgerente", "Asesor senior", "Asesor"] },
        salario_hora: { bsonType: ["double", "int"], minimum: 7.25 },
        correo: { bsonType: "string", pattern: "^[^@]+@[^@]+\\.[a-z]+$" }
      } } }
  } } } });

// ---------------------------------------------------------------------
// clientes
// ---------------------------------------------------------------------
db.createCollection("clientes", { validator: { $jsonSchema: {
  bsonType: "object",
  required: ["_id", "nombre", "apellido", "correo", "estado", "membresia", "puntos", "credito_tienda"],
  properties: {
    correo: { bsonType: "string", pattern: "^[^@]+@[^@]+\\.[a-z]+$" },
    estado: { bsonType: "string", minLength: 2, maxLength: 2 },
    membresia: { bsonType: "object", required: ["nivel"],
                 properties: { nivel: { enum: ["PowerUp Rewards", "GameStop Pro"] }, vencimiento: fecha } },
    puntos: { bsonType: "int", minimum: 0 },
    credito_tienda: dinero
  } } } });

db.createCollection("proveedores", { validator: { $jsonSchema: {
  bsonType: "object", required: ["_id", "nombre"],
  properties: { nombre: { bsonType: "string" } } } } });

// ---------------------------------------------------------------------
// productos (con inventario embebido)
// ---------------------------------------------------------------------
db.createCollection("productos", { validator: { $jsonSchema: {
  bsonType: "object",
  required: ["_id", "nombre", "categoria", "condicion", "precio_venta", "costo", "activo", "inventario"],
  properties: {
    _id: { bsonType: "string" },
    categoria: { enum: ["Videojuego", "Consola", "Accesorio", "Coleccionable", "Tarjeta de regalo"] },
    condicion: { enum: ["Nuevo", "Usado", "Reacondicionado"] },
    clasificacion_esrb: { enum: ["E", "E10+", "T", "M", "RP"] },
    precio_venta: { bsonType: ["double", "int", "decimal"], minimum: 0, exclusiveMinimum: true },
    costo: dinero,
    generos: { bsonType: "array", items: { bsonType: "string" } },
    inventario: { bsonType: "array", items: {
      bsonType: "object", required: ["sucursal", "existencia"],
      properties: { sucursal: { bsonType: "int" },
                    existencia: { bsonType: "int", minimum: 0 },
                    stock_minimo: { bsonType: "int", minimum: 0 } } } }
  } },
  // regla entre campos: el precio no puede ser menor al costo
  $expr: { $gte: ["$precio_venta", "$costo"] } } });

// ---------------------------------------------------------------------
// ventas (artículos y devoluciones embebidos)
// ---------------------------------------------------------------------
db.createCollection("ventas", { validator: { $jsonSchema: {
  bsonType: "object",
  required: ["_id", "fecha", "sucursal", "empleado", "metodo_pago", "articulos", "subtotal", "impuesto", "total", "estado"],
  properties: {
    fecha: fecha,
    metodo_pago: { enum: ["Efectivo", "Tarjeta de crédito", "Tarjeta de débito", "Crédito en tienda", "Tarjeta de regalo"] },
    estado: { enum: ["Completada", "Devuelta parcial", "Devuelta"] },
    articulos: { bsonType: "array", minItems: 1, items: {
      bsonType: "object", required: ["sku", "cantidad", "precio_unitario"],
      properties: { cantidad: { bsonType: "int", minimum: 1 }, precio_unitario: dinero, descuento: dinero } } },
    subtotal: dinero, descuento: dinero, impuesto: dinero, total: dinero,
    devoluciones: { bsonType: "array", items: {
      bsonType: "object", required: ["fecha", "motivo", "articulos"],
      properties: { motivo: { enum: ["Defectuoso", "No le gustó", "Regalo duplicado", "Error de compra"] } } } }
  } } } });

db.createCollection("intercambios", { validator: { $jsonSchema: {
  bsonType: "object",
  required: ["_id", "fecha", "sucursal", "cliente", "forma_pago", "articulos", "total_pagado"],
  properties: {
    forma_pago: { enum: ["Efectivo", "Crédito en tienda"] },
    articulos: { bsonType: "array", minItems: 1 },
    total_pagado: dinero
  } } } });

db.createCollection("preventas", { validator: { $jsonSchema: {
  bsonType: "object", required: ["fecha", "cliente", "producto", "sucursal", "anticipo", "estado"],
  properties: { estado: { enum: ["Pendiente", "Entregada", "Cancelada"] }, anticipo: dinero } } } });

db.createCollection("ordenes_compra", { validator: { $jsonSchema: {
  bsonType: "object", required: ["_id", "fecha", "proveedor", "sucursal", "estado", "articulos"],
  properties: { estado: { enum: ["Pendiente", "Recibida", "Cancelada"] }, articulos: { bsonType: "array", minItems: 1 } } } } });

db.createCollection("bitacora_precios");

// ---------------------------------------------------------------------
// Índices
// ---------------------------------------------------------------------
db.sucursales.createIndex({ numero_tienda: 1 }, { unique: true });
db.sucursales.createIndex({ "empleados._id": 1 });
db.sucursales.createIndex({ "empleados.correo": 1 }, { unique: true });
db.clientes.createIndex({ correo: 1 }, { unique: true });
db.clientes.createIndex({ estado: 1, "membresia.nivel": 1 });
db.productos.createIndex({ nombre: "text" });                       // búsqueda por texto
db.productos.createIndex({ categoria: 1, "plataforma.nombre": 1 });
db.productos.createIndex({ "inventario.sucursal": 1 });
db.ventas.createIndex({ fecha: 1 });
db.ventas.createIndex({ "sucursal._id": 1, fecha: 1 });
db.ventas.createIndex({ cliente: 1 });
db.ventas.createIndex({ "articulos.sku": 1 });
db.intercambios.createIndex({ cliente: 1 });
db.preventas.createIndex({ cliente: 1, producto: 1, estado: 1 }, { unique: true });
db.ordenes_compra.createIndex({ sucursal: 1, estado: 1 });

// ---------------------------------------------------------------------
// Vistas (equivalentes a las vistas de MySQL)
// ---------------------------------------------------------------------

// Ventas por tienda
db.createView("v_ventas_tienda", "ventas", [
  { $group: { _id: "$sucursal._id", tienda: { $first: "$sucursal.nombre" }, estado: { $first: "$sucursal.estado" },
              tickets: { $sum: 1 }, ventas_netas: { $sum: { $subtract: ["$subtotal", "$descuento"] } },
              impuesto: { $sum: "$impuesto" }, total: { $sum: "$total" } } },
  { $set: { ventas_netas: { $round: ["$ventas_netas", 2] }, impuesto: { $round: ["$impuesto", 2] }, total: { $round: ["$total", 2] } } },
  { $sort: { total: -1 } }
]);

// Catálogo con existencia total en la cadena y margen
db.createView("v_catalogo", "productos", [
  { $project: { nombre: 1, categoria: 1, plataforma: "$plataforma.nombre", condicion: 1, precio_venta: 1, costo: 1, activo: 1,
                margen_pct: { $round: [{ $multiply: [{ $divide: [{ $subtract: ["$precio_venta", "$costo"] }, "$precio_venta"] }, 100] }, 1] },
                existencia_total: { $sum: "$inventario.existencia" } } },
  { $sort: { categoria: 1, nombre: 1 } }
]);

// Valor del inventario por tienda
db.createView("v_inventario_valorizado", "productos", [
  { $unwind: "$inventario" },
  { $group: { _id: "$inventario.sucursal",
              piezas: { $sum: "$inventario.existencia" },
              valor_costo: { $sum: { $multiply: ["$inventario.existencia", "$costo"] } },
              valor_venta: { $sum: { $multiply: ["$inventario.existencia", "$precio_venta"] } } } },
  { $lookup: { from: "sucursales", localField: "_id", foreignField: "_id", as: "s" } },
  { $project: { _id: 0, numero_tienda: { $first: "$s.numero_tienda" }, tienda: { $first: "$s.nombre" },
                piezas: 1, valor_costo: { $round: ["$valor_costo", 2] }, valor_venta: { $round: ["$valor_venta", 2] } } },
  { $sort: { valor_venta: -1 } }
]);

// Ventas diarias
db.createView("v_ventas_diarias", "ventas", [
  { $group: { _id: { $dateToString: { format: "%Y-%m-%d", date: "$fecha" } },
              tickets: { $sum: 1 }, total: { $sum: "$total" } } },
  { $set: { total: { $round: ["$total", 2] } } },
  { $sort: { _id: 1 } }
]);

print("Colecciones, validaciones, índices y vistas creadas en 'gamestop_usa'.");
