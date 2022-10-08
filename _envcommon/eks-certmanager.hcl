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

dependency "eks" {
  config_path = "${get_terragrunt_dir()}/../eks/"
}

dependency "externaldns" {
  config_path  = "${get_terragrunt_dir()}/../eks-externaldns/"
  skip_outputs = true
}


# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  uniqueName = "logscale_${local.env}"

  attach_cert_manager_policy = true

  repository       = "https://charts.jetstack.io"
  release          = "main"
  chart            = "cert-manager"
  chart_version    = "1.9.1"
  namespace        = "cert-manager"
  create_namespace = true
  sa               = "cert-manager"

  values = [<<EOF
topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: topology.kubernetes.io/zone
    whenUnsatisfiable: DoNotSchedule

installCRDs: true

replicaCount: 2
webhook:
  replicaCount: 2
cainjector:
  replicaCount: 2
serviceAccount:
  create: true
  name: cert-manager
admissionWebhooks:
  certManager:
    enabled: true


EOF 
  ]

  value_arn = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"

  eks_cluster_id                         = dependency.eks.outputs.eks_cluster_id
  eks_endpoint                           = dependency.eks.outputs.eks_endpoint
  eks_cluster_certificate_authority_data = dependency.eks.outputs.eks_cluster_certificate_authority_data
  eks_oidc_provider_arn                  = dependency.eks.outputs.eks_oidc_provider_arn

  zone_id = local.zone_id
}