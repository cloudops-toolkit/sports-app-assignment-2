output "vpc_endpoint_sg_id" {
  value = aws_security_group.vpc_endpoints.id
}

output "endpoints" {
  value = {
    interface = aws_vpc_endpoint.interface_endpoints
    s3       = aws_vpc_endpoint.s3
    dynamodb = aws_vpc_endpoint.dynamodb
  }
}