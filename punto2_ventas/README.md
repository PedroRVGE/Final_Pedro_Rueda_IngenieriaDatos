# Punto 2 (2.0) — Ventas diarias con control de actualidad (dbt + Airflow)

Enunciado: <https://github.com/smm-0216/DE-Final-Ventas>. Entorno local del docente (imagen `smendezm/examen-ventas:1.0`,
digest `sha256:c57ddf51…6842c77`): Airflow 2.10.5, dbt-core 1.9.4, dbt-duckdb 1.9.2.

## Archivos modificados (solo los tres permitidos)

| Archivo | Cambio |
|---|---|
| [`dbt/models/ventas_diarias.sql`](dbt/models/ventas_diarias.sql) | Resumen con una fila por `fecha_venta`: `count(*)`, `sum(cantidad)`, `sum(cantidad * precio_unitario)` en DECIMAL (sin float) |
| [`dbt/models/sources.yml`](dbt/models/sources.yml) | `loaded_at_field: _loaded_at` y `freshness` (warn > 12 h, error > 24 h) como propiedades de la tabla, sintaxis 1.9 |
| [`airflow/dags/examen_ventas.py`](airflow/dags/examen_ventas.py) | Nueva tarea `comprobar_frescura` = `run_dbt(["source", "freshness"])` y dependencia `comprobar_frescura >> construir_resumen` (regla `all_success` por defecto, sin `--warn-error`) |

`git status` del repositorio del docente después de los cambios: solo esos tres archivos aparecen modificados.

## Cómo se ejecutó

```bash
cd DE-Final-Ventas                       # clon del repo del enunciado
cp ../entorno-estudiantes/.env .env      # se conserva el .env creado por scripts/preparar.sh (AIRFLOW_UID)
docker compose up -d --wait airflow
bash scripts/examen.sh check             # todo OK

# Comprobación del modelo
bash scripts/examen.sh scenario actualizada
bash scripts/examen.sh dbt build         # Done. PASS=19 WARN=0 ERROR=0 SKIP=0 TOTAL=19
bash scripts/examen.sh query 'select * from analytics.ventas_diarias order by fecha_venta'

# Escenario 1 (obligatorio): sin tareas en ejecución
bash scripts/examen.sh scenario actualizada
#   Interfaz de Airflow: botón Trigger DAG en examen_ventas -> esperar a que termine

# Escenario 2 (obligatorio): sin build manual en medio, sin limpiar la ejecución anterior
bash scripts/examen.sh scenario desactualizada
#   Interfaz de Airflow: botón Trigger DAG -> NUEVA ejecución

docker compose stop                      # nunca docker compose down -v
```

## Resultados

### Resumen (`analytics.ventas_diarias`)

| fecha_venta | numero_ventas | unidades_vendidas | ingreso_total |
|---|---:|---:|---:|
| 2026-01-10 | 2 | 3 | 46.00 |
| 2026-01-11 | 3 | 6 | 51.25 |
| 2026-01-12 | 1 | 4 | 12.40 |

Coincide con los resultados esperados del enunciado.

### Escenario 1 — `actualizada` (run oficial `manual__2026-11-12T12:13:27.061735+00:00`)

`scenario actualizada` → `max_loaded_at = 2026-11-12T10:12:45Z` (~2 h). Ejecución creada con el botón **Trigger DAG**
(`run_type = manual`, `external_trigger = True`).

| Tarea | Estado | try_number | Inicio → fin (UTC) |
|---|---|---|---|
| `comprobar_frescura` | success | 1 | 12:13:31 → 12:13:34 |
| `construir_resumen` | success | 1 | 12:13:38 → 12:13:42 |

Freshness antes de build. dbt: `1 of 1 PASS freshness of ventas_raw.ventas` y luego `Done. PASS=19 WARN=0 ERROR=0`.
Ambos logs con `INICIO dbt` / `FIN dbt`. Resumen guardado en `resumen_antes_bloqueo.txt`.
Evidencias: `estados_actualizada.txt`, `log_actualizada_*.log`, `dbt_actualizada_stdout.txt`, `artifacts_tras_actualizada.txt`,
capturas 01–04.

### Escenario 2 — `desactualizada` (run oficial `manual__2026-11-12T12:15:02.076887+00:00`)

`scenario desactualizada` → `max_loaded_at = 2026-11-11T06:14:20Z`. Nueva ejecución con el botón **Trigger DAG**, sin limpiar
ni reutilizar la anterior y sin build manual entre la preparación y las evidencias.

| Tarea | Estado | try_number | Duración |
|---|---|---|---|
| `comprobar_frescura` | **failed** | 1 | 2.97 s |
| `construir_resumen` | **upstream_failed** (no se ejecutó) | 0 | 0 s |

- Motivo (salida de dbt): `1 of 1 ERROR STALE freshness of ventas_raw.ventas ... [ERROR STALE]`; según `sources.json`,
  `status = error`, **30.0 h** de antigüedad frente a `error_after` de 24 h. En Airflow la tarea falla con
  `CalledProcessError: ... dbt source freshness ... returned non-zero exit status 1` (lo propaga `run_dbt`).
- Build no corrió: try_number 0, duración 0, sin carpeta de log ni `INICIO dbt` para esa ejecución (solo existe
  `task_id=comprobar_frescura`), y el último `build` en `run_results.json` es el del escenario 1 (`generated_at 2026-11-12T12:13:41Z`).
- **Resumen conservado:** `resumen_antes_bloqueo.txt` y `resumen_despues_bloqueo.txt` son idénticos (diff vacío).

Nota: `run_dbt` lanza dbt como subproceso sin capturar su salida, así que el detalle `ERROR STALE` aparece en la salida del
contenedor y en `dbt.log`, no en el log de la tarea; ambos se guardaron (`dbt_freshness_desactualizada_stdout.txt`,
`dbt_log_desactualizada.txt`) y además se renderizó como imagen (`capturas/07-…-motivo-dbt_parte3.png`, marcada como salida de CLI).

## Evidencias (`evidencias/`) — ejecuciones oficiales

| Archivo | Qué demuestra |
|---|---|
| `capturas/01..08-*.jpg` | Grafo, grilla (Run ID y estados) y logs de las dos ejecuciones oficiales; índice en `capturas/CAPTURAS.md` |
| `capturas/07-ventas-desactualizada-motivo-dbt_parte3.png` | Motivo `ERROR STALE` (30 h > 24 h) renderizado como imagen (**salida de CLI, no captura de la UI**) |
| `escenario_*.json` | Salida de `scenario` (filas y `max_loaded_at`) |
| `estados_*.txt`, `intentos_desactualizada.txt` | Run ID, `run_type`, `external_trigger`, estado, try_number y horas de cada tarea; carpetas de log existentes |
| `log_actualizada_*.log`, `log_desactualizada_comprobar_frescura.log` | Logs de Airflow de las tareas |
| `dbt_actualizada_stdout.txt`, `dbt_freshness_desactualizada_stdout.txt`, `dbt_log_desactualizada.txt`, `motivo_error_freshness.txt` | Salida de dbt (`PASS` / `ERROR STALE`) |
| `artifacts_tras_actualizada.txt`, `artifacts_tras_desactualizada.txt` | `sources.json` y `run_results.json` después de cada escenario |
| `resumen_antes_bloqueo.txt`, `resumen_despues_bloqueo.txt` | El resumen se conserva tras el bloqueo |

Respuestas conceptuales: [`respuestas.md`](respuestas.md).

## Ejecuciones oficiales y prueba previa

- **Oficiales** (las que se evalúan, creadas con el botón **Trigger DAG** como indica el enunciado):
  `manual__2026-11-12T12:13:27.061735+00:00` (actualizada) y `manual__2026-11-12T12:15:02.076887+00:00` (desactualizada).
  Son las de `evidencias/`.
- **Prueba previa equivalente** (`evidencias/prueba_cli/`): antes se dispararon las mismas dos ejecuciones por CLI
  (`airflow dags trigger`), con run_id `manual__actualizada_20261112T113547` y `manual__desactualizada_20261112T113710`, y un
  escenario opcional `advertencia` (`manual__2026-11-12T12:03:56+00:00`: WARN por ~18 h, freshness y build en success).
  Dieron los mismos estados y resultados; se repitieron con el botón para seguir el README al pie de la letra. Se conservan
  como referencia y aparecen en la grilla de Airflow como las tres primeras columnas.
