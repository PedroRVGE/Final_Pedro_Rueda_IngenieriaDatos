# Punto 1 — Respuestas conceptuales

## 1. ¿Por qué se pudo consultar el tercer día sin registrar una partición nueva?

Porque la tabla no depende de una lista de particiones guardada en el catálogo. Con partition projection, Glue guarda
**reglas** y Athena calcula las particiones en el momento de la consulta. En `infraestructura/principal.tf` la tabla
`final_entregas_db.entregas` tiene:

- `projection.enabled = true` y `projection.fecha.type = date`, con formato `yyyy-MM-dd`, intervalo `1` `DAYS` y rango
  `2026-10-01,2026-10-03` desde el primer despliegue;
- `storage.location.template = s3://final-entregas-pedro-rueda-466494951615/entregas/fecha=${fecha}/`.

Con eso Athena genera los tres valores posibles de `fecha` y, para cada uno, el prefijo de S3 donde buscar
(`.../entregas/fecha=2026-10-03/`). En la etapa inicial ese prefijo no tenía objetos, así que la fecha simplemente no aportó
filas (`resultados/inicial/verificacion_etapa_inicial.csv`: 12 registros, 0 del día 3). Cuando se subió
`entregas/fecha=2026-10-03/entregas.csv`, la siguiente consulta encontró el archivo en la ubicación que ya calculaba y
devolvió sus seis filas (`resultados/final/verificacion_tercer_dia.csv`) y el total de 18
(`resultados/final/verificacion_tercer_dia_total.csv`).

No hubo crawler, `MSCK REPAIR TABLE`, `ALTER TABLE ADD PARTITION` ni cambios a la tabla: `terraform plan` antes de subir el
día 3 no mostraba cambios y `aws glue get-partitions` devolvía **0** particiones registradas antes y después
(`evidencias/tabla_glue.json` guarda las propiedades de la tabla). Lo único que cambió fue un objeto en S3.

## 2. Si se subiera un archivo para el 4 de octubre manteniendo la configuración actual, ¿qué se esperaría y qué habría que modificar?

Se esperaría que **ese día no aparezca**. El archivo quedaría guardado en
`s3://<bucket>/entregas/fecha=2026-10-04/entregas.csv`, pero el rango proyectado termina en `2026-10-03` (incluido), así que
Athena nunca genera el valor `2026-10-04` ni consulta ese prefijo. Las consultas agregadas seguirían devolviendo solo los
tres días (los mismos resultados de `resultados/final/`) y un `WHERE fecha = '2026-10-04'` daría cero filas, sin error.
Esto se comprobó en el workgroup (sin subir ningún archivo del día 4): `SELECT COUNT(*) ... WHERE fecha = '2026-10-04'`
terminó `SUCCEEDED` con `0` (ejecución `f09e7378-4ace-4252-89ba-27d6d291cc92`). La proyección no descubre carpetas por su
cuenta: solo considera fechas dentro de su regla.

Para incluirlo hay que **ampliar el rango de la proyección** en la definición de la tabla, es decir, cambiar
`projection.fecha.range` a `2026-10-01,2026-10-04` (en este código, la variable `fecha_final = "2026-10-04"`) y aplicar con
Terraform, para que el cambio quede en código y sea reproducible. No hace falta crear la partición del día 4. Otra opción es
dejar el rango abierto con una fecha relativa, por ejemplo `2026-10-01,NOW`, para que cada día nuevo quede incluido sin
volver a tocar la tabla. Mientras el nuevo archivo respete la misma ruta (`fecha=yyyy-MM-dd/entregas.csv`) y el mismo
esquema de cinco columnas con encabezado, se consultará con solo subirlo.
