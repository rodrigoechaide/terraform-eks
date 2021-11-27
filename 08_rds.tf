resource "aws_db_instance" "db" {
  for_each = local.rds

  allocated_storage                   = each.value.allocated_storage
  storage_type                        = each.value.storage_type
  engine                              = each.value.engine
  engine_version                      = each.value.engine_version
  instance_class                      = each.value.instance_class
  name                                = each.value.db_name
  identifier                          = each.key
  username                            = each.value.db_username
  password                            = each.value.db_password
  availability_zone                   = each.value.availability_zone
  backup_retention_period             = each.value.backup_retention_period
  enabled_cloudwatch_logs_exports     = each.value.enabled_cloudwatch_logs_exports
  backup_window                       = each.value.backup_window
  ca_cert_identifier                  = "rds-ca-2019"
  copy_tags_to_snapshot               = true
  iam_database_authentication_enabled = try(each.value.iam_database_authentication_enabled, false)
  db_subnet_group_name                = each.value.db_subnet_group_name
  storage_encrypted                   = true
  max_allocated_storage               = each.value.max_allocated_storage
  performance_insights_enabled        = each.value.performance_insights_enabled
  monitoring_interval                 = each.value.monitoring_interval
  snapshot_identifier                 = try(each.value.snapshot_identifier, null)
  skip_final_snapshot                 = try(each.value.skip_final_snapshot, false)
  final_snapshot_identifier           = try(each.value.final_snapshot_identifier, null)
  allow_major_version_upgrade         = try(each.value.allow_major_version_upgrade, false)
  deletion_protection                 = try(each.value.deletion_protection, false)
  vpc_security_group_ids              = [ for sg in each.value.db_security_groups: aws_security_group.sg[sg].id ]
  tags                                = merge({ Environment=upper(var.environment) }, try(each.value.extra_tags, {}))

  depends_on = [ aws_security_group.sg  ]

  lifecycle {
    ignore_changes = [ engine_version ]
  }
}

resource "aws_db_subnet_group" "subnet_group" {
  name       = "${var.environment}_back"
  subnet_ids = [ aws_subnet.back["eu-north-1a"].id, aws_subnet.back["eu-north-1b"].id, aws_subnet.back["eu-north-1c"].id ]
  description = "${var.environment} backend subnets"
}