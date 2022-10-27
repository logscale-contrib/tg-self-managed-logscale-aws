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
  source_module = local.module_vars.locals.k8s_helm

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
dependencies {
  paths = [
    "${get_terragrunt_dir()}/../logscale-ops-otel/",
    "${get_terragrunt_dir()}/../logscale-ops-project/"
  ]
}
# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  uniqueName = "logscale-${local.env}"


  repository       = "https://charts.bitnami.com/bitnami"
  release          = "ops"
  chart            = "zookeeper"
  chart_version    = "10.0.*"
  namespace        = "logscale-ops"
  create_namespace = false
  project          = "logscale-ops"

  values = yamldecode(<<EOF
autopurge:
  purgeInterval: 1
#jvmFlags: "-XX:+HeapDumpOnOutOfMemoryError -XX:OnOutOfMemoryError='kill -9 %p'"
replicaCount: 5
fourlwCommandsWhitelist: srvr, mntr, ruok, stat
auth:
  client: 
    enabled: true
    createSecret: true
    clientUser: logscale
    clientPassword: sddadasadfsdfsd  
    serverUsers: admin
    serverPasswords: sdfsdfdsfsdf
pdb:
  create: true
metrics:
  enabled: true
persistence:
  storageClass: ebs-gp3-enc
  size: 10Gi
affinity:
#   nodeAffinity:
#     requiredDuringSchedulingIgnoredDuringExecution:
#       nodeSelectorTerms:
#         - matchExpressions:
#             - key: beta.humio.com/pool
#               operator: In
#               values:
#                 - compute
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
            - key: app.kubernetes.io/instance
              operator: In
              values:
                - "ops"
            - key: app.kubernetes.io/component
              operator: In
              values:
                - "zookeeper"
            - key: app.kubernetes.io/name
              operator: In
              values:
                - "zookeeper"                
        topologyKey: kubernetes.io/hostname
topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: topology.kubernetes.io/zone
    whenUnsatisfiable: DoNotSchedule
    labelSelector:
      matchExpressions:
        - key: app.kubernetes.io/instance
          operator: In
          values:
            - "ops"

EOF
  )

}
