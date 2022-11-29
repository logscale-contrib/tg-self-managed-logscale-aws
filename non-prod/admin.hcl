

# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  aws_admin_arn = "arn:aws:iam::473367108367:user/rfaircloth-dev-mb"
}