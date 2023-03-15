#
# Required
#

variable "deployment_type" {
  description = "The filesystem deployment type. One of: SCRATCH_1, SCRATCH_2, PERSISTENT_1, PERSISTENT_2"
  type        = string
}

variable "subnet_ids" {
  description = " A list of IDs for the subnets that the file system will be accessible from"
  type        = list(string)
}

#
# Optional - Lustre File System & SG
#

variable "create_lustre_fs" {
  description = "Whether to create the file system"
  type        = bool
  default     = true
}

variable "create_lustre_security_group" {
  description = "Whether a security group will be created for the VPC/Subnet CIDR blocks specified and added to your file system"
  type        = bool
  default     = false
}

variable "additional_ipv4_cidr_blocks_lustre_security_group" {
  description = "Additional IPv4 CIDR block(s) you want to add to the Lustre security group"
  type        = list(string)
  default     = []
}

variable "additional_ipv6_cidr_blocks_lustre_security_group" {
  description = "Additional IPv6 CIDR block(s) you want to add to the Lustre security group"
  type        = list(string)
  default     = []
}

variable "storage_capacity" {
  description = "The storage capacity (GiB) of the file system. Minimum of 1200"
  type        = number
  default     = 1200
}

variable "backup_id" {
  description = "The ID of the source backup to create the filesystem from"
  type        = string
  default     = null
}

variable "export_path" {
  description = "S3 URI (with optional prefix) where the root of your Amazon FSx file system is exported"
  type        = string
  default     = null
}

variable "import_path" {
  description = "S3 URI (with optional prefix) that you're using as the data repository for your FSx for Lustre file system"
  type        = string
  default     = null
}

variable "imported_file_chunk_size" {
  description = "For files imported from a data repository, this value determines the stripe count and maximum amount of data per file (in MiB) stored on a single physical disk"
  type        = number
  default     = null
}

variable "security_group_ids" {
  description = "A list of IDs for the security groups that apply to the specified network interfaces created for file system access"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to assign to the file system"
  type        = map(string)
  default     = {}
}

variable "weekly_maintenance_start_time" {
  description = "The preferred start time (in d:HH:MM format) to perform weekly maintenance, in the UTC time zone"
  type        = string
  default     = null
}

variable "kms_key_id" {
  description = "ARN for the KMS Key to encrypt the file system at rest, applicable for PERSISTENT_1 and PERSISTENT_2 deployment_type"
  type        = string
  default     = null
}

variable "per_unit_storage_throughput" {
  description = "Describes the amount of read and write throughput for each TB of storage, in MB/s/TiB, required for the PERSISTENT_1 and PERSISTENT_2 deployment_type."
  type        = number
  default     = null
}

variable "automatic_backup_retention_days" {
  description = "The number of days to retain automatic backups. Setting this to 0 disables automatic backups."
  type        = number
  default     = null
}

variable "storage_type" {
  description = "The filesystem storage type. Either SSD or HDD"
  type        = string
  default     = "SSD"
}

variable "drive_cache_type" {
  description = "The type of drive cache used by persistent filesystems that are provisioned with HDD storage_type. Required for HDD storage_type, set to either READ or NONE"
  type        = string
  default     = null
}

variable "daily_automatic_backup_start_time" {
  description = "A recurring daily time, in the format HH:MM. HH is the zero-padded hour of the day (0-23), and MM is the zero-padded minute of the hour"
  type        = string
  default     = null
}

variable "auto_import_policy" {
  description = "How Amazon FSx keeps your file and directory listings up to date as you add or modify objects in your linked S3 bucket"
  type        = string
  default     = null
}

variable "copy_tags_to_backups" {
  description = "A boolean flag indicating whether tags for the file system should be copied to backups. "
  type        = bool
  default     = false
}

variable "data_compression_type" {
  description = "Sets the data compression configuration for the file system. Valid values are LZ4 and NONE"
  type        = string
  default     = "NONE"
}

variable "file_system_type_version" {
  description = "Sets the Lustre version for the file system that you're creating. Valid values are 2.10 for SCRATCH_1, SCRATCH_2 and PERSISTENT_1 deployment types. Valid values for 2.12 include all deployment types"
  type        = string
  default     = null
}

variable "log_destination" {
  description = "The Amazon Resource Name (ARN) that specifies the destination of the logs. The name of the Amazon CloudWatch Logs log group must begin with the /aws/fsx prefix.  If you do not provide a destination, Amazon FSx will create and use a log stream in the CloudWatch Logs /aws/fsx/lustre log group"
  type        = string
  default     = null
}

variable "log_level" {
  description = "Sets which data repository events are logged by Amazon FSx. Valid values are WARN_ONLY, FAILURE_ONLY, ERROR_ONLY, WARN_ERROR and DISABLED"
  type        = string
  default     = "DISABLED"
}

variable "data_repository_associations" {
  description = "Manages a FSx for Lustre Data Repository Associations: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/fsx_data_repository_association"
  type = map(
    # the key to each object is a descriptive name and only added to the tags
    object({
      # Required
      data_repository_path = string
      file_system_path     = string

      # Optional
      batch_import_meta_data_on_create = optional(bool, false)
      imported_file_chunk_size         = optional(number)
      delete_data_in_filesystem        = optional(bool, false)

      s3 = optional(
        object({
          auto_export_policy_events = optional(list(string))
          auto_import_policy_events = optional(list(string))
        })
      )
    })
  )
  default = null
}