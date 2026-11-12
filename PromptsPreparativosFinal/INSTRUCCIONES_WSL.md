# INSTRUCCIONES — Sesión Claude Code en WSL (`~/ing_datos/Final`)

> Pedro copia este archivo a `~/ing_datos/Final` y te dice: "lee INSTRUCCIONES_WSL.md y ejecútalo".
> Ejecuta la **FASE 1** completa ahora y quédate esperando. Pedro pondrá el enunciado en `./enunciado/` (hoy vacía)
> y te avisará: ahí empieza la **FASE 2**.

## Contexto
- Examen final de Ingeniería de Datos (EIA 2026-2), AWS + Terraform. Se permite usar Claude.
- Tu rol: TODO el código, Terraform, AWS CLI, Python, git. La otra sesión (Cowork + extensión de Chrome, en Windows)
  solo toma capturas de la consola de AWS; nunca crea ni borra recursos.
- Pedro te maneja por Remote Control desde el navegador. La terminal queda abierta: si se cae la conexión, sigue ahí.
- Región: **us-east-2**. Perfil AWS: **taller** (usuario IAM PedroRuedaNubeIngData; su región por defecto es us-east-1, así que SIEMPRE forzar AWS_REGION=us-east-2). Tope de gasto: **5 USD**. Toda prueba en la nube termina con destroy + verificación.
- Internet de la universidad: hablar con AWS sí funciona, descargar (pip, npm, conda, terraform init) puede fallar.
  **En el examen se puede descargar si hace falta, pero la meta es no necesitarlo**: todo se descarga en la FASE 1.
- Carpeta de Windows de la otra sesión:
  `WIN="/mnt/c/Users/pedro/Universidad EIA/Semestre 6/Ingenieria De Datos/Final"`
  Ahí solo escribes `CAPTURAS.md` (copia) y lees `ESTADO_COWORK.md`. El enunciado NO lo tomas de ahí: lo lees de tu `./enunciado/`.
- `Tips-Terraform-AWS.md`: errores que otro Claude cometió en el taller anterior. Úsalo SOLO para reconocerlos y evitarlos.
  No es requisito ni fuente de verdad. La única fuente de verdad es el enunciado del examen.

---

## FASE 1 — Preparación (ejecutar ya, con buen internet)

1. **Archivos base.** Crea `./enunciado/` vacía si no existe. Si no está `./Tips-Terraform-AWS.md`, cópialo desde
   `"$WIN/Tips-Terraform-AWS.md"` y léelo.

2. **Herramientas** (sin sudo si se puede; Terraform ya estaba en `~/.local/bin`). Verifica/instala y reporta versiones:
   terraform, aws cli v2, session-manager-plugin, gh, git, make, jq, zip/unzip, conda, docker.
   Comprueba `aws sts get-caller-identity --profile taller`. Si no existe el perfil, PARA y pídele a Pedro que corra
   `aws configure --profile taller` (región us-east-2). Nunca escribas llaves en archivos.
   (Si es AWS Academy, las credenciales vencen por sesión de lab: deja anotado cómo renovarlas.)

3. **Entorno conda `final` (Python 3.12)** — todas las librerías del examen viven aquí:
   - pip dentro del entorno: boto3, pandas, pyarrow, duckdb, psycopg2-binary, redshift_connector, sqlalchemy, pymongo,
     gremlinpython, redis, neo4j, requests, feedparser, python-dotenv, pyspark, awswrangler, pytest, moto[all],
     jupyter, ipykernel, pillow, matplotlib, dbt-core, dbt-redshift, dbt-duckdb.
   - `conda env config vars set AWS_PROFILE=taller AWS_REGION=us-east-2 AWS_DEFAULT_REGION=us-east-2 TF_PLUGIN_CACHE_DIR=$HOME/.terraform.d/plugin-cache`
   - Guarda `requirements.txt` (pip freeze) y `environment.yml`.
   - Respaldo offline: `pip download -r requirements.txt -d .local/wheelhouse` y PRUEBA en un entorno temporal
     `pip install --no-index --find-links .local/wheelhouse -r requirements.txt`; luego bórralo.
   - `.env.example` y `.env` (en .gitignore) solo con NOMBRES de recursos; contraseñas solo en Secrets Manager.

4. **Terraform offline**
   - `plantillas/_providers/versions.tf` con versiones EXACTAS de hashicorp/aws, random, archive, null, local, tls, time;
     `terraform init` y guarda `.terraform.lock.hcl`.
   - `terraform providers mirror ~/.terraform.d/mirror` y `~/.terraformrc` con `plugin_cache_dir` en `~/.terraform.d/plugin-cache`
     y `provider_installation { filesystem_mirror {...} direct {} }`. Nada de cachés en /tmp ni carpetas temporales de Claude.
   - PRUEBA OFFLINE: directorio nuevo + `TF_CLI_CONFIG_FILE` con un rc que SOLO tenga filesystem_mirror → `terraform init` funciona.

5. **Otras descargas** a `.local/descargas`: global-bundle.pem (RDS/DocumentDB), instalador Miniconda Linux x86_64,
   y opcional `docker pull` de mongo, redis, neo4j. (Lo que instala una EC2 con user_data lo descarga AWS, no hay que prepararlo.)

6. **Referencia (solo lectura)** en `referencia/`: clona
   https://github.com/pgil766/Actividad_Aws , https://github.com/pgil766/Taller3_ingData ,
   https://github.com/PedroRVGE/taller2-ing.Datos-Pedro-rueda-y-pablo-Gil , https://github.com/PedroRVGE/Taller-Arquitecturas-de-Datos
   y escribe `referencia/INDICE.md`: patrón reutilizable → archivo (módulos network y ec2-airflow, crear/eliminar.sh,
   verificar_cuenta_limpia.sh, Secrets Manager, túneles SSM, Redshift Data API, Glue/Athena, DocumentDB TLS, Neptune).

7. **Plantillas** en `plantillas/` (main.tf, variables.tf, outputs.tf, un .py de prueba, README corto). Todas pasan
   `terraform init` offline + `terraform validate`. NO se despliegan (salvo la prueba del paso 11):
   a) s3_datalake: zonas raw/trusted/refined, Glue database/tablas, Athena workgroup + resultados; script que sube CSV/JSON/imagen,
      consulta con Athena y lee desde S3 con DuckDB.
   b) redshift_serverless: mínima + límite de RPU, rol para leer S3; Redshift Data API (tabla estrella, COPY, consulta).
   c) dynamodb: on-demand + put_item, get_item, scan, query.
   d) rds_postgres: mínima, contraseña generada en Secrets Manager; carga y consulta.
   e) documentdb: cluster mínimo + acceso SSM/bastión; pymongo con TLS.
   f) ec2_basico: instancia pequeña con SSM; user_data instala miniconda y corre un .py.
   g) glue_spark_job: PySpark raw → parquet en trusted (computación distribuida).
   h) lambda_s3_trigger: Lambda Python que procesa un archivo al llegar a raw.
   Todo con prefijo común y `default_tags` (Proyecto=final, Owner=pedro).

8. **Scripts** en `scripts/`:
   - `verificar_cuenta_limpia.sh` (servicios de las plantillas, us-east-2, por prefijo/tag); `costo_actual.sh` (Cost Explorer).
   - `evidencia.sh <nombre> "<comando>"` → guarda la salida en `evidencias/<nombre>.txt`.
   - `mover_capturas.sh`: toma las imágenes nuevas de la carpeta indicada en `"$WIN/ESTADO_COWORK.md"` (donde caen las capturas
     de Chrome) y las mueve/renombra a `evidencias/` según CAPTURAS.md.
   - `salida_a_imagen.sh <archivo.txt> <salida.png>`: último recurso si no se puede capturar la consola (se aclara en la entrega).

9. **Archivos de proyecto**
   - `CLAUDE.md` con lo esencial de este archivo (fuente de verdad = enunciado; tips solo para evitar errores; región, perfil,
     prefijo, tags, secretos, tamaños mínimos, evidencias, destroy + verificación; descargas permitidas pero evitadas: si falta algo, avisar).
   - `.gitignore`: `*.tfstate*`, `.terraform/`, `*.tfplan`, `.env`, `.local/`, `*accessKeys*.csv`, `*credentials*.csv`.
   - `.claude/settings.json`: permitir terraform init/plan/validate/fmt/output/show/apply, aws, python, pytest,
     ls/cat/cp/mv/mkdir, `bash scripts/*.sh` (las aprobaciones llegan por Remote Control y con mal internet son lentas).
     Que SIGAN pidiendo confirmación: terraform destroy, rm, `aws ... delete*`, git push --force.
   - Formato de `evidencias/CAPTURAS.md` (debe servirle a una PERSONA si la extensión no puede capturar):
     ```
     ## NN-descripcion.png
     - Punto del enunciado que demuestra:
     - Servicio y recurso (nombre exacto / ARN):
     - URL directa de la consola (us-east-2):
     - Clics desde esa URL:
     - Qué TIENE que verse (campos/valores exactos, estado, hora):
     - Comando CLI equivalente:
     - [ ] tomada
     ```
     Cada vez que lo actualices, cópialo a `"$WIN/CAPTURAS.md"`.

10. **Repo de entrega (prueba de push).** Con gh (si no hay login, pide un token a Pedro; el login por navegador falla desde WSL)
    crea el repo **público** `Final_Pedro_Rueda_IngenieriaDatos`, clónalo en `entrega/`, pon `.gitignore` y README mínimo
    ANTES del primer commit, revisa que no haya llaves ni tfstate, commit + push y muestra la URL.
    Pregunta a Pedro si quiere quitar la atribución de Claude en los commits. Solo `entrega/` se entrega.

11. **Prueba real (barata).** Despliega solo `plantillas/s3_datalake`, sube datos, consulta con Athena y DuckDB, guarda evidencias,
    escribe CAPTURAS.md (y su copia en $WIN). Dile a Pedro que pruebe las capturas con la otra sesión y ESPERA su "listo".
    Prueba `mover_capturas.sh` con esas capturas. Luego destroy + `verificar_cuenta_limpia.sh`. Reporta tiempo y costo.

12. **Cierre de FASE 1.** Escribe `ESTADO_WSL.md`: checklist de lo listo, lo que NO quedó offline y cómo renovar credenciales.
    Dile a Pedro: "FASE 1 lista, esperando el enunciado".

---

## FASE 2 — Examen (cuando Pedro avise que el enunciado está en `./enunciado/`)

1. Verifica `aws sts get-caller-identity` (si es AWS Academy, pide credenciales nuevas).
2. Lee el enunciado completo. Es la ÚNICA fuente de verdad: si choca con plantillas, referencia o tips, manda el enunciado.
   Haz un plan corto: punto → servicios → plantilla a reutilizar → entregable → evidencias. Señala ambigüedades. **Espera el OK.**
3. Antes de desplegar, escribe `evidencias/CAPTURAS.md` completo y cópialo a `$WIN`. Verifica que cada escenario pedido produzca un
   cambio visible antes de capturarlo.
4. Código entregable en `entrega/`, commits por punto. Primero usa lo preparado (conda `final`, mirror, wheelhouse); si falta algo,
   avisa a Pedro y luego descarga.
5. Salidas importantes con `scripts/evidencia.sh`. Cuando Pedro diga "mueve las capturas", usa `mover_capturas.sh` y marca en CAPTURAS.md.
6. Evita los errores de `Tips-Terraform-AWS.md` (fileset sobre todo el módulo, filtros que excluyen carpetas sin avisar, cachés en /tmp,
   DAGs activos durante destroy, destroy sin verificar, QuickSight sin cancelar...).
7. Antes del destroy: compara CAPTURAS.md y evidencias/ contra el enunciado y di qué falta. Luego push final, destroy,
   `verificar_cuenta_limpia.sh` y `costo_actual.sh`.
