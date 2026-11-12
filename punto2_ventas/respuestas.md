# Punto 2 — Respuestas conceptuales

## 1. ¿Por qué usar `_loaded_at` y no `fecha_venta` para este control?

Porque lo que queremos vigilar es si la **carga** está al día, no cuándo ocurrieron las ventas. `fecha_venta` es la fecha del
negocio: una venta del 10 de enero puede llegar hoy y eso no significa que la fuente esté atrasada. De hecho, en este ejercicio
las ventas son todas de enero de 2026 en los tres escenarios; si midiéramos con `fecha_venta`, la fuente parecería "vieja"
siempre (meses de antigüedad) y el control fallaría incluso con una carga recién hecha, o no distinguiría nada.

`_loaded_at` es el instante (UTC) en que el registro llegó a `raw`, así que `max(_loaded_at)` responde a la pregunta
"¿cuándo fue la última vez que llegaron datos?". Es justo lo que cambió entre escenarios con los mismos datos de negocio:
en la ejecución `actualizada` el máximo era de hace unas 2 h y freshness pasó; en `desactualizada` era
`2026-11-11T05:37:09Z`, 30.0 h antes de la comprobación (`evidencias/artifacts_tras_desactualizada.txt`), y dbt reportó
`ERROR STALE freshness of ventas_raw.ventas` (`evidencias/dbt_freshness_desactualizada_stdout.txt`).

Aun así, este control mira solo la carga más reciente: no demuestra que hayan llegado **todas** las ventas esperadas.

## 2. ¿Por qué las pruebas de integridad no garantizan actualidad?

Las pruebas de `unique`, `not_null` y `valores_ventas` revisan si las filas que **ya están** cumplen reglas de forma
(identificador único, campos obligatorios, cantidades y precios válidos). No preguntan cuándo llegaron esas filas. Un conjunto
de datos de ayer, o del mes pasado, puede ser perfectamente íntegro y pasar todas las pruebas.

En el ejercicio se ve directamente: los tres escenarios cargan los mismos seis registros válidos; con la fuente de 30 h de
antigüedad, las 17 pruebas de datos seguirían pasando (son las mismas filas que pasaron `PASS=19` en el build) y el resumen
se reconstruiría "con éxito" usando información desactualizada. Por eso la actualidad necesita un control propio
(`dbt source freshness`, que además `dbt build` no ejecuta solo) y, en el DAG, ese control va **antes** del build: con
error, `comprobar_frescura` queda `failed`, `construir_resumen` queda `upstream_failed` sin ejecutarse (try_number 0,
sin `INICIO dbt`) y se conserva el resumen anterior (`resumen_antes_bloqueo.txt` = `resumen_despues_bloqueo.txt`).
