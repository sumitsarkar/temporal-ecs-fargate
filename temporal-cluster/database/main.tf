
locals {
  name = var.service_name
  tags = {
    Application = var.service_name
    Environment = var.environment
  }
}

resource "random_password" "master" {
  length = 10
}

module "temporal_database" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "6.1.4"

  name           = "temporal-aurora-db-postgres96"
  engine         = "aurora-postgresql"
  engine_mode = "serverless"
  storage_encrypted = true

  database_name = "temporal"

  vpc_id                 = var.vpc_id
  subnets                = var.private_subnets_ids
  create_db_subnet_group = true
  create_security_group  = true

  monitoring_interval = 60

  apply_immediately   = true
  skip_final_snapshot = true

  db_parameter_group_name         = aws_db_parameter_group.temporal_db_parameter_group.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.temporal_rds_cluster_parameter_group.id
  #  enabled_cloudwatch_logs_exports = ["postgresql"]

  master_password = random_password.master.result
  create_random_password = false

  scaling_configuration = {
    auto_pause               = true
    min_capacity             = 2
    max_capacity             = 16
    seconds_until_auto_pause = 300
    timeout_action           = "ForceApplyCapacityChange"
  }

  tags = local.tags
}


resource "aws_db_parameter_group" "temporal_db_parameter_group" {
  name        = "${local.name}-aurora-db-postgres10-parameter-group"
  family      = "aurora-postgresql10"
  description = "${local.name}-aurora-db-postgres10-parameter-group"
  tags        = local.tags
}

resource "aws_rds_cluster_parameter_group" "temporal_rds_cluster_parameter_group" {
  name        = "${local.name}-aurora-postgres10-cluster-parameter-group"
  family      = "aurora-postgresql10"
  description = "${local.name}-aurora-postgres10-cluster-parameter-group"
  tags        = local.tags
}
