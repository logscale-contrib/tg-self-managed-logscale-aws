
locals {
  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  aws_region  = local.region_vars.locals.aws_region

  # Extract the variables we need for easy access
  account_id = local.account_vars.locals.aws_account_id

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  env = local.environment_vars.locals.environment

  cluster_endpoint       = run_cmd("sh", "-c", "aws eks describe-cluster --name logscale-${local.env} --region ${local.aws_region} | jq -r .cluster.endpoint")
  cluster_ca_certificate = base64decode(run_cmd("sh", "-c", "aws eks describe-cluster --name logscale-${local.env} --region ${local.aws_region} | jq -r .cluster.certificateAuthority.data"))
}

# Generate an AWS provider block
generate "provider_k8s" {
  path      = "provider_k8s.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "kubernetes" {
  
  host                   = "${local.cluster_endpoint}"
  cluster_ca_certificate = <<INNEREOT
${local.cluster_ca_certificate}
INNEREOT

  exec {
    api_version = "client.authentication.k8s.io/v1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", "logscale-${local.env}"]
  }
}
EOF
}