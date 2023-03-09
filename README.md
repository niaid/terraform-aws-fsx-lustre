# Terraform Module for a AWS FSx Lustre

This is a simple module which closely maps to the [FSx Lustre file system](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/fsx_lustre_file_system) resource.  Optional capabilities:

- Create a security group; given the subnet ID passed in, the VPC ID and CIDR blocks used by that subnet will be looked up to automatically create a security group matching [the requirements outlined](https://docs.aws.amazon.com/fsx/latest/LustreGuide/limit-access-security-groups.html)
- Create one or more [data repository associations](https://docs.aws.amazon.com/fsx/latest/LustreGuide/create-dra-linked-data-repo.html) for the file system you are managing

## Examples

Basic scratch file system with a Lustre-enabled security group attached:

```hcl
module "lustre" {
  source = "."

  subnet_ids                   = ["subnet-111111111"]
  deployment_type              = "SCRATCH_2"
  import_path                  = "s3://some-s3-bucket/import/"
  create_lustre_security_group = true
}
```

Create a `PERSISTENT_2` file system along with a data repository association for it to use:

```hcl
module "lustre" {
  source = "."

  subnet_ids                   = ["subnet-111111111"]
  deployment_type              = "PERSISTENT_2"
  create_lustre_security_group = true
  per_unit_storage_throughput  = 125

  data_repository_associations = [
    {
      data_repository_path = "s3://some-s3-bucket/"
      file_system_path     = "/test"

      s3 = {
        auto_export_policy_events = ["NEW", "CHANGED", "DELETED"]
        auto_import_policy_events = ["NEW", "CHANGED", "DELETED"]
      }
    }
  ]
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_fsx_data_repository_association.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/fsx_data_repository_association) | resource |
| [aws_fsx_lustre_file_system.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/fsx_lustre_file_system) | resource |
| [aws_security_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_ipv4_cidr_blocks_lustre_security_group"></a> [additional\_ipv4\_cidr\_blocks\_lustre\_security\_group](#input\_additional\_ipv4\_cidr\_blocks\_lustre\_security\_group) | Additional IPv4 CIDR block(s) you want to add to the Lustre security group | `list(string)` | `[]` | no |
| <a name="input_additional_ipv6_cidr_blocks_lustre_security_group"></a> [additional\_ipv6\_cidr\_blocks\_lustre\_security\_group](#input\_additional\_ipv6\_cidr\_blocks\_lustre\_security\_group) | Additional IPv6 CIDR block(s) you want to add to the Lustre security group | `list(string)` | `[]` | no |
| <a name="input_auto_import_policy"></a> [auto\_import\_policy](#input\_auto\_import\_policy) | How Amazon FSx keeps your file and directory listings up to date as you add or modify objects in your linked S3 bucket | `string` | `null` | no |
| <a name="input_automatic_backup_retention_days"></a> [automatic\_backup\_retention\_days](#input\_automatic\_backup\_retention\_days) | The number of days to retain automatic backups. Setting this to 0 disables automatic backups. | `number` | `null` | no |
| <a name="input_backup_id"></a> [backup\_id](#input\_backup\_id) | The ID of the source backup to create the filesystem from | `string` | `null` | no |
| <a name="input_copy_tags_to_backups"></a> [copy\_tags\_to\_backups](#input\_copy\_tags\_to\_backups) | A boolean flag indicating whether tags for the file system should be copied to backups. | `bool` | `false` | no |
| <a name="input_create_lustre_fs"></a> [create\_lustre\_fs](#input\_create\_lustre\_fs) | Whether to create the file system | `bool` | `true` | no |
| <a name="input_create_lustre_security_group"></a> [create\_lustre\_security\_group](#input\_create\_lustre\_security\_group) | Whether a security group will be created for the VPC/Subnet CIDR blocks specified and added to your file system | `bool` | `false` | no |
| <a name="input_daily_automatic_backup_start_time"></a> [daily\_automatic\_backup\_start\_time](#input\_daily\_automatic\_backup\_start\_time) | A recurring daily time, in the format HH:MM. HH is the zero-padded hour of the day (0-23), and MM is the zero-padded minute of the hour | `string` | `null` | no |
| <a name="input_data_compression_type"></a> [data\_compression\_type](#input\_data\_compression\_type) | Sets the data compression configuration for the file system. Valid values are LZ4 and NONE | `string` | `"NONE"` | no |
| <a name="input_data_repository_associations"></a> [data\_repository\_associations](#input\_data\_repository\_associations) | Manages a FSx for Lustre Data Repository Associations: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/fsx_data_repository_association | <pre>list(<br>    object({<br>      # Required<br>      data_repository_path = string<br>      file_system_path     = string<br>      # Optional<br>      batch_import_meta_data_on_create = optional(bool, false)<br>      imported_file_chunk_size         = optional(number)<br>      delete_data_in_filesystem        = optional(bool, false)<br><br>      s3 = optional(<br>        object({<br>          auto_export_policy_events = optional(list(string))<br>          auto_import_policy_events = optional(list(string))<br>        })<br>      )<br>    })<br>  )</pre> | `null` | no |
| <a name="input_deployment_type"></a> [deployment\_type](#input\_deployment\_type) | The filesystem deployment type. One of: SCRATCH\_1, SCRATCH\_2, PERSISTENT\_1, PERSISTENT\_2 | `string` | n/a | yes |
| <a name="input_drive_cache_type"></a> [drive\_cache\_type](#input\_drive\_cache\_type) | The type of drive cache used by persistent filesystems that are provisioned with HDD storage\_type. Required for HDD storage\_type, set to either READ or NONE | `string` | `null` | no |
| <a name="input_export_path"></a> [export\_path](#input\_export\_path) | S3 URI (with optional prefix) where the root of your Amazon FSx file system is exported | `string` | `null` | no |
| <a name="input_file_system_type_version"></a> [file\_system\_type\_version](#input\_file\_system\_type\_version) | Sets the Lustre version for the file system that you're creating. Valid values are 2.10 for SCRATCH\_1, SCRATCH\_2 and PERSISTENT\_1 deployment types. Valid values for 2.12 include all deployment types | `string` | `null` | no |
| <a name="input_import_path"></a> [import\_path](#input\_import\_path) | S3 URI (with optional prefix) that you're using as the data repository for your FSx for Lustre file system | `string` | `null` | no |
| <a name="input_imported_file_chunk_size"></a> [imported\_file\_chunk\_size](#input\_imported\_file\_chunk\_size) | For files imported from a data repository, this value determines the stripe count and maximum amount of data per file (in MiB) stored on a single physical disk | `number` | `null` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | ARN for the KMS Key to encrypt the file system at rest, applicable for PERSISTENT\_1 and PERSISTENT\_2 deployment\_type | `string` | `null` | no |
| <a name="input_log_destination"></a> [log\_destination](#input\_log\_destination) | The Amazon Resource Name (ARN) that specifies the destination of the logs. The name of the Amazon CloudWatch Logs log group must begin with the /aws/fsx prefix.  If you do not provide a destination, Amazon FSx will create and use a log stream in the CloudWatch Logs /aws/fsx/lustre log group | `string` | `null` | no |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | Sets which data repository events are logged by Amazon FSx. Valid values are WARN\_ONLY, FAILURE\_ONLY, ERROR\_ONLY, WARN\_ERROR and DISABLED | `string` | `"DISABLED"` | no |
| <a name="input_per_unit_storage_throughput"></a> [per\_unit\_storage\_throughput](#input\_per\_unit\_storage\_throughput) | Describes the amount of read and write throughput for each TB of storage, in MB/s/TiB, required for the PERSISTENT\_1 and PERSISTENT\_2 deployment\_type. | `number` | `null` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | A list of IDs for the security groups that apply to the specified network interfaces created for file system access | `list(string)` | `[]` | no |
| <a name="input_storage_capacity"></a> [storage\_capacity](#input\_storage\_capacity) | The storage capacity (GiB) of the file system. Minimum of 1200 | `number` | `1200` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | The filesystem storage type. Either SSD or HDD | `string` | `"SSD"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of IDs for the subnets that the file system will be accessible from | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the file system | `map(string)` | `{}` | no |
| <a name="input_weekly_maintenance_start_time"></a> [weekly\_maintenance\_start\_time](#input\_weekly\_maintenance\_start\_time) | The preferred start time (in d:HH:MM format) to perform weekly maintenance, in the UTC time zone | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_data_repository_associations"></a> [data\_repository\_associations](#output\_data\_repository\_associations) | Information about any data repository associations created |
| <a name="output_file_system"></a> [file\_system](#output\_file\_system) | Information about the Lustre file system |
| <a name="output_security_group"></a> [security\_group](#output\_security\_group) | Information about the Lustre security group |
