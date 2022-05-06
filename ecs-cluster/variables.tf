variable "public_subnets_ids" {
  type    = list(string)

}
variable "private_subnets_ids" {
  type    = list(string)
}
variable "vpc_id" {
  type = string
}

variable "environment" {
  type = string
  description = "Name of the environment"
}
variable "cluster_name" {
  type = string
  default = "Name of the cluster"
}
