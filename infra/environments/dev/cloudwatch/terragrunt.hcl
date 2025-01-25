include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../infra-modules/cloudwatch"
}

dependency "ecs" {
  config_path = "../ecs"
  mock_outputs = {
    cluster_name = "ecs-cluster-dev"
  }
}

dependency "alb" {
  config_path = "../alb"
  mock_outputs = {
    alb_name = "app-alb-dev"
  }
}

dependency "rds" {
  config_path = "../rds"
  mock_outputs = {
    rds_instance_id = "rds-instance-dev"
  }
}

dependency "redis" {
  config_path = "../redis"
  mock_outputs = {
    redis_cluster_id = "redis-cluster-dev"
  }
}

inputs = {
  ecs_cluster_name = dependency.ecs.outputs.cluster_name
  alb_name         = dependency.alb.outputs.alb_name
  rds_instance_id  = dependency.rds.outputs.rds_instance_id
  redis_cluster_id = dependency.redis.outputs.redis_cluster_id
  alarm_topic_arns = ["arn:aws:sns:us-east-1:123456789012:dev-alerts"]
}