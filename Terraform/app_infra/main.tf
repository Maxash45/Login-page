terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ----------------------------
# Module: Network
# ----------------------------
locals {
  network = {
    vpc = {
      name = var.project_name
      cidr = var.vpc_cidr
      azs  = var.azs
      public_subnets  = var.public_subnets
      private_subnets = var.private_subnets
      tags = {
        Terraform   = "true"
        Environment = var.environment
      }
    }
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = local.network.vpc.name
  cidr = local.network.vpc.cidr

  azs             = local.network.vpc.azs
  public_subnets  = local.network.vpc.public_subnets
  private_subnets = local.network.vpc.private_subnets

  enable_nat_gateway     = true
  single_nat_gateway     = true
  enable_dns_hostnames   = true
  enable_dns_support     = true
  enable_ipv6            = false
  map_public_ip_on_launch = true

  tags = local.network.vpc.tags
}

# ----------------------------
# Module: Storage
# ----------------------------
locals {
  storage = {
    bucket = {
      name_prefix = "${var.project_name}-bucket-"
      force_destroy = true
    }
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "app_bucket" {
  bucket        = "${local.storage.bucket.name_prefix}${random_id.suffix.hex}"
  force_destroy = local.storage.bucket.force_destroy
}

# ----------------------------
# Module: IAM
# ----------------------------
locals {
  iam = {
    ecs_task_execution_role = {
      name = "${var.project_name}-ecs-execution-role"
    }
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name = local.iam.ecs_task_execution_role.name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Effect = "Allow",
      Sid    = ""
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ----------------------------
# Module: ECR
# ----------------------------
locals {
  ecr = {
    repository = {
      name = "${var.project_name}-repo"
      image_tag_mutability = "MUTABLE"
      force_delete = true
    }
  }
}

resource "aws_ecr_repository" "app" {
  name                 = local.ecr.repository.name
  image_tag_mutability = local.ecr.repository.image_tag_mutability
  force_delete         = local.ecr.repository.force_delete
}

# ----------------------------
# Module: ECS
# ----------------------------
locals {
  ecs = {
    cluster = {
      name = "${var.project_name}-cluster"
    }
    task_definition = {
      family = "${var.project_name}-task"
      cpu    = "256"
      memory = "512"
      container_definitions = [{
        name      = "app"
        image     = "${aws_ecr_repository.app.repository_url}:latest"
        essential = true
        portMappings = [{
          containerPort = 80
          hostPort      = 80
        }]
      }]
    }
    service = {
      name          = "${var.project_name}-service"
      desired_count = 1
    }
  }
}

resource "aws_ecs_cluster" "main" {
  name = local.ecs.cluster.name
}

resource "aws_ecs_task_definition" "app" {
  family                   = local.ecs.task_definition.family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = local.ecs.task_definition.cpu
  memory                   = local.ecs.task_definition.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode(local.ecs.task_definition.container_definitions)
}

# ----------------------------
# Module: Security
# ----------------------------
locals {
  security = {
    ecs_service_sg = {
      name = "${var.project_name}-sg"
      ingress_rules = [{
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }]
      egress_rules = [{
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }]
    }
  }
}

resource "aws_security_group" "ecs_service" {
  name   = local.security.ecs_service_sg.name
  vpc_id = module.vpc.vpc_id

  dynamic "ingress" {
    for_each = local.security.ecs_service_sg.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = local.security.ecs_service_sg.egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
}

# ----------------------------
# ECS Service (depends on all modules)
# ----------------------------
resource "aws_ecs_service" "app" {
  name            = local.ecs.service.name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  launch_type     = "FARGATE"
  desired_count   = local.ecs.service.desired_count

  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.ecs_service.id]
    assign_public_ip = false
  }
}
