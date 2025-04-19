# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
  }
}

# Subnets (example for public, need similar for private)
resource "aws_subnet" "public" {
  count             = length(var.public_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.azs[count.index]
  tags = {
    Name = "${var.project_name}-${var.environment}-public-${count.index}"
  }
}

# ECS Cluster (example)
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}-cluster"
}

# ECR Repository (example)
resource "aws_ecr_repository" "app" {
  name = "${var.project_name}-${var.environment}-app"
}

# S3 Bucket (example)
resource "aws_s3_bucket" "app_bucket" {
  bucket = "${var.project_name}-${var.environment}-app-bucket"
}
