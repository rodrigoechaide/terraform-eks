resource "aws_iam_policy" "policy" {
  for_each    = local.iam_policies

  name        = each.key
  description = each.value.description
  policy      = jsonencode(each.value.policy)
  tags        = local.common_tags
}

# EKS IAM Roles

data "aws_iam_policy_document" "trust_eks" {
  for_each  = local.iam_roles_eks

  policy_id = each.key

  statement {
    actions = each.value.trust_relationship.actions

    dynamic principals {
      for_each      = try(each.value.trust_relationship.principals, {})
      content {
        type        = principals.key
        identifiers = [ for value in principals.value: value == "eks_oidc" ? module.eks_cluster.oidc_provider_arn : value ]
      }
    }

    condition {
        test        = "StringEquals"
        variable    = "${replace(module.eks_cluster.cluster_oidc_issuer_url,"https://","")}:aud"
        values      = [ "sts.amazonaws.com" ]
    }

    dynamic condition {
      for_each      = { for item in each.value.trust_relationship.service_accounts: "${item.namespace}:${item.name}" => item }
      content {
        test        = "StringEquals"
        variable    = "${replace(module.eks_cluster.cluster_oidc_issuer_url,"https://","")}:sub"
        values      = [ "system:serviceaccount:${condition.value.namespace}:${condition.value.name}" ]
      }
    }
  }

  depends_on = [ module.eks_cluster ]
}

module "iam_role_eks" {
  source                  = "./modules/iam_role"
  for_each                = local.iam_roles_eks

  name                    = each.key
  trust_policy_json       = data.aws_iam_policy_document.trust_eks[each.key].json
  policy_attachment       = each.value.policy_attachment
  iam_policies            = aws_iam_policy.policy
  create_instance_profile = try(each.value.create_instance_profile, false)
  tags                    = local.common_tags

  depends_on              = [ aws_iam_policy.policy, data.aws_iam_policy_document.trust_eks ]
}