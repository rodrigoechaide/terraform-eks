data "aws_eks_cluster" "cluster" {
  name = module.eks_cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks_cluster.cluster_id
}

module "eks_cluster" {
  source                      = "terraform-aws-modules/eks/aws"
  version                     = "17.19.0"
  write_kubeconfig            = false
  cluster_name                = var.environment
  cluster_version             = local.eks.control_plane.cluster_version
  subnets                     = [ aws_subnet.back["eu-north-1a"].id, aws_subnet.back["eu-north-1b"].id, aws_subnet.back["eu-north-1c"].id ]
  vpc_id                      = aws_vpc.main.id
  enable_irsa                 = true
  manage_worker_iam_resources = true

  # Private cluster
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access_cidrs  = local.eks.control_plane.cluster_endpoint_public_access_cidrs

  # Logging
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # aws-auth config-map
  manage_aws_auth = true
  map_users       = local.eks.control_plane.map_users

  # Compute
  # worker_additional_security_group_ids =
  node_groups_defaults                 = local.eks.node_groups_defaults
  node_groups                          = local.eks.node_groups

  tags = local.common_tags
}

locals {
  asg_tags = { for ng_tag in flatten([ for ng_name, ng in lookup(local.eks,"node_groups", {}): [ for index,tag in ng.asg_tags: "${ng_name}_${index}"  ] ]): ng_tag => local.eks.node_groups[split("_",ng_tag)[0]].asg_tags[parseint(split("_",ng_tag)[1],10)] }
}

resource "aws_autoscaling_group_tag" "tag" {
  for_each = local.asg_tags
  autoscaling_group_name = module.eks_cluster.node_groups[split("_",each.key)[0]].resources[0].autoscaling_groups[0].name

  tag {
    key   = each.value.key
    value = each.value.value
    propagate_at_launch = false
  }
}