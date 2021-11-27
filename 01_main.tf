# Common local variables

locals {
  common_tags     = {
    Environment   = upper(var.environment)
  }

  region          = "eu-north-1"
  ami_id          = "ami-0d1bf5b68307103c2"

  vpc             = yamldecode(templatefile("./values/vpc.yaml", {}))
  eks             = yamldecode(templatefile("./values/eks.yaml", {
    "environment"         = var.environment
  }))
  iam_roles_eks   = yamldecode(templatefile("./values/iam_roles_eks.yaml", {}))
  iam_policies    = yamldecode(templatefile("./values/iam_policies.yaml", {
    "environment"         = var.environment,
    "account_id"          = data.aws_caller_identity.current.account_id
  }))
  security_groups = yamldecode(templatefile("./values/security_groups.yaml", {}))
  rds = yamldecode(templatefile("./values/rds.yaml", {}))
}

# Terraform and Providers configurations

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 3.5, != 3.14.0, < 4.0"
    }
    kubernetes  = ">= 2.4.1"
  }
  required_version = ">= 0.13"
}

provider "aws" {
  region = "eu-north-1"
}

provider "aws" {
  alias  = "paris"
  region = "us-west-3"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}