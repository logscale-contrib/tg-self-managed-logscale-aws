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
  # Automatically load modules variables
  module_vars   = read_terragrunt_config(find_in_parent_folders("modules.hcl"))
  source_module = local.module_vars.locals.vpc

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env = local.environment_vars.locals.environment

}


# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  name = "logscale-${local.env}"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]
  public_subnets  = ["10.0.48.0/20", "10.0.64.0/20", "10.0.80.0/20"]

  enable_nat_gateway     = true
  enable_vpn_gateway     = false
  single_nat_gateway     = true
  enable_dns_hostnames   = true
  one_nat_gateway_per_az = false


  enable_flow_log                      = true
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true

  # enable_ipv6                     = true
  # assign_ipv6_address_on_creation = true

  # private_subnet_assign_ipv6_address_on_creation = false

  # public_subnet_ipv6_prefixes  = [0, 1, 2]
  # private_subnet_ipv6_prefixes = [3, 4, 5]

  public_subnet_tags = {
    # "kubernetes.io/cluster/logscale-${local.env}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
    # "karpenter.sh/discovery"                      = "logscale-${local.env}"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/logscale-${local.env}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
    "karpenter.sh/discovery"                      = "logscale-${local.env}"
  }

}