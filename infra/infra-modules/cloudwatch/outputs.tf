output "ecs_dashboard_name" {
  value = aws_cloudwatch_dashboard.ecs_dashboard.dashboard_name
}

output "alb_alarm_name" {
  value = aws_cloudwatch_metric_alarm.alb_high_request_count.alarm_name
}

output "rds_alarm_name" {
  value = aws_cloudwatch_metric_alarm.rds_high_cpu.alarm_name
}

output "redis_alarm_name" {
  value = aws_cloudwatch_metric_alarm.redis_high_memory.alarm_name
}
