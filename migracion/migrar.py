"""
Migración MySQL (gamestop_usa) -> MongoDB (gamestop_usa)

Transforma las 22 tablas relacionales en 10 colecciones de documentos:

    estados + sucursales + empleados          -> sucursales   (empleados embebidos)
    clientes + niveles_membresia              -> clientes     (membresía embebida)
    productos + categorias + plataformas
      + producto_genero + inventario          -> productos    (inventario y géneros embebidos)
    ventas + detalle_venta + devoluciones
      + detalle_devolucion                    -> ventas       (artículos y devoluciones embebidos)
    intercambios + detalle_intercambio        -> intercambios
    ordenes_compra + detalle_orden_compra     -> ordenes_compra
    preventas, proveedores, niveles_membresia, bitacora_precios -> 1 a 1

Uso:
    # 1) crear colecciones con validación:  mongosh mongodb/01_colecciones.js
    # 2) migrar directo a MongoDB:
    python migracion/migrar.py
    # o generar el script de mongosh (así se creó mongodb/02_datos.js):
    python migracion/migrar.py --js mongodb/02_datos.js

Las colecciones se vacían antes de insertar, así se puede ejecutar varias veces.
Como 01_colecciones.js define validadores $jsonSchema, MongoDB rechaza
cualquier documento migrado que no cumpla la estructura.
"""
import argparse
import datetime
import decimal
import json
import sys
import time

from conexion import mysql, mongo

ORDEN_COLECCIONES = ["niveles_membresia", "sucursales", "clientes", "proveedores", "productos",
                     "ventas", "intercambios", "preventas", "ordenes_compra", "bitacora_precios"]


# ---------------------------------------------------------------------------
# Conversión de tipos MySQL -> BSON
# ---------------------------------------------------------------------------
def valor(v):
    """DECIMAL -> double (o int si es entero sin decimales), DATE -> datetime."""
    if isinstance(v, decimal.Decimal):
        return int(v) if v == v.to_integral_value() and v.as_tuple().exponent >= 0 else float(v)
    if isinstance(v, datetime.datetime):
        return v
    if isinstance(v, datetime.date):
        return datetime.datetime(v.year, v.month, v.day)
    return v


def limpiar(doc, conservar_nulos=()):
    """Convierte tipos y quita campos NULL (en MongoDB simplemente no existen)."""
    if isinstance(doc, dict):
        return {k: limpiar(v, conservar_nulos) for k, v in doc.items() if v is not None or k in conservar_nulos}
    if isinstance(doc, list):
        return [limpiar(x, conservar_nulos) for x in doc]
    return valor(doc)


# ---------------------------------------------------------------------------
# Transformación
# ---------------------------------------------------------------------------
def construir_documentos(cn):
    def filas(sql):
        with cn.cursor() as c:
            c.execute(sql)
            return c.fetchall()

    def agrupar(rows, llave):
        g = {}
        for r in rows:
            g.setdefault(r[llave], []).append(r)
        return g

    docs = {}

    # niveles de membresía
    niveles = filas("SELECT * FROM niveles_membresia ORDER BY id_nivel")
    nombre_nivel = {n["id_nivel"]: n["nombre"] for n in niveles}
    docs["niveles_membresia"] = [dict(_id=n["id_nivel"], nombre=n["nombre"], costo_anual=n["costo_anual"],
                                      descuento_usados_pct=n["descuento_usados_pct"],
                                      bono_intercambio_pct=n["bono_intercambio_pct"],
                                      puntos_por_dolar=n["puntos_por_dolar"]) for n in niveles]

    # sucursales con estado y empleados
    estados = {e["id_estado"]: e for e in filas("SELECT * FROM estados")}
    emp_por_tienda = agrupar(filas("SELECT * FROM empleados ORDER BY id_empleado"), "id_sucursal")
    docs["sucursales"] = []
    for s in filas("SELECT * FROM sucursales ORDER BY id_sucursal"):
        e = estados[s["id_estado"]]
        docs["sucursales"].append(dict(
            _id=s["id_sucursal"], numero_tienda=s["numero_tienda"], nombre=s["nombre"], direccion=s["direccion"],
            ciudad=s["ciudad"], estado=dict(abreviatura=e["abreviatura"], nombre=e["nombre"], tasa_impuesto=e["tasa_impuesto"]),
            codigo_postal=s["codigo_postal"], telefono=s["telefono"], fecha_apertura=s["fecha_apertura"], activa=bool(s["activa"]),
            empleados=[dict(_id=x["id_empleado"], nombre=x["nombre"], apellido=x["apellido"], correo=x["correo"],
                            telefono=x["telefono"], puesto=x["puesto"], salario_hora=x["salario_hora"],
                            fecha_contratacion=x["fecha_contratacion"], id_supervisor=x["id_supervisor"], activo=bool(x["activo"]))
                       for x in emp_por_tienda.get(s["id_sucursal"], [])]))
    tienda = {s["_id"]: s for s in docs["sucursales"]}
    nombre_emp = {x["_id"]: f'{x["nombre"]} {x["apellido"]}' for s in docs["sucursales"] for x in s["empleados"]}

    # clientes
    docs["clientes"] = []
    for c in filas("SELECT * FROM clientes ORDER BY id_cliente"):
        membresia = dict(nivel=nombre_nivel[c["id_nivel"]])
        if c["vencimiento_membresia"]:
            membresia["vencimiento"] = c["vencimiento_membresia"]
        docs["clientes"].append(dict(
            _id=c["id_cliente"], nombre=c["nombre"], apellido=c["apellido"], correo=c["correo"], telefono=c["telefono"],
            fecha_nacimiento=c["fecha_nacimiento"], estado=estados[c["id_estado"]]["abreviatura"], membresia=membresia,
            puntos=c["puntos"], credito_tienda=c["credito_tienda"], fecha_registro=c["fecha_registro"]))

    # proveedores
    docs["proveedores"] = [dict(_id=p["id_proveedor"], nombre=p["nombre"], contacto=p["contacto"], telefono=p["telefono"],
                                correo=p["correo"], ciudad=p["ciudad"],
                                estado=estados[p["id_estado"]]["abreviatura"] if p["id_estado"] else None)
                           for p in filas("SELECT * FROM proveedores ORDER BY id_proveedor")]

    # productos con géneros e inventario
    categorias = {c["id_categoria"]: c["nombre"] for c in filas("SELECT * FROM categorias")}
    plataformas = {p["id_plataforma"]: p for p in filas("SELECT * FROM plataformas")}
    generos = agrupar(filas("SELECT pg.id_producto, g.nombre FROM producto_genero pg "
                            "JOIN generos g USING (id_genero) ORDER BY g.nombre"), "id_producto")
    inventario = agrupar(filas("SELECT * FROM inventario ORDER BY id_sucursal"), "id_producto")
    productos = filas("SELECT * FROM productos ORDER BY id_producto")
    prod = {p["id_producto"]: p for p in productos}
    docs["productos"] = []
    for p in productos:
        d = dict(_id=p["sku"], nombre=p["nombre"], categoria=categorias[p["id_categoria"]])
        if p["id_plataforma"]:
            pl = plataformas[p["id_plataforma"]]
            d["plataforma"] = dict(nombre=pl["nombre"], fabricante=pl["fabricante"])
        d.update(proveedor=p["id_proveedor"], condicion=p["condicion"], clasificacion_esrb=p["clasificacion_esrb"],
                 precio_venta=p["precio_venta"], costo=p["costo"], fecha_lanzamiento=p["fecha_lanzamiento"],
                 activo=bool(p["activo"]))
        if p["id_producto"] in generos:
            d["generos"] = [g["nombre"] for g in generos[p["id_producto"]]]
        d["inventario"] = [dict(sucursal=i["id_sucursal"], existencia=i["existencia"], stock_minimo=i["stock_minimo"])
                           for i in inventario.get(p["id_producto"], [])]
        docs["productos"].append(d)

    # ventas con artículos y devoluciones
    detalle = agrupar(filas("SELECT * FROM detalle_venta ORDER BY id_venta, id_producto"), "id_venta")
    det_dev = agrupar(filas("SELECT * FROM detalle_devolucion ORDER BY id_devolucion, id_producto"), "id_devolucion")
    devoluciones = agrupar(filas("SELECT * FROM devoluciones ORDER BY id_devolucion"), "id_venta")
    docs["ventas"] = []
    for v in filas("SELECT * FROM ventas ORDER BY id_venta"):
        t = tienda[v["id_sucursal"]]
        d = dict(_id=v["id_venta"], fecha=v["fecha"],
                 sucursal=dict(_id=t["_id"], nombre=t["nombre"], estado=t["estado"]["abreviatura"]),
                 empleado=dict(_id=v["id_empleado"], nombre=nombre_emp[v["id_empleado"]]),
                 cliente=v["id_cliente"], metodo_pago=v["metodo_pago"],
                 articulos=[dict(sku=prod[a["id_producto"]]["sku"], nombre=prod[a["id_producto"]]["nombre"],
                                 categoria=categorias[prod[a["id_producto"]]["id_categoria"]],
                                 condicion=prod[a["id_producto"]]["condicion"], cantidad=a["cantidad"],
                                 precio_unitario=a["precio_unitario"], descuento=a["descuento"])
                            for a in detalle[v["id_venta"]]],
                 subtotal=v["subtotal"], descuento=v["descuento"], impuesto=v["impuesto"], total=v["total"], estado=v["estado"])
        if v["id_venta"] in devoluciones:
            d["devoluciones"] = [dict(_id=x["id_devolucion"], fecha=x["fecha"], empleado=x["id_empleado"], motivo=x["motivo"],
                                      monto_reembolsado=x["monto_reembolsado"],
                                      articulos=[dict(sku=prod[a["id_producto"]]["sku"], cantidad=a["cantidad"])
                                                 for a in det_dev.get(x["id_devolucion"], [])])
                                 for x in devoluciones[v["id_venta"]]]
        docs["ventas"].append(d)

    # intercambios
    det_int = agrupar(filas("SELECT * FROM detalle_intercambio ORDER BY id_intercambio, id_producto"), "id_intercambio")
    docs["intercambios"] = [dict(_id=i["id_intercambio"], fecha=i["fecha"], sucursal=i["id_sucursal"], empleado=i["id_empleado"],
                                 cliente=i["id_cliente"], forma_pago=i["forma_pago"],
                                 articulos=[dict(sku=prod[a["id_producto"]]["sku"], nombre=prod[a["id_producto"]]["nombre"],
                                                 cantidad=a["cantidad"], valor_unitario=a["valor_unitario"])
                                            for a in det_int[i["id_intercambio"]]],
                                 total_pagado=i["total_pagado"])
                            for i in filas("SELECT * FROM intercambios ORDER BY id_intercambio")]

    # preventas
    docs["preventas"] = [dict(_id=p["id_preventa"], fecha=p["fecha"], cliente=p["id_cliente"], producto=prod[p["id_producto"]]["sku"],
                              sucursal=p["id_sucursal"], anticipo=p["anticipo"], estado=p["estado"])
                         for p in filas("SELECT * FROM preventas ORDER BY id_preventa")]

    # órdenes de compra
    det_oc = agrupar(filas("SELECT * FROM detalle_orden_compra ORDER BY id_orden, id_producto"), "id_orden")
    docs["ordenes_compra"] = [dict(_id=o["id_orden"], fecha=o["fecha"], proveedor=o["id_proveedor"], sucursal=o["id_sucursal"],
                                   empleado=o["id_empleado"], estado=o["estado"], fecha_recepcion=o["fecha_recepcion"],
                                   articulos=[dict(sku=prod[a["id_producto"]]["sku"], cantidad=a["cantidad"],
                                                   costo_unitario=a["costo_unitario"]) for a in det_oc[o["id_orden"]]],
                                   total=o["total"])
                              for o in filas("SELECT * FROM ordenes_compra ORDER BY id_orden")]

    # bitácora
    docs["bitacora_precios"] = [dict(_id=b["id_bitacora"], producto=prod[b["id_producto"]]["sku"],
                                     precio_anterior=b["precio_anterior"], precio_nuevo=b["precio_nuevo"],
                                     fecha=b["fecha"], usuario=b["usuario"])
                                for b in filas("SELECT * FROM bitacora_precios ORDER BY id_bitacora")]

    # cliente = null se conserva en ventas (cliente no registrado)
    return {k: [limpiar(d, conservar_nulos=("cliente",) if k == "ventas" else ()) for d in v] for k, v in docs.items()}


# ---------------------------------------------------------------------------
# Salida 1: directo a MongoDB
# ---------------------------------------------------------------------------
def cargar_en_mongo(docs, uri=None):
    db = mongo(uri)
    for col in ORDEN_COLECCIONES:
        inicio = time.time()
        db[col].delete_many({})
        if docs[col]:
            db[col].insert_many(docs[col], ordered=True)
        print(f"  {col:<18} {len(docs[col]):>5} documentos  ({time.time() - inicio:.2f} s)")


# ---------------------------------------------------------------------------
# Salida 2: script para mongosh
# ---------------------------------------------------------------------------
def a_js(o):
    if isinstance(o, datetime.datetime):
        if o.time() == datetime.time(0):
            return f'D("{o.date().isoformat()}")'
        return f'D("{o.strftime("%Y-%m-%dT%H:%M:%S")}")'
    if isinstance(o, dict):
        return "{ " + ", ".join(f"{k}: {a_js(v)}" for k, v in o.items()) + " }"
    if isinstance(o, list):
        return "[" + ", ".join(a_js(x) for x in o) + "]"
    if isinstance(o, bool):
        return "true" if o else "false"
    if o is None:
        return "null"
    return json.dumps(o, ensure_ascii=False)


COMENTARIOS = {
    "niveles_membresia": "Niveles del programa de lealtad",
    "sucursales": "Tiendas, con su estado (y tasa de impuesto) y sus empleados embebidos",
    "clientes": "Clientes con su membresía embebida",
    "proveedores": "Proveedores",
    "productos": "Catálogo (el _id es el SKU), con géneros e inventario por tienda embebidos",
    "ventas": "Ventas: artículos y devoluciones embebidos; cliente = null si no está registrado",
    "intercambios": "Intercambios (trade-ins) con artículos embebidos",
    "preventas": "Preventas",
    "ordenes_compra": "Órdenes de compra con artículos embebidos",
    "bitacora_precios": "Bitácora de cambios de precio",
}


def escribir_js(docs, ruta):
    L = ["// =====================================================================",
         "//  BASE DE DATOS: gamestop_usa (MongoDB)",
         "//  Archivo 2 de 4: datos",
         "//  Ejecutar después de 01_colecciones.js:   mongosh mongodb/02_datos.js",
         "//",
         "//  GENERADO con:  python migracion/migrar.py --js mongodb/02_datos.js",
         "//  Son exactamente los mismos datos que la versión MySQL (estado después",
         "//  de cargar los archivos 01 a 05), ya calculados: importes, impuestos,",
         "//  puntos, crédito en tienda e inventario.",
         "//  Personas, direcciones, teléfonos y correos son FICTICIOS.",
         "// =====================================================================",
         "",
         'db = db.getSiblingDB("gamestop_usa");',
         "// Las fechas se guardan en UTC",
         'const D = (s) => new Date(s.length === 10 ? s + "T00:00:00Z" : s + "Z");',
         ""]
    for col in ORDEN_COLECCIONES:
        L += [f"// {COMENTARIOS[col]}", f"db.{col}.deleteMany({{}});", f"db.{col}.insertMany(["]
        n = len(docs[col])
        L += ["  " + a_js(d) + ("," if i < n - 1 else "") for i, d in enumerate(docs[col])]
        L += ["]);", ""]
    L += ['print("Datos cargados:");',
          "[" + ", ".join(f'"{c}"' for c in ORDEN_COLECCIONES) + "]",
          '  .forEach(c => print("  " + c.padEnd(18) + db[c].countDocuments()));']
    with open(ruta, "w", encoding="utf-8") as f:
        f.write("\n".join(L) + "\n")
    print(f"Script generado: {ruta}")


def main():
    ap = argparse.ArgumentParser(description="Migra gamestop_usa de MySQL a MongoDB")
    ap.add_argument("--js", metavar="ARCHIVO", help="en lugar de conectarse a MongoDB, genera un script de mongosh")
    ap.add_argument("--mongo-uri", help="URI de MongoDB (por defecto MONGO_URI o mongodb://localhost:27017)")
    args = ap.parse_args()

    print("Leyendo MySQL...")
    cn = mysql()
    docs = construir_documentos(cn)
    cn.close()
    print(f"  {sum(len(v) for v in docs.values())} documentos construidos a partir de 22 tablas")

    if args.js:
        escribir_js(docs, args.js)
    else:
        print("Cargando en MongoDB...")
        cargar_en_mongo(docs, args.mongo_uri)
        print("Migración terminada. Ejecuta  python migracion/validar.py  para comprobarla.")


if __name__ == "__main__":
    sys.exit(main())
