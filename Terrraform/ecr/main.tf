resource "aws_ecr_repository" "app" {
  name                 = "${var.project_name}-repo"
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.force_delete
}