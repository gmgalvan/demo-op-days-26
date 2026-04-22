variable "aws_region" {
  description = "Region de AWS."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre base para los recursos."
  type        = string
  default     = "hola-microservicio"
}

variable "instance_type" {
  description = "Tipo de instancia EC2."
  type        = string
  default     = "t3.micro"
}

variable "ssh_cidr_blocks" {
  description = "CIDRs permitidos para SSH."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "app_cidr_blocks" {
  description = "CIDRs permitidos para acceder a la app."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "app_port" {
  description = "Puerto donde correra la aplicacion."
  type        = number
  default     = 8080
}

variable "public_key_name" {
  description = "Nombre del key pair en AWS."
  type        = string
  default     = "hola-microservicio-key"
}

variable "pem_output_path" {
  description = "Ruta local donde Terraform guardara la llave privada PEM."
  type        = string
  default     = "keys/hola-microservicio.pem"
}
