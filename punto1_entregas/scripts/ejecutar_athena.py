"""Ejecuta las sentencias de un archivo .sql en el workgroup del ejercicio y guarda cada resultado como CSV.

Uso (desde punto1_entregas/):
    python scripts/ejecutar_athena.py <etapa> <consultas/archivo.sql> <resultados/.../salida1.csv> [salida2.csv ...]

- Una salida por sentencia, en el mismo orden en que aparecen en el .sql (separadas por ';').
- Usa los nombres del workgroup y la base desde evidencias/outputs.json (terraform output -json).
- Escribe los CSV con encabezado, separador coma, sin comillas y con fin de línea LF (mismo formato que resultados_esperados/).
- Agrega una fila por ejecución a evidencias/ejecuciones_athena.csv: etapa, archivo_sql, id_ejecucion, archivo_resultado.
"""
import csv
import json
import re
import sys
import time
from pathlib import Path

import boto3

RAIZ = Path(__file__).resolve().parents[1]
REGISTRO = RAIZ / "evidencias" / "ejecuciones_athena.csv"


def sentencias(texto: str) -> list[str]:
    sin_comentarios = re.sub(r"--[^\n]*", "", texto)
    return [s.strip() for s in sin_comentarios.split(";") if s.strip()]


def ejecutar(athena, sql: str, workgroup: str, base: str) -> tuple[str, list[list[str]]]:
    qid = athena.start_query_execution(
        QueryString=sql, WorkGroup=workgroup, QueryExecutionContext={"Database": base}
    )["QueryExecutionId"]
    while True:
        estado = athena.get_query_execution(QueryExecutionId=qid)["QueryExecution"]["Status"]
        if estado["State"] in ("SUCCEEDED", "FAILED", "CANCELLED"):
            break
        time.sleep(1)
    if estado["State"] != "SUCCEEDED":
        raise SystemExit(f"Consulta {qid} terminó en {estado['State']}: {estado.get('StateChangeReason')}")
    filas = []
    for pagina in athena.get_paginator("get_query_results").paginate(QueryExecutionId=qid):
        for fila in pagina["ResultSet"]["Rows"]:
            filas.append([c.get("VarCharValue", "") for c in fila["Data"]])
    return qid, filas  # la primera fila es el encabezado


def main() -> None:
    if len(sys.argv) < 4 or sys.argv[1] not in ("inicial", "final"):
        raise SystemExit(__doc__)
    etapa, archivo_sql, salidas = sys.argv[1], sys.argv[2], sys.argv[3:]
    out = {k: v["value"] for k, v in json.loads((RAIZ / "evidencias" / "outputs.json").read_text()).items()}
    athena = boto3.Session(region_name=out["region"]).client("athena")

    consultas = sentencias((RAIZ / archivo_sql).read_text(encoding="utf-8"))
    if len(consultas) != len(salidas):
        raise SystemExit(f"{archivo_sql} tiene {len(consultas)} sentencias y se dieron {len(salidas)} salidas")

    nuevo = not REGISTRO.exists()
    with REGISTRO.open("a", newline="", encoding="utf-8") as reg:
        escritor = csv.writer(reg, lineterminator="\n")
        if nuevo:
            escritor.writerow(["etapa", "archivo_sql", "id_ejecucion", "archivo_resultado"])
        for sql, salida in zip(consultas, salidas):
            qid, filas = ejecutar(athena, sql, out["workgroup_athena"], out["base_datos_glue"])
            destino = RAIZ / salida
            destino.parent.mkdir(parents=True, exist_ok=True)
            with destino.open("w", newline="", encoding="utf-8") as f:
                csv.writer(f, lineterminator="\n").writerows(filas)
            escritor.writerow([etapa, archivo_sql, qid, salida])
            print(f"[{etapa}] {archivo_sql} -> {salida}  id={qid}  ({len(filas) - 1} filas)")
            print(destino.read_text(encoding="utf-8"))


if __name__ == "__main__":
    main()
