output "file_system" {
  description = "Information about the Lustre file system"
  value       = var.create_lustre_fs ? aws_fsx_lustre_file_system.main[0] : null
}

output "security_group" {
  description = "Information about the Lustre security group"
  value       = var.create_lustre_security_group ? aws_security_group.main[0] : null
}

output "data_repository_associations" {
  description = "Information about any data repository associations created"
  value       = var.data_repository_associations != null ? aws_fsx_data_repository_association.main.* : null
}