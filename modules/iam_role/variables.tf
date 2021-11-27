variable "create_instance_profile" {
  type = bool
}

variable "iam_policies" {
}

variable "name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "policy_attachment" {
  type = list(string)
}

variable "trust_policy_json" {
  type = string
}