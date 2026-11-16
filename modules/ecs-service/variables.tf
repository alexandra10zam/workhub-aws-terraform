variable "name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  description = "Subnets for the internet-facing ALB"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Subnets for the Fargate tasks"
  type        = list(string)
}

variable "app_security_group_id" {
  description = "Security group attached to the tasks (also whitelisted by the database)"
  type        = string
}

variable "image_tag" {
  description = "Tag of the image in the ECR repository created by this module"
  type        = string
  default     = "latest"
}

variable "container_port" {
  type    = number
  default = 8080
}

variable "cpu" {
  description = "Fargate task CPU units (1024 = 1 vCPU)"
  type        = number
  default     = 512
}

variable "memory" {
  description = "Fargate task memory in MiB"
  type        = number
  default     = 1024
}

variable "desired_count" {
  type    = number
  default = 2
}

variable "min_count" {
  type    = number
  default = 2
}

variable "max_count" {
  type    = number
  default = 6
}

variable "cpu_target_percent" {
  description = "Target average CPU for target-tracking autoscaling"
  type        = number
  default     = 60
}

variable "environment" {
  description = "Plain (non-secret) environment variables for the container"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Container env var name => Secrets Manager ARN (optionally with :json-key::)"
  type        = map(string)
  default     = {}
}

variable "secret_arns_to_read" {
  description = "Secret ARNs the task execution role may read"
  type        = list(string)
  default     = []
}

variable "certificate_arn" {
  description = "ACM certificate for HTTPS. Empty = plain HTTP listener (dev only)"
  type        = string
  default     = ""
}

variable "log_retention_days" {
  type    = number
  default = 14
}
