# CAPTURAS — Examen final, punto 2 (Ventas, Airflow local) — EJECUCIONES OFICIALES (botón Trigger DAG)

> **Nueva tanda.** Las capturas anteriores (Run ID `manual__actualizada_...` / `manual__desactualizada_...`) eran de la prueba por CLI
> y ya están guardadas: NO borrarlas ni sobrescribirlas. Guardar las nuevas con los MISMOS nombres de abajo en `capturas_cowork\oficial\`.
> En la grilla ahora hay 5 columnas: las dos ÚLTIMAS (derecha) son las oficiales: verde (actualizada) y roja/naranja (desactualizada).

> Airflow en **http://localhost:8080** (usuario `estudiante`, contraseña `examen-local`). No es AWS: es Docker en el PC de Pedro.
> Solo mirar: **NO pulsar Trigger, Clear, Mark success/failed ni pausar el DAG.** Si pide login, iniciar sesión con esos datos.
> Las ejecuciones ya están hechas; solo hay que fotografiarlas. Si algo no coincide con "Qué TIENE que verse", avisar a Pedro.
> El punto 1 (AWS) no requiere capturas de consola: sus evidencias son archivos de texto.

## 01-ventas-actualizada-grafo.png
- Punto del enunciado que demuestra: punto 2, escenario 1 "fuente actualizada": freshness y build en success, freshness antes de build
- Servicio y recurso (nombre exacto / ARN): Airflow, DAG `examen_ventas`, ejecución `manual__2026-11-12T12:13:27.061735+00:00`
- URL directa: http://localhost:8080/dags/examen_ventas/grid?dag_run_id=manual__2026-11-12T12%3A13%3A27.061735%2B00%3A00&tab=graph
- Clics desde esa URL: ninguno (pestaña Graph de esa ejecución). Si no abre el run, clic en la barra verde de la izquierda en la grilla.
- Qué TIENE que verse: el **Run ID `manual__2026-11-12T12:13:27.061735+00:00`** arriba; dos cajas `comprobar_frescura` → `construir_resumen` unidas por una flecha, **ambas verdes (success)**
- Comando CLI equivalente: `docker compose exec airflow airflow tasks states-for-dag-run examen_ventas manual__2026-11-12T12:13:27.061735+00:00`
- [x] tomada → evidencias/capturas/01-ventas-actualizada-grafo*.jpg

## 02-ventas-actualizada-grilla.png
- Punto del enunciado que demuestra: punto 2, escenario 1: estados y orden de ejecución
- Servicio y recurso (nombre exacto / ARN): Airflow, DAG `examen_ventas`, ejecución `manual__2026-11-12T12:13:27.061735+00:00`
- URL directa: http://localhost:8080/dags/examen_ventas/grid?dag_run_id=manual__2026-11-12T12%3A13%3A27.061735%2B00%3A00&tab=details
- Clics desde esa URL: ninguno (vista Grid con el panel Details del run a la derecha)
- Qué TIENE que verse: Run ID `manual__2026-11-12T12:13:27.061735+00:00`, **State success**, Run type manual; en la grilla la columna de ese run con 2 cuadros verdes
- Comando CLI equivalente: igual que 01
- [x] tomada → evidencias/capturas/02-ventas-actualizada-grilla*.jpg

## 03-ventas-actualizada-log-freshness.png
- Punto del enunciado que demuestra: punto 2, escenario 1: log de la tarea nueva con INICIO dbt / FIN dbt
- Servicio y recurso (nombre exacto / ARN): tarea `comprobar_frescura` de `manual__2026-11-12T12:13:27.061735+00:00`
- URL directa: http://localhost:8080/dags/examen_ventas/grid?dag_run_id=manual__2026-11-12T12%3A13%3A27.061735%2B00%3A00&task_id=comprobar_frescura&tab=logs
- Clics desde esa URL: ninguno
- Qué TIENE que verse: líneas `INICIO dbt ['source', 'freshness']`, `FIN dbt ['source', 'freshness']` y `Marking task as SUCCESS`
- Comando CLI equivalente: `entrega/punto2_ventas/evidencias/log_actualizada_comprobar_frescura.log`
- [x] tomada → evidencias/capturas/03-ventas-actualizada-log-freshness*.jpg

## 04-ventas-actualizada-log-build.png
- Punto del enunciado que demuestra: punto 2, escenario 1: log del build
- Servicio y recurso (nombre exacto / ARN): tarea `construir_resumen` de `manual__2026-11-12T12:13:27.061735+00:00`
- URL directa: http://localhost:8080/dags/examen_ventas/grid?dag_run_id=manual__2026-11-12T12%3A13%3A27.061735%2B00%3A00&task_id=construir_resumen&tab=logs
- Clics desde esa URL: ninguno
- Qué TIENE que verse: `INICIO dbt ['build']`, `FIN dbt ['build']`, `Marking task as SUCCESS`
- Comando CLI equivalente: `entrega/punto2_ventas/evidencias/log_actualizada_construir_resumen.log`
- [x] tomada → evidencias/capturas/04-ventas-actualizada-log-build*.jpg

## 05-ventas-desactualizada-grafo.png
- Punto del enunciado que demuestra: punto 2, escenario 2 "fuente desactualizada": freshness failed y build upstream_failed (bloqueado)
- Servicio y recurso (nombre exacto / ARN): Airflow, DAG `examen_ventas`, ejecución NUEVA `manual__2026-11-12T12:15:02.076887+00:00`
- URL directa: http://localhost:8080/dags/examen_ventas/grid?dag_run_id=manual__2026-11-12T12%3A15%3A02.076887%2B00%3A00&tab=graph
- Clics desde esa URL: ninguno
- Qué TIENE que verse: **Run ID `manual__2026-11-12T12:15:02.076887+00:00`**; `comprobar_frescura` **roja (failed)** y `construir_resumen` **naranja (upstream_failed)**
- Comando CLI equivalente: `docker compose exec airflow airflow tasks states-for-dag-run examen_ventas manual__2026-11-12T12:15:02.076887+00:00`
- [x] tomada → evidencias/capturas/05-ventas-desactualizada-grafo*.jpg

## 06-ventas-desactualizada-grilla.png
- Punto del enunciado que demuestra: punto 2, escenario 2: es una ejecución nueva distinta de la anterior, con sus estados
- Servicio y recurso (nombre exacto / ARN): DAG `examen_ventas`, ejecuciones `manual__2026-11-12T12:13:27.061735+00:00` y `manual__2026-11-12T12:15:02.076887+00:00`
- URL directa: http://localhost:8080/dags/examen_ventas/grid?dag_run_id=manual__2026-11-12T12%3A15%3A02.076887%2B00%3A00&tab=details
- Clics desde esa URL: ninguno
- Qué TIENE que verse: en la grilla las **dos últimas columnas**: verde (oficial actualizada) y roja/naranja (oficial desactualizada); panel Details con Run ID `manual__2026-11-12T12:15:02.076887+00:00` y **State failed**
- Comando CLI equivalente: `airflow dags list-runs -d examen_ventas`
- [x] tomada → evidencias/capturas/06-ventas-desactualizada-grilla*.jpg

## 07-ventas-desactualizada-log-freshness.png
- Punto del enunciado que demuestra: punto 2, escenario 2: log de freshness que muestra el motivo del error
- Servicio y recurso (nombre exacto / ARN): tarea `comprobar_frescura` de `manual__2026-11-12T12:15:02.076887+00:00`
- URL directa: http://localhost:8080/dags/examen_ventas/grid?dag_run_id=manual__2026-11-12T12%3A15%3A02.076887%2B00%3A00&task_id=comprobar_frescura&tab=logs
- Clics desde esa URL: ninguno; si el texto es largo, bajar hasta el final (usar `_parte2` si hace falta otra captura)
- Qué TIENE que verse: `INICIO dbt ['source', 'freshness']`, `ERROR - Task failed with exception`, `CalledProcessError ... 'source', 'freshness' ... returned non-zero exit status 1`, `Marking task as FAILED` y **NO** debe aparecer `FIN dbt`
- Comando CLI equivalente: `entrega/punto2_ventas/evidencias/log_desactualizada_comprobar_frescura.log` (el detalle `ERROR STALE freshness of ventas_raw.ventas` está en `dbt_freshness_desactualizada_stdout.txt`)
- [x] tomada → evidencias/capturas/07-ventas-desactualizada-log-freshness*.jpg

## 08-ventas-desactualizada-build-sin-ejecutar.png
- Punto del enunciado que demuestra: punto 2, escenario 2: build no se ejecutó (sin intento, sin INICIO dbt)
- Servicio y recurso (nombre exacto / ARN): tarea `construir_resumen` de `manual__2026-11-12T12:15:02.076887+00:00`
- URL directa: http://localhost:8080/dags/examen_ventas/grid?dag_run_id=manual__2026-11-12T12%3A15%3A02.076887%2B00%3A00&task_id=construir_resumen&tab=details
- Clics desde esa URL: ninguno (pestaña Details de la tarea)
- Qué TIENE que verse: Status **upstream_failed**, Try Number **0** (o sin intentos) y sin pestaña de log con contenido / sin `INICIO dbt`
- Comando CLI equivalente: `entrega/punto2_ventas/evidencias/intentos_desactualizada.txt`
- [x] tomada → evidencias/capturas/08-ventas-desactualizada-build-sin-ejecutar*.jpg
