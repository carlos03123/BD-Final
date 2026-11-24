"""Acceso a MySQL para la interfaz web."""
import os
from decimal import Decimal

import pymysql
from flask import g


def conectar():
    params = dict(
        host=os.getenv("MYSQL_HOST", "localhost"),
        port=int(os.getenv("MYSQL_PORT", "3306")),
        user=os.getenv("MYSQL_USER", "root"),
        password=os.getenv("MYSQL_PASSWORD", ""),
        database=os.getenv("MYSQL_DB", "gamestop_usa"),
        charset="utf8mb4",
        cursorclass=pymysql.cursors.DictCursor,
        autocommit=True,
    )
    if os.getenv("MYSQL_SOCKET"):
        params["unix_socket"] = os.getenv("MYSQL_SOCKET")
    return pymysql.connect(**params)


def cn():
    if "cn" not in g:
        g.cn = conectar()
    return g.cn


def cerrar(_=None):
    c = g.pop("cn", None)
    if c is not None:
        c.close()


def consulta(sql, params=None):
    with cn().cursor() as c:
        c.execute(sql, params)
        return c.fetchall()


def uno(sql, params=None):
    filas = consulta(sql, params)
    return filas[0] if filas else None


def ejecutar(sql, params=None):
    with cn().cursor() as c:
        c.execute(sql, params)
        return c.lastrowid


def procedimiento(sql, params=None):
    """Ejecuta un CALL y devuelve el primer conjunto de resultados."""
    with cn().cursor() as c:
        c.execute(sql, params)
        filas = c.fetchall()
        while c.nextset():
            pass
        return filas


def mensaje_error(e):
    """Mensaje legible de un error de MySQL (SIGNAL de triggers, CHECK, FK...)."""
    if isinstance(e, pymysql.err.MySQLError) and len(e.args) >= 2:
        return f"{e.args[1]} (MySQL {e.args[0]})"
    return str(e)


def numeros(filas):
    """Decimal -> float para poder mandar los datos a las gráficas."""
    return [{k: float(v) if isinstance(v, Decimal) else v for k, v in f.items()} for f in filas]
