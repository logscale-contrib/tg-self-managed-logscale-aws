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


  repository       = "ghcr.io/logscale-contrib/helm-logscale-strimzi-kafka/charts"
  release          = "ops"
  chart            = "logscale-strimzi-kafka"
  chart_version    = "1.0.*"
  namespace        = "logscale-ops"
  create_namespace = false
  project          = "logscale-ops"

  values = yamldecode(<<EOF
#Note: Kafka is a subchart
kafka:
  # affinity:
  #   nodeAffinity:
  #     requiredDuringSchedulingIgnoredDuringExecution:
  #       nodeSelectorTerms:
  #         - matchExpressions:
  #             - key: kubernetes.azure.com/agentpool
  #               operator: In
  #               values:
  #                 - compute1
  #                 - compute2
  #   podAntiAffinity:
  #     requiredDuringSchedulingIgnoredDuringExecution:
  #       - labelSelector:
  #           matchExpressions:
  #             - key: strimzi.io/name
  #               operator: In
  #               values:
  #                 - "ops-kafka-kafkacluster-kafka"
  #         topologyKey: kubernetes.io/hostname
  topologySpreadConstraints:
    - maxSkew: 1
      topologyKey: topology.kubernetes.io/zone
      whenUnsatisfiable: DoNotSchedule
      labelSelector:
        matchExpressions:
          - key: strimzi.io/name
            operator: In
            values:
              - "ops-kafka-kafkacluster-kafka"

  # At least 3 replicas are required the number of replicas must be at east 3 and evenly
  # divisible by number of zones
  # The Following Configuration is valid for approximatly 1TB/day
  # ref: https://library.humio.com/humio-server/installation-prep.html#installation-prep-rec
  replicas: 3
  resources:
    requests:
      # Increase the memory as needed to support more than 5/TB day
      memory: 2Gi
      #Note the following resources are expected to support 1-3 TB/Day however
      # storage is sized for 1TB/day increase the storage to match the expected load
      cpu: 1
    limits:
      memory: 2Gi
      cpu: 2
  #(total ingest uncompressed per day / 5 ) * 3 / ReplicaCount
  # ReplicaCount must be odd and greater than 3 should be divisible by AZ
  # Example: 1 TB/Day '1/5*3/3=205' 3 Replcias may not survive a zone failure at peak
  # Example:  1 TB/Day '1/5*3/6=103' 6 ensures at least one node per zone
  # 100 GB should be the smallest disk used for Kafka this may result in some waste
  storage:
    type: persistent-claim
    size: 50Gi
    deleteClaim: true
    #Must be SSD or NVME like storage IOPs is the primary node constraint
    class: ebs-gp3-enc
zookeeper:
  # affinity:
  #   nodeAffinity:
  #     requiredDuringSchedulingIgnoredDuringExecution:
  #       nodeSelectorTerms:
  #         - matchExpressions:
  #             - key: kubernetes.azure.com/agentpool
  #               operator: In
  #               values:
  #                 - compute1
  #                 - compute2
  #   podAntiAffinity:
  #     requiredDuringSchedulingIgnoredDuringExecution:
  #       - labelSelector:
  #           matchExpressions:
  #             - key: strimzi.io/name
  #               operator: In
  #               values:
  #                 - "ops-kafka-kafkacluster-zookeeper"
  #         topologyKey: kubernetes.io/hostname
  topologySpreadConstraints:
    - maxSkew: 1
      topologyKey: topology.kubernetes.io/zone
      whenUnsatisfiable: DoNotSchedule
      labelSelector:
        matchExpressions:
          - key: strimzi.io/name
            operator: In
            values:
              - "ops-kafka-kafkacluster-zookeeper"
  resources:
    requests:
      memory: 1Gi
      cpu: "250m"
    limits:
      memory: 2Gi
      cpu: "1"
  storage:
    deleteClaim: true
    type: persistent-claim
    size: 10Gi
    class: ebs-gp3-enc

EOF
  )

}
