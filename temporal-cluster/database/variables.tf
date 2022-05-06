variable "service_name" {
  type = string
  description = "Provide a Service Name that acts as the RDS name in AWS Console"
}
variable "environment" {
  type = string
  description = "Specify Environment name such as dev, stage, prod etc"
}
variable "vpc_id" {
  type = string
  description = "Provide the ID for the AWS VPC"
}
variable "private_subnets_ids" {
  type = list(string)
  description = "Provide list of Private Subnet IDs in the VPC. This will be used for Aurora database."
}
