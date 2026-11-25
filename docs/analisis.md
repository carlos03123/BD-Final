# Análisis del sistema — Base de datos GameStop USA

## 1. Contexto

**GameStop** es una cadena de tiendas de videojuegos de Estados Unidos con sede en Grapevine, Texas. Vende videojuegos, consolas, accesorios, coleccionables y tarjetas de regalo. Su negocio tiene un rasgo que la distingue de otras tiendas: **compra a sus clientes juegos y consolas usados** (*trade-ins*) para revenderlos, y tiene un programa de lealtad de pago llamado **GameStop Pro**.

Este proyecto modela la operación de un distrito de **10 tiendas en 7 estados** (TX, CA, NY, FL, IL, AZ, WA) durante octubre y noviembre de 2026, la temporada más fuerte del año: incluye el lanzamiento de *Grand Theft Auto VI* y las ofertas de Black Friday.

## 2. Problema

Sin una base de datos central, cada tienda tendría que llevar por separado:

- **Inventario:** no sabe cuántas piezas tiene ni cuándo reabastecer, y no ve las existencias de las otras tiendas.
- **Precios e impuestos:** cada estado cobra un impuesto distinto y los precios cambian con las ofertas. Sin un historial no se puede auditar quién cambió un precio ni cuándo.
- **Clientes:** los puntos, el crédito por intercambios y la vigencia de la membresía Pro tendrían que llevarse a mano, con riesgo de errores o fraude (por ejemplo, gastar un crédito que no existe).
- **Devoluciones e intercambios:** no habría control de plazos ni de cantidades, y se podrían recibir productos nuevos como si fueran usados.
- **Reportes:** la gerencia no podría comparar tiendas, vendedores o productos.

## 3. Objetivos

**General:** diseñar e implementar una base de datos que centralice la operación de las tiendas y garantice la integridad de los datos mediante reglas en la propia base de datos.

**Específicos:**

1. Modelar tiendas, personal, clientes, catálogo, inventario y todas las operaciones (ventas, devoluciones, intercambios, preventas y compras).
2. Automatizar los cálculos de impuestos, descuentos, puntos, crédito e inventario con triggers y funciones.
3. Asegurar que no se puedan registrar operaciones inválidas.
4. Generar reportes para la toma de decisiones (ventas por tienda, producto y vendedor; inventario; clientes).
5. Controlar el acceso a los datos según el puesto (roles).
6. Migrar el modelo a una base NoSQL (MongoDB), validar que los datos coinciden y comparar ambos enfoques.
7. Ofrecer una interfaz web para usar la base de datos.

## 4. Actores (usuarios del sistema)

| Actor | Descripción | Rol en la BD |
|---|---|---|
| **Asesor / vendedor** | Atiende el mostrador: vende, recibe intercambios, devoluciones y preventas | `rol_vendedor` |
| **Gerente de tienda** | Supervisa la tienda, pide mercancía, cambia precios, transfiere inventario | `rol_gerente` |
| **Gerente de distrito** | Supervisa a varios gerentes de tienda | `rol_gerente` |
| **Analista** | Consulta reportes; no debe ver datos personales completos | `rol_analista` |
| **Administrador de BD** | Mantiene la base de datos | `rol_admin` |
| **Cliente** | No usa el sistema directamente; sus datos y saldos se guardan en él | — |
| **Proveedor** | Recibe órdenes de compra | — |

## 5. Requerimientos funcionales

| ID | Requerimiento | Implementación |
|---|---|---|
| RF-01 | Registrar tiendas con su estado y tasa de impuesto | `sucursales`, `estados` |
| RF-02 | Registrar empleados con su puesto, salario y jefe directo | `empleados` (relación recursiva) |
| RF-03 | Registrar clientes y su nivel de membresía | `clientes`, `niveles_membresia` |
| RF-04 | Mantener un catálogo de productos con categoría, plataforma, proveedor, condición (nuevo/usado/reacondicionado), clasificación ESRB y géneros | `productos`, `categorias`, `plataformas`, `proveedores`, `generos`, `producto_genero` |
| RF-05 | Llevar la existencia de cada producto en cada tienda | `inventario` |
| RF-06 | Registrar ventas con varios productos, calculando subtotal, descuento, impuesto y total | `ventas`, `detalle_venta`, `sp_registrar_venta`, triggers |
| RF-07 | Registrar devoluciones parciales o totales y reembolsar | `devoluciones`, `detalle_devolucion`, triggers |
| RF-08 | Comprar artículos usados a los clientes en efectivo o crédito en tienda | `intercambios`, `detalle_intercambio`, `fn_valor_intercambio` |
| RF-09 | Registrar preventas de productos que aún no salen | `preventas` |
| RF-10 | Crear órdenes de compra a proveedores y recibir la mercancía | `ordenes_compra`, `sp_recibir_orden`, `sp_generar_reabasto` |
| RF-11 | Transferir inventario entre tiendas | `sp_transferir_inventario` |
| RF-12 | Cambiar precios individualmente o por oferta y guardar el historial | `sp_ajustar_precios`, `bitacora_precios` |
| RF-13 | Contratar o renovar la membresía GameStop Pro | `sp_renovar_pro` |
| RF-14 | Reportes: ventas por tienda, estado, producto, categoría, vendedor y día; inventario valorizado; clientes | 7 vistas, procedimientos de reporte, 30 consultas |
| RF-15 | Consultar los datos desde una interfaz web | `app/` (Flask) |
| RF-16 | Auditar cada alta, cambio y baja de todas las tablas (qué cambió, quién y cuándo) | 21 tablas `aud_<tabla>` con triggers (`09_auditoria.sql`) |
| RF-17 | Dar de alta, consultar, modificar y dar de baja tiendas, empleados, clientes, categorías, plataformas, proveedores y productos | 28 procedimientos CRUD (`10_crud.sql`) |

## 6. Reglas de negocio

| ID | Regla |
|---|---|
| RN-01 | No se puede vender más piezas de las que hay en la tienda |
| RN-02 | No se venden productos descontinuados |
| RN-03 | El impuesto se calcula con la tasa del estado donde está la tienda, sobre el precio después del descuento |
| RN-04 | Un cliente **GameStop Pro con membresía vigente** tiene 10 % de descuento en productos usados y reacondicionados |
| RN-05 | Puntos: 1 por dólar gastado (2 para Pro). Se quitan al devolver |
| RN-06 | Solo un cliente registrado puede pagar con crédito en tienda, y el saldo debe alcanzar |
| RN-07 | Las devoluciones se aceptan hasta 30 días después de la compra y nunca por más piezas de las compradas |
| RN-08 | Una devolución regresa el producto al inventario y reembolsa el precio pagado más el impuesto, por el mismo medio de pago |
| RN-09 | En un intercambio solo se reciben productos usados o reacondicionados |
| RN-10 | Por un intercambio la tienda paga 25 % del precio de venta en efectivo o 35 % en crédito; los Pro reciben 10 % extra si eligen crédito |
| RN-11 | El precio de venta nunca puede ser menor al costo |
| RN-12 | Todo cambio de precio queda registrado con fecha y usuario |
| RN-13 | Solo se reciben órdenes de compra pendientes, una sola vez |
| RN-14 | Un empleado solo puede vender en la tienda donde trabaja |
| RN-15 | El salario por hora no puede ser menor al mínimo federal ($7.25) |
| RN-16 | No se puede borrar una tienda, cliente o producto que tenga historial |

## 7. Requerimientos no funcionales

| ID | Requerimiento | Cómo se cumple |
|---|---|---|
| RNF-01 | **Integridad:** los datos siempre son consistentes | PK, FK, CHECK, UNIQUE, ENUM y triggers |
| RNF-02 | **Atomicidad:** una venta se guarda completa o no se guarda | Transacciones con `ROLLBACK` en los procedimientos |
| RNF-03 | **Seguridad:** cada usuario ve y modifica solo lo que necesita | Roles y privilegios por tabla y por columna, caducidad de contraseña y bloqueo por intentos fallidos |
| RNF-04 | **Auditoría:** saber quién cambió cualquier dato, cuándo y cuál era el valor anterior | `bitacora_precios` y las 21 tablas `aud_<tabla>`, llenadas por triggers e inmodificables |
| RNF-05 | **Rendimiento:** reportes rápidos | Índices por fecha, por tienda y por producto; totales guardados en la venta |
| RNF-06 | **Internacionalización:** acentos y caracteres especiales (Pokémon, Yōtei) | `utf8mb4` |
| RNF-07 | **Portabilidad:** la base se puede recrear desde cero | Scripts numerados que se pueden volver a ejecutar |

## 8. Casos de uso principales

### CU-01 Registrar una venta
1. El asesor captura la tienda, su número de empleado, el cliente (opcional), el método de pago y los productos.
2. El sistema valida que el empleado sea de esa tienda, que cada producto esté activo y que haya existencia (RN-01, RN-02, RN-14).
3. Si el cliente es Pro vigente, aplica el descuento en usados (RN-04).
4. Calcula el impuesto del estado (RN-03) y el total.
5. Si el pago es con crédito en tienda, verifica el saldo y lo descuenta (RN-06).
6. Descuenta el inventario y suma los puntos (RN-05).
7. **Flujo alterno:** si algo falla, no se guarda nada (RNF-02) y se muestra el motivo.

### CU-02 Recibir un intercambio
1. El cliente entrega juegos o consolas usados y elige efectivo o crédito.
2. El sistema rechaza los productos nuevos (RN-09).
3. Calcula el valor según la forma de pago y la membresía (RN-10).
4. Suma los artículos al inventario y, si es crédito, al saldo del cliente.

### CU-03 Procesar una devolución
1. El asesor indica la venta y los productos a devolver.
2. El sistema valida el plazo y las cantidades (RN-07).
3. Regresa el inventario, calcula el reembolso con impuesto, quita los puntos y marca la venta como "Devuelta parcial" o "Devuelta" (RN-08).

### CU-04 Reabastecer una tienda
1. El gerente consulta los productos bajo el mínimo (`sp_bajo_stock`).
2. Genera automáticamente una orden por proveedor (`sp_generar_reabasto`).
3. Al llegar la mercancía, la recibe (`sp_recibir_orden`) y el inventario se actualiza (RN-13).

### CU-05 Consultar reportes
El gerente o el analista consulta las ventas por tienda y periodo, los productos más vendidos, la utilidad, el inventario valorizado y el desempeño de los vendedores.

## 9. Entidades identificadas

| Entidad | Atributos clave | Relaciones |
|---|---|---|
| Estado | abreviatura, tasa de impuesto | 1:N con tiendas, clientes y proveedores |
| Tienda | número, dirección, estado | 1:N con empleados, inventario y operaciones |
| Empleado | puesto, salario, jefe | N:1 con tienda; recursiva consigo misma |
| Nivel de membresía | descuento, bono, puntos por dólar | 1:N con clientes |
| Cliente | correo, puntos, crédito, vencimiento Pro | 1:N con ventas, intercambios y preventas |
| Producto | SKU, condición, precio, costo | N:M con géneros; N:M con tiendas (inventario) |
| Venta | fecha, método de pago, totales | N:M con productos (detalle) |
| Devolución | motivo, reembolso | N:1 con venta; N:M con productos |
| Intercambio | forma de pago, total pagado | N:M con productos |
| Preventa | anticipo, estado | N:1 con cliente, producto y tienda |
| Orden de compra | estado, total | N:1 con proveedor y tienda; N:M con productos |
| Bitácora de precios | precio anterior y nuevo, usuario | N:1 con producto |

Estas entidades llevan al modelo de 22 tablas descrito en el [diccionario de datos](diccionario_datos.md) y justificado en [normalización](normalizacion.md).

## 10. Supuestos y alcance

- Se usa solo el **impuesto estatal** sobre ventas; los impuestos locales de condado o ciudad quedan fuera.
- Los precios están en dólares y **no incluyen impuesto**, como se acostumbra en Estados Unidos.
- Los porcentajes de intercambio y los beneficios de GameStop Pro son una **simplificación** del programa real.
- No se modelan ventas en línea, envíos ni pagos con tarjeta más allá de registrar el método.
- Todos los nombres de personas, correos, teléfonos y direcciones son **ficticios**.
