output "vpc_id" {
  value = module.vpc.vpc_id
}

output "ecs_cluster_id" {
  value = aws_ecs_cluster.main.id
}

output "s3_bucket_name" {
  value = aws_s3_bucket.app_bucket.bucket
}

output "ecr_repo_url" {
  value = aws_ecr_repository.app.repository_url
}
