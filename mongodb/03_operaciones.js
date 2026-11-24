// =====================================================================
//  BASE DE DATOS: gamestop_usa (MongoDB)
//  Archivo 3 de 4: operaciones con reglas de negocio + pruebas
//
//  En MySQL las reglas viven en triggers y procedimientos. En MongoDB
//  viven en la aplicación; aquí se programan como funciones de JavaScript
//  que hacen lo mismo:
//
//    registrarVenta()       -> valida empleado, existencia, producto activo y
//                              crédito; calcula descuento Pro, impuesto, total;
//                              descuenta inventario; suma puntos; cobra crédito
//    registrarDevolucion()  -> plazo de 30 días, cantidades, reembolso con
//                              impuesto, regresa inventario, quita puntos
//    registrarIntercambio() -> solo usados; 25% efectivo / 35% crédito (+bono Pro)
//    recibirOrden()         -> suma la mercancía al inventario
//    cambiarPrecio()        -> no permite precio < costo; escribe la bitácora
//
//  Si el servidor es un replica set (MongoDB Atlas, por ejemplo) cada
//  operación corre dentro de una TRANSACCIÓN; en un servidor local
//  sencillo (standalone) corre sin transacción.
//
//  Ejecutar después de 02_datos.js:   mongosh mongodb/03_operaciones.js
//  OJO: este archivo modifica datos (agrega una venta, un intercambio...).
// =====================================================================

db = db.getSiblingDB("gamestop_usa");

// ---------------------------------------------------------------------
// Utilidades
// ---------------------------------------------------------------------
// redondeo a centavos (los números de JavaScript son de punto flotante)
const r2 = (x) => Math.round((x + Number.EPSILON) * 100) / 100;
const err = (msg) => { throw new Error(msg); };
const siguienteId = (col) => ((db[col].find({}, { _id: 1 }).sort({ _id: -1 }).limit(1).toArray()[0] || { _id: 0 })._id + 1);

function enTransaccion(fn) {
  let session;
  try { session = db.getMongo().startSession(); } catch (e) { return fn(); }
  const original = db;
  try {
    let resultado;
    session.withTransaction(() => {
      // dentro de la transacción todas las operaciones usan la base de la sesión
      db = session.getDatabase("gamestop_usa");
      try { resultado = fn(); } finally { db = original; }
    });
    return resultado;
  } catch (e) {
    db = original;
    // 20 / 263: el servidor standalone no soporta transacciones -> se ejecuta normal
    if (e.code === 20 || e.code === 263 || /replica set|Transaction numbers/i.test(e.message)) return fn();
    throw e;
  } finally { session.endSession(); }
}

function tasaImpuesto(idSucursal) {
  const s = db.sucursales.findOne({ _id: idSucursal }, { estado: 1 });
  return s ? s.estado.tasa_impuesto : err("La tienda no existe");
}

function esPro(idCliente, fecha) {
  const c = db.clientes.findOne({ _id: idCliente });
  return !!(c && c.membresia.nivel === "GameStop Pro" && c.membresia.vencimiento && c.membresia.vencimiento >= fecha);
}

function nivelDe(idCliente) {
  const c = db.clientes.findOne({ _id: idCliente });
  return db.niveles_membresia.findOne({ nombre: c.membresia.nivel });
}

// Suma piezas al inventario de una tienda; si la tienda no tenía el
// producto, agrega el elemento al arreglo inventario.
function sumarInventario(sku, sucursal, cantidad, stockMinimo) {
  if (db.productos.countDocuments({ _id: sku, "inventario.sucursal": sucursal }) > 0)
    db.productos.updateOne({ _id: sku }, { $inc: { "inventario.$[i].existencia": cantidad } },
                           { arrayFilters: [{ "i.sucursal": sucursal }] });
  else
    db.productos.updateOne({ _id: sku }, { $push: { inventario: { sucursal, existencia: cantidad, stock_minimo: stockMinimo } } });
}

// ---------------------------------------------------------------------
// registrarVenta
// ---------------------------------------------------------------------
function registrarVenta({ sucursal, empleado, cliente = null, metodo_pago, articulos, fecha = new Date() }) {
  return enTransaccion(() => {
    const tienda = db.sucursales.findOne({ _id: sucursal });
    if (!tienda) err("La tienda no existe");
    const emp = tienda.empleados.find(e => e._id === empleado && e.activo);
    if (!emp) err("El empleado no trabaja en esa tienda");
    if (metodo_pago === "Crédito en tienda" && cliente === null) err("El crédito en tienda requiere un cliente registrado");

    const tasa = tienda.estado.tasa_impuesto;
    const pro = cliente !== null && esPro(cliente, fecha);
    const descPct = pro ? nivelDe(cliente).descuento_usados_pct : 0;

    const lineas = articulos.map(({ sku, cantidad }) => {
      const p = db.productos.findOne({ _id: sku });
      if (!p) err("El SKU " + sku + " no existe en el catálogo");
      if (!p.activo) err("El producto " + sku + " está descontinuado");
      const inv = p.inventario.find(i => i.sucursal === sucursal);
      if (!inv || inv.existencia < cantidad) err("No hay existencia suficiente de " + sku + " en la tienda");
      const descuento = p.condicion !== "Nuevo" ? r2(cantidad * p.precio_venta * descPct / 100) : 0;
      return { sku, nombre: p.nombre, categoria: p.categoria, condicion: p.condicion,
               cantidad, precio_unitario: p.precio_venta, descuento };
    });

    const subtotal  = r2(lineas.reduce((s, l) => s + l.cantidad * l.precio_unitario, 0));
    const descuento = r2(lineas.reduce((s, l) => s + l.descuento, 0));
    const impuesto  = r2((subtotal - descuento) * tasa);
    const total     = r2(subtotal - descuento + impuesto);

    if (metodo_pago === "Crédito en tienda") {
      const c = db.clientes.findOne({ _id: cliente });
      if (c.credito_tienda < total) err("Crédito en tienda insuficiente");
    }

    const _id = siguienteId("ventas");
    db.ventas.insertOne({ _id, fecha, sucursal: { _id: sucursal, nombre: tienda.nombre, estado: tienda.estado.abreviatura },
                          empleado: { _id: empleado, nombre: emp.nombre + " " + emp.apellido },
                          cliente, metodo_pago, articulos: lineas, subtotal, descuento, impuesto, total, estado: "Completada" });

    lineas.forEach(l => db.productos.updateOne(
      { _id: l.sku }, { $inc: { "inventario.$[i].existencia": -l.cantidad } }, { arrayFilters: [{ "i.sucursal": sucursal }] }));

    if (cliente !== null) {
      const c = db.clientes.findOne({ _id: cliente });
      const puntos = Math.floor((subtotal - descuento) * nivelDe(cliente).puntos_por_dolar);
      const cargo = metodo_pago === "Crédito en tienda" ? total : 0;
      db.clientes.updateOne({ _id: cliente }, { $inc: { puntos: puntos },
                                                $set: { credito_tienda: r2(c.credito_tienda - cargo) } });
    }
    return _id;
  });
}

// ---------------------------------------------------------------------
// registrarDevolucion
// ---------------------------------------------------------------------
function registrarDevolucion(idVenta, { empleado, motivo, articulos, fecha = new Date() }) {
  return enTransaccion(() => {
    const v = db.ventas.findOne({ _id: idVenta });
    if (!v) err("La venta no existe");
    if ((fecha - v.fecha) / 86400000 > 30) err("Pasaron más de 30 días desde la compra");
    const tasa = tasaImpuesto(v.sucursal._id);
    const devueltoAntes = (sku) => (v.devoluciones || []).flatMap(d => d.articulos)
                                     .filter(a => a.sku === sku).reduce((s, a) => s + a.cantidad, 0);
    let monto = 0, netoTotal = 0;
    articulos.forEach(({ sku, cantidad }) => {
      const l = v.articulos.find(a => a.sku === sku);
      if (!l) err("Ese producto no está en la venta");
      if (devueltoAntes(sku) + cantidad > l.cantidad) err("Se intenta devolver más de lo que se compró");
      const neto = r2(cantidad * l.precio_unitario - l.descuento * cantidad / l.cantidad);
      netoTotal += neto;
      monto += r2(neto * (1 + tasa));
    });
    const ultima = db.ventas.aggregate([{ $unwind: "$devoluciones" },
                                        { $group: { _id: null, max: { $max: "$devoluciones._id" } } }]).toArray()[0];
    const dev = { _id: (ultima ? ultima.max : 0) + 1, fecha, empleado, motivo, monto_reembolsado: r2(monto), articulos };
    const vendidas = v.articulos.reduce((s, a) => s + a.cantidad, 0);
    const devueltas = (v.devoluciones || []).flatMap(d => d.articulos).reduce((s, a) => s + a.cantidad, 0)
                      + articulos.reduce((s, a) => s + a.cantidad, 0);
    db.ventas.updateOne({ _id: idVenta }, { $push: { devoluciones: dev },
                                            $set: { estado: devueltas >= vendidas ? "Devuelta" : "Devuelta parcial" } });
    articulos.forEach(a => db.productos.updateOne(
      { _id: a.sku }, { $inc: { "inventario.$[i].existencia": a.cantidad } }, { arrayFilters: [{ "i.sucursal": v.sucursal._id }] }));
    if (v.cliente !== null) {
      const c = db.clientes.findOne({ _id: v.cliente });
      const quitar = Math.min(c.puntos, Math.floor(netoTotal * nivelDe(v.cliente).puntos_por_dolar));
      const abono = v.metodo_pago === "Crédito en tienda" ? monto : 0;
      db.clientes.updateOne({ _id: v.cliente }, { $inc: { puntos: -quitar },
                                                  $set: { credito_tienda: r2(c.credito_tienda + abono) } });
    }
    return dev;
  });
}

// ---------------------------------------------------------------------
// registrarIntercambio
// ---------------------------------------------------------------------
function registrarIntercambio({ sucursal, empleado, cliente, forma_pago, articulos, fecha = new Date() }) {
  return enTransaccion(() => {
    if (!db.clientes.findOne({ _id: cliente })) err("El cliente no existe");
    let pct = forma_pago === "Crédito en tienda" ? 0.35 : 0.25;
    if (forma_pago === "Crédito en tienda" && esPro(cliente, fecha)) pct *= 1 + nivelDe(cliente).bono_intercambio_pct / 100;

    const lineas = articulos.map(({ sku, cantidad }) => {
      const p = db.productos.findOne({ _id: sku });
      if (!p) err("El SKU " + sku + " no existe");
      if (p.condicion === "Nuevo") err("En un intercambio solo entran productos usados o reacondicionados");
      return { sku, nombre: p.nombre, cantidad, valor_unitario: r2(p.precio_venta * pct) };
    });
    const total_pagado = r2(lineas.reduce((s, l) => s + l.cantidad * l.valor_unitario, 0));
    const _id = siguienteId("intercambios");
    db.intercambios.insertOne({ _id, fecha, sucursal, empleado, cliente, forma_pago, articulos: lineas, total_pagado });

    lineas.forEach(l => sumarInventario(l.sku, sucursal, l.cantidad, 1));
    if (forma_pago === "Crédito en tienda") {
      const c = db.clientes.findOne({ _id: cliente });
      db.clientes.updateOne({ _id: cliente }, { $set: { credito_tienda: r2(c.credito_tienda + total_pagado) } });
    }
    return _id;
  });
}

// ---------------------------------------------------------------------
// recibirOrden
// ---------------------------------------------------------------------
function recibirOrden(idOrden, fecha = new Date()) {
  return enTransaccion(() => {
    const o = db.ordenes_compra.findOne({ _id: idOrden });
    if (!o) err("La orden no existe");
    if (o.estado !== "Pendiente") err("Solo se pueden recibir órdenes pendientes");
    o.articulos.forEach(a => sumarInventario(a.sku, o.sucursal, a.cantidad, 3));
    db.ordenes_compra.updateOne({ _id: idOrden }, { $set: { estado: "Recibida", fecha_recepcion: fecha } });
  });
}

// ---------------------------------------------------------------------
// cambiarPrecio (con bitácora)
// ---------------------------------------------------------------------
function cambiarPrecio(sku, nuevo, usuario = "mongosh") {
  return enTransaccion(() => {
    const p = db.productos.findOne({ _id: sku });
    if (!p) err("El SKU no existe");
    if (nuevo < p.costo) err("El precio de venta no puede ser menor al costo");
    db.productos.updateOne({ _id: sku }, { $set: { precio_venta: nuevo } });
    db.bitacora_precios.insertOne({ _id: siguienteId("bitacora_precios"), producto: sku,
                                    precio_anterior: p.precio_venta, precio_nuevo: nuevo, fecha: new Date(), usuario });
  });
}

// =====================================================================
// PRUEBAS
// =====================================================================
function probar(nombre, fn) {
  try { const r = fn(); print("ACEPTADA   " + nombre + (r !== undefined ? "  -> " + JSON.stringify(r) : "")); }
  catch (e) { print("RECHAZADA  " + nombre + "  -> " + e.message); }
}

print("\n=== Operaciones que deben RECHAZARSE ===");
const sinCredito = db.clientes.findOne({ credito_tienda: 0 })._id;
const ventaOct   = db.ventas.find({ fecha: { $lt: new Date("2026-10-05T00:00:00Z") } }).sort({ _id: 1 }).limit(1).toArray()[0];
const ventaNov   = db.ventas.find({ fecha: { $gte: new Date("2026-11-20T00:00:00Z") }, estado: "Completada" }).sort({ _id: 1 }).limit(1).toArray()[0];

probar("Vender 500 PS5", () => registrarVenta({ sucursal: 1, empleado: 3, metodo_pago: "Efectivo",
                                                 articulos: [{ sku: "CON-PS5-SLM", cantidad: 500 }] }));
probar("Vender un producto descontinuado", () => registrarVenta({ sucursal: 1, empleado: 3, metodo_pago: "Efectivo",
                                                 articulos: [{ sku: "VJ-PS4-FIFA23", cantidad: 1 }] }));
probar("Pagar con crédito en tienda sin saldo", () => registrarVenta({ sucursal: 1, empleado: 3, cliente: sinCredito,
                                                 metodo_pago: "Crédito en tienda", articulos: [{ sku: "VJ-PS5-GTA6", cantidad: 1 }] }));
probar("Empleado de otra tienda", () => registrarVenta({ sucursal: 2, empleado: 3, metodo_pago: "Efectivo",
                                                 articulos: [{ sku: "ACC-PS5-DS", cantidad: 1 }] }));
probar("SKU inexistente", () => registrarVenta({ sucursal: 1, empleado: 3, metodo_pago: "Efectivo",
                                                 articulos: [{ sku: "NO-EXISTE", cantidad: 1 }] }));
probar("Devolver más de lo comprado", () => registrarDevolucion(ventaNov._id, { empleado: 3, motivo: "No le gustó",
                                                 fecha: new Date("2026-11-23T19:00:00Z"),
                                                 articulos: [{ sku: ventaNov.articulos[0].sku, cantidad: ventaNov.articulos[0].cantidad + 5 }] }));
probar("Devolución fuera de los 30 días", () => registrarDevolucion(ventaOct._id, { empleado: 3, motivo: "No le gustó",
                                                 fecha: new Date("2026-11-23T19:00:00Z"),
                                                 articulos: [{ sku: ventaOct.articulos[0].sku, cantidad: 1 }] }));
probar("Intercambiar un juego nuevo", () => registrarIntercambio({ sucursal: 1, empleado: 3, cliente: 1, forma_pago: "Efectivo",
                                                 articulos: [{ sku: "VJ-PS5-GTA6", cantidad: 1 }] }));
probar("Precio menor al costo", () => cambiarPrecio("CON-PS5-PRO", 10));
probar("Recibir dos veces la misma orden", () => recibirOrden(1));
probar("Validación $jsonSchema: existencia negativa", () =>
  db.productos.updateOne({ _id: "CON-PS5-SLM" }, { $set: { "inventario.0.existencia": -1 } }));
probar("Índice único: correo de cliente repetido", () =>
  db.clientes.insertOne({ _id: 999, nombre: "Test", apellido: "Test", correo: db.clientes.findOne({ _id: 1 }).correo,
                          estado: "TX", membresia: { nivel: "PowerUp Rewards" }, puntos: 0, credito_tienda: 0 }));

print("\n=== Operaciones válidas ===");
const clientePro = db.clientes.findOne({ "membresia.nivel": "GameStop Pro",
                                         "membresia.vencimiento": { $gte: new Date() } })._id;
const antes = db.clientes.findOne({ _id: clientePro }, { puntos: 1, credito_tienda: 1 });

probar("Intercambio con crédito (cliente Pro, recibe bono)", () => registrarIntercambio({
  sucursal: 1, empleado: 3, cliente: clientePro, forma_pago: "Crédito en tienda",
  articulos: [{ sku: "VJ-PS4-RDR2-U", cantidad: 1 }, { sku: "VJ-NSW-SMO-U", cantidad: 1 }] }));

let nuevaVenta;
probar("Venta: juego usado (con descuento Pro) + sobres Pokémon, pagada con crédito", () =>
  nuevaVenta = registrarVenta({ sucursal: 1, empleado: 3, cliente: clientePro, metodo_pago: "Crédito en tienda",
                                articulos: [{ sku: "VJ-PS4-GTAV-U", cantidad: 1 }, { sku: "COL-PKM-BOOST", cantidad: 2 }] }));
printjson(db.ventas.findOne({ _id: nuevaVenta }, { articulos: 1, subtotal: 1, descuento: 1, impuesto: 1, total: 1 }));
print("Cliente antes:   " + JSON.stringify(antes));
print("Cliente después: " + JSON.stringify(db.clientes.findOne({ _id: clientePro }, { puntos: 1, credito_tienda: 1 })));

probar("Devolución parcial de la venta anterior", () =>
  registrarDevolucion(nuevaVenta, { empleado: 3, motivo: "Regalo duplicado", articulos: [{ sku: "COL-PKM-BOOST", cantidad: 1 }] }));
printjson(db.ventas.findOne({ _id: nuevaVenta }, { estado: 1, devoluciones: 1 }));

probar("Recibir una orden pendiente", () =>
  recibirOrden(db.ordenes_compra.findOne({ estado: "Pendiente" }, { _id: 1 })._id));
probar("Cambiar un precio (queda en la bitácora)", () => cambiarPrecio("ACC-XSX-CTL", 58.49));
printjson(db.bitacora_precios.find().sort({ _id: -1 }).limit(1).toArray());
