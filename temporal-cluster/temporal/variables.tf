variable "region" {
  default = "eu-west-1"
}

variable "public_subnets_ids" {
  type    = list(string)

}
variable "private_subnets_ids" {
  type    = list(string)
}
variable "vpc_id" {
  type    = string
}

variable "environment" {
  type        = string
  description = "Name of the environment"
}

variable "service_name" {
  description = "Name of the Service Cluster"
}

variable "web_image" {
  type = string
}

variable "temporal_image" {
  type = string
}
