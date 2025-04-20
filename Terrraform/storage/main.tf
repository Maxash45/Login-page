resource "aws_s3_bucket" "app_bucket" {
  bucket        = "${var.project_name}-bucket-${random_id.suffix.hex}"
  force_destroy = var.force_destroy
}

resource "random_id" "suffix" {
  byte_length = 4
}