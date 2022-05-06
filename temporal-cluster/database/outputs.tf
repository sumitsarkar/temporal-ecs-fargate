# aws_db_subnet_group
output "postgresql_db_subnet_group_name" {
  description = "The db subnet group name"
  value       = module.temporal_database.db_subnet_group_name
}

# aws_rds_cluster
output "postgresql_cluster_arn" {
  description = "Amazon Resource Name (ARN) of cluster"
  value       = module.temporal_database.cluster_arn
}

output "postgresql_cluster_id" {
  description = "The RDS Cluster Identifier"
  value       = module.temporal_database.cluster_id
}

output "postgresql_cluster_resource_id" {
  description = "The RDS Cluster Resource ID"
  value       = module.temporal_database.cluster_resource_id
}

output "postgresql_cluster_members" {
  description = "List of RDS Instances that are a part of this cluster"
  value       = module.temporal_database.cluster_members
}

output "postgresql_cluster_endpoint" {
  description = "Writer endpoint for the cluster"
  value       = module.temporal_database.cluster_endpoint
}

output "postgresql_cluster_reader_endpoint" {
  description = "A read-only endpoint for the cluster, automatically load-balanced across replicas"
  value       = module.temporal_database.cluster_reader_endpoint
}

output "postgresql_cluster_engine_version_actual" {
  description = "The running version of the cluster database"
  value       = module.temporal_database.cluster_engine_version_actual
}

# database_name is not set on `aws_rds_cluster` resource if it was not specified, so can't be used in output
output "postgresql_cluster_database_name" {
  description = "Name for an automatically created database on cluster creation"
  value       = module.temporal_database.cluster_database_name
}

output "postgresql_cluster_port" {
  description = "The database port"
  value       = module.temporal_database.cluster_port
}

output "postgresql_cluster_master_password" {
  description = "The database master password"
  value       = module.temporal_database.cluster_master_password
  sensitive   = true
}

output "postgresql_cluster_master_username" {
  description = "The database master username"
  value       = module.temporal_database.cluster_master_username
  sensitive   = true
}

output "postgresql_cluster_hosted_zone_id" {
  description = "The Route53 Hosted Zone ID of the endpoint"
  value       = module.temporal_database.cluster_hosted_zone_id
}

# aws_rds_cluster_instances
output "postgresql_cluster_instances" {
  description = "A map of cluster instances and their attributes"
  value       = module.temporal_database.cluster_instances
}

# aws_rds_cluster_endpoint
output "postgresql_additional_cluster_endpoints" {
  description = "A map of additional cluster endpoints and their attributes"
  value       = module.temporal_database.additional_cluster_endpoints
}

# aws_rds_cluster_role_association
output "postgresql_cluster_role_associations" {
  description = "A map of IAM roles associated with the cluster and their attributes"
  value       = module.temporal_database.cluster_role_associations
}

# Enhanced monitoring role
output "postgresql_enhanced_monitoring_iam_role_name" {
  description = "The name of the enhanced monitoring role"
  value       = module.temporal_database.enhanced_monitoring_iam_role_name
}

output "postgresql_enhanced_monitoring_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the enhanced monitoring role"
  value       = module.temporal_database.enhanced_monitoring_iam_role_arn
}

output "postgresql_enhanced_monitoring_iam_role_unique_id" {
  description = "Stable and unique string identifying the enhanced monitoring role"
  value       = module.temporal_database.enhanced_monitoring_iam_role_unique_id
}

# aws_security_group
output "postgresql_security_group_id" {
  description = "The security group ID of the cluster"
  value       = module.temporal_database.security_group_id
}

