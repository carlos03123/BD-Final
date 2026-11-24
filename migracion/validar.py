"""
Validación de la migración MySQL -> MongoDB

Comprueba que MongoDB tenga exactamente la misma información que MySQL:

  1. Conteos: cada tabla contra su colección o arreglo embebido
  2. Totales: importes de ventas, impuestos, reembolsos, intercambios,
     inventario, puntos y crédito (en general, por tienda y por producto)
  3. Integridad referencial dentro de MongoDB (referencias que apunten
     a documentos existentes)
  4. Estructura: que existan los validadores $jsonSchema y que ningún
     documento los viole
  5. Muestra: 25 ventas al azar comparadas campo por campo

Uso:
    python migracion/validar.py                       # muestra el resultado
    python migracion/validar.py --reporte docs/reporte_validacion.md
"""
import argparse
import datetime
import random
import sys
from decimal import Decimal

from conexion import mysql, mongo

TOL = 0.005
resultados = []   # (sección, prueba, mysql, mongo, ok)


NA = "n/a"   # prueba que el servidor no puede ejecutar


def registrar(seccion, prueba, a, b, ok=None):
    if ok is None:
        if isinstance(a, (int, float, Decimal)) and isinstance(b, (int, float, Decimal)):
            ok = abs(float(a) - float(b)) <= TOL
        else:
            ok = a == b
    resultados.append((seccion, prueba, a, b, ok))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--reporte", help="archivo .md donde guardar el reporte")
    ap.add_argument("--mongo-uri")
    args = ap.parse_args()

    cn = mysql()
    db = mongo(args.mongo_uri)

    def uno(sql):
        with cn.cursor() as c:
            c.execute(sql)
            r = c.fetchone()
            return list(r.values())[0] if r else None

    def filas(sql):
        with cn.cursor() as c:
            c.execute(sql)
            return c.fetchall()

    def agg(col, pipeline):
        return list(db[col].aggregate(pipeline))

    def suma(col, expr, unwind=None, match=None):
        p = []
        if match: p.append({"$match": match})
        if unwind: p.append({"$unwind": unwind})
        p.append({"$group": {"_id": None, "s": {"$sum": expr}}})
        r = agg(col, p)
        return round(r[0]["s"], 2) if r else 0

    # ------------------------------------------------------------------ 1. conteos
    S = "1. Conteos"
    for tabla, coleccion in [("niveles_membresia", "niveles_membresia"), ("sucursales", "sucursales"), ("clientes", "clientes"),
                             ("proveedores", "proveedores"), ("productos", "productos"), ("ventas", "ventas"),
                             ("intercambios", "intercambios"), ("preventas", "preventas"), ("ordenes_compra", "ordenes_compra"),
                             ("bitacora_precios", "bitacora_precios")]:
        registrar(S, f"{tabla} → {coleccion}", uno(f"SELECT COUNT(*) FROM {tabla}"), db[coleccion].count_documents({}))
    embebidos = [
        ("empleados → sucursales.empleados[]", "empleados", "sucursales", "$empleados"),
        ("inventario → productos.inventario[]", "inventario", "productos", "$inventario"),
        ("producto_genero → productos.generos[]", "producto_genero", "productos", "$generos"),
        ("detalle_venta → ventas.articulos[]", "detalle_venta", "ventas", "$articulos"),
        ("devoluciones → ventas.devoluciones[]", "devoluciones", "ventas", "$devoluciones"),
        ("detalle_intercambio → intercambios.articulos[]", "detalle_intercambio", "intercambios", "$articulos"),
        ("detalle_orden_compra → ordenes_compra.articulos[]", "detalle_orden_compra", "ordenes_compra", "$articulos"),
    ]
    for nombre, tabla, col, campo in embebidos:
        r = agg(col, [{"$unwind": campo}, {"$count": "n"}])
        registrar(S, nombre, uno(f"SELECT COUNT(*) FROM {tabla}"), r[0]["n"] if r else 0)
    r = agg("ventas", [{"$unwind": "$devoluciones"}, {"$unwind": "$devoluciones.articulos"}, {"$count": "n"}])
    registrar(S, "detalle_devolucion → ventas.devoluciones[].articulos[]", uno("SELECT COUNT(*) FROM detalle_devolucion"), r[0]["n"] if r else 0)
    registrar(S, "estados usados por tiendas → sucursales.estado",
              uno("SELECT COUNT(DISTINCT id_estado) FROM sucursales"), len(db.sucursales.distinct("estado.abreviatura")))
    registrar(S, "ventas sin cliente (cliente = null)",
              uno("SELECT COUNT(*) FROM ventas WHERE id_cliente IS NULL"), db.ventas.count_documents({"cliente": None}))

    # ------------------------------------------------------------------ 2. totales
    S = "2. Totales"
    for campo in ["subtotal", "descuento", "impuesto", "total"]:
        registrar(S, f"Suma de ventas.{campo}", float(uno(f"SELECT SUM({campo}) FROM ventas")), suma("ventas", f"${campo}"))
    registrar(S, "Unidades vendidas", int(uno("SELECT SUM(cantidad) FROM detalle_venta")), suma("ventas", "$articulos.cantidad", "$articulos"))
    registrar(S, "Reembolsos", float(uno("SELECT SUM(monto_reembolsado) FROM devoluciones")),
              suma("ventas", "$devoluciones.monto_reembolsado", "$devoluciones"))
    registrar(S, "Pagado en intercambios", float(uno("SELECT SUM(total_pagado) FROM intercambios")), suma("intercambios", "$total_pagado"))
    registrar(S, "Total de órdenes de compra", float(uno("SELECT SUM(total) FROM ordenes_compra")), suma("ordenes_compra", "$total"))
    registrar(S, "Piezas en inventario", int(uno("SELECT SUM(existencia) FROM inventario")), suma("productos", "$inventario.existencia", "$inventario"))
    registrar(S, "Puntos de clientes", int(uno("SELECT SUM(puntos) FROM clientes")), suma("clientes", "$puntos"))
    registrar(S, "Crédito en tienda", float(uno("SELECT SUM(credito_tienda) FROM clientes")), suma("clientes", "$credito_tienda"))
    registrar(S, "Anticipos de preventas", float(uno("SELECT SUM(anticipo) FROM preventas")), suma("preventas", "$anticipo"))

    # por tienda
    my = {r["id_sucursal"]: float(r["t"]) for r in filas("SELECT id_sucursal, SUM(total) t FROM ventas GROUP BY id_sucursal")}
    mg = {r["_id"]: round(r["t"], 2) for r in agg("ventas", [{"$group": {"_id": "$sucursal._id", "t": {"$sum": "$total"}}}])}
    malas = [k for k in my if abs(my[k] - mg.get(k, -1)) > TOL]
    registrar(S, "Total vendido de cada tienda (10 tiendas)", f"{len(my)} tiendas", f"{len(my) - len(malas)} coinciden", not malas)
    # por producto: existencia y unidades
    my = {r["sku"]: int(r["e"]) for r in filas("SELECT p.sku, IFNULL(SUM(i.existencia),0) e FROM productos p LEFT JOIN inventario i USING (id_producto) GROUP BY p.sku")}
    mg = {d["_id"]: sum(i["existencia"] for i in d.get("inventario", [])) for d in db.productos.find({}, {"inventario": 1})}
    malas = [k for k in my if my[k] != mg.get(k)]
    registrar(S, "Existencia de cada producto", f"{len(my)} productos", f"{len(my) - len(malas)} coinciden", not malas)
    my = {r["correo"]: (r["puntos"], float(r["credito_tienda"])) for r in filas("SELECT correo, puntos, credito_tienda FROM clientes")}
    mg = {d["correo"]: (d["puntos"], round(d["credito_tienda"], 2)) for d in db.clientes.find({}, {"correo": 1, "puntos": 1, "credito_tienda": 1})}
    malas = [k for k in my if my[k] != mg.get(k)]
    registrar(S, "Puntos y crédito de cada cliente", f"{len(my)} clientes", f"{len(my) - len(malas)} coinciden", not malas)

    # ------------------------------------------------------------------ 3. integridad referencial
    S = "3. Integridad referencial en MongoDB"
    ids_cli = set(db.clientes.distinct("_id"))
    ids_suc = set(db.sucursales.distinct("_id"))
    ids_emp = set(db.sucursales.distinct("empleados._id"))
    skus = set(db.productos.distinct("_id"))
    ids_prov = set(db.proveedores.distinct("_id"))
    def huerfanos(valores, validos):
        return sorted({v for v in valores if v is not None} - validos, key=str)
    checks = [
        ("ventas.cliente → clientes", db.ventas.distinct("cliente"), ids_cli),
        ("ventas.sucursal → sucursales", db.ventas.distinct("sucursal._id"), ids_suc),
        ("ventas.empleado → empleados", db.ventas.distinct("empleado._id"), ids_emp),
        ("ventas.articulos.sku → productos", db.ventas.distinct("articulos.sku"), skus),
        ("productos.inventario.sucursal → sucursales", db.productos.distinct("inventario.sucursal"), ids_suc),
        ("productos.proveedor → proveedores", db.productos.distinct("proveedor"), ids_prov),
        ("intercambios.cliente → clientes", db.intercambios.distinct("cliente"), ids_cli),
        ("intercambios.articulos.sku → productos", db.intercambios.distinct("articulos.sku"), skus),
        ("preventas.producto → productos", db.preventas.distinct("producto"), skus),
        ("ordenes_compra.proveedor → proveedores", db.ordenes_compra.distinct("proveedor"), ids_prov),
        ("empleados.id_supervisor → empleados", db.sucursales.distinct("empleados.id_supervisor"), ids_emp),
        ("bitacora_precios.producto → productos", db.bitacora_precios.distinct("producto"), skus),
    ]
    for nombre, valores, validos in checks:
        h = huerfanos(valores, validos)
        registrar(S, nombre, "0 huérfanos", f"{len(h)} huérfanos" + (f": {h[:5]}" if h else ""), not h)

    # reglas de negocio que deben seguir cumpliéndose
    registrar(S, "Ninguna existencia negativa", 0, db.productos.count_documents({"inventario.existencia": {"$lt": 0}}))
    registrar(S, "Ningún precio menor al costo", 0,
              len([d for d in db.productos.find({}, {"precio_venta": 1, "costo": 1}) if d["precio_venta"] < d["costo"]]))
    registrar(S, "total = subtotal − descuento + impuesto en cada venta", 0,
              len([v for v in db.ventas.find({}, {"subtotal": 1, "descuento": 1, "impuesto": 1, "total": 1})
                   if abs(v["subtotal"] - v["descuento"] + v["impuesto"] - v["total"]) > TOL]))

    # ------------------------------------------------------------------ 4. estructura
    S = "4. Estructura y validadores ($jsonSchema)"
    try:
        info = {c["name"]: c.get("options", {}) for c in db.list_collections()}
        for col in ["niveles_membresia", "sucursales", "clientes", "proveedores", "productos", "ventas",
                    "intercambios", "preventas", "ordenes_compra"]:
            validador = info.get(col, {}).get("validator")
            if not validador:
                registrar(S, f"{col}: tiene validador", "sí", "no (ejecuta mongodb/01_colecciones.js)", False)
                continue
            violan = db[col].count_documents({"$nor": [validador]})
            registrar(S, f"{col}: documentos que violan su $jsonSchema", 0, violan)
        vistas = [c["name"] for c in db.list_collections() if c.get("type") == "view"]
        registrar(S, "Vistas creadas", 4, len(vistas))
    except Exception as e:
        registrar(S, "Validadores", "disponibles", f"este servidor no permite leerlos ({type(e).__name__})", NA)

    # ------------------------------------------------------------------ 5. muestra
    S = "5. Muestra al azar (25 ventas, campo por campo)"
    ids = [r["id_venta"] for r in filas("SELECT id_venta FROM ventas")]
    random.seed(7)
    errores = []
    for i in random.sample(ids, min(25, len(ids))):
        v = filas(f"SELECT * FROM ventas WHERE id_venta = {i}")[0]
        d = filas(f"SELECT p.sku, d.cantidad, d.precio_unitario, d.descuento FROM detalle_venta d "
                  f"JOIN productos p USING (id_producto) WHERE d.id_venta = {i} ORDER BY p.sku")
        m = db.ventas.find_one({"_id": i})
        esperado = (v["fecha"], v["id_sucursal"], v["id_empleado"], v["id_cliente"], v["metodo_pago"],
                    float(v["total"]), v["estado"],
                    [(a["sku"], a["cantidad"], float(a["precio_unitario"]), float(a["descuento"])) for a in d])
        obtenido = (m["fecha"].replace(tzinfo=None) if isinstance(m["fecha"], datetime.datetime) else m["fecha"],
                    m["sucursal"]["_id"], m["empleado"]["_id"], m["cliente"], m["metodo_pago"], m["total"], m["estado"],
                    sorted((a["sku"], a["cantidad"], a["precio_unitario"], a["descuento"]) for a in m["articulos"]))
        if esperado != obtenido:
            errores.append(i)
    registrar(S, "Ventas idénticas", "25", f"{25 - len(errores)}" + (f" (difieren: {errores})" if errores else ""), not errores)

    # ------------------------------------------------------------------ salida
    total = len(resultados)
    ok = sum(1 for r in resultados if r[4] is True)
    fallas = sum(1 for r in resultados if r[4] is False)
    seccion = None
    for s, prueba, a, b, bien in resultados:
        if s != seccion:
            print(f"\n{s}"); seccion = s
        marca = "OK " if bien is True else ("-- " if bien == NA else "ERR")
        print(f"  [{marca}] {prueba:<58} MySQL: {str(a):<18} MongoDB: {b}")
    print(f"\nResultado: {ok} de {total} pruebas correctas, {fallas} con diferencias.")

    if args.reporte:
        L = ["# Reporte de validación de la migración MySQL → MongoDB", "",
             f"Generado el {datetime.datetime.now():%Y-%m-%d %H:%M} con `python migracion/validar.py --reporte {args.reporte}`.", "",
             f"**Resultado: {ok} de {total} pruebas correctas" + (", sin diferencias.**" if not fallas else f", {fallas} con diferencias.**"), ""]
        seccion = None
        for s, prueba, a, b, bien in resultados:
            if s != seccion:
                L += ["", f"## {s}", "", "| Prueba | MySQL | MongoDB | |", "|---|---|---|:-:|"]
                seccion = s
            L.append(f"| {prueba} | {a} | {b} | {'✅' if bien is True else ('—' if bien == NA else '❌')} |")
        with open(args.reporte, "w", encoding="utf-8") as f:
            f.write("\n".join(L) + "\n")
        print(f"Reporte guardado en {args.reporte}")
    return 1 if fallas else 0


if __name__ == "__main__":
    sys.exit(main())
