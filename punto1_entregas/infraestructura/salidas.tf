output "bucket" {
  description = "Bucket privado del ejercicio"
  value       = aws_s3_bucket.entregas.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.entregas.arn
}

output "ubicacion_datos" {
  description = "Prefijo de los CSV (cada día en fecha=yyyy-MM-dd/entregas.csv)"
  value       = local.ubicacion_datos
}

output "ubicacion_resultados_athena" {
  value = local.ubicacion_resultados
}

output "base_datos_glue" {
  value = aws_glue_catalog_database.entregas.name
}

output "tabla_glue" {
  value = aws_glue_catalog_table.entregas.name
}

output "tabla_glue_arn" {
  value = aws_glue_catalog_table.entregas.arn
}

output "workgroup_athena" {
  value = aws_athena_workgroup.entregas.name
}

output "region" {
  value = var.region
}
