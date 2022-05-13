provider "aws" {
  region = "ap-south-1"
}

locals {
  name = var.service_name
  tags = {
    Application = var.service_name
    Environment = var.environment
  }
  database_username          = data.terraform_remote_state.temporal_database.outputs.postgresql_cluster_master_username
  database_password          = data.terraform_remote_state.temporal_database.outputs.postgresql_cluster_master_password
  database_url               = data.terraform_remote_state.temporal_database.outputs.postgresql_cluster_endpoint
  database_port              = data.terraform_remote_state.temporal_database.outputs.postgresql_cluster_port
  database_security_group_id = data.terraform_remote_state.temporal_database.outputs.postgresql_security_group_id

  temporal_service_common_env = [
    {
      name : "DB",
      value : "postgresql"
    },
    {
      name : "POSTGRES_USER"
      value : local.database_username
    }, {
      name : "POSTGRES_PWD"
      value : local.database_password
    }, {
      name : "POSTGRES_SEEDS",
      value : local.database_url
    }, {
      name : "DB_PORT",
      value : local.database_port
    }, {
      name : "PROMETHEUS_ENDPOINT"
      value : "127.0.0.1:9090"
    }, {
      name : "DYNAMIC_CONFIG_FILE_PATH",
      value : "/etc/temporal/config/dynamicconfig/poc.yaml"
    }, {
      name : "TEMPORAL_CLI_ADDRESS",
      value : "frontend.${var.environment}.temporal.local:7233"
    }
  ]
}


resource "aws_service_discovery_private_dns_namespace" "temporal_service_discovery" {
  name        = "${var.environment}.temporal.local"
  description = "Temporal Service Discovery"
  vpc         = var.vpc_id
}


resource "aws_service_discovery_service" "frontend" {
  name = "frontend"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.temporal_service_discovery.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}

module "temporal-services" {
  source         = "./services"
  ecs_cluster_id = data.terraform_remote_state.cluster.outputs.cluster_id
  environment    = var.environment
  cluster_name   = var.service_name

  vpc_id                         = var.vpc_id
  private_subnets_ids            = var.private_subnets_ids
  service_discovery_arn          = aws_service_discovery_service.frontend.arn
  temporal_service_configuration = [
    {
      service_name          = "frontend",
      service_discovery     = true
      container_name        = "frontend",
      image_url             = var.temporal_image
      requires_sidecar_config_container = true
      sidecar_volume_path = "/etc/temporal/config/dynamicconfig"
      environment_variables = concat([
        {
          name : "SERVICES",
          value : "frontend"
        }
      ], local.temporal_service_common_env),
      port_mappings : [
        {
          containerPort = 7233
          hostPort      = 7233
          protocol      = "tcp"
        }, {
          containerPort = 6933
          hostPort      = 6933
          protocol      = "tcp"
        }
      ],
      memory             = 2048,
      cpu                = 512,
      execution_role_arn = aws_iam_role.execution_role.arn,
      task_role_arn      = aws_iam_role.task_role.arn,
      expose_to_public   = false,
      exposed_ports      = [7233],
      security_group_id  = aws_security_group.frontend_security_group.id,
      root_directory     = "/temporal/dynamic_config"
    }, {
      service_name          = "history",
      container_name        = "history",
      image_url             = var.temporal_image
      environment_variables = concat([
        {
          name : "SERVICES",
          value : "history"
        }
      ], local.temporal_service_common_env),
      port_mappings : [
        {
          containerPort = 7234
          hostPort      = 7234
          protocol      = "tcp"
        }, {
          containerPort = 6934
          hostPort      = 6934
          protocol      = "tcp"
        }
      ],
      memory             = 2048,
      cpu                = 512,
      execution_role_arn = aws_iam_role.execution_role.arn,
      task_role_arn      = aws_iam_role.task_role.arn,
      expose_to_public   = false,
      exposed_ports      = [7234],
      security_group_id  = aws_security_group.history_security_group.id,
      root_directory     = "/temporal/dynamic_config"
    }, {
      service_name          = "matching",
      container_name        = "matching",
      image_url             = var.temporal_image
      environment_variables = concat([
        {
          name : "SERVICES",
          value : "matching"
        }
      ], local.temporal_service_common_env),
      port_mappings : [
        {
          containerPort = 7235
          hostPort      = 7235
          protocol      = "tcp"
        }, {
          containerPort = 6935
          hostPort      = 6935
          protocol      = "tcp"
        }
      ],
      memory             = 2048,
      cpu                = 512,
      execution_role_arn = aws_iam_role.execution_role.arn,
      task_role_arn      = aws_iam_role.task_role.arn,
      expose_to_public   = false,
      exposed_ports      = [7235],
      security_group_id  = aws_security_group.matching_security_group.id,
      root_directory     = "/temporal/dynamic_config"
    }, {
      service_name          = "worker",
      container_name        = "worker",
      image_url             = var.temporal_image
      environment_variables = concat([
        {
          name : "SERVICES",
          value : "worker"
        },
        {
          name : "PUBLIC_FRONTEND_ADDRESS",
          value : "frontend.${var.environment}.temporal.local:7233"
        }
      ], local.temporal_service_common_env),
      port_mappings : [
        {
          containerPort = 7239
          hostPort      = 7239
          protocol      = "tcp"
        }, {
          containerPort = 6939
          hostPort      = 6939
          protocol      = "tcp"
        }
      ],
      memory             = 2048,
      cpu                = 512,
      execution_role_arn = aws_iam_role.execution_role.arn,
      task_role_arn      = aws_iam_role.task_role.arn,
      expose_to_public   = false,
      exposed_ports      = [7239],
      security_group_id  = aws_security_group.worker_security_group.id,
      root_directory     = "/temporal/dynamic_config"
    }
  ]
}


resource "aws_security_group" "frontend_security_group" {
  name   = "frontend_${var.environment}_sg"
  vpc_id = var.vpc_id
}
resource "aws_security_group" "history_security_group" {
  name   = "history_${var.environment}_sg"
  vpc_id = var.vpc_id
}
resource "aws_security_group" "matching_security_group" {
  name   = "matching_${var.environment}_sg"
  vpc_id = var.vpc_id
}
resource "aws_security_group" "worker_security_group" {
  name   = "worker_${var.environment}_sg"
  vpc_id = var.vpc_id
}
resource "aws_security_group" "web_security_group" {
  name   = "web_${var.environment}_sg"
  vpc_id = var.vpc_id
}


###
# FrontEnd Security Rules
###
resource "aws_security_group_rule" "frontend_inbound_tcp_1" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 7233
  to_port     = 7233
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  ipv6_cidr_blocks = [
    "::/0"
  ]
  security_group_id = aws_security_group.frontend_security_group.id
}
resource "aws_security_group_rule" "frontend_inbound_tcp_2" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 6933
  to_port     = 6933
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  ipv6_cidr_blocks = [
    "::/0"
  ]
  security_group_id = aws_security_group.frontend_security_group.id
}
resource "aws_security_group_rule" "frontend_inbound_tcp_web" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 7233
  to_port                  = 7233
  source_security_group_id = aws_security_group.web_security_group.id
  security_group_id        = aws_security_group.frontend_security_group.id
}

resource "aws_security_group_rule" "frontend_outbound" {
  protocol          = "-1"
  security_group_id = aws_security_group.frontend_security_group.id
  to_port           = 65535
  type              = "egress"
  from_port         = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "frontend_to_db_access" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = local.database_port
  to_port                  = local.database_port
  source_security_group_id = aws_security_group.frontend_security_group.id
  security_group_id        = local.database_security_group_id
}


###
# History Security Rules
###
resource "aws_security_group_rule" "history_inbound_tcp_1" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 7234
  to_port     = 7234
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  ipv6_cidr_blocks = [
    "::/0"
  ]
  security_group_id = aws_security_group.history_security_group.id
}
resource "aws_security_group_rule" "history_inbound_tcp_2" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 6934
  to_port     = 6934
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  ipv6_cidr_blocks = [
    "::/0"
  ]
  security_group_id = aws_security_group.history_security_group.id
}
resource "aws_security_group_rule" "history_outbound" {
  protocol          = "-1"
  security_group_id = aws_security_group.history_security_group.id
  to_port           = 65535
  type              = "egress"
  from_port         = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "history_to_db_access" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = local.database_port
  to_port                  = local.database_port
  source_security_group_id = aws_security_group.history_security_group.id
  security_group_id        = local.database_security_group_id
}


###
# Matching Security Rules
###
resource "aws_security_group_rule" "matching_inbound_tcp_1" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 7235
  to_port     = 7235
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  ipv6_cidr_blocks = [
    "::/0"
  ]
  security_group_id = aws_security_group.matching_security_group.id
}
resource "aws_security_group_rule" "matching_inbound_tcp_2" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 6935
  to_port     = 6935
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  ipv6_cidr_blocks = [
    "::/0"
  ]
  security_group_id = aws_security_group.matching_security_group.id
}
resource "aws_security_group_rule" "matching_outbound" {
  protocol          = "-1"
  security_group_id = aws_security_group.matching_security_group.id
  to_port           = 65535
  type              = "egress"
  from_port         = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "matching_to_db_access" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = local.database_port
  to_port                  = local.database_port
  source_security_group_id = aws_security_group.matching_security_group.id
  security_group_id        = local.database_security_group_id
}

###
# Worker Security Rules
###
resource "aws_security_group_rule" "worker_inbound_tcp_1" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 7239
  to_port     = 7239
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  ipv6_cidr_blocks = [
    "::/0"
  ]
  security_group_id = aws_security_group.worker_security_group.id
}
resource "aws_security_group_rule" "worker_inbound_tcp_2" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 6939
  to_port     = 6939
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  ipv6_cidr_blocks = [
    "::/0"
  ]
  security_group_id = aws_security_group.worker_security_group.id
}
resource "aws_security_group_rule" "worker_outbound" {
  protocol          = "-1"
  security_group_id = aws_security_group.worker_security_group.id
  to_port           = 65535
  type              = "egress"
  from_port         = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "worker_to_db_access" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = local.database_port
  to_port                  = local.database_port
  source_security_group_id = aws_security_group.worker_security_group.id
  security_group_id        = local.database_security_group_id
}

###
# Web Security Rules
###
resource "aws_security_group_rule" "web_inbound" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 8088
  to_port     = 8088
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  ipv6_cidr_blocks = [
    "::/0"
  ]
  security_group_id = aws_security_group.web_security_group.id
}

resource "aws_security_group_rule" "web_outbound" {
  protocol          = "-1"
  security_group_id = aws_security_group.web_security_group.id
  to_port           = 65535
  type              = "egress"
  from_port         = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

