// =====================================================================
//  BASE DE DATOS: gamestop  (MongoDB)
//  Ejecutar con:  mongosh mongodb/01_crear_bd.js
//  o pegarlo en la pestaña "Mongosh" de MongoDB Compass.
//
//  Diseño documental:
//    sucursales   -> empleados EMBEBIDOS
//    productos    -> inventario por sucursal EMBEBIDO
//    clientes     -> datos y membresía
//    ventas       -> artículos EMBEBIDOS (copia de nombre y precio al vender)
//    intercambios -> artículos usados EMBEBIDOS
//    preventas    -> referencias a cliente, producto y sucursal
// =====================================================================

db = db.getSiblingDB("gamestop");
db.dropDatabase();
const D = (s) => new Date(s);

// ---------------------------------------------------------------------
// Validación de esquema para productos y ventas
// ---------------------------------------------------------------------
db.createCollection("productos", {
  validator: { $jsonSchema: {
    bsonType: "object",
    required: ["_id", "nombre", "categoria", "condicion", "precio_venta", "costo"],
    properties: {
      categoria:    { enum: ["Videojuego", "Consola", "Accesorio", "Coleccionable", "Tarjeta de regalo"] },
      condicion:    { enum: ["Nuevo", "Usado", "Reacondicionado"] },
      precio_venta: { bsonType: ["double", "int"], minimum: 0 },
      costo:        { bsonType: ["double", "int"], minimum: 0 },
      inventario:   { bsonType: "array", items: {
        bsonType: "object", required: ["sucursal", "existencia"],
        properties: { existencia: { bsonType: ["int", "double"], minimum: 0 } } } }
    } } }
});

db.createCollection("ventas", {
  validator: { $jsonSchema: {
    bsonType: "object",
    required: ["fecha", "sucursal", "empleado", "metodo_pago", "articulos"],
    properties: {
      metodo_pago: { enum: ["Efectivo", "Tarjeta", "Crédito en tienda"] },
      articulos:   { bsonType: "array", minItems: 1 }
    } } }
});

// ---------------------------------------------------------------------
// Sucursales con sus empleados
// ---------------------------------------------------------------------
db.sucursales.insertMany([
  { _id: 1, nombre: "GameStop Plaza Río", direccion: "Paseo de los Héroes 96, Zona Río", ciudad: "Tijuana",
    estado: "Baja California", telefono: "664-100-2001", fecha_apertura: D("2015-06-12"),
    empleados: [
      { _id: 1,  nombre: "Roberto Sánchez", puesto: "Gerente",    salario_mensual: 22000, contratacion: D("2015-06-01") },
      { _id: 2,  nombre: "Fernanda Ruiz",   puesto: "Vendedor",   salario_mensual: 11500, contratacion: D("2022-01-10") },
      { _id: 3,  nombre: "Kevin Morales",   puesto: "Vendedor",   salario_mensual: 11500, contratacion: D("2023-05-15") },
      { _id: 10, nombre: "Miguel Torres",   puesto: "Subgerente", salario_mensual: 16000, contratacion: D("2020-07-01") }] },
  { _id: 2, nombre: "GameStop Macroplaza", direccion: "Blvd. Insurgentes 17017, Otay", ciudad: "Tijuana",
    estado: "Baja California", telefono: "664-100-2002", fecha_apertura: D("2018-03-20"),
    empleados: [
      { _id: 4, nombre: "Patricia Gómez", puesto: "Gerente",  salario_mensual: 22000, contratacion: D("2018-03-01") },
      { _id: 5, nombre: "Iván Castro",    puesto: "Vendedor", salario_mensual: 11500, contratacion: D("2024-02-05") }] },
  { _id: 3, nombre: "GameStop Plaza La Cachanilla", direccion: "Blvd. López Mateos 1306", ciudad: "Mexicali",
    estado: "Baja California", telefono: "686-200-3001", fecha_apertura: D("2016-09-01"),
    empleados: [
      { _id: 6, nombre: "Jorge Hernández", puesto: "Gerente",  salario_mensual: 21000, contratacion: D("2016-08-15") },
      { _id: 7, nombre: "Daniela Ortiz",   puesto: "Vendedor", salario_mensual: 11000, contratacion: D("2023-10-01") }] },
  { _id: 4, nombre: "GameStop Ensenada Centro", direccion: "Av. Reforma 1025", ciudad: "Ensenada",
    estado: "Baja California", telefono: "646-300-4001", fecha_apertura: D("2019-11-15"),
    empleados: [
      { _id: 8, nombre: "Ricardo Flores", puesto: "Gerente",  salario_mensual: 21000, contratacion: D("2019-11-01") },
      { _id: 9, nombre: "Andrea Vargas",  puesto: "Vendedor", salario_mensual: 11000, contratacion: D("2025-01-20") }] }
]);

// ---------------------------------------------------------------------
// Clientes
// ---------------------------------------------------------------------
db.clientes.insertMany([
  { _id: 1, nombre: "Carlos Ramírez",  correo: "carlos.ramirez@correo.com",  telefono: "664-555-0101", membresia: "Pro",    puntos: 1200, registro: D("2022-04-10") },
  { _id: 2, nombre: "Mariana López",   correo: "mariana.lopez@correo.com",   telefono: "664-555-0102", membresia: "Pro",    puntos: 850,  registro: D("2023-01-22") },
  { _id: 3, nombre: "Luis Martínez",   correo: "luis.martinez@correo.com",   telefono: "686-555-0103", membresia: "Básica", puntos: 150,  registro: D("2023-07-03") },
  { _id: 4, nombre: "Sofía García",    correo: "sofia.garcia@correo.com",    telefono: "646-555-0104", membresia: "Básica", puntos: 300,  registro: D("2024-02-14") },
  { _id: 5, nombre: "Diego Pérez",     correo: "diego.perez@correo.com",     telefono: "664-555-0105", membresia: "Básica", puntos: 0,    registro: D("2024-11-29") },
  { _id: 6, nombre: "Valeria Jiménez", correo: "valeria.jimenez@correo.com", telefono: "664-555-0106", membresia: "Pro",    puntos: 2100, registro: D("2021-12-01") },
  { _id: 7, nombre: "Emilio Navarro",  correo: "emilio.navarro@correo.com",  telefono: "646-555-0107", membresia: "Básica", puntos: 40,   registro: D("2025-06-18") },
  { _id: 8, nombre: "Ximena Rojas",    correo: "ximena.rojas@correo.com",    telefono: "664-555-0108", membresia: "Básica", puntos: 90,   registro: D("2025-09-09") }
]);

// ---------------------------------------------------------------------
// Productos (con inventario por sucursal embebido)
// ---------------------------------------------------------------------
const productos = [
  // _id,          nombre,                                        categoria,          plataforma,          proveedor,                        condicion,        esrb,  precio,  costo, lanzamiento
  ["CON-PS5-SLM",  "Consola PlayStation 5 Slim 1TB",                 "Consola",          "PlayStation 5",     "Sony Interactive Entertainment", "Nuevo",           null,   9999, 8200, "2023-11-10"],
  ["CON-XSX-1TB",  "Consola Xbox Series X 1TB",                      "Consola",          "Xbox Series X|S",   "Microsoft Xbox",                 "Nuevo",           null,  11999, 9900, "2020-11-10"],
  ["CON-NS2-STD",  "Consola Nintendo Switch 2",                      "Consola",          "Nintendo Switch 2", "Nintendo",                       "Nuevo",           null,   9499, 7900, "2025-06-05"],
  ["CON-NSW-OLR",  "Consola Nintendo Switch OLED (reacondicionada)", "Consola",          "Nintendo Switch",   null,                             "Reacondicionado", null,   4999, 2600, "2021-10-08"],
  ["VJ-PS5-FC26",  "EA Sports FC 26",                                "Videojuego",       "PlayStation 5",     "Electronic Arts",                "Nuevo",           "E",    1399,  950, "2025-09-26"],
  ["VJ-NS2-MKW",   "Mario Kart World",                               "Videojuego",       "Nintendo Switch 2", "Nintendo",                       "Nuevo",           "E",    1699, 1200, "2025-06-05"],
  ["VJ-PS5-BO7",   "Call of Duty: Black Ops 7",                      "Videojuego",       "PlayStation 5",     "Activision",                     "Nuevo",           "M",    1599, 1100, "2025-11-14"],
  ["VJ-PS5-ELR-U", "Elden Ring (usado)",                             "Videojuego",       "PlayStation 5",     null,                             "Usado",           "M",     649,  220, "2022-02-25"],
  ["VJ-NSW-TOTK",  "The Legend of Zelda: Tears of the Kingdom",      "Videojuego",       "Nintendo Switch",   "Nintendo",                       "Nuevo",           "E10+", 1299,  900, "2023-05-12"],
  ["VJ-NSW-MINE",  "Minecraft",                                      "Videojuego",       "Nintendo Switch",   "Microsoft Xbox",                 "Nuevo",           "E10+",  599,  380, "2018-06-21"],
  ["VJ-PS5-GTA-U", "Grand Theft Auto V (usado)",                     "Videojuego",       "PlayStation 5",     null,                             "Usado",           "M",     399,  120, "2022-03-15"],
  ["VJ-NS2-PLZA",  "Pokémon Legends: Z-A",                           "Videojuego",       "Nintendo Switch 2", "Nintendo",                       "Nuevo",           "E10+", 1299,  900, "2025-10-16"],
  ["VJ-XSX-HAL-U", "Halo Infinite (usado)",                          "Videojuego",       "Xbox Series X|S",   null,                             "Usado",           "T",     299,   90, "2021-12-08"],
  ["VJ-PS5-SM2",   "Marvel's Spider-Man 2",                          "Videojuego",       "PlayStation 5",     "Sony Interactive Entertainment", "Nuevo",           "T",    1199,  800, "2023-10-20"],
  ["ACC-PS5-DS",   "Control inalámbrico DualSense",                  "Accesorio",        "PlayStation 5",     "Sony Interactive Entertainment", "Nuevo",           null,   1599, 1100, "2020-11-12"],
  ["ACC-XSX-CTL",  "Control inalámbrico Xbox",                       "Accesorio",        "Xbox Series X|S",   "Microsoft Xbox",                 "Nuevo",           null,   1399,  950, "2020-11-10"],
  ["ACC-NS2-PRO",  "Control Pro para Nintendo Switch 2",             "Accesorio",        "Nintendo Switch 2", "Nintendo",                       "Nuevo",           null,   1799, 1250, "2025-06-05"],
  ["ACC-HX-CL3",   "Audífonos HyperX Cloud III",                     "Accesorio",        null,                "HyperX",                         "Nuevo",           null,   1999, 1300, "2023-03-01"],
  ["TAR-PSN-500",  "Tarjeta PlayStation Store $500",                 "Tarjeta de regalo","PlayStation 5",     "Sony Interactive Entertainment", "Nuevo",           null,    500,  475, null],
  ["TAR-ESH-500",  "Tarjeta Nintendo eShop $500",                    "Tarjeta de regalo","Nintendo Switch",   "Nintendo",                       "Nuevo",           null,    500,  475, null],
  ["COL-FNK-MAR",  "Funko Pop! Mario",                               "Coleccionable",    null,                "Funko",                          "Nuevo",           null,    349,  180, null],
  ["COL-FNK-KRA",  "Funko Pop! Kratos",                              "Coleccionable",    null,                "Funko",                          "Nuevo",           null,    349,  180, null],
  ["COL-AMI-LNK",  "Amiibo Link",                                    "Coleccionable",    "Nintendo Switch",   "Nintendo",                       "Nuevo",           null,    399,  250, "2023-05-12"],
  ["VJ-PS5-GOY",   "Ghost of Yōtei",                                 "Videojuego",       "PlayStation 5",     "Sony Interactive Entertainment", "Nuevo",           "M",    1599, 1100, "2025-10-02"],
  ["VJ-NS2-MP4",   "Metroid Prime 4: Beyond",                        "Videojuego",       "Nintendo Switch 2", "Nintendo",                       "Nuevo",           "T",    1499, 1050, "2025-12-04"],
  ["ACC-PS5-DSE",  "Control DualSense Edición Especial",             "Accesorio",        "PlayStation 5",     "Sony Interactive Entertainment", "Nuevo",           null,   1899, 1300, "2026-12-12"]
];

const HOY = D("2026-11-23");
db.productos.insertMany(productos.map(([_id, nombre, categoria, plataforma, proveedor, condicion, esrb, precio, costo, lanz], idx) => {
  const doc = { _id, nombre, categoria, condicion, precio_venta: precio, costo, activo: true };
  if (plataforma) doc.plataforma = plataforma;
  if (proveedor)  doc.proveedor  = proveedor;
  if (esrb)       doc.clasificacion = esrb;
  if (lanz)       doc.fecha_lanzamiento = D(lanz);
  const lanzado = !lanz || D(lanz) <= HOY;
  // Misma fórmula que en MySQL: existencia entre 3 y 12 según producto y sucursal
  doc.inventario = lanzado
    ? [1, 2, 3, 4].map(s => ({ sucursal: s, existencia: 3 + ((idx + 1) * 7 + s * 3) % 10,
                               stock_minimo: categoria === "Consola" ? 2 : 3 }))
    : [];
  return doc;
}));

// ---------------------------------------------------------------------
// Ventas: se calcula el total y se descuenta el inventario al insertar
// (lo que en MySQL hacen los triggers, aquí lo hace el script)
// ---------------------------------------------------------------------
function registrarVenta(id, fecha, sucursal, empleado, cliente, metodo_pago, items) {
  const articulos = items.map(([sku, cantidad]) => {
    const p = db.productos.findOne({ _id: sku });
    const inv = p.inventario.find(i => i.sucursal === sucursal);
    if (!inv || inv.existencia < cantidad) throw new Error("Sin existencia de " + sku + " en sucursal " + sucursal);
    return { sku, nombre: p.nombre, cantidad, precio_unitario: p.precio_venta };
  });
  const subtotal  = articulos.reduce((s, a) => s + a.cantidad * a.precio_unitario, 0);
  const cli       = cliente ? db.clientes.findOne({ _id: cliente }) : null;
  const descuento = cli && cli.membresia === "Pro" ? Math.round(subtotal * 0.10 * 100) / 100 : 0;
  const total     = Math.round((subtotal - descuento) * 100) / 100;
  const iva       = Math.round(total / 1.16 * 0.16 * 100) / 100;

  db.ventas.insertOne({ _id: id, fecha: D(fecha), sucursal, empleado, cliente, metodo_pago,
                        articulos, subtotal, descuento, iva, total });

  articulos.forEach(a => db.productos.updateOne(
    { _id: a.sku, "inventario.sucursal": sucursal },
    { $inc: { "inventario.$.existencia": -a.cantidad } }));

  if (cliente) db.clientes.updateOne({ _id: cliente },
    { $inc: { puntos: articulos.reduce((s, a) => s + Math.floor(a.cantidad * a.precio_unitario / 10), 0) } });
}

registrarVenta( 1, "2026-11-02T11:15:00", 1,  2, 1,    "Tarjeta",           [["CON-PS5-SLM", 1], ["ACC-PS5-DS", 1]]);
registrarVenta( 2, "2026-11-03T17:40:00", 1,  3, null, "Efectivo",          [["VJ-NSW-MINE", 1]]);
registrarVenta( 3, "2026-11-05T13:05:00", 2,  5, 2,    "Tarjeta",           [["CON-NS2-STD", 1], ["VJ-NS2-MKW", 1]]);
registrarVenta( 4, "2026-11-07T18:20:00", 3,  7, 3,    "Crédito en tienda", [["VJ-PS5-ELR-U", 1], ["VJ-PS5-GTA-U", 1]]);
registrarVenta( 5, "2026-11-08T12:00:00", 4,  9, 4,    "Tarjeta",           [["VJ-PS5-BO7", 1], ["ACC-XSX-CTL", 1]]);
registrarVenta( 6, "2026-11-10T16:45:00", 1,  2, 5,    "Efectivo",          [["COL-FNK-MAR", 2], ["COL-AMI-LNK", 1]]);
registrarVenta( 7, "2026-11-12T19:10:00", 2,  5, null, "Tarjeta",           [["TAR-PSN-500", 1]]);
registrarVenta( 8, "2026-11-14T15:30:00", 1, 10, 6,    "Tarjeta",           [["VJ-PS5-GOY", 1], ["VJ-PS5-SM2", 1]]);
registrarVenta( 9, "2026-11-15T11:50:00", 3,  7, 1,    "Tarjeta",           [["ACC-HX-CL3", 1]]);
registrarVenta(10, "2026-11-18T20:05:00", 4,  9, 7,    "Efectivo",          [["CON-XSX-1TB", 1], ["VJ-XSX-HAL-U", 1]]);
registrarVenta(11, "2026-11-20T14:25:00", 1,  3, 8,    "Tarjeta",           [["VJ-NS2-PLZA", 1], ["ACC-NS2-PRO", 1]]);
registrarVenta(12, "2026-11-21T17:00:00", 2,  4, 2,    "Crédito en tienda", [["VJ-NS2-MP4", 1], ["TAR-ESH-500", 1]]);
registrarVenta(13, "2026-11-22T12:35:00", 1,  2, null, "Efectivo",          [["VJ-PS5-FC26", 2]]);
registrarVenta(14, "2026-11-22T18:55:00", 3,  6, 3,    "Tarjeta",           [["CON-NSW-OLR", 1], ["VJ-NSW-TOTK", 1]]);

// ---------------------------------------------------------------------
// Intercambios: la tienda paga 30% en efectivo o 40% en crédito
// ---------------------------------------------------------------------
function registrarIntercambio(id, fecha, sucursal, empleado, cliente, forma_pago, items) {
  const pct = forma_pago === "Crédito en tienda" ? 0.40 : 0.30;
  const articulos = items.map(([sku, cantidad]) => {
    const p = db.productos.findOne({ _id: sku });
    return { sku, nombre: p.nombre, cantidad, valor_unitario: Math.round(p.precio_venta * pct * 100) / 100 };
  });
  const total_pagado = Math.round(articulos.reduce((s, a) => s + a.cantidad * a.valor_unitario, 0) * 100) / 100;
  db.intercambios.insertOne({ _id: id, fecha: D(fecha), sucursal, empleado, cliente, forma_pago, articulos, total_pagado });
  articulos.forEach(a => db.productos.updateOne(
    { _id: a.sku, "inventario.sucursal": sucursal },
    { $inc: { "inventario.$.existencia": a.cantidad } }));
}

registrarIntercambio(1, "2026-11-04T16:00:00", 1, 2, 5, "Crédito en tienda", [["VJ-PS5-ELR-U", 1], ["VJ-PS5-GTA-U", 1]]);
registrarIntercambio(2, "2026-11-09T13:30:00", 3, 7, 3, "Efectivo",          [["VJ-XSX-HAL-U", 2]]);
registrarIntercambio(3, "2026-11-16T18:15:00", 2, 5, 2, "Crédito en tienda", [["CON-NSW-OLR", 1]]);

// ---------------------------------------------------------------------
// Preventas
// ---------------------------------------------------------------------
db.preventas.insertMany([
  { fecha: D("2025-10-20"), cliente: 2, producto: "VJ-NS2-MP4",  sucursal: 2, anticipo: 300,  estado: "Entregada" },
  { fecha: D("2025-09-15"), cliente: 8, producto: "VJ-NS2-PLZA", sucursal: 1, anticipo: 300,  estado: "Entregada" },
  { fecha: D("2026-11-01"), cliente: 1, producto: "ACC-PS5-DSE", sucursal: 1, anticipo: 500,  estado: "Pendiente" },
  { fecha: D("2026-11-11"), cliente: 6, producto: "ACC-PS5-DSE", sucursal: 1, anticipo: 500,  estado: "Pendiente" },
  { fecha: D("2026-11-13"), cliente: 4, producto: "ACC-PS5-DSE", sucursal: 4, anticipo: 200,  estado: "Pendiente" },
  { fecha: D("2026-10-05"), cliente: 7, producto: "CON-PS5-SLM", sucursal: 4, anticipo: 1000, estado: "Cancelada" }
]);

// ---------------------------------------------------------------------
// Índices
// ---------------------------------------------------------------------
db.clientes.createIndex({ correo: 1 }, { unique: true });
db.productos.createIndex({ nombre: 1 });
db.productos.createIndex({ categoria: 1, plataforma: 1 });
db.productos.createIndex({ "inventario.sucursal": 1 });
db.ventas.createIndex({ fecha: 1 });
db.ventas.createIndex({ sucursal: 1, fecha: 1 });
db.ventas.createIndex({ cliente: 1 });
db.preventas.createIndex({ estado: 1, producto: 1 });

print("Base de datos 'gamestop' creada:");
["sucursales", "clientes", "productos", "ventas", "intercambios", "preventas"]
  .forEach(c => print("  " + c.padEnd(13) + db[c].countDocuments()));
