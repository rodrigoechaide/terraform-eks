resource "aws_security_group_rule" "ingress_cidr" {
  for_each = { for rule in var.ingress_rules_cidr: join("_", [ rule.from_port, rule.to_port, rule.protocol, join("_", rule.cidr_blocks ) ] ) => rule }

  type              = "ingress"
  description       = each.value.description
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = [ for cidr_block_item in each.value.cidr_blocks: cidr_block_item ]
  security_group_id = var.security_group_id
}

resource "aws_security_group_rule" "ingress_sg" {
  for_each = { for rule in var.ingress_rules_sg: join("_", [ rule.from_port, rule.to_port, rule.protocol, rule.source_security_group ] ) => rule }

  type                     = "ingress"
  description              = each.value.description
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  source_security_group_id = try( lookup(var.security_groups_ids, each.value.source_security_group), "ID for ${each.value.source_security_group} not found")
  security_group_id        = var.security_group_id
}

resource "aws_security_group_rule" "egress" {
  for_each = { for rule in var.egress_rules: join("_", [ rule.from_port, rule.to_port, rule.protocol, join("_", rule.cidr_blocks ) ] ) => rule }

  type              = "egress"
  description       = each.value.description
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = [ for cidr_block_item in each.value.cidr_blocks: cidr_block_item ]
  security_group_id = var.security_group_id
}

resource "aws_security_group_rule" "default_egress" {
  count = length(var.egress_rules) == 0 ? 1 : 0

  type              = "egress"
  description       = "full outbound"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"

  cidr_blocks       = [ "0.0.0.0/0" ] 
  security_group_id = var.security_group_id
}