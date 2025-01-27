data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  # Use proxy endpoint if provided, otherwise use direct cluster endpoint
  db_host = coalesce(var.rds_proxy_endpoint, var.db_cluster_endpoint)
}

resource "aws_ecs_cluster" "main" {
  name = "${var.project}-cluster-${var.environment}"
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.project}-ecs-task-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# ECS Task Execution Role (existing)
resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.project}-ecs-task-execution-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Task Execution Role policy attachment
resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# RDS Proxy access policy for Task Role
resource "aws_iam_role_policy" "ecs_rds_proxy_access" {
  name = "${var.project}-ecs-rds-proxy-access-${var.environment}"
  role = aws_iam_role.ecs_task_role.id  # Changed to task role

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "rds-db:connect"
        ]
        Resource = [
          var.db_secret_arn,
          "arn:aws:rds-db:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dbuser:*/*"
        ]
      }
    ]
  })
}

# SQS access Task Role
resource "aws_iam_role_policy" "ecs_sqs_access" {
  name = "${var.project}-ecs-sqs-access-${var.environment}"
  role = aws_iam_role.ecs_task_role.id  # Changed to task role

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:CreateQueue",
          "sqs:DeleteQueue",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl",
          "sqs:ListQueues",
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage"
        ]
        Resource = "arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:ListQueues"
        ]
        Resource = "*"
      }
    ]
  })
}

# SSM Parameter access policy for Task Role
resource "aws_iam_role_policy" "task_role_ssm_policy" {
  name = "${var.project}-ecs-ssm-policy-${var.environment}"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter"
        ]
        Resource = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.project}-*-${var.environment}"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_task_execution_ssm" {
  name = "${var.project}-ecs-execution-ssm-policy-${var.environment}"
  role = aws_iam_role.ecs_task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter"
        ]
        Resource = [
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.project}-*-${var.environment}"
        ]
      }
    ]
  })
}

# Add Secrets Manager access if you're using it
resource "aws_iam_role_policy" "ecs_task_execution_secrets" {
  name = "${var.project}-ecs-execution-secrets-policy-${var.environment}"
  role = aws_iam_role.ecs_task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          var.db_secret_arn
        ]
      }
    ]
  })
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project}-app-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn           = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name               = "backend"
      image              = "${var.ecr_repository_url}:backend-latest"
      memory            = 1536
      memoryReservation = 1024
      essential         = true
      
      # Updated command to handle migrations and application startup properly
      command = [
        "/bin/sh", 
        "-c", 
        "npm run db:mig && npm run db:seed && (node ./build/bin/server.js & node ./build/bin/consumers.js & wait)"
      ]
      
      healthCheck = {
        command     = ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:8080/api/healthcheck || exit 1"]
        interval    = 45
        timeout     = 30
        retries     = 5
        startPeriod = 180
      }
      
      portMappings = [{
        containerPort = 8080
        hostPort      = 8080
        protocol      = "tcp"
      }]
      
      environment = [
        {
          name  = "API_DB_PORT"
          value = "5432"
        },
        {
          name  = "ENABLE_DB_LOGGING"
          value = "true"
        },
        {
          name  = "NODE_ENV"
          value = var.environment
        },
        {
          name  = "DB_RETRY_ATTEMPTS"
          value = "5"
        },
        {
          name  = "DB_RETRY_DELAY"
          value = "5000"
        },
        {
          name  = "AWS_SDK_LOAD_CONFIG"
          value = "1"
        },
        {
          name  = "AWS_REGION"
          value = "us-east-1"
        },
        {
          name  = "AWS_SDK_DEBUG"
          value = "true"
        },
        {
          name  = "NODE_OPTIONS"
          value = "--max-old-space-size=1536"
        },
        {
          name  = "DEBUG"
          value = "*"
        },
        {
          name  = "NODE_DEBUG"
          value = "aws*"
        }
      ]
      
      secrets = [
        {
          name      = "SESSION_SECRET"
          valueFrom = "/${var.project}-SESSION-SECRET-${var.environment}"
        },
        {
          name      = "ENCODING_KEY"
          valueFrom = "/${var.project}-ENCODING-KEY-${var.environment}"
        },
        {
          name      = "REDIS_URL"
          valueFrom = "/${var.project}-REDIS-URL-${var.environment}"
        },
        {
          name      = "API_DB_NAME"
          valueFrom = "/${var.project}-API_DB_NAME-${var.environment}"
        },
        {
          name      = "API_DB_HOST"
          valueFrom = "/${var.project}-API_DB_HOST-${var.environment}"
        },
        {
          name      = "API_DB_USERNAME"
          valueFrom = "/${var.project}-API_DB_USERNAME-${var.environment}"
        },
        {
          name      = "API_DB_PASSWORD"
          valueFrom = "/${var.project}-API_DB_PASSWORD-${var.environment}"
        },
        {
          name      = "OPEN_AI_API_SECRET"
          valueFrom = "/${var.project}-OPEN_AI_API_SECRET-${var.environment}"
        }
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"            = "/ecs/${var.project}-${var.environment}"
          "awslogs-region"           = data.aws_region.current.name
          "awslogs-stream-prefix"    = "ecs"
          "mode"                     = "non-blocking"
          "max-buffer-size"          = "25m"
          "awslogs-datetime-format"  = "%Y-%m-%d %H:%M:%S"
        }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project}-${var.environment}"
  retention_in_days = 30

  tags = {
    Name = "${var.project}-ecs-logs-${var.environment}"
  }
}

resource "aws_ecs_service" "app" {
  name            = "${var.project}-service-${var.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 2
  launch_type     = "EC2"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.ecs_security_group_id]
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "backend"
    container_port   = 8080
  }
}