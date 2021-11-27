resource "aws_security_group" "sg" {
  for_each    = { for sg in local.security_groups: sg.name => sg }

  name_prefix = "${each.value.name}_"
  description = join(" ", [upper(var.environment), each.value.description])
  vpc_id      = aws_vpc.main.id
  tags        = local.common_tags
  
  lifecycle {
    create_before_destroy = true
  }

}

module "security_group_rules" {
  source              = "./modules/security_groups_rules"
  for_each            = { for sg in local.security_groups: sg.name => sg }

  security_group_id   = aws_security_group.sg[each.value.name].id
  ingress_rules_cidr  = try( each.value.ingress_rules_cidr, [] )
  ingress_rules_sg    = try( each.value.ingress_rules_sg, [] )
  egress_rules        = try( each.value.egress_rules, [] )
  security_groups_ids = try( zipmap([ for sg in local.security_groups: sg.name ], try([for sg in local.security_groups: aws_security_group.sg[sg.name].id ], [])), {} )

  depends_on          = [ aws_security_group.sg ]
}
