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
  source_module = local.module_vars.locals.helm_release

  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load region-level variables
  admin = read_terragrunt_config(find_in_parent_folders("admin.hcl"))

  # Extract the variables we need for easy access
  account_name = local.account_vars.locals.account_name
  account_id   = local.account_vars.locals.aws_account_id
  aws_region   = local.region_vars.locals.aws_region


}

dependency "eks" {
  config_path = "${get_terragrunt_dir()}/../../aws/infra/eks/"
}
dependency "linkerdTA" {
  config_path = "${get_terragrunt_dir()}/../k8s-linkerd-ta/"
}
dependencies {
  paths = [
    "${get_terragrunt_dir()}/../k8s-linkerd-ns-linkerd-viz/",
    "${get_terragrunt_dir()}/../k8s-linkerd-cp/"
  ]
}


# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  repository = "https://helm.linkerd.io/stable"
  namespace  = "linkerd-viz"

  app = {
    name             = "cw-viz"
    chart            = "linkerd-viz"
    version          = "30.3.*"
    create_namespace = false


    deploy = 1
  }

  values = [yamlencode(
    {
      "tap" = {
        "externalSecret" = true
        "caBundle"       = dependency.linkerdTA.outputs.trustAnchorPEM
      }
      "tapInjector" = {
        "externalSecret" = true
        "caBundle"       = dependency.linkerdTA.outputs.trustAnchorPEM
      }
    }
  )]
}