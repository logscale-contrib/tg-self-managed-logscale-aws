#This file contains all external modules and versions

locals {
  vpc = {
    base_url = "tfr:///terraform-aws-modules/vpc/aws"
    version  = "?version=3.16.0"
  }
  aws_acm = {
    base_url = "tfr:///terraform-aws-modules/acm/aws"
    version  = "?version=4.1.0"
  }
  eks = {
    base_url = "git::git@github.com:logscale-contrib/tf-self-managed-logscale-aws-k8s-cluster.git"
    version  = "?ref=v1.0.0"
  }
  aws_k8s_helm_w_iam = {
    base_url = "git::git@github.com:logscale-contrib/tf-self-managed-logscale-aws-k8s-helm-with-iam.git"
    version  = "?ref=v1.0.0"
  }
  aws_k8s_argocd = {
    base_url = "git::git@github.com:logscale-contrib/tf-self-managed-logscale-common-argocd.git"
    version  = "?ref=v1.0.0"
  }
  eks_karpenter = {
    base_url = "git::git@github.com:logscale-contrib/tf-self-managed-logscale-aws-k8s-karpenter.git"
    version  = "?ref=v1.0.0"
  }
  eks_linkerd = {
    base_url = "git::git@github.com:logscale-contrib/tf-self-managed-logscale-aws-k8s-helm-with-iam.git"
    version  = "?ref=v1.0.0"
  }
}