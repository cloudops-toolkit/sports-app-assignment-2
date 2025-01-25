# ECS Cluster Metrics Dashboard
resource "aws_cloudwatch_dashboard" "ecs_dashboard" {
  dashboard_name = "${var.project}-ecs-dashboard-${var.environment}"
  dashboard_body = jsonencode({
    widgets = [
      {
        type       = "metric",
        x          = 0,
        y          = 0,
        width      = 12,
        height     = 6,
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", var.ecs_cluster_name],
            ["AWS/ECS", "MemoryUtilization", "ClusterName", var.ecs_cluster_name]
          ],
          title = "ECS Cluster Metrics",
          view  = "timeSeries",
          stacked = false
        }
      }
    ]
  })
}

# ALB Request Count Alarm
resource "aws_cloudwatch_metric_alarm" "alb_high_request_count" {
  alarm_name          = "${var.project}-alb-high-requests-${var.environment}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "RequestCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 1000
  alarm_description   = "Triggered when ALB RequestCount exceeds 1000 requests in 1 minute."
  actions_enabled     = true

  dimensions = {
    LoadBalancer = var.alb_name
  }

  alarm_actions = var.alarm_topic_arns
}

# RDS CPU Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "rds_high_cpu" {
  alarm_name          = "${var.project}-rds-high-cpu-${var.environment}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Triggered when RDS CPUUtilization exceeds 80%."
  actions_enabled     = true

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }

  alarm_actions = var.alarm_topic_arns
}

# Redis Memory Usage Alarm
resource "aws_cloudwatch_metric_alarm" "redis_high_memory" {
  alarm_name          = "${var.project}-redis-high-memory-${var.environment}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseMemoryUsagePercentage"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Average"
  threshold           = 75
  alarm_description   = "Triggered when Redis memory usage exceeds 75%."
  actions_enabled     = true

  dimensions = {
    CacheClusterId = var.redis_cluster_id
  }

  alarm_actions = var.alarm_topic_arns
}
