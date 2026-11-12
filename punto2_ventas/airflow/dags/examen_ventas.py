from datetime import datetime, timezone

from airflow import DAG
from airflow.operators.python import PythonOperator
from runtime import run_dbt

with DAG(
    dag_id="examen_ventas",
    start_date=datetime(2026, 1, 1, tzinfo=timezone.utc),
    schedule=None,
    catchup=False,
    max_active_runs=1,
    max_active_tasks=1,
    default_args={"retries": 0},
    tags=["examen"],
) as dag:
    # Control de actualidad de la fuente antes de reconstruir el resumen.
    # `dbt source freshness` sale con 0 si pasa o solo advierte (> 12 h) y con error si supera 24 h;
    # run_dbt propaga ese error (check=True), la tarea queda failed y construir_resumen no se ejecuta
    # (regla predeterminada all_success -> upstream_failed). Así se conserva el resumen anterior.
    comprobar_frescura = PythonOperator(
        task_id="comprobar_frescura",
        python_callable=run_dbt,
        op_args=[["source", "freshness"]],
    )

    construir_resumen = PythonOperator(
        task_id="construir_resumen",
        python_callable=run_dbt,
        op_args=[["build"]],
    )

    comprobar_frescura >> construir_resumen
