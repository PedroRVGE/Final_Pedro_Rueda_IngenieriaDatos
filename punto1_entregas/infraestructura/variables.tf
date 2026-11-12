variable "region" {
  description = "Región de AWS del ejercicio"
  type        = string
  default     = "us-east-2"
}

variable "perfil_aws" {
  description = "Perfil de AWS CLI con permisos sobre S3, Glue y Athena"
  type        = string
  default     = "taller"
}

variable "nombre_bucket" {
  description = "Nombre global y disponible del bucket privado del ejercicio"
  type        = string
  default     = "final-entregas-pedro-rueda-466494951615"
}

variable "prefijo_datos" {
  description = "Prefijo de los CSV de entrada"
  type        = string
  default     = "entregas"
}

variable "prefijo_resultados" {
  description = "Prefijo donde Athena escribe los resultados"
  type        = string
  default     = "resultados-athena"
}

variable "nombre_base_datos" {
  description = "Base de datos de Glue Data Catalog"
  type        = string
  default     = "final_entregas_db"
}

variable "nombre_tabla" {
  description = "Tabla externa de intentos de entrega"
  type        = string
  default     = "entregas"
}

variable "nombre_workgroup" {
  description = "Workgroup de Athena del ejercicio"
  type        = string
  default     = "final-entregas-wg"
}

variable "fecha_inicial" {
  description = "Primer día proyectado (yyyy-MM-dd, incluido)"
  type        = string
  default     = "2026-10-01"
}

variable "fecha_final" {
  description = "Último día proyectado (yyyy-MM-dd, incluido)"
  type        = string
  default     = "2026-10-03"
}
