# Reporte de validación de la migración MySQL → MongoDB

Generado el 2026-11-24 13:16 con `python migracion/validar.py --reporte docs/reporte_validacion.md`.

**Resultado: 61 de 61 pruebas correctas, sin diferencias.**


## 1. Conteos

| Prueba | MySQL | MongoDB | |
|---|---|---|:-:|
| niveles_membresia → niveles_membresia | 2 | 2 | ✅ |
| sucursales → sucursales | 10 | 10 | ✅ |
| clientes → clientes | 60 | 60 | ✅ |
| proveedores → proveedores | 15 | 15 | ✅ |
| productos → productos | 67 | 67 | ✅ |
| ventas → ventas | 474 | 474 | ✅ |
| intercambios → intercambios | 30 | 30 | ✅ |
| preventas → preventas | 23 | 23 | ✅ |
| ordenes_compra → ordenes_compra | 25 | 25 | ✅ |
| bitacora_precios → bitacora_precios | 11 | 11 | ✅ |
| empleados → sucursales.empleados[] | 45 | 45 | ✅ |
| inventario → productos.inventario[] | 670 | 670 | ✅ |
| producto_genero → productos.generos[] | 76 | 76 | ✅ |
| detalle_venta → ventas.articulos[] | 774 | 774 | ✅ |
| devoluciones → ventas.devoluciones[] | 14 | 14 | ✅ |
| detalle_intercambio → intercambios.articulos[] | 47 | 47 | ✅ |
| detalle_orden_compra → ordenes_compra.articulos[] | 44 | 44 | ✅ |
| detalle_devolucion → ventas.devoluciones[].articulos[] | 20 | 20 | ✅ |
| estados usados por tiendas → sucursales.estado | 7 | 7 | ✅ |
| ventas sin cliente (cliente = null) | 115 | 115 | ✅ |

## 2. Totales

| Prueba | MySQL | MongoDB | |
|---|---|---|:-:|
| Suma de ventas.subtotal | 96746.81 | 96746.81 | ✅ |
| Suma de ventas.descuento | 93.7 | 93.7 | ✅ |
| Suma de ventas.impuesto | 6052.04 | 6052.04 | ✅ |
| Suma de ventas.total | 102705.15 | 102705.15 | ✅ |
| Unidades vendidas | 880 | 880 | ✅ |
| Reembolsos | 2509.07 | 2509.07 | ✅ |
| Pagado en intercambios | 1236.39 | 1236.39 | ✅ |
| Total de órdenes de compra | 43941.0 | 43941.0 | ✅ |
| Piezas en inventario | 5344 | 5344 | ✅ |
| Puntos de clientes | 135379 | 135379 | ✅ |
| Crédito en tienda | 475.78 | 475.78 | ✅ |
| Anticipos de preventas | 355.0 | 355.0 | ✅ |
| Total vendido de cada tienda (10 tiendas) | 10 tiendas | 10 coinciden | ✅ |
| Existencia de cada producto | 67 productos | 67 coinciden | ✅ |
| Puntos y crédito de cada cliente | 60 clientes | 60 coinciden | ✅ |

## 3. Integridad referencial en MongoDB

| Prueba | MySQL | MongoDB | |
|---|---|---|:-:|
| ventas.cliente → clientes | 0 huérfanos | 0 huérfanos | ✅ |
| ventas.sucursal → sucursales | 0 huérfanos | 0 huérfanos | ✅ |
| ventas.empleado → empleados | 0 huérfanos | 0 huérfanos | ✅ |
| ventas.articulos.sku → productos | 0 huérfanos | 0 huérfanos | ✅ |
| productos.inventario.sucursal → sucursales | 0 huérfanos | 0 huérfanos | ✅ |
| productos.proveedor → proveedores | 0 huérfanos | 0 huérfanos | ✅ |
| intercambios.cliente → clientes | 0 huérfanos | 0 huérfanos | ✅ |
| intercambios.articulos.sku → productos | 0 huérfanos | 0 huérfanos | ✅ |
| preventas.producto → productos | 0 huérfanos | 0 huérfanos | ✅ |
| ordenes_compra.proveedor → proveedores | 0 huérfanos | 0 huérfanos | ✅ |
| empleados.id_supervisor → empleados | 0 huérfanos | 0 huérfanos | ✅ |
| bitacora_precios.producto → productos | 0 huérfanos | 0 huérfanos | ✅ |
| Ninguna existencia negativa | 0 | 0 | ✅ |
| Ningún precio menor al costo | 0 | 0 | ✅ |
| total = subtotal − descuento + impuesto en cada venta | 0 | 0 | ✅ |

## 4. Estructura y validadores ($jsonSchema)

| Prueba | MySQL | MongoDB | |
|---|---|---|:-:|
| niveles_membresia: documentos que violan su $jsonSchema | 0 | 0 | ✅ |
| sucursales: documentos que violan su $jsonSchema | 0 | 0 | ✅ |
| clientes: documentos que violan su $jsonSchema | 0 | 0 | ✅ |
| proveedores: documentos que violan su $jsonSchema | 0 | 0 | ✅ |
| productos: documentos que violan su $jsonSchema | 0 | 0 | ✅ |
| ventas: documentos que violan su $jsonSchema | 0 | 0 | ✅ |
| intercambios: documentos que violan su $jsonSchema | 0 | 0 | ✅ |
| preventas: documentos que violan su $jsonSchema | 0 | 0 | ✅ |
| ordenes_compra: documentos que violan su $jsonSchema | 0 | 0 | ✅ |
| Vistas creadas | 4 | 4 | ✅ |

## 5. Muestra al azar (25 ventas, campo por campo)

| Prueba | MySQL | MongoDB | |
|---|---|---|:-:|
| Ventas idénticas | 25 | 25 | ✅ |
