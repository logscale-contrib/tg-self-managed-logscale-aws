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
    version  = "?ref=v1.2.1"
  }

  aws_k8s_helm_w_iam = {
    base_url = "git::git@github.com:logscale-contrib/tf-self-managed-logscale-aws-k8s-helm-with-iam.git"
    version  = "?ref=v1.5.1"
  }
  eks_karpenter = {
    base_url = "git::git@github.com:logscale-contrib/tf-self-managed-logscale-aws-k8s-karpenter.git"
    version  = "?ref=v1.3.0"
  }
  eks_linkerd_ta = {
    base_url = "git::git@github.com:logscale-contrib/terraform-k8s-linkerd-trust-anchor.git"
    version  = "?ref=v1.0.20"
  }

  k8s_ns = {
    base_url = "git::git@github.com:logscale-contrib/terraform-k8s-namespace.git"
    version  = "?ref=v1.0.0"
  }

  k8s_helm = {
    base_url = "git::git@github.com:logscale-contrib/tf-self-managed-logscale-k8s-helm.git"
    version  = "?ref=v1.3.0"
  }
  helm_release = {
    base_url = "tfr:///terraform-module/release/helm"
    version  = "?version=2.8.0"
  }
  argocd_project = {
    #base_url = "tfr:///project-octal/k8s-argocd-project/kubernetes"
    #version  = "?version=2.0.0"
    base_url = "git::git@github.com:logscale-contrib/terraform-kubernetes-argocd-project.git"
    version  = ""

  }

}