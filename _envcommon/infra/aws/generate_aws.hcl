
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


  tag_vars = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  tags = jsonencode(merge(
    local.tag_vars.locals.tags,
    {
      Environment   = local.env
      Owner         = get_aws_caller_identity_user_id()
      GitRepository = run_cmd("sh", "-c", "git config --get remote.origin.url")
    },
  ))


}

# Generate an AWS provider block
generate "provider_aws" {
  path      = "provider_aws.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
    region = "${local.aws_region}"

    # Only these AWS Account IDs may be operated on by this template
    allowed_account_ids = ["${local.account_id}"]

    default_tags {
        tags = jsondecode(<<INNEREOF
${local.tags}
INNEREOF
)
    }
}
EOF
}