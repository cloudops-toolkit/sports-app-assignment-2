resource "aws_elasticache_subnet_group" "redis" {
  name        = "${var.project}-redis-subnet-${var.environment}"
  description = "Subnet group for Redis"
  subnet_ids  = var.private_subnet_ids
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.project}-redis-${var.environment}"
  engine              = "redis"
  node_type           = "cache.t3.micro"
  num_cache_nodes     = 1
  port                = 6379
  
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids   = [var.security_group_id]

  tags = {
    Name = "${var.project}-redis-${var.environment}"
  }
}