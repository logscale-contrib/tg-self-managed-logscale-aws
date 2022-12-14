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

  # Extract the variables we need for easy access
  account_name = local.account_vars.locals.account_name
  account_id   = local.account_vars.locals.aws_account_id
  aws_region   = local.region_vars.locals.aws_region

}

dependency "eks" {
  config_path = "${get_terragrunt_dir()}/../eks/"
}
generate "provider" {
  path      = "provider_k8s.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
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
provider "helm" {
  kubernetes {
    host                   = "${dependency.eks.outputs.eks_endpoint}"
    cluster_ca_certificate = base64decode("${dependency.eks.outputs.eks_cluster_certificate_authority_data}")

    exec {
      api_version = "client.authentication.k8s.io/v1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", "logscale-${local.env}"]
    }
  }
}
EOF
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  uniqueName = "logscale-${local.env}"

  attach_ebs_csi_policy = true

  repository       = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  release          = "ebs-csi"
  chart            = "aws-ebs-csi-driver"
  chart_version    = "2.10.*"
  namespace        = "kube-system"
  create_namespace = false
  sa               = "ebs-csi-controller-sa"
  project          = "cluster-wide"

  values = [<<EOF
controller:
    topologySpreadConstraints:
    - maxSkew: 1
      topologyKey: topology.kubernetes.io/zone
      whenUnsatisfiable: DoNotSchedule
storageClasses: 
- name: ebs-gp3-enc
  volumeBindingMode: WaitForFirstConsumer
  reclaimPolicy: Delete
  parameters:
    encrypted: "true"
    type: gp3
    csi.storage.k8s.io/fstype: "ext4" 
    allowautoiopspergbincrease: "true"
- name: ebs-gp3-noenc
  volumeBindingMode: WaitForFirstConsumer
  reclaimPolicy: Delete
  parameters:
    encrypted: "false"
    type: gp3
    csi.storage.k8s.io/fstype: "ext4" 
    allowautoiopspergbincrease: "true"
node:
    tolerations:
    #Any tolerations used to control pod deployment should be here
    - operator: "Exists"
EOF
  ]


  value_arn = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"

  eks_oidc_provider_arn = dependency.eks.outputs.eks_oidc_provider_arn

}