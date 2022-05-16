data "terraform_remote_state" "cluster" {
  backend = "s3"

  config = {
    bucket = "temporal-terraform"
    key    = "ecs-cluster/temporal-infra/${var.environment}/terraform.tfstate"
    region = "ap-south-1"
  }
}


data "terraform_remote_state" "temporal_database" {
  backend = "s3"

  config = {
    bucket = "temporal-terraform"
    key    = "ecs-cluster/temporal-infra/${var.environment}/services/temporal-database/terraform.tfstate"
    region = "ap-south-1"
  }
}
