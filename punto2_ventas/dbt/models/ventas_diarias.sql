-- Resumen diario de ventas: una fila por fecha_venta.
-- ingreso_total = suma de cantidad * precio_unitario; se mantiene DECIMAL (sin pasar por float) para conservar la precisión.
select
    fecha_venta,
    count(*) as numero_ventas,
    sum(cantidad) as unidades_vendidas,
    cast(sum(cantidad * precio_unitario) as decimal(18, 2)) as ingreso_total
from {{ ref('stg_ventas') }}
group by fecha_venta
