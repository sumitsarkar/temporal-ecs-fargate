data "terraform_remote_state" "cluster" {
  backend = "s3"

  config = {
    bucket = "s3-bucket-for-state-backup"
    key    = "ecs-cluster/temporal-infra/${var.environment}/terraform.tfstate"
    region = "eu-west-1"
  }
}


data "terraform_remote_state" "temporal_database" {
  backend = "s3"

  config = {
    bucket = "s3-bucket-for-state-backup"
    key    = "ecs-cluster/temporal-infra/${var.environment}/services/temporal-database/terraform.tfstate"
    region = "eu-west-1"
  }
}
