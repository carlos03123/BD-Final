# Normalización y decisiones de diseño

Este documento explica cómo el modelo relacional de `gamestop_usa` cumple las formas normales, qué datos se guardan "repetidos" a propósito y por qué. Al final compara este diseño con el de la versión en MongoDB.

## 1. Punto de partida: la tabla sin normalizar

Si todo se guardara en una sola tabla de "tickets", un renglón se vería así:

| ticket | fecha | tienda | estado | tasa | vendedor | cliente | nivel cliente | productos | plataformas | géneros | total |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 250 | 2026-11-19 | Northgate, Seattle | WA | 6.5 % | Michael Johnson | Ana Ruiz | GameStop Pro | Switch OLED, GTA VI, GTA VI (Xbox) | Switch, PS5, Xbox | Acción, Mundo abierto | 575.07 |

Esta tabla tiene problemas:

- **Grupos repetidos.** Un ticket tiene varios productos, y un juego tiene varios géneros, todo metido en una sola celda.
- **Anomalía de actualización.** Si cambia la tasa de impuesto de Washington, hay que corregir miles de renglones.
- **Anomalía de inserción.** No se puede dar de alta un producto que todavía no se ha vendido.
- **Anomalía de borrado.** Si se borra el único ticket de un cliente, se pierden sus datos.

## 2. Primera forma normal (1FN)

> Cada celda tiene un solo valor atómico y no hay grupos repetidos.

- Los productos de un ticket pasan a **`detalle_venta`** (un renglón por producto).
- Los géneros de un juego pasan a **`producto_genero`** (relación N:M con `generos`).
- La existencia por tienda pasa a **`inventario`**, en lugar de columnas como `stock_tienda1`, `stock_tienda2`...
- Lo mismo se hace con `detalle_devolucion`, `detalle_intercambio` y `detalle_orden_compra`.
- Nombre y apellido se guardan en columnas separadas.

## 3. Segunda forma normal (2FN)

> Estar en 1FN y que ningún atributo dependa solo de una parte de una llave primaria compuesta.

Estas son las tablas con llave compuesta:

| Tabla | Llave primaria | Atributos | ¿Dependen de toda la llave? |
|---|---|---|---|
| `detalle_venta` | (id_venta, id_producto) | cantidad, precio_unitario, descuento | Sí. Son de *ese producto en esa venta* |
| `inventario` | (id_sucursal, id_producto) | existencia, stock_minimo | Sí. Son de *ese producto en esa tienda* |
| `producto_genero` | (id_producto, id_genero) | — | — |
| `detalle_devolucion` | (id_devolucion, id_producto) | cantidad | Sí |
| `detalle_intercambio` | (id_intercambio, id_producto) | cantidad, valor_unitario | Sí |
| `detalle_orden_compra` | (id_orden, id_producto) | cantidad, costo_unitario | Sí |

El nombre del producto **no** está en `detalle_venta`, porque depende solo de `id_producto` y violaría la 2FN. Está en `productos`.

## 4. Tercera forma normal (3FN)

> Estar en 2FN y que no haya dependencias transitivas (un atributo no llave que dependa de otro atributo no llave).

Para eliminar las dependencias transitivas:

| Dependencia transitiva | Solución |
|---|---|
| tienda → estado → **tasa de impuesto** | La tasa vive en `estados`; `sucursales` solo guarda `id_estado` |
| cliente → nivel → **descuento, puntos por dólar, bono** | Las reglas viven en `niveles_membresia`; `clientes` guarda `id_nivel` |
| producto → categoría → **descripción de la categoría** | Tabla `categorias` |
| producto → plataforma → **fabricante, generación** | Tabla `plataformas` |
| producto → proveedor → **contacto, teléfono** | Tabla `proveedores` |
| empleado → jefe → **datos del jefe** | Relación recursiva `empleados.id_supervisor` |

Así, si Texas cambia su impuesto, solo se actualiza **un renglón** de `estados`. Si GameStop Pro cambia su descuento, solo se actualiza **un renglón** de `niveles_membresia`.

## 5. Datos que parecen redundantes pero son intencionales

| Dato | Por qué se guarda |
|---|---|
| `detalle_venta.precio_unitario` | **No es redundante.** Es el precio *histórico* al momento de vender. El precio del catálogo cambia (ver `bitacora_precios`) y el ticket no debe cambiar con él. |
| `ventas.subtotal`, `descuento`, `impuesto`, `total` | Son derivados de `detalle_venta` y se guardan por **rendimiento y auditoría**: los reportes no recalculan miles de renglones, y el total cobrado queda fijo aunque cambie una tasa. La consistencia la garantiza el trigger `trg_detalle_venta_ai`; nadie los escribe a mano. |
| `clientes.puntos`, `clientes.credito_tienda` | Son saldos acumulados que mantienen los triggers. Recalcularlos desde todo el historial en cada consulta sería costoso. |
| `devoluciones.monto_reembolsado`, `intercambios.total_pagado`, `ordenes_compra.total` | Mismo caso: son totales mantenidos por trigger. |

Esta es una **desnormalización controlada**: el dato derivado se guarda, pero solo lo modifica la propia base de datos (triggers), nunca la aplicación.

**Tablas de auditoría (`aud_<tabla>`).** No se normalizan a propósito. Cada registro guarda una *foto* completa del renglón antes y después del cambio en columnas `JSON`. Así, si mañana se agrega una columna a `clientes`, la auditoría la registra sin cambiar su estructura, y el historial no depende de que los registros relacionados sigan existiendo. Por ejemplo, un cliente borrado sigue apareciendo en `aud_clientes` con todos sus datos.

## 6. Integridad

| Tipo | Cómo se implementa |
|---|---|
| Entidad | Llave primaria en las 22 tablas |
| Referencial | 36 llaves foráneas. El historial está protegido: no se puede borrar una tienda con ventas |
| Dominio | `ENUM` (puestos, métodos de pago, condición, ESRB), 16 restricciones `CHECK` (existencia ≥ 0, salario ≥ $7.25, precio ≥ costo, cantidades > 0, tasa de impuesto entre 0 y 20 %) |
| Unicidad | `UNIQUE` en correos, SKU, número de tienda, abreviatura de estado |
| Reglas de negocio | 9 triggers: existencia, crédito, plazo de devolución, solo usados en intercambio, precio ≥ costo, bitácora |

## 7. Diseño en MongoDB: cuándo embeber y cuándo referenciar

En MongoDB la pregunta no es "¿está normalizado?", sino **"¿cómo se va a leer?"**. La regla es embeber lo que se lee junto y referenciar lo que se comparte o crece sin límite.

| Relación | Decisión | Razón |
|---|---|---|
| Venta → artículos | **Embebido** | Un ticket siempre se lee completo y sus artículos no existen fuera de él. Es como `detalle_venta`, pero sin JOIN |
| Venta → devoluciones | **Embebido** | Pertenecen a la venta y son pocas |
| Venta → nombre y categoría del producto | **Copia** al vender | Funciona como el precio histórico: el ticket no cambia si se renombra el producto. Además permite agrupar por categoría sin `$lookup` |
| Producto → inventario por tienda | **Embebido** | Hay como máximo 10 tiendas (arreglo acotado) y se consulta "¿dónde hay?" desde el producto |
| Producto → géneros | **Embebido** (arreglo de texto) | Reemplaza la tabla N:M `producto_genero`; se consulta con `$all` / `$in` |
| Tienda → empleados | **Embebido** | Pocos por tienda y siempre se ven con su tienda |
| Tienda → estado e impuesto | **Embebido** | Es dato de solo lectura y evita un `$lookup` por venta |
| Venta → cliente | **Referencia** (`cliente: _id`) | El cliente se comparte entre muchas ventas y sus puntos cambian; copiarlo los dejaría desactualizados |
| Producto → proveedor | **Referencia** | Se comparte entre muchos productos |

Las reglas que en MySQL cumplen los triggers, en MongoDB las cumplen:

- `$jsonSchema`: tipos, `enum`, mínimos, campos obligatorios.
- `$expr` en el validador: precio ≥ costo.
- Índices únicos: correo, número de tienda.
- Las funciones de `mongodb/03_operaciones.js`: existencia, crédito, plazo, cálculos. Corren en transacción cuando el servidor es un replica set.
