output "repository_name" {
  description = "Nombre del repositorio ECR."
  value       = aws_ecr_repository.app.name
}

output "repository_url" {
  description = "URL del repositorio ECR."
  value       = aws_ecr_repository.app.repository_url
}

output "registry_id" {
  description = "ID del registry de ECR."
  value       = aws_ecr_repository.app.registry_id
}
