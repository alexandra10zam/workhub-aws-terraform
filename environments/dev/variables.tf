variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "image_tag" {
  description = "WorkHub image tag to deploy (pushed to the ECR repo created here)"
  type        = string
  default     = "latest"
}

variable "certificate_arn" {
  description = "Optional ACM certificate ARN to enable HTTPS"
  type        = string
  default     = ""
}
