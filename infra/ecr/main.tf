locals {
  effective_repository_name = trimspace(var.repository_name) != "" ? var.repository_name : var.project_name

  common_tags = merge(
    {
      Name    = local.effective_repository_name
      Project = var.project_name
      Managed = "terraform"
    },
    var.tags
  )
}

resource "aws_ecr_repository" "app" {
  name                 = local.effective_repository_name
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = local.common_tags
}

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Conservar solo las imagenes etiquetadas mas recientes"
        selection = {
          tagStatus   = "tagged"
          countType   = "imageCountMoreThan"
          countNumber = var.keep_tagged_images
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Conservar solo unas pocas imagenes sin tag"
        selection = {
          tagStatus   = "untagged"
          countType   = "imageCountMoreThan"
          countNumber = var.keep_untagged_images
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
