# ---------------------------------------------------------------------------------------------------------------------
# COMMON TERRAGRUNT CONFIGURATION
# This is the common component configuration for mysql. The common variables for each environment to
# deploy mysql are defined here. This configuration will be merged into the environment configuration
# via an include block.
# ---------------------------------------------------------------------------------------------------------------------

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder. If any environment
# needs to deploy a different module version, it should redefine this block with a different ref to override the
# deployed version.
terraform {
  source = "${local.source_module.base_url}${local.source_module.version}"
}

# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env = local.environment_vars.locals.environment

  # Expose the base source URL so different versions of the module can be deployed in different environments. This will
  # be used to construct the terraform block in the child terragrunt configurations.
  module_vars   = read_terragrunt_config(find_in_parent_folders("modules.hcl"))
  source_module = local.module_vars.locals.aws_k8s_helm_w_iam

  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load region-level variables
  admin = read_terragrunt_config(find_in_parent_folders("admin.hcl"))

  dns = read_terragrunt_config(find_in_parent_folders("dns.hcl"))

  # Extract the variables we need for easy access
  account_name = local.account_vars.locals.account_name
  account_id   = local.account_vars.locals.aws_account_id
  aws_region   = local.region_vars.locals.aws_region

  zone_id = local.dns.locals.zone_id

}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"

  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${local.account_id}"]
}
provider "kubernetes" {
  
  host                   = "${dependency.eks.outputs.eks_endpoint}"
  cluster_ca_certificate = base64decode("${dependency.eks.outputs.eks_cluster_certificate_authority_data}")

  exec {
    api_version = "client.authentication.k8s.io/v1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", "logscale-${local.env}"]
  }
}
provider "kubectl" {
  apply_retry_count      = 10
  load_config_file       = false

  host                   = "${dependency.eks.outputs.eks_endpoint}"
  cluster_ca_certificate = base64decode("${dependency.eks.outputs.eks_cluster_certificate_authority_data}")

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", "logscale-${local.env}"]
  }
}
EOF
}
dependency "eks" {
  config_path = "${get_terragrunt_dir()}/../../platform/aws-eks/"
}
dependency "argocd_project" {
  config_path  = "${get_terragrunt_dir()}/../../platform/k8s-argocd-project/"
  skip_outputs = true
}


# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  uniqueName = "logscale-${local.env}"

  attach_external_dns_policy = true

  repository       = "https://charts.bitnami.com/bitnami"
  release          = "cw"
  chart            = "external-dns"
  chart_version    = "6.5.*"
  namespace        = "external-dns"
  create_namespace = true
  sa               = "external-dns"
  project          = "cluster-wide"

  values = yamldecode(<<EOF
topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: topology.kubernetes.io/zone
    whenUnsatisfiable: DoNotSchedule

replicaCount: 2
serviceAccount:
  name: external-dns
txtOwnerId: "logscale-${local.env}"

EOF 
  )

  value_arn = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"

  eks_oidc_provider_arn = dependency.eks.outputs.eks_oidc_provider_arn

  zone_id = local.zone_id
}