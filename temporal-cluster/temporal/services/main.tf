terraform {
  # Optional attributes and the defaults function are
  # both experimental, so we must opt in to the experiment.
  experiments = [module_variable_optional_attrs]
}

module "temporal_service_definition_json" {
  count   = length(var.temporal_service_configuration)
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.58.1"

  container_name  = lookup(var.temporal_service_configuration[count.index], "container_name")
  container_image = lookup(var.temporal_service_configuration[count.index], "image_url")

  environment = lookup(var.temporal_service_configuration[count.index], "environment_variables")

  port_mappings = lookup(var.temporal_service_configuration[count.index], "port_mappings")

  log_configuration = {
    logDriver = "json-file"
    options = {
      "max-size" = "10m"
      "max-file" = "3"
    }
  }

  container_memory_reservation = 512
}


resource "aws_ecs_task_definition" "temporal_task" {
  count = length(var.temporal_service_configuration)

  container_definitions = jsonencode(concat([
    module.temporal_service_definition_json[count.index].json_map_object
  ]))

  family = "${lookup(var.temporal_service_configuration[count.index], "service_name")}-${var.environment}"

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  memory = lookup(var.temporal_service_configuration[count.index], "memory")
  cpu    = lookup(var.temporal_service_configuration[count.index], "cpu")

  execution_role_arn = lookup(var.temporal_service_configuration[count.index], "execution_role_arn")
  task_role_arn      = lookup(var.temporal_service_configuration[count.index], "task_role_arn")
}


resource "aws_ecs_service" "temporal_frontend_service" {
  count = length(var.temporal_service_configuration)

  name = lookup(var.temporal_service_configuration[count.index], "service_name")
  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    base              = 1
    weight            = 1
  }

  cluster = var.ecs_cluster_id

  network_configuration {
    subnets          = var.private_subnets_ids
    assign_public_ip = false
    security_groups  = [lookup(var.temporal_service_configuration[count.index], "security_group_id")]
  }

  desired_count          = 3
  enable_execute_command = true
  task_definition        = aws_ecs_task_definition.temporal_task[count.index].arn


  dynamic "service_registries" {
    for_each = lookup(var.temporal_service_configuration[count.index], "service_discovery") == true ? [1] : []
    content {
      registry_arn   = var.service_discovery_arn
      container_name = lookup(var.temporal_service_configuration[count.index], "service_name")
    }
  }
}
