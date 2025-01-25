data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# Get SSM parameters for container environment variables
data "aws_ssm_parameter" "app_params" {
  for_each = toset([
    "${var.project}-SESSION-SECRET-${var.environment}",
    "${var.project}-ENCODING-KEY-${var.environment}",
    "${var.project}-NODE_ENV-${var.environment}",
    "${var.project}-API_DB_NAME-${var.environment}",
    "${var.project}-API_DB_HOST-${var.environment}",
    "${var.project}-API_DB_USERNAME-${var.environment}",
    "${var.project}-API_DB_PASSWORD-${var.environment}",
    "${var.project}-API_DB_PORT-${var.environment}",
    "${var.project}-REDIS-URL-${var.environment}"
  ])
  name = each.value
}

# Create ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project}-cluster-${var.environment}"
}

# Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project}-app-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = 256  # 0.25 vCPU
  memory                   = 512  # 512MB
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn           = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = "${var.ecr_repository_url}:${var.image_tag}"
      cpu       = 256
      memory    = 512
      essential = true
      
      portMappings = [{
        containerPort = var.container_port
        hostPort      = var.container_port
        protocol      = "tcp"
      }]
      
      environment = [
        {
          name  = "NODE_ENV"
          value = data.aws_ssm_parameter.app_params["${var.project}-NODE_ENV-${var.environment}"].value
        },
        {
          name  = "API_DB_NAME"
          value = data.aws_ssm_parameter.app_params["${var.project}-API_DB_NAME-${var.environment}"].value
        },
        {
          name  = "API_DB_HOST"
          value = data.aws_ssm_parameter.app_params["${var.project}-API_DB_HOST-${var.environment}"].value
        },
        {
          name  = "API_DB_PORT"
          value = data.aws_ssm_parameter.app_params["${var.project}-API_DB_PORT-${var.environment}"].value
        },
        {
          name  = "REDIS_URL"
          value = data.aws_ssm_parameter.app_params["${var.project}-REDIS-URL-${var.environment}"].value
        }
      ]
      
      secrets = [
        {
          name      = "SESSION_SECRET"
          valueFrom = data.aws_ssm_parameter.app_params["${var.project}-SESSION-SECRET-${var.environment}"].arn
        },
        {
          name      = "ENCODING_KEY"
          valueFrom = data.aws_ssm_parameter.app_params["${var.project}-ENCODING-KEY-${var.environment}"].arn
        },
        {
          name      = "API_DB_USERNAME"
          valueFrom = data.aws_ssm_parameter.app_params["${var.project}-API_DB_USERNAME-${var.environment}"].arn
        },
        {
          name      = "API_DB_PASSWORD"
          valueFrom = data.aws_ssm_parameter.app_params["${var.project}-API_DB_PASSWORD-${var.environment}"].arn
        }
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.project}-${var.environment}"
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "app" {
  name            = "${var.project}-service-${var.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1  # For demo purposes, just run one instance
  launch_type     = "EC2"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.ecs_security_group_id]
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "app"
    container_port   = var.container_port
  }
}