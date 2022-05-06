locals {
  tags = {
    Application = var.service_name
    Environment = var.environment
  }
  database_username          = sensitive(data.terraform_remote_state.temporal_database.outputs.postgresql_cluster_master_username)
  database_password          = sensitive(data.terraform_remote_state.temporal_database.outputs.postgresql_cluster_master_password)
  database_url               = data.terraform_remote_state.temporal_database.outputs.postgresql_cluster_endpoint
  database_port              = data.terraform_remote_state.temporal_database.outputs.postgresql_cluster_port
  database_security_group_id = data.terraform_remote_state.temporal_database.outputs.postgresql_security_group_id
}


module "lambda_function_container_image" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "2.34.1"

  function_name = "${var.service_name}-${var.environment}"
  description   = "Lambda for execution of SQL Schema Migration"

  create_package = false

  image_uri    = var.lambda_image_uri
  package_type = "Image"

  vpc_security_group_ids = [aws_security_group.lambda_security_group.id]
  vpc_subnet_ids         = var.private_subnets_ids

  attach_network_policy = true

  environment_variables = {
    DB : "postgresql"
    POSTGRES_SEEDS : "${local.database_url}"
    DB_PORT : "${local.database_port}"
    POSTGRES_USER : "${local.database_username}"
    POSTGRES_PWD : "${local.database_password}"
    TEMPORAL_CLI_ADDRESS: "frontend.dev.temporal.local:7233"
  }

  timeout = 900

  tags = {
    Service = var.service_name
    Environment = var.environment
  }
}


# Update DB security group to add permission to Lambda to execute.
resource "aws_security_group" "lambda_security_group" {
  name   = "${var.service_name}_${var.environment}_sg"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "lambda_to_db_access" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = local.database_port
  to_port                  = local.database_port
  source_security_group_id = aws_security_group.lambda_security_group.id
  security_group_id        = local.database_security_group_id
}

resource "aws_security_group_rule" "lambda_outbound" {
  protocol          = "-1"
  security_group_id = aws_security_group.lambda_security_group.id
  to_port           = 65535
  type              = "egress"
  from_port         = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "lambda_to_temporal_frontend_access" {
  count = length(length(data.terraform_remote_state.temporal_services.outputs.frontend_security_group_id) > 0 ? [1] : [])
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 7233
  to_port                  = 7233
  source_security_group_id = aws_security_group.lambda_security_group.id
  security_group_id        = data.terraform_remote_state.temporal_services.outputs.frontend_security_group_id
}
