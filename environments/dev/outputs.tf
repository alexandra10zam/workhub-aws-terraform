output "app_url" {
  value = var.certificate_arn == "" ? "http://${module.app.alb_dns_name}" : "https://${module.app.alb_dns_name}"
}

output "ecr_repository_url" {
  description = "Push the WorkHub image here"
  value       = module.app.ecr_repository_url
}

output "ecs_cluster" {
  value = module.app.cluster_name
}

output "ecs_service" {
  value = module.app.service_name
}

output "api_credentials_secret" {
  description = "Read with: aws secretsmanager get-secret-value --secret-id <this>"
  value       = aws_secretsmanager_secret.api.name
}
