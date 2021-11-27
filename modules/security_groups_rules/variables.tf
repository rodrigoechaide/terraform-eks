variable "security_group_id" {
  type = string
}

variable "ingress_rules_cidr" {
  type = list(object({
    description = string
    from_port   = string
    to_port     = string
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "ingress_rules_sg" {
  type = list(object({
    description = string
    from_port   = string
    to_port     = string
    protocol    = string
    source_security_group = string
  }))
}

variable "egress_rules" {
  type = list(object({
    description = string
    from_port   = string
    to_port     = string
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "security_groups_ids" {
  type = map(string)
}
