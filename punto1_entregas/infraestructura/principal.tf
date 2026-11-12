# Punto 1 — Entregas: S3 + Glue Data Catalog (tabla externa con partition projection) + Athena.
# No se crean particiones individuales: Athena calcula fecha y ubicación con las propiedades projection.*.

terraform {
  required_version = ">= 1.9.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.72.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.perfil_aws

  default_tags {
    tags = {
      Proyecto = "final"
      Owner    = "pedro"
      Modulo   = "punto1-entregas"
    }
  }
}

# ---------------------------------------------------------------- S3 (privado)
resource "aws_s3_bucket" "entregas" {
  bucket        = var.nombre_bucket
  force_destroy = true # permite que terraform destroy elimine también datos y resultados de Athena
}

resource "aws_s3_bucket_public_access_block" "entregas" {
  bucket                  = aws_s3_bucket.entregas.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "entregas" {
  bucket = aws_s3_bucket.entregas.id
  rule {
    object_ownership = "BucketOwnerEnforced" # sin ACL: el acceso lo define solo IAM
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "entregas" {
  bucket = aws_s3_bucket.entregas.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Los prefijos entregas/ y resultados-athena/ son parte de las claves de los objetos: no se crean "carpetas".
locals {
  ubicacion_datos      = "s3://${aws_s3_bucket.entregas.bucket}/${var.prefijo_datos}/"
  ubicacion_resultados = "s3://${aws_s3_bucket.entregas.bucket}/${var.prefijo_resultados}/"
}

# ---------------------------------------------------------------- Glue Data Catalog
resource "aws_glue_catalog_database" "entregas" {
  name        = var.nombre_base_datos
  description = "Catalogo del ejercicio de intentos de entrega (examen final)"
}

resource "aws_glue_catalog_table" "entregas" {
  name          = var.nombre_tabla
  database_name = aws_glue_catalog_database.entregas.name
  table_type    = "EXTERNAL_TABLE"
  description   = "Intentos de entrega en CSV, particionados por carpeta fecha=yyyy-MM-dd con partition projection"

  parameters = {
    "EXTERNAL"               = "TRUE"
    "classification"         = "csv"
    "skip.header.line.count" = "1" # omite el encabezado de cada archivo

    # Partition projection: Athena calcula las particiones al consultar (sin crawlers ni ADD PARTITION).
    "projection.enabled"             = "true"
    "projection.fecha.type"          = "date"
    "projection.fecha.format"        = "yyyy-MM-dd"
    "projection.fecha.range"         = "${var.fecha_inicial},${var.fecha_final}" # ambos extremos incluidos
    "projection.fecha.interval"      = "1"
    "projection.fecha.interval.unit" = "DAYS"
    # Prefijo de cada partición (termina en /); el objeto es <prefijo>entregas.csv.
    # $${fecha} es la sintaxis de Terraform para escribir literalmente ${fecha} (lo reemplaza Athena).
    "storage.location.template" = "${local.ubicacion_datos}fecha=$${fecha}/"
  }

  # fecha NO es columna del CSV: es la clave de partición, de tipo texto.
  partition_keys {
    name    = "fecha"
    type    = "string"
    comment = "Fecha tomada de la carpeta fecha=yyyy-MM-dd"
  }

  storage_descriptor {
    location      = local.ubicacion_datos
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      name                  = "csv-coma"
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
      parameters = {
        "field.delim"          = ","
        "serialization.format" = ","
      }
    }

    # Las cinco columnas del diccionario, en el orden del encabezado.
    columns {
      name    = "id_envio"
      type    = "string"
      comment = "Identificador unico del envio (texto)"
    }
    columns {
      name    = "ciudad"
      type    = "string"
      comment = "Ciudad del intento"
    }
    columns {
      name    = "transportadora"
      type    = "string"
      comment = "Transportadora responsable"
    }
    columns {
      name    = "estado"
      type    = "string"
      comment = "entregado | destinatario_ausente | direccion_incorrecta"
    }
    columns {
      name    = "duracion_minutos"
      type    = "int"
      comment = "Positiva si entregado, 0 si fallido"
    }
  }
}

# ---------------------------------------------------------------- Athena
resource "aws_athena_workgroup" "entregas" {
  name          = var.nombre_workgroup
  description   = "Consultas del ejercicio de entregas"
  force_destroy = true

  configuration {
    enforce_workgroup_configuration    = true # todas las consultas escriben en resultados-athena/
    publish_cloudwatch_metrics_enabled = false
    bytes_scanned_cutoff_per_query     = 104857600 # 100 MB: tope de costo por consulta

    result_configuration {
      output_location = local.ubicacion_resultados
      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }
}
