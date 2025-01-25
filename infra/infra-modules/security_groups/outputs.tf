output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "ecs_sg_id" {
  value = aws_security_group.ecs.id
}

output "rds_sg_id" {
  value = aws_security_group.rds.id
}

output "bastion_sg_id" {
  value = aws_security_group.bastion.id
}

output "rds_proxy_sg_id" {
  value = aws_security_group.rds_proxy.id
}

output "redis_sg_id" {
  value = aws_security_group.redis.id
}