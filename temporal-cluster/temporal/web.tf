
module "temporal_web_service_definition_json" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.58.1"

  container_name  = "web"
  container_image = var.web_image

  environment = [
    {
      name : "TEMPORAL_GRPC_ENDPOINT",
      value : "frontend.${var.environment}.temporal.local:7233"
    }, {
      name : "TEMPORAL_WEB_PORT",
      value : "8088"
    }, {
      name : "TEMPORAL_SESSION_SECRET",
      value : "superdupersessionsecret"
    }
  ]

  port_mappings = [
    {
      containerPort = 8088
      hostPort      = 8088
      protocol      = "tcp"
    }
  ]

  log_configuration = {
    logDriver = "json-file"
    options = {
      "max-size" = "10m"
      "max-file" = "3"
    }
  }

  container_memory_reservation = 512
}


resource "aws_ecs_task_definition" "web_task" {

  container_definitions = jsonencode([
    module.temporal_web_service_definition_json.json_map_object
  ])
  family = "web-${var.environment}"

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  memory = 2048
  cpu    = 512

  execution_role_arn = aws_iam_role.execution_role.arn
  task_role_arn      = aws_iam_role.task_role.arn
}


resource "aws_ecs_service" "temporal_frontend_service" {
  name = "web"
  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    base              = 1
    weight            = 1
  }

  cluster = data.terraform_remote_state.cluster.outputs.cluster_id

  network_configuration {
    subnets          = var.private_subnets_ids
    assign_public_ip = false
    security_groups  = [aws_security_group.web_security_group.id]
  }

  desired_count          = 1
  enable_execute_command = true
  task_definition        = aws_ecs_task_definition.web_task.arn


  #  dynamic "service_registries" {
  #    for_each = lookup(var.temporal_service_configuration[count.index], "service_discovery") == true ? [1] : []
  #    content {
  #      registry_arn   = var.service_discovery_arn
  #      container_name = lookup(var.temporal_service_configuration[count.index], "service_name")
  #    }
  #  }

  load_balancer {
    container_port   = 8088
    target_group_arn = aws_lb_target_group.web_target_group_https.arn
    container_name   = "web"
  }

  load_balancer {
    container_port   = 8088
    target_group_arn = aws_lb_target_group.web_target_group_http.arn
    container_name   = "web"
  }
}


# Load Balancer Listeners
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = data.terraform_remote_state.cluster.outputs.nlb_arn
  port              = 443
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_target_group_https.arn
  }
}
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = data.terraform_remote_state.cluster.outputs.nlb_arn
  port              = 80
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_target_group_http.arn
  }
}


# Load Balancer Target Group
resource "aws_lb_target_group" "web_target_group_https" {
  name                 = "web-${var.environment}-https-tg"
  port                 = 443
  protocol             = "TCP"
  vpc_id               = var.vpc_id
  target_type          = "ip"
  deregistration_delay = 20
}
resource "aws_lb_target_group" "web_target_group_http" {
  name                 = "web-${var.environment}-http-tg"
  port                 = 80
  protocol             = "TCP"
  vpc_id               = var.vpc_id
  target_type          = "ip"
  deregistration_delay = 20
}
