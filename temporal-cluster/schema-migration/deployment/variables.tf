variable "service_name" {
  description = "Name of the function"
  default = "Temporal SQL Schema Migration"
  type = string
}
variable "environment" {
  type = string
  description = "Name of the environment"
}

variable "vpc_id" {
  type = string
}

variable "private_subnets_ids" {
  type = list(string)
}

variable "lambda_image_uri" {
  description = "ECR URL for the Lambda Image"
}
