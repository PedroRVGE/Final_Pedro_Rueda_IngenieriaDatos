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

# Escenario 1 (obligatorio): fuente actualizada  -> ejecución manual del DAG
bash scripts/examen.sh scenario actualizada
#   Trigger DAG examen_ventas (run manual__actualizada_20261112T113547)

# Escenario 2 (obligatorio): fuente desactualizada -> NUEVA ejecución, sin limpiar la anterior ni correr build a mano
bash scripts/examen.sh scenario desactualizada
#   Trigger DAG examen_ventas (run manual__desactualizada_20261112T113710)

docker compose stop                      # nunca docker compose down -v
```

Los disparos se hicieron como ejecuciones manuales (`airflow dags trigger examen_ventas --run-id ...`, equivalente al botón
**Trigger DAG**; `run_type = manual`).

## Resultados

### Resumen (`analytics.ventas_diarias`)

| fecha_venta | numero_ventas | unidades_vendidas | ingreso_total |
|---|---:|---:|---:|
| 2026-01-10 | 2 | 3 | 46.00 |
| 2026-01-11 | 3 | 6 | 51.25 |
| 2026-01-12 | 1 | 4 | 12.40 |

Coincide con los resultados esperados del enunciado.

### Escenario 1 — `actualizada` (run `manual__actualizada_20261112T113547`)

| Tarea | Estado | Inicio (UTC) | Fin (UTC) |
|---|---|---|---|
| `comprobar_frescura` | success | 11:36:01 | 11:36:10 |
| `construir_resumen` | success | 11:36:16 | 11:36:24 |

Freshness antes de build; ambos logs con `INICIO dbt` / `FIN dbt`.
Evidencias: `estados_actualizada.txt`, `log_actualizada_*.log`, `resumen_antes_bloqueo.txt`, capturas 01–04.

### Escenario 2 — `desactualizada` (run `manual__desactualizada_20261112T113710`)

| Tarea | Estado | try_number |
|---|---|---|
| `comprobar_frescura` | **failed** | 1 |
| `construir_resumen` | **upstream_failed** (no se ejecutó) | 0 |

- Motivo (salida de dbt): `1 of 1 ERROR STALE freshness of ventas_raw.ventas ... [ERROR STALE]`; `max_loaded_at = 2026-11-11T05:37:09Z`,
  **30.0 h** de antigüedad frente a `error_after` de 24 h (`sources.json`). En Airflow la tarea falla con
  `CalledProcessError: ... dbt source freshness ... returned non-zero exit status 1` (lo propaga `run_dbt`).
- Build no corrió: sin intento (try_number 0), sin carpeta de log ni `INICIO dbt` para esa ejecución, y el último `build`
  registrado en `run_results.json` es el del escenario 1 (`generated_at 2026-11-12T11:36:23Z`).
- **Resumen conservado:** `resumen_antes_bloqueo.txt` y `resumen_despues_bloqueo.txt` son idénticos (diff vacío).

Nota: `run_dbt` lanza dbt como subproceso sin capturar su salida, así que el detalle `ERROR STALE` aparece en la salida del
contenedor y en `dbt.log`, no en el log de la tarea; ambos se guardaron (`dbt_freshness_desactualizada_stdout.txt`,
`dbt_log_desactualizada.txt`).

## Evidencias (`evidencias/`)

| Archivo | Qué demuestra |
|---|---|
| `capturas/01..08-*.png` | Grafo, grilla y logs de las dos ejecuciones obligatorias (ver índice en `capturas/CAPTURAS.md`) |
| `escenario_*.json` | Salida de `scenario` (filas y `max_loaded_at`) |
| `estados_*.txt` | `airflow tasks states-for-dag-run` de cada ejecución |
| `log_actualizada_*.log`, `log_desactualizada_comprobar_frescura.log` | Logs de Airflow de las tareas |
| `dbt_freshness_desactualizada_stdout.txt`, `dbt_log_desactualizada.txt` | Motivo del fallo según dbt (`ERROR STALE`) |
| `artifacts_tras_desactualizada.txt` | `sources.json` (status error, 30 h) y `run_results.json` (último build = escenario 1) |
| `intentos_desactualizada.txt` | try_number de cada tarea en la ejecución bloqueada |
| `resumen_antes_bloqueo.txt`, `resumen_despues_bloqueo.txt` | El resumen se conserva tras el bloqueo |

Respuestas conceptuales: [`respuestas.md`](respuestas.md).
