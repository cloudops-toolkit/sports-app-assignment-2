output "cluster_endpoint" {
  value = aws_rds_cluster.aurora.endpoint
}

output "rds_instance_id" {
  value = aws_rds_cluster.aurora.endpoint
}

output "reader_endpoint" {
  value = aws_rds_cluster.aurora.reader_endpoint
}

output "cluster_identifier" {
  value = aws_rds_cluster.aurora.cluster_identifier
}

# output "database_name" {
#   value = aws_rds_cluster.aurora.database_name
# }

output "secrets_manager_secret_arn" {
  value = aws_secretsmanager_secret.aurora_credentials.arn
}

output "cloudwatch_log_group_name" {
  value = aws_cloudwatch_log_group.aurora_logs.name
}

output "sns_topic_arn" {
  value = aws_sns_topic.rds_events.arn
}