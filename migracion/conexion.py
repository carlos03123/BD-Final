"""Conexiones compartidas por los scripts de migración y validación.

Los datos de conexión se toman de variables de entorno (o de los valores
por defecto), así no se escriben contraseñas en el código:

    MYSQL_HOST=localhost  MYSQL_PORT=3306  MYSQL_USER=root
    MYSQL_PASSWORD=...    MYSQL_DB=gamestop_usa
    MONGO_URI=mongodb://localhost:27017   MONGO_DB=gamestop_usa
"""
import os
import pymysql


def mysql():
    params = dict(
        host=os.getenv("MYSQL_HOST", "localhost"),
        port=int(os.getenv("MYSQL_PORT", "3306")),
        user=os.getenv("MYSQL_USER", "root"),
        password=os.getenv("MYSQL_PASSWORD", ""),
        database=os.getenv("MYSQL_DB", "gamestop_usa"),
        charset="utf8mb4",
        cursorclass=pymysql.cursors.DictCursor,
    )
    if os.getenv("MYSQL_SOCKET"):
        params["unix_socket"] = os.getenv("MYSQL_SOCKET")
    return pymysql.connect(**params)


def mongo(uri=None):
    """Devuelve la base de MongoDB. 'mongomock://' permite probar sin servidor."""
    uri = uri or os.getenv("MONGO_URI", "mongodb://localhost:27017")
    nombre = os.getenv("MONGO_DB", "gamestop_usa")
    if uri.startswith("mongomock://"):
        global _mock
        import mongomock
        if "_mock" not in globals():
            _mock = mongomock.MongoClient()   # en memoria, compartido dentro del mismo proceso
        return _mock[nombre]
    from pymongo import MongoClient
    return MongoClient(uri, serverSelectionTimeoutMS=5000)[nombre]
