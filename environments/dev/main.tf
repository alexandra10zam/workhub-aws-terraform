locals {
  name = "workhub-${var.environment}"
}

module "network" {
  source = "../../modules/network"

  name               = local.name
  cidr_block         = "10.20.0.0/16"
  az_count           = 2
  single_nat_gateway = true # dev: one NAT to keep cost down
}

# Created here (not inside a module) because both the ECS service and the
# database reference it: the DB only accepts connections from this group.
resource "aws_security_group" "app" {
  name        = "${local.name}-app"
  description = "WorkHub Fargate tasks"
  vpc_id      = module.network.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "app_all" {
  security_group_id = aws_security_group.app.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Outbound: database, ECR, CloudWatch, Secrets Manager"
}

module "database" {
  source = "../../modules/database"

  name                       = local.name
  vpc_id                     = module.network.vpc_id
  subnet_ids                 = module.network.private_subnet_ids
  allowed_security_group_ids = [aws_security_group.app.id]
  instance_class             = "db.t4g.micro"
  multi_az                   = false
  deletion_protection        = false
}

# API basic-auth credentials for WorkHub, generated and kept in Secrets Manager
resource "random_password" "api" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "api" {
  name                    = "${local.name}/api-credentials"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "api" {
  secret_id = aws_secretsmanager_secret.api.id
  secret_string = jsonencode({
    username = "admin"
    password = random_password.api.result
  })
}

module "app" {
  source = "../../modules/ecs-service"

  name                  = local.name
  aws_region            = var.aws_region
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  private_subnet_ids    = module.network.private_subnet_ids
  app_security_group_id = aws_security_group.app.id
  image_tag             = var.image_tag
  certificate_arn       = var.certificate_arn

  cpu           = 512
  memory        = 1024
  desired_count = 2
  min_count     = 2
  max_count     = 4

  environment = {
    DB_URL      = "jdbc:postgresql://${module.database.address}:${module.database.port}/${module.database.db_name}?sslmode=require"
    DB_USERNAME = module.database.username
  }

  # ECS injects single JSON keys from the secrets at container start
  secrets = {
    DB_PASSWORD  = "${module.database.master_user_secret_arn}:password::"
    APP_USERNAME = "${aws_secretsmanager_secret.api.arn}:username::"
    APP_PASSWORD = "${aws_secretsmanager_secret.api.arn}:password::"
  }

  secret_arns_to_read = [
    module.database.master_user_secret_arn,
    aws_secretsmanager_secret.api.arn,
  ]
}
