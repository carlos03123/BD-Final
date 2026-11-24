"""
Interfaz web de la base de datos gamestop_usa (Flask + MySQL)

Ejecutar:
    pip install -r requirements.txt
    set MYSQL_PASSWORD=tu_contraseña        (Windows)   |   export MYSQL_PASSWORD=...  (Mac/Linux)
    python app/app.py
    -> abrir http://127.0.0.1:5000
"""
import csv
import io
import json
import os
import sys

from flask import Flask, Response, abort, flash, jsonify, redirect, render_template, request, url_for

import db

app = Flask(__name__)
app.secret_key = os.getenv("SECRET_KEY", "gamestop-bd-final")
app.teardown_appcontext(db.cerrar)

INICIO, FIN = "2026-10-01", "2026-11-30"


@app.template_filter("dinero")
def dinero(v):
    return "" if v is None else f"${float(v):,.2f}"


@app.template_filter("entero")
def entero(v):
    return "" if v is None else f"{int(v):,}"


app.jinja_env.globals["zip"] = zip


def tiendas():
    return db.consulta("SELECT s.id_sucursal, s.numero_tienda, s.nombre, e.abreviatura "
                       "FROM sucursales s JOIN estados e USING (id_estado) ORDER BY s.nombre")


# ---------------------------------------------------------------------------
# Tablero
# ---------------------------------------------------------------------------
@app.route("/")
def tablero():
    kpi = db.uno("""SELECT COUNT(*) tickets, SUM(total) total, AVG(total) promedio, SUM(impuesto) impuesto,
                           (SELECT SUM(cantidad) FROM detalle_venta) unidades
                      FROM ventas""")
    kpi["pro"] = db.uno("SELECT COUNT(*) n FROM clientes WHERE fn_es_pro(id_cliente, CURDATE())")["n"]
    kpi["inventario"] = db.uno("SELECT SUM(valor_venta) v FROM v_inventario_valorizado")["v"]
    kpi["bajo_minimo"] = db.uno("SELECT SUM(productos_bajo_minimo) n FROM v_inventario_valorizado")["n"]

    diarias = db.numeros(db.consulta("SELECT DATE_FORMAT(dia, '%d/%m') dia, total FROM v_ventas_diarias ORDER BY v_ventas_diarias.dia"))
    por_tienda = db.numeros(db.procedimiento("CALL sp_reporte_ventas(%s, %s)", (INICIO, FIN)))
    categorias = db.numeros(db.consulta("""
        SELECT c.nombre categoria, SUM(d.cantidad * d.precio_unitario - d.descuento) ingreso
          FROM detalle_venta d JOIN productos p USING (id_producto) JOIN categorias c USING (id_categoria)
         GROUP BY c.nombre ORDER BY ingreso DESC"""))
    top = db.consulta("SELECT nombre, categoria, unidades_netas, ingreso_neto, utilidad_bruta "
                      "FROM v_ventas_producto ORDER BY unidades_netas DESC, ingreso_neto DESC LIMIT 8")
    ultimas = db.consulta("SELECT * FROM v_tickets ORDER BY fecha DESC LIMIT 6")
    return render_template("tablero.html", kpi=kpi, top=top, ultimas=ultimas,
                           graficas=json.dumps({"diarias": diarias, "tiendas": por_tienda, "categorias": categorias}))


# ---------------------------------------------------------------------------
# Catálogo
# ---------------------------------------------------------------------------
@app.route("/catalogo")
def catalogo():
    f = {k: request.args.get(k, "") for k in ("q", "categoria", "plataforma", "condicion")}
    sql, p = "SELECT * FROM v_catalogo WHERE 1=1", []
    if f["q"]:
        sql += " AND (nombre LIKE %s OR sku LIKE %s)"; p += [f"%{f['q']}%"] * 2
    for campo in ("categoria", "plataforma", "condicion"):
        if f[campo]:
            sql += f" AND {campo} = %s"; p.append(f[campo])
    productos = db.consulta(sql + " ORDER BY categoria, nombre", p)
    opciones = {
        "categoria": [r["nombre"] for r in db.consulta("SELECT nombre FROM categorias ORDER BY nombre")],
        "plataforma": [r["nombre"] for r in db.consulta("SELECT nombre FROM plataformas ORDER BY nombre")],
        "condicion": ["Nuevo", "Usado", "Reacondicionado"],
    }
    return render_template("catalogo.html", productos=productos, f=f, opciones=opciones)


@app.route("/catalogo/<sku>/precio", methods=["POST"])
def cambiar_precio(sku):
    try:
        db.ejecutar("UPDATE productos SET precio_venta = %s WHERE sku = %s", (request.form["precio"], sku))
        flash(f"Precio de {sku} actualizado. El cambio quedó en la bitácora.", "ok")
    except Exception as e:
        flash(f"No se pudo cambiar el precio: {db.mensaje_error(e)}", "error")
    return redirect(request.referrer or url_for("catalogo"))


# ---------------------------------------------------------------------------
# Inventario
# ---------------------------------------------------------------------------
@app.route("/inventario")
def inventario():
    id_tienda = request.args.get("tienda", type=int) or 1
    tienda = db.uno("SELECT s.*, e.abreviatura FROM sucursales s JOIN estados e USING (id_estado) WHERE id_sucursal = %s", (id_tienda,))
    if not tienda:
        abort(404)
    solo_bajo = request.args.get("bajo") == "1"
    filas = db.consulta(f"""
        SELECT p.sku, p.nombre, c.nombre categoria, p.condicion, p.precio_venta, i.existencia, i.stock_minimo,
               i.existencia <= i.stock_minimo AS bajo
          FROM inventario i JOIN productos p USING (id_producto) JOIN categorias c USING (id_categoria)
         WHERE i.id_sucursal = %s AND p.activo {"AND i.existencia <= i.stock_minimo" if solo_bajo else ""}
         ORDER BY bajo DESC, c.nombre, p.nombre""", (id_tienda,))
    ordenes = db.consulta("""
        SELECT oc.id_orden, oc.fecha, pr.nombre proveedor, oc.estado, oc.fecha_recepcion, oc.total,
               COUNT(d.id_producto) productos, SUM(d.cantidad) piezas
          FROM ordenes_compra oc JOIN proveedores pr USING (id_proveedor) JOIN detalle_orden_compra d USING (id_orden)
         WHERE oc.id_sucursal = %s
         GROUP BY oc.id_orden, oc.fecha, pr.nombre, oc.estado, oc.fecha_recepcion, oc.total
         ORDER BY oc.estado = 'Pendiente' DESC, oc.fecha DESC""", (id_tienda,))
    valor = db.uno("SELECT * FROM v_inventario_valorizado WHERE numero_tienda = %s", (tienda["numero_tienda"],))
    return render_template("inventario.html", tienda=tienda, tiendas=tiendas(), filas=filas, ordenes=ordenes,
                           valor=valor, solo_bajo=solo_bajo)


@app.route("/inventario/<int:id_tienda>/reabasto", methods=["POST"])
def reabasto(id_tienda):
    gerente = db.uno("SELECT id_empleado FROM empleados WHERE id_sucursal = %s AND puesto = 'Gerente de tienda' LIMIT 1", (id_tienda,))
    try:
        r = db.procedimiento("CALL sp_generar_reabasto(%s, %s, CURDATE())", (id_tienda, gerente["id_empleado"]))
        flash(f"Se generaron {r[0]['ordenes_creadas']} órdenes de compra.", "ok")
    except Exception as e:
        flash(db.mensaje_error(e), "error")
    return redirect(url_for("inventario", tienda=id_tienda))


@app.route("/ordenes/<int:id_orden>/recibir", methods=["POST"])
def recibir_orden(id_orden):
    try:
        db.procedimiento("CALL sp_recibir_orden(%s, CURDATE())", (id_orden,))
        flash(f"Orden {id_orden} recibida: la mercancía ya está en el inventario.", "ok")
    except Exception as e:
        flash(db.mensaje_error(e), "error")
    return redirect(request.referrer or url_for("inventario"))


@app.route("/inventario/transferir", methods=["POST"])
def transferir():
    f = request.form
    try:
        db.procedimiento("CALL sp_transferir_inventario(%s, %s, %s, %s)",
                         (f["origen"], f["destino"], f["sku"].strip(), f["cantidad"]))
        flash(f"Se transfirieron {f['cantidad']} piezas de {f['sku']}.", "ok")
    except Exception as e:
        flash(f"Transferencia rechazada: {db.mensaje_error(e)}", "error")
    return redirect(url_for("inventario", tienda=f["origen"]))


# ---------------------------------------------------------------------------
# Ventas
# ---------------------------------------------------------------------------
@app.route("/ventas")
def ventas():
    f = {k: request.args.get(k, "") for k in ("tienda", "desde", "hasta", "estado")}
    pagina = request.args.get("pagina", 1, type=int)
    sql, p = "FROM v_tickets WHERE 1=1", []
    if f["tienda"]:
        sql += " AND numero_tienda = %s"; p.append(f["tienda"])
    if f["desde"]:
        sql += " AND fecha >= %s"; p.append(f["desde"])
    if f["hasta"]:
        sql += " AND fecha < DATE_ADD(%s, INTERVAL 1 DAY)"; p.append(f["hasta"])
    if f["estado"]:
        sql += " AND estado = %s"; p.append(f["estado"])
    total = db.uno("SELECT COUNT(*) n, SUM(total) t " + sql, p)
    filas = db.consulta("SELECT * " + sql + " ORDER BY fecha DESC LIMIT 40 OFFSET %s", p + [(pagina - 1) * 40])
    return render_template("ventas.html", filas=filas, f=f, tiendas=tiendas(), total=total, pagina=pagina,
                           paginas=max(1, -(-total["n"] // 40)))


@app.route("/ventas/<int:id_venta>")
def venta(id_venta):
    t = db.uno("SELECT * FROM v_tickets WHERE id_venta = %s", (id_venta,))
    if not t:
        abort(404)
    lineas = db.consulta("""
        SELECT p.sku, p.nombre, p.condicion, d.cantidad, d.precio_unitario, d.descuento,
               d.cantidad * d.precio_unitario - d.descuento importe,
               d.cantidad - IFNULL((SELECT SUM(dd.cantidad) FROM detalle_devolucion dd JOIN devoluciones de USING (id_devolucion)
                                     WHERE de.id_venta = d.id_venta AND dd.id_producto = d.id_producto), 0) devolvible
          FROM detalle_venta d JOIN productos p USING (id_producto) WHERE d.id_venta = %s""", (id_venta,))
    devs = db.consulta("""
        SELECT de.id_devolucion, de.fecha, de.motivo, de.monto_reembolsado, p.nombre, dd.cantidad
          FROM devoluciones de JOIN detalle_devolucion dd USING (id_devolucion) JOIN productos p USING (id_producto)
         WHERE de.id_venta = %s ORDER BY de.fecha""", (id_venta,))
    return render_template("venta.html", t=t, lineas=lineas, devs=devs)


@app.route("/ventas/<int:id_venta>/devolucion", methods=["POST"])
def devolucion(id_venta):
    v = db.uno("SELECT id_sucursal FROM ventas WHERE id_venta = %s", (id_venta,))
    emp = db.uno("SELECT id_empleado FROM empleados WHERE id_sucursal = %s AND puesto = 'Gerente de tienda' LIMIT 1", (v["id_sucursal"],))
    c = db.cn()
    try:
        c.begin()
        with c.cursor() as cur:
            cur.execute("INSERT INTO devoluciones (id_venta, fecha, id_empleado, motivo) VALUES (%s, NOW(), %s, %s)",
                        (id_venta, emp["id_empleado"], request.form["motivo"]))
            id_dev = cur.lastrowid
            cur.execute("INSERT INTO detalle_devolucion (id_devolucion, id_producto, cantidad) "
                        "SELECT %s, id_producto, %s FROM productos WHERE sku = %s",
                        (id_dev, request.form["cantidad"], request.form["sku"]))
            cur.execute("SELECT monto_reembolsado FROM devoluciones WHERE id_devolucion = %s", (id_dev,))
            monto = cur.fetchone()["monto_reembolsado"]
        c.commit()
        flash(f"Devolución registrada. Reembolso: {dinero(monto)}", "ok")
    except Exception as e:
        c.rollback()
        flash(f"Devolución rechazada: {db.mensaje_error(e)}", "error")
    return redirect(url_for("venta", id_venta=id_venta))


@app.route("/ventas/nueva", methods=["GET", "POST"])
def nueva_venta():
    if request.method == "POST":
        f = request.form
        articulos = [{"sku": s.strip(), "cantidad": int(q)}
                     for s, q in zip(f.getlist("sku"), f.getlist("cantidad")) if s.strip() and q]
        cliente = None
        if f.get("cliente"):
            r = db.uno("SELECT id_cliente FROM clientes WHERE correo = %s", (f["cliente"].strip(),))
            if not r:
                flash("No existe un cliente con ese correo.", "error")
                return render_template("nueva_venta.html", **datos_formulario(), form=f)
            cliente = r["id_cliente"]
        if not articulos:
            flash("Agrega al menos un producto.", "error")
            return render_template("nueva_venta.html", **datos_formulario(), form=f)
        try:
            with db.cn().cursor() as cur:
                cur.execute("CALL sp_registrar_venta(%s, %s, %s, %s, %s, @id_venta)",
                            (f["tienda"], f["empleado"], cliente, f["metodo"], json.dumps(articulos)))
                while cur.nextset():
                    pass
                cur.execute("SELECT @id_venta id")
                id_venta = cur.fetchone()["id"]
            flash("Venta registrada correctamente.", "ok")
            return redirect(url_for("venta", id_venta=id_venta))
        except Exception as e:
            flash(f"La base de datos rechazó la venta: {db.mensaje_error(e)}", "error")
            return render_template("nueva_venta.html", **datos_formulario(), form=f)
    return render_template("nueva_venta.html", **datos_formulario(), form={})


def datos_formulario():
    return dict(
        tiendas=tiendas(),
        empleados=db.consulta("SELECT id_empleado, CONCAT(nombre, ' ', apellido) nombre, puesto, id_sucursal "
                              "FROM empleados WHERE activo ORDER BY nombre"),
        productos=db.consulta("SELECT sku, nombre, precio_venta, condicion FROM productos WHERE activo ORDER BY nombre"),
        clientes=db.consulta("SELECT correo, CONCAT(nombre, ' ', apellido) nombre FROM clientes ORDER BY nombre"),
        metodos=["Tarjeta de crédito", "Tarjeta de débito", "Efectivo", "Tarjeta de regalo", "Crédito en tienda"],
    )


@app.route("/api/existencia")
def api_existencia():
    r = db.uno("SELECT i.existencia, p.precio_venta FROM inventario i JOIN productos p USING (id_producto) "
               "WHERE i.id_sucursal = %s AND p.sku = %s", (request.args.get("tienda"), request.args.get("sku")))
    return jsonify({"existencia": r["existencia"] if r else 0, "precio": float(r["precio_venta"]) if r else None})


# ---------------------------------------------------------------------------
# Clientes
# ---------------------------------------------------------------------------
@app.route("/clientes")
def clientes():
    q, nivel = request.args.get("q", ""), request.args.get("nivel", "")
    sql, p = "SELECT * FROM v_clientes_resumen WHERE 1=1", []
    if q:
        sql += " AND (cliente LIKE %s OR correo LIKE %s)"; p += [f"%{q}%"] * 2
    if nivel:
        sql += " AND nivel = %s"; p.append(nivel)
    return render_template("clientes.html", filas=db.consulta(sql + " ORDER BY total_gastado DESC", p), q=q, nivel=nivel)


@app.route("/clientes/<int:id_cliente>")
def cliente(id_cliente):
    c = db.uno("SELECT * FROM v_clientes_resumen WHERE id_cliente = %s", (id_cliente,))
    if not c:
        abort(404)
    compras = db.procedimiento("CALL sp_historial_cliente(%s)", (c["correo"],))
    intercambios = db.consulta("""
        SELECT i.id_intercambio, i.fecha, s.nombre tienda, i.forma_pago, i.total_pagado,
               GROUP_CONCAT(p.nombre SEPARATOR ', ') articulos
          FROM intercambios i JOIN sucursales s USING (id_sucursal)
          JOIN detalle_intercambio d USING (id_intercambio) JOIN productos p USING (id_producto)
         WHERE i.id_cliente = %s GROUP BY i.id_intercambio, i.fecha, s.nombre, i.forma_pago, i.total_pagado
         ORDER BY i.fecha DESC""", (id_cliente,))
    preventas = db.consulta("SELECT pr.fecha, p.nombre, pr.anticipo, pr.estado FROM preventas pr JOIN productos p USING (id_producto) "
                            "WHERE pr.id_cliente = %s ORDER BY pr.fecha DESC", (id_cliente,))
    return render_template("cliente.html", c=c, compras=compras, intercambios=intercambios, preventas=preventas)


@app.route("/clientes/<int:id_cliente>/pro", methods=["POST"])
def renovar_pro(id_cliente):
    try:
        r = db.procedimiento("CALL sp_renovar_pro(%s, CURDATE())", (id_cliente,))
        flash(f"GameStop Pro activo hasta {r[0]['vencimiento_membresia']}.", "ok")
    except Exception as e:
        flash(db.mensaje_error(e), "error")
    return redirect(url_for("cliente", id_cliente=id_cliente))


# ---------------------------------------------------------------------------
# Reportes
# ---------------------------------------------------------------------------
REPORTES = {
    "tiendas": ("Ventas por tienda", None),
    "categorias": ("Ingresos por categoría", """
        SELECT c.nombre categoria, SUM(d.cantidad) unidades, SUM(d.cantidad * d.precio_unitario - d.descuento) ingreso
          FROM ventas v JOIN detalle_venta d USING (id_venta) JOIN productos p USING (id_producto) JOIN categorias c USING (id_categoria)
         WHERE v.fecha >= %(desde)s AND v.fecha < DATE_ADD(%(hasta)s, INTERVAL 1 DAY)
         GROUP BY c.nombre ORDER BY ingreso DESC"""),
    "estados": ("Ventas e impuesto por estado", """
        SELECT e.nombre estado, e.tasa_impuesto tasa, COUNT(*) tickets, SUM(v.subtotal - v.descuento) ventas_netas, SUM(v.impuesto) impuesto
          FROM ventas v JOIN sucursales s USING (id_sucursal) JOIN estados e USING (id_estado)
         WHERE v.fecha >= %(desde)s AND v.fecha < DATE_ADD(%(hasta)s, INTERVAL 1 DAY)
         GROUP BY e.nombre, e.tasa_impuesto ORDER BY ventas_netas DESC"""),
    "vendedores": ("Ranking de vendedores", """
        SELECT RANK() OVER (ORDER BY SUM(v.total) DESC) lugar, CONCAT(e.nombre, ' ', e.apellido) vendedor, e.puesto,
               s.nombre tienda, COUNT(*) tickets, SUM(v.total) total_vendido, ROUND(AVG(v.total), 2) ticket_promedio
          FROM ventas v JOIN empleados e USING (id_empleado) JOIN sucursales s ON s.id_sucursal = e.id_sucursal
         WHERE v.fecha >= %(desde)s AND v.fecha < DATE_ADD(%(hasta)s, INTERVAL 1 DAY)
         GROUP BY e.id_empleado, vendedor, e.puesto, s.nombre ORDER BY total_vendido DESC"""),
    "productos": ("Productos más vendidos y utilidad", """
        SELECT sku, nombre, categoria, condicion, unidades_netas, ingreso_neto, utilidad_bruta
          FROM v_ventas_producto ORDER BY utilidad_bruta DESC"""),
    "inventario": ("Valor del inventario por tienda", "SELECT * FROM v_inventario_valorizado ORDER BY valor_venta DESC"),
    "devoluciones": ("Devoluciones", """
        SELECT de.id_devolucion, de.fecha, s.nombre tienda, de.id_venta, de.motivo, de.monto_reembolsado
          FROM devoluciones de JOIN ventas v USING (id_venta) JOIN sucursales s ON s.id_sucursal = v.id_sucursal
         WHERE de.fecha >= %(desde)s AND de.fecha < DATE_ADD(%(hasta)s, INTERVAL 1 DAY) ORDER BY de.fecha"""),
    "bitacora": ("Bitácora de cambios de precio", """
        SELECT b.fecha, p.sku, p.nombre, b.precio_anterior, b.precio_nuevo,
               ROUND((b.precio_nuevo - b.precio_anterior) / b.precio_anterior * 100, 1) cambio_pct, b.usuario
          FROM bitacora_precios b JOIN productos p USING (id_producto) ORDER BY b.fecha DESC"""),
}


def correr_reporte(nombre, desde, hasta):
    titulo, sql = REPORTES[nombre]
    if nombre == "tiendas":
        return titulo, db.procedimiento("CALL sp_reporte_ventas(%s, %s)", (desde, hasta))
    return titulo, db.consulta(sql, {"desde": desde, "hasta": hasta})


@app.route("/reportes")
def reportes():
    nombre = request.args.get("r", "tiendas")
    if nombre not in REPORTES:
        abort(404)
    desde, hasta = request.args.get("desde", INICIO), request.args.get("hasta", FIN)
    titulo, filas = correr_reporte(nombre, desde, hasta)
    return render_template("reportes.html", reportes=REPORTES, nombre=nombre, titulo=titulo, filas=filas,
                           desde=desde, hasta=hasta, grafica=json.dumps(db.numeros(filas), default=str))


@app.route("/reportes/<nombre>.csv")
def reporte_csv(nombre):
    if nombre not in REPORTES:
        abort(404)
    _, filas = correr_reporte(nombre, request.args.get("desde", INICIO), request.args.get("hasta", FIN))
    buf = io.StringIO()
    if filas:
        w = csv.DictWriter(buf, fieldnames=list(filas[0].keys()))
        w.writeheader()
        w.writerows(filas)
    return Response("﻿" + buf.getvalue(), mimetype="text/csv",
                    headers={"Content-Disposition": f"attachment; filename=reporte_{nombre}.csv"})


# ---------------------------------------------------------------------------
# MySQL vs MongoDB
# ---------------------------------------------------------------------------
@app.route("/mongodb")
def mongodb():
    comparacion, error, ejemplo = [], None, None
    try:
        from pymongo import MongoClient
        m = MongoClient(os.getenv("MONGO_URI", "mongodb://localhost:27017"), serverSelectionTimeoutMS=2000)[os.getenv("MONGO_DB", "gamestop_usa")]
        m.command("ping")

        def mg_suma(col, campo, unwind=None):
            p = ([{"$unwind": unwind}] if unwind else []) + [{"$group": {"_id": None, "s": {"$sum": campo}}}]
            r = list(m[col].aggregate(p))
            return round(r[0]["s"], 2) if r else 0

        def mg_cuenta(col, unwind):
            r = list(m[col].aggregate([{"$unwind": unwind}, {"$count": "n"}]))
            return r[0]["n"] if r else 0

        pruebas = [
            ("Tiendas", "SELECT COUNT(*) v FROM sucursales", lambda: m.sucursales.count_documents({})),
            ("Empleados (embebidos en sucursales)", "SELECT COUNT(*) v FROM empleados", lambda: mg_cuenta("sucursales", "$empleados")),
            ("Clientes", "SELECT COUNT(*) v FROM clientes", lambda: m.clientes.count_documents({})),
            ("Productos", "SELECT COUNT(*) v FROM productos", lambda: m.productos.count_documents({})),
            ("Ventas", "SELECT COUNT(*) v FROM ventas", lambda: m.ventas.count_documents({})),
            ("Renglones de venta (embebidos)", "SELECT COUNT(*) v FROM detalle_venta", lambda: mg_cuenta("ventas", "$articulos")),
            ("Total vendido", "SELECT SUM(total) v FROM ventas", lambda: mg_suma("ventas", "$total")),
            ("Impuesto cobrado", "SELECT SUM(impuesto) v FROM ventas", lambda: mg_suma("ventas", "$impuesto")),
            ("Piezas en inventario", "SELECT SUM(existencia) v FROM inventario", lambda: mg_suma("productos", "$inventario.existencia", "$inventario")),
            ("Crédito en tienda de clientes", "SELECT SUM(credito_tienda) v FROM clientes", lambda: mg_suma("clientes", "$credito_tienda")),
        ]
        for nombre, sql, fn in pruebas:
            a, b = db.uno(sql)["v"], fn()
            comparacion.append({"nombre": nombre, "mysql": a, "mongo": b, "ok": abs(float(a or 0) - float(b or 0)) < 0.01})
        ejemplo = m.ventas.find_one({"devoluciones": {"$exists": True}})
        if ejemplo:
            ejemplo = json.dumps(ejemplo, default=str, ensure_ascii=False, indent=2)
    except Exception as e:
        error = f"{type(e).__name__}: {e}"
    return render_template("mongodb.html", comparacion=comparacion, error=error, ejemplo=ejemplo)


@app.errorhandler(404)
def no_encontrado(_):
    return render_template("base.html", contenido_error="Página no encontrada"), 404


if __name__ == "__main__":
    try:
        db.conectar().close()
    except Exception as e:
        sys.exit(f"No se pudo conectar a MySQL: {db.mensaje_error(e)}\n"
                 "Revisa MYSQL_USER / MYSQL_PASSWORD y que ya ejecutaste los scripts de mysql/.")
    app.run(debug=True, port=int(os.getenv("PORT", "5000")))
