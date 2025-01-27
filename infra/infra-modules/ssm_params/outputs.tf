output "ssm_parameter_arns" {
  value = aws_ssm_parameter.app_parameters.arn
}