output "vpc_id" {
  value = module.app_infra.vpc_id
}

output "public_subnets" {
  value = module.app_infra.public_subnets
}

output "private_subnets" {
  value = module.app_infra.private_subnets
}

output "ecs_cluster_name" {
  value = module.app_infra.ecs_cluster_name
}

output "ecr_repo_url" {
  value = module.app_infra.ecr_repo_url
}

output "s3_bucket_name" {
  value = module.app_infra.s3_bucket_name
}
