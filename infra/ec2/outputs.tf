output "instance_id" {
  description = "ID de la instancia EC2."
  value       = aws_instance.app.id
}

output "public_ip" {
  description = "IP publica de la instancia."
  value       = aws_instance.app.public_ip
}

output "app_url" {
  description = "URL publica esperada de la aplicacion."
  value       = "http://${aws_instance.app.public_ip}:${var.app_port}"
}

output "ssh_command" {
  description = "Comando sugerido para conectarte por SSH."
  value       = "ssh -i ${path.module}/${var.pem_output_path} ubuntu@${aws_instance.app.public_ip}"
}

output "pem_file" {
  description = "Ruta local de la llave PEM generada."
  value       = "${path.module}/${var.pem_output_path}"
}
