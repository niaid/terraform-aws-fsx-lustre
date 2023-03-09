locals {
  vpc_id = data.aws_subnet.subnets[var.subnet_ids[0]].vpc_id

  subnets_cidr_blocks_raw = [
    for id, values in data.aws_subnet.subnets :
    values["cidr_block"]
  ]

  subnets_ipv6_cidr_blocks_raw = [
    for id, values in data.aws_subnet.subnets :
    values["ipv6_cidr_block"]
  ]

  subnets_cidr_blocks = (
    local.subnets_cidr_blocks_raw != [] ?
    concat(
      local.subnets_cidr_blocks_raw,
      var.additional_ipv4_cidr_blocks_lustre_security_group,
    ) :
    var.additional_ipv4_cidr_blocks_lustre_security_group
  )

  subnets_ipv6_cidr_blocks = (
    local.subnets_ipv6_cidr_blocks_raw != [] ?
    concat(
      local.subnets_ipv6_cidr_blocks_raw,
      var.additional_ipv6_cidr_blocks_lustre_security_group,
    ) :
    var.additional_ipv6_cidr_blocks_lustre_security_group
  )

  security_group_ids = (
    var.create_lustre_security_group ?
    concat(var.security_group_ids, [aws_security_group.main[0].id]) :
    var.security_group_ids
  )

  data_repository_associations = (
    var.data_repository_associations != null ?
    {
      for index, association in var.data_repository_associations :
      association.data_repository_path => association
    } :
    {}
  )
}

resource "aws_security_group" "main" {
  count = var.create_lustre_security_group ? 1 : 0

  name_prefix = "lustre-fs-"
  vpc_id      = local.vpc_id

  ingress {
    from_port        = 988
    to_port          = 988
    protocol         = "tcp"
    cidr_blocks      = local.subnets_cidr_blocks
    ipv6_cidr_blocks = local.subnets_ipv6_cidr_blocks
    self             = true
  }

  ingress {
    from_port        = 1018
    to_port          = 1023
    protocol         = "tcp"
    cidr_blocks      = local.subnets_cidr_blocks
    ipv6_cidr_blocks = local.subnets_ipv6_cidr_blocks
    self             = true
  }

  egress {
    from_port        = 988
    to_port          = 988
    protocol         = "tcp"
    cidr_blocks      = local.subnets_cidr_blocks
    ipv6_cidr_blocks = local.subnets_ipv6_cidr_blocks
    self             = true
  }

  egress {
    from_port        = 1018
    to_port          = 1023
    protocol         = "tcp"
    cidr_blocks      = local.subnets_cidr_blocks
    ipv6_cidr_blocks = local.subnets_ipv6_cidr_blocks
    self             = true
  }

  tags = var.tags
}

resource "aws_fsx_lustre_file_system" "main" {
  count = var.create_lustre_fs ? 1 : 0

  deployment_type                   = var.deployment_type
  subnet_ids                        = var.subnet_ids
  storage_capacity                  = var.storage_capacity
  backup_id                         = var.backup_id
  export_path                       = var.export_path
  import_path                       = var.import_path
  imported_file_chunk_size          = var.imported_file_chunk_size
  weekly_maintenance_start_time     = var.weekly_maintenance_start_time
  kms_key_id                        = var.kms_key_id
  per_unit_storage_throughput       = var.per_unit_storage_throughput
  automatic_backup_retention_days   = var.automatic_backup_retention_days
  storage_type                      = var.storage_type
  drive_cache_type                  = var.drive_cache_type
  daily_automatic_backup_start_time = var.daily_automatic_backup_start_time
  auto_import_policy                = var.auto_import_policy
  copy_tags_to_backups              = var.copy_tags_to_backups
  data_compression_type             = var.data_compression_type
  file_system_type_version          = var.file_system_type_version

  log_configuration {
    destination = var.log_destination
    level       = var.log_level
  }

  security_group_ids = local.security_group_ids

  tags = var.tags
}

resource "aws_fsx_data_repository_association" "main" {
  for_each = local.data_repository_associations

  file_system_id       = aws_fsx_lustre_file_system.main[0].id
  data_repository_path = each.value["data_repository_path"]
  file_system_path     = each.value["file_system_path"]

  batch_import_meta_data_on_create = each.value["batch_import_meta_data_on_create"]
  imported_file_chunk_size         = each.value["imported_file_chunk_size"]
  delete_data_in_filesystem        = each.value["delete_data_in_filesystem"]

  dynamic "s3" {
    for_each = (
      each.value["s3"] != null ?
      { "s3" = each.value["s3"] } :
      {}
    )

    content {
      auto_export_policy {
        events = s3.value["auto_export_policy_events"]
      }

      auto_import_policy {
        events = s3.value["auto_import_policy_events"]
      }
    }
  }

  tags = var.tags
}