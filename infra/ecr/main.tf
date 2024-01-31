resource "aws_ecr_repository" "container_repo" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
  force_delete = var.force_delete_ecr
}

resource "aws_ecr_lifecycle_policy" "repo_lifecycle_policy" {
  repository = aws_ecr_repository.container_repo.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire images older than 30 days"
        selection    = {
          tagStatus = "untagged"
          countType = "sinceImagePushed"
          countUnit = "days"
          countNumber = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
