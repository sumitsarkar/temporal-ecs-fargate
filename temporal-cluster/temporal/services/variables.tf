

variable "temporal_service_configuration" {
  type = list(object({
    service_name: string,
    service_discovery: optional(bool),
    image_url: string,
    container_name: string,
    requires_sidecar_config_container: optional(bool),
    sidecar_config_container_commands: optional(list(string)),
    sidecar_volume_path: optional(string)
    environment_variables: list(object({
      name: string,
      value: string
    })),
    port_mappings: list(object({
      containerPort = number
      hostPort      = number
      protocol      = string
    })),
    memory: number,
    cpu: number,
    execution_role_arn: string,
    task_role_arn: string,
    expose_to_public: bool,
    exposed_ports: list(number),
    security_group_id: string,
    root_directory = string
  }))
}

variable "service_discovery_arn" {
  type = string
}

variable "environment" {
  type = string
}

variable "ecs_cluster_id" {
  type = string
}


variable "private_subnets_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}


variable "cluster_name" {
  type = string
}
