variable "name" {
  description = "Prefix used for resource names"
  type        = string
}

variable "cidr_block" {
  description = "VPC CIDR range"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of availability zones to spread subnets across"
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 2 && var.az_count <= 3
    error_message = "Use 2 or 3 AZs: RDS and the ALB need at least two."
  }
}

variable "single_nat_gateway" {
  description = "One shared NAT gateway (cheaper, dev) instead of one per AZ (highly available, prod)"
  type        = bool
  default     = true
}

variable "flow_log_retention_days" {
  type    = number
  default = 30
}
