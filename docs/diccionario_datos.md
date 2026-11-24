# Diccionario de datos — `gamestop_usa` (MySQL)

Base de datos de la cadena GameStop en Estados Unidos. **22 tablas**, juego de caracteres `utf8mb4`, motor InnoDB.

Abreviaturas: **PK** llave primaria · **FK** llave foránea · **UQ** valor único · **AI** autoincremental

## Índice

1. [estados](#estados)
2. [sucursales](#sucursales)
3. [empleados](#empleados)
4. [niveles_membresia](#niveles_membresia)
5. [clientes](#clientes)
6. [categorias](#categorias)
7. [plataformas](#plataformas)
8. [generos](#generos)
9. [proveedores](#proveedores)
10. [productos](#productos)
11. [producto_genero](#producto_genero)
12. [inventario](#inventario)
13. [ventas](#ventas)
14. [detalle_venta](#detalle_venta)
15. [devoluciones](#devoluciones)
16. [detalle_devolucion](#detalle_devolucion)
17. [intercambios](#intercambios)
18. [detalle_intercambio](#detalle_intercambio)
19. [preventas](#preventas)
20. [ordenes_compra](#ordenes_compra)
21. [detalle_orden_compra](#detalle_orden_compra)
22. [bitacora_precios](#bitacora_precios)

## estados

Estados de EE.UU. y su impuesto estatal sobre ventas (sales tax).

| Columna | Tipo | Nulo | Llave | Default | Descripción |
|---|---|:-:|---|---|---|
| `id_estado` | int | No | PK · AI |  | Identificador |
| `nombre` | varchar(40) | No | UQ |  | Nombre del estado |
| `abreviatura` | char(2) | No | UQ |  | Clave postal de 2 letras (TX, CA...) |
| `tasa_impuesto` | decimal(5,4) | No |  |  | Impuesto estatal sobre ventas (0.0625 = 6.25 %) |

**Restricciones CHECK:** `(tasa_impuesto between 0 and 0.2)`

## sucursales

Tiendas físicas de la cadena.

| Columna | Tipo | Nulo | Llave | Default | Descripción |
|---|---|:-:|---|---|---|
| `id_sucursal` | int | No | PK · AI |  | Identificador |
| `numero_tienda` | smallint | No | UQ |  | Número de tienda interno de GameStop |
| `nombre` | varchar(80) | No |  |  | Nombre |
| `direccion` | varchar(150) | No |  |  | Calle y número |
| `ciudad` | varchar(60) | No |  |  | Ciudad |
| `id_estado` | int | No | FK → estados |  | Referencia a estados |
| `codigo_postal` | char(5) | No |  |  | ZIP code de 5 dígitos |
| `telefono` | varchar(20) | Sí |  |  | Teléfono |
| `fecha_apertura` | date | No |  |  | Fecha en que abrió |
| `activa` | tinyint(1) | No |  | 1 | Si la tienda sigue abierta |

## empleados

Personal de tienda; id_supervisor es una relación recursiva.

| Columna | Tipo | Nulo | Llave | Default | Descripción |
|---|---|:-:|---|---|---|
| `id_empleado` | int | No | PK · AI |  | Identificador |
| `nombre` | varchar(50) | No |  |  | Nombre |
| `apellido` | varchar(50) | No |  |  | Apellido |
| `correo` | varchar(120) | No | UQ |  | Correo electrónico |
| `telefono` | varchar(20) | Sí |  |  | Teléfono |
| `puesto` | enum('Gerente de distrito','Gerente de tienda','Subgerente','Asesor senior','Asesor') | No |  |  | Puesto dentro de la tienda |
| `salario_hora` | decimal(6,2) | No |  |  | Pago por hora en USD (mínimo federal $7.25) |
| `fecha_contratacion` | date | No |  |  | Fecha de ingreso |
| `id_sucursal` | int | No | FK → sucursales |  | Referencia a sucursales |
| `id_supervisor` | int | Sí | FK → empleados |  | Jefe directo (relación recursiva a empleados) |
| `activo` | tinyint(1) | No |  | 1 | Si sigue trabajando en la empresa |

**Restricciones CHECK:** `(salario_hora >= 7.25)`

## niveles_membresia

Niveles del programa de lealtad (PowerUp Rewards / GameStop Pro).

| Columna | Tipo | Nulo | Llave | Default | Descripción |
|---|---|:-:|---|---|---|
| `id_nivel` | int | No | PK · AI |  | Identificador |
| `nombre` | varchar(40) | No | UQ |  | Nombre |
| `costo_anual` | decimal(6,2) | No |  | 0.00 | Costo de la membresía por año (USD) |
| `descuento_usados_pct` | decimal(4,2) | No |  | 0.00 | % de descuento en productos usados y reacondicionados |
| `bono_intercambio_pct` | decimal(4,2) | No |  | 0.00 | % extra que recibe al intercambiar por crédito en tienda |
| `puntos_por_dolar` | tinyint | No |  | 1 | Puntos que gana por cada dólar gastado |

## clientes

Clientes registrados en el programa de lealtad.

| Columna | Tipo | Nulo | Llave | Default | Descripción |
|---|---|:-:|---|---|---|
| `id_cliente` | int | No | PK · AI |  | Identificador |
| `nombre` | varchar(50) | No |  |  | Nombre |
| `apellido` | varchar(50) | No |  |  | Apellido |
| `correo` | varchar(120) | No | UQ |  | Correo electrónico |
| `telefono` | varchar(20) | Sí |  |  | Teléfono |
| `fecha_nacimiento` | date | Sí |  |  | Fecha de nacimiento |
| `id_estado` | int | No | FK → estados |  | Referencia a estados |
| `id_nivel` | int | No | FK → niveles_membresia | 1 | Nivel del programa de lealtad |
| `vencimiento_membresia` | date | Sí |  |  | Fecha en que vence GameStop Pro (NULL si es gratuito) |
| `puntos` | int | No |  | 0 | Puntos acumulados (los actualizan los triggers) |
| `credito_tienda` | decimal(9,2) | No |  | 0.00 | Saldo a favor por intercambios (USD) |
| `fecha_registro` | date | No |  |  | Fecha en que se registró |

**Restricciones CHECK:** `(puntos >= 0)` · `(credito_tienda >= 0)`

## categorias

| Columna | Tipo | Nulo | Llave | Default | Descripción |
|---|---|:-:|---|---|---|
| `id_categoria` | int | No | PK · AI |  | Identificador |
| `nombre` | varchar(40) | No | UQ |  | Nombre |
| `descripcion` | varchar(150) | Sí |  |  | Descripción |

## plataformas

| Columna | Tipo | Nulo | Llave | Default | Descripción |
|---|---|:-:|---|---|---|
| `id_plataforma` | int | No | PK · AI |  | Identificador |
| `nombre` | varchar(40) | No | UQ |  | Nombre |
| `fabricante` | varchar(40) | No |  |  | Empresa que la fabrica |
| `generacion` | tinyint | Sí |  |  | Generación de consola (8 = PS4/Xbox One/Switch, 9 = PS5/Series/Switch 2) |
| `fecha_lanzamiento` | date | Sí |  |  | Fecha de lanzamiento |

## generos

| Columna | Tipo | Nulo | Llave | Default | Descripción |
|---|---|:-:|---|---|---|
| `id_genero` | int | No | PK · AI |  | Identificador |
| `nombre` | varchar(40) | No | UQ |  | Nombre |

## proveedores

Fabricantes y distribuidores que surten a la cadena.

| Columna | Tipo | Nulo | Llave | Default | Descripción |
|---|---|:-:|---|---|---|
| `id_proveedor` | int | No | PK · AI |  | Identificador |
| `nombre` | varchar(80) | No | UQ |  | Nombre |
| `contacto` | varchar(80) | Sí |  |  | Persona de contacto |
| `telefono` | varchar(20) | Sí |  |  | Teléfono |
| `correo` | varchar(120) | Sí |  |  | Correo electrónico |
| `ciudad` | varchar(60) | Sí |  |  | Ciudad |
| `id_estado` | int | Sí | FK → estados |  | Referencia a estados |

## productos

Catálogo: juegos, consolas, accesorios, coleccionables y tarjetas.

| Columna | Tipo | Nulo | Llave | Default | Descripción |
|---|---|:-:|---|---|---|
| `id_producto` | int | No | PK · AI |  | Identificador |
| `sku` | varchar(20) | No | UQ |  | Código único del producto en tienda |
| `nombre` | varchar(120) | No |  |  | Nombre |
| `id_categoria` | int | No | FK → categorias |  | Referencia a categorias |
| `id_plataforma` | int | Sí | FK → plataformas |  | Consola a la que pertenece (NULL si no aplica) |
| `id_proveedor` | int | Sí | FK → proveedores |  | Proveedor (NULL en usados que llegan por intercambio) |
| `condicion` | enum('Nuevo','Usado','Reacondicionado') | No |  | Nuevo | Nuevo, Usado o Reacondicionado |
| `clasificacion_esrb` | enum('E','E10+','T','M','RP') | Sí |  |  | Clasificación por edad (solo videojuegos) |
| `precio_venta` | decimal(8,2) | No |  |  | Precio al público sin impuesto (USD) |
| `costo` | decimal(8,2) | No |  |  | Costo de compra al proveedor (USD) |
| `fecha_lanzamiento` | date | Sí |  |  | Fecha de lanzamiento |
| `activo` | tinyint(1) | No |  | 1 | FALSE = descontinuado, no se puede vender |

**Restricciones CHECK:** `(precio_venta >= costo)` · `(precio_venta > 0)` · `(costo >= 0)`

**Triggers:** `trg_productos_au` (AFTER UPDATE) · `trg_productos_bu` (BEFORE UPDATE)

## producto_genero

Relación N:M entre videojuegos y géneros.

| Columna | Tipo | Nulo | Llave | Default | Descripción |
|---|---|:-:|---|---|---|
| `id_producto` | int | No | PK · FK → productos |  | Referencia a productos |
| `id_genero` | int | No | PK · FK → generos |  | Referencia a generos |

## inventario

Existencias de cada producto en cada tienda (N:M sucursales-productos).

| Columna | Tipo | Nulo | Llave | Default | Descripción |
|---|---|:-:|---|---|---|
| `id_sucursal` | int | No | PK · FK → sucursales |  | Referencia a sucursales |
| `id_producto` | int | No | PK · FK → productos |  | Referencia a productos |
| `existencia` | int | No |  | 0 | Piezas disponibles en la tienda |
| `stock_minimo` | int | No |  | 3 | Nivel en el que se debe reabastecer |
| `ultima_actualizacion` | timestamp | No |  | CURRENT_TIMESTAMP | Se actualiza sola en cada cambio |

**Restricciones CHECK:** `(existencia >= 0)` · `(stock_minimo >= 0)`

## ventas

Encabezado del ticket; los importes los calculan los triggers.

| Columna | Tipo | Nulo | Llave | Default | Descripción |
|---|---|:-:|---|---|---|
| `id_venta` | int | No | PK · AI |  | Identificador |
| `fecha` | datetime | No |  | CURRENT_TIMESTAMP | Fecha y hora de la operación |
| `id_sucursal` | int | No | FK → sucursales |  | Referencia a sucursales |
| `id_empleado` | int | No | FK → empleados |  | Referencia a empleados |
| `id_cliente` | int | Sí | FK → clientes |  | Cliente registrado (NULL = cliente no registrado) |
| `metodo_pago` | enum('Efectivo','Tarjeta de crédito','Tarjeta de débito','Crédito en tienda','Tarjeta de regalo') | No |  |  | Forma de pago del cliente |
| `subtotal` | decimal(10,2) | No |  | 0.00 | Suma de cantidad × precio (la calcula un trigger) |
| `descuento` | decimal(10,2) | No |  | 0.00 | Descuento GameStop Pro aplicado (trigger) |
| `impuesto` | decimal(10,2) | No |  | 0.00 | Impuesto estatal (trigger) |
| `total` | decimal(10,2) | No |  | 0.00 | Subtotal − descuento + impuesto (trigger) |
| `estado` | enum('Completada','Devuelta parcial','Devuelta') | No |  | Completada | Completada, Devuelta parcial o Devuelta |

## detalle_venta

Renglones de cada venta.

| Columna | Tipo | Nulo | Llave | Default | Descripción |
|---|---|:-:|---|---|---|
| `id_venta` | int | No | PK · FK → ventas |  | Referencia a ventas |
| `id_producto` | int | No | PK · FK → productos |  | Referencia a productos |
| `cantidad` | int | No |  |  | Número de piezas |
| `precio_unitario` | decimal(8,2) | No |  |  | Precio al momento de la venta (si se manda NULL, el trigger usa el del catálogo) |
| `descuento` | decimal(8,2) | No |  | 0.00 | Descuento del renglón (trigger) |

**Restricciones CHECK:** `(cantidad > 0)`

**Triggers:** `trg_detalle_venta_ai` (AFTER INSERT) · `trg_detalle_venta_bi` (BEFORE INSERT)

## devoluciones

Devoluciones sobre una venta (máximo 30 días).

| Columna | Tipo | Nulo | Llave | Default | Descripción |
|---|---|:-:|---|---|---|
| `id_devolucion` | int | No | PK · AI |  | Identificador |
| `id_venta` | int | No | FK → ventas |  | Referencia a ventas |
| `fecha` | datetime | No |  | CURRENT_TIMESTAMP | Fecha y hora de la operación |
| `id_empleado` | int | No | FK → empleados |  | Referencia a empleados |
| `motivo` | enum('Defectuoso','No le gustó','Regalo duplicado','Error de compra') | No |  |  | Razón de la devolución |
| `monto_reembolsado` | decimal(10,2) | No |  | 0.00 | Total regresado al cliente con impuesto (trigger) |

## detalle_devolucion

| Columna | Tipo | Nulo | Llave | Default | Descripción |
|---|---|:-:|---|---|---|
| `id_devolucion` | int | No | PK · FK → devoluciones |  | Referencia a devoluciones |
| `id_producto` | int | No | PK · FK → productos |  | Referencia a productos |
| `cantidad` | int | No |  |  | Número de piezas |

**Restricciones CHECK:** `(cantidad > 0)`

**Triggers:** `trg_detalle_devolucion_ai` (AFTER INSERT) · `trg_detalle_devolucion_bi` (BEFORE INSERT)

## intercambios

El cliente vende juegos/consolas usados a la tienda.

| Columna | Tipo | Nulo | Llave | Default | Descripción |
|---|---|:-:|---|---|---|
| `id_intercambio` | int | No | PK · AI |  | Identificador |
| `fecha` | datetime | No |  | CURRENT_TIMESTAMP | Fecha y hora de la operación |
| `id_sucursal` | int | No | FK → sucursales |  | Referencia a sucursales |
| `id_empleado` | int | No | FK → empleados |  | Referencia a empleados |
| `id_cliente` | int | No | FK → clientes |  | Referencia a clientes |
| `forma_pago` | enum('Efectivo','Crédito en tienda') | No |  |  | Cómo se le paga al cliente: efectivo o crédito en tienda |
| `total_pagado` | decimal(10,2) | No |  | 0.00 | Total pagado al cliente (trigger) |

## detalle_intercambio

| Columna | Tipo | Nulo | Llave | Default | Descripción |
|---|---|:-:|---|---|---|
| `id_intercambio` | int | No | PK · FK → intercambios |  | Referencia a intercambios |
| `id_producto` | int | No | PK · FK → productos |  | Referencia a productos |
| `cantidad` | int | No |  |  | Número de piezas |
| `valor_unitario` | decimal(8,2) | No |  |  | Lo que paga la tienda por pieza (fn_valor_intercambio) |

**Restricciones CHECK:** `(cantidad > 0)`

**Triggers:** `trg_detalle_intercambio_ai` (AFTER INSERT) · `trg_detalle_intercambio_bi` (BEFORE INSERT)

## preventas

Apartados de productos antes de su lanzamiento.

| Columna | Tipo | Nulo | Llave | Default | Descripción |
|---|---|:-:|---|---|---|
| `id_preventa` | int | No | PK · AI |  | Identificador |
| `fecha` | date | No |  |  | Fecha y hora de la operación |
| `id_cliente` | int | No | FK → clientes · UQ |  | Referencia a clientes |
| `id_producto` | int | No | FK → productos · UQ |  | Referencia a productos |
| `id_sucursal` | int | No | FK → sucursales |  | Referencia a sucursales |
| `anticipo` | decimal(8,2) | No |  |  | Pago adelantado del apartado (USD) |
| `estado` | enum('Pendiente','Entregada','Cancelada') | No | UQ | Pendiente | Estado del registro |

**Restricciones CHECK:** `(anticipo >= 0)`

## ordenes_compra

Pedidos de mercancía a proveedores.

| Columna | Tipo | Nulo | Llave | Default | Descripción |
|---|---|:-:|---|---|---|
| `id_orden` | int | No | PK · AI |  | Identificador |
| `fecha` | date | No |  |  | Fecha y hora de la operación |
| `id_proveedor` | int | No | FK → proveedores |  | Referencia a proveedores |
| `id_sucursal` | int | No | FK → sucursales |  | Referencia a sucursales |
| `id_empleado` | int | No | FK → empleados |  | Referencia a empleados |
| `estado` | enum('Pendiente','Recibida','Cancelada') | No |  | Pendiente | Estado del registro |
| `fecha_recepcion` | date | Sí |  |  | Cuándo llegó la mercancía (sp_recibir_orden) |
| `total` | decimal(10,2) | No |  | 0.00 | Suma de la orden (trigger) |

**Restricciones CHECK:** `((fecha_recepcion is null) or (fecha_recepcion >= fecha))`

## detalle_orden_compra

| Columna | Tipo | Nulo | Llave | Default | Descripción |
|---|---|:-:|---|---|---|
| `id_orden` | int | No | PK · FK → ordenes_compra |  | Referencia a ordenes_compra |
| `id_producto` | int | No | PK · FK → productos |  | Referencia a productos |
| `cantidad` | int | No |  |  | Número de piezas |
| `costo_unitario` | decimal(8,2) | No |  |  | Costo por pieza (USD) |

**Restricciones CHECK:** `(cantidad > 0)` · `(costo_unitario >= 0)`

**Triggers:** `trg_detalle_orden_ai` (AFTER INSERT)

## bitacora_precios

Auditoría: la llena un trigger cada vez que cambia un precio.

| Columna | Tipo | Nulo | Llave | Default | Descripción |
|---|---|:-:|---|---|---|
| `id_bitacora` | int | No | PK · AI |  | Identificador |
| `id_producto` | int | No | FK → productos |  | Referencia a productos |
| `precio_anterior` | decimal(8,2) | No |  |  | Precio antes del cambio |
| `precio_nuevo` | decimal(8,2) | No |  |  | Precio después del cambio |
| `fecha` | datetime | No |  | CURRENT_TIMESTAMP | Fecha y hora de la operación |
| `usuario` | varchar(100) | No |  |  | Usuario de MySQL que hizo el cambio |

## Vistas

| Vista | Descripción |
|---|---|
| `v_catalogo` | Catálogo con categoría, plataforma, géneros, margen y existencia total |
| `v_clientes_resumen` | Compras, gasto, puntos, crédito y vigencia Pro de cada cliente |
| `v_inventario_valorizado` | Piezas y valor (a costo y a precio de venta) del inventario de cada tienda |
| `v_organigrama` | Empleados con su tienda, antigüedad y jefe directo |
| `v_tickets` | Cada venta con tienda, estado, vendedor y cliente |
| `v_ventas_diarias` | Tickets y ventas por día de toda la cadena |
| `v_ventas_producto` | Unidades, ingreso y utilidad por producto, descontando devoluciones |

## Funciones y procedimientos

| Nombre | Tipo | Parámetros |
|---|---|---|
| `fn_antiguedad` | Función | p_id_empleado INT, p_fecha DATE |
| `fn_es_pro` | Función | p_id_cliente INT, p_fecha DATE |
| `fn_tasa_impuesto` | Función | p_id_sucursal INT |
| `fn_valor_intercambio` | Función | p_id_producto INT, p_forma_pago VARCHAR(20), p_id_cliente INT, p_fecha DATE |
| `sp_ajustar_precios` | Procedimiento | p_categoria VARCHAR(40), p_plataforma VARCHAR(40), p_porcentaje DECIMAL(5,2) |
| `sp_bajo_stock` | Procedimiento | p_id_sucursal INT |
| `sp_generar_reabasto` | Procedimiento | p_id_sucursal INT, p_id_empleado INT, p_fecha DATE |
| `sp_historial_cliente` | Procedimiento | p_correo VARCHAR(120) |
| `sp_recibir_orden` | Procedimiento | p_id_orden INT, p_fecha DATE |
| `sp_registrar_venta` | Procedimiento | p_id_sucursal INT, p_id_empleado INT, p_id_cliente INT, p_metodo_pago VARCHAR(20), p_articulos JSON, OUT p_id_venta INT |
| `sp_renovar_pro` | Procedimiento | p_id_cliente INT, p_fecha DATE |
| `sp_reporte_ventas` | Procedimiento | p_inicio DATE, p_fin DATE |
| `sp_transferir_inventario` | Procedimiento | p_origen INT, p_destino INT, p_sku VARCHAR(20), p_cantidad INT |
