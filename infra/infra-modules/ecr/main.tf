resource "aws_ecr_repository" "app" {
  name = "${var.project}-app-${var.environment}"
  
  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = true
}