

# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  aws_admin_arn = "arn:aws:iam::397791650528:user/cs-mb"
}