resource "aws_iam_role" "this" {
  name = var.name
  assume_role_policy = var.trust_policy_json
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each   = toset(var.policy_attachment)

  role       = aws_iam_role.this.name
  policy_arn = var.iam_policies[each.value].arn
}

resource "aws_iam_instance_profile" "this" {
  count   = var.create_instance_profile ? 1 : 0
  name    = var.name
  role    = var.name
}