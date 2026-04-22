variable "aws_region" {
  description = "Region de AWS."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre base del proyecto."
  type        = string
  default     = "hola-microservicio"
}

variable "repository_name" {
  description = "Nombre del repositorio ECR. Si no se define, usa project_name."
  type        = string
  default     = ""
}

variable "image_tag_mutability" {
  description = "Mutabilidad de tags en ECR."
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability debe ser MUTABLE o IMMUTABLE."
  }
}

variable "scan_on_push" {
  description = "Activa escaneo automatico de vulnerabilidades al subir una imagen."
  type        = bool
  default     = true
}

variable "keep_tagged_images" {
  description = "Cantidad de imagenes etiquetadas que se conservaran."
  type        = number
  default     = 10
}

variable "keep_untagged_images" {
  description = "Cantidad de imagenes sin tag que se conservaran."
  type        = number
  default     = 3
}

variable "tags" {
  description = "Tags adicionales para los recursos."
  type        = map(string)
  default     = {}
}
