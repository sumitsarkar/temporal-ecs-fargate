provider "aws" {
  region = "ap-south-1"
}

resource "aws_ecs_cluster" "temporal_infrastructure" {
  name = "${var.cluster_name}_${var.environment}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Cluster : var.cluster_name,
    Environment : var.environment,
  }
}

resource "aws_ecs_cluster_capacity_providers" "temporal_infrastructure" {
  cluster_name = aws_ecs_cluster.temporal_infrastructure.name
  capacity_providers = ["FARGATE"]
}

resource "aws_lb" "network_load_balancer" {
  name                             = replace("${var.cluster_name}_${var.environment}_nlb", "_", "-")
  internal                         = false
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true
  subnets                          = var.public_subnets_ids

  tags = {
    Cluster : var.cluster_name,
    Environment : var.environment,
  }
}

output "cluster_arn" {
  value = aws_ecs_cluster.temporal_infrastructure.arn
}

output "cluster_id" {
  value = aws_ecs_cluster.temporal_infrastructure.id
}

output "nlb_arn" {
  value = aws_lb.network_load_balancer.arn
}

output "dns_name" {
  value = aws_lb.network_load_balancer.dns_name
}
