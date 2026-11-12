# Final — Ingeniería de Datos (EIA 2026-2)

Pedro Rueda. Examen final.

| Punto | Enunciado | Carpeta | Tecnología |
|---|---|---|---|
| 1 (3.0) | [DE-Final-Entregas](https://github.com/smm-0216/DE-Final-Entregas) | [`punto1_entregas/`](punto1_entregas/) | AWS us-east-2: S3 + Glue Data Catalog con partition projection + Athena, con Terraform |
| 2 (2.0) | [DE-Final-Ventas](https://github.com/smm-0216/DE-Final-Ventas) | [`punto2_ventas/`](punto2_ventas/) | Local (Docker del docente): dbt source freshness + Airflow |

Cada carpeta tiene su `README.md` con prerrequisitos, pasos reproducibles, evidencias y un `respuestas.md`.
`punto1_entregas/` sigue exactamente la estructura de entrega pedida en su enunciado.

## Uso de IA

El examen se desarrolló con Claude Code (Anthropic) y Claude Cowork. Los hilos se adjuntan en [`chat_ia/`](chat_ia/) y las
instrucciones con las que se prepararon ambas sesiones en [`PromptsPreparativosFinal/`](PromptsPreparativosFinal/).

No se versionan credenciales, estado de Terraform (`*.tfstate`), planes ni la carpeta `.terraform/`.
