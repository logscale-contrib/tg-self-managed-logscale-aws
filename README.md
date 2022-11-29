# humio-infra-aws-eks-base

This project serves as a reference deployment for Humio on AWS EKS:

The approach taken is to use terraform to deploy components to azure 
in sequence to avoid cross service dependency challanges with terraform.

A typical deployment for non production use will provision the following 
AWS resources

* S3 Account
* EKS Cluster >v1.23.0

# Access Requirements

This toolkit will utilize the default AWS credentials of the user profile
executing the commands. See [Configuring AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)

## Optional if using a model with spot instances for ingest

```bash
aws iam create-service-linked-role --aws-service-name spot.amazonaws.com
```

# Requirements

This reference deployent uses [terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/) and [terraform](https://www.terraform.io/downloads)

Both executables must be available in path

# Configuration

Create a variables file as follows `stack.tfvars`

```text
domain_name              = "rfaircloth.com"
humio_rootUser           = "ryan@dss-i.com"
humio_license            = "eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzUxMiJ9"
humio_sso_idpCertificate = <<-EOT
-----BEGIN CERTIFICATE-----
MIIDdDCCAlygAwIBAgIGAYDb5DpjMA0GCSqGSIb3DQEBCwUAMHsxFDASBgNVBAoTC0dvb2dsZSBJ
bmMuMRYwFAYDVQQHEw1Nb3VudGFpbiBWaWV3MQ8wDQYDVQQDEwZHb29nbGUxGDAWBgNVBAsTD0dv
b2dsZSBGb3IgV29yazELMAkGA1UEBhMCVVMxEzARBgNVBAgTCkNhbGlmb3JuaWEwHhcNMjIwNTE5
MTAzNjQ4WhcNMjcwNTE4MTAzNjQ4WjB7MRQwEgYDVQQKEwtHb29nbGUgSW5jLjEWMBQGA1UEBxMN
TW91bnRhaW4gVmlldzEPMA0GA1UEAxMGR29vZ2xlMRgwFgYDVQQLEw9Hb29nbGUgRm9yIFdvcmsx
CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpDYWxpZm9ybmlhMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A
MIIBCgKCAQEAoQEsZwNm5F8v9wP5tHhD9udu95HhVwOjepcXP5oZWtaAn3pSj/eXFJ/XXwLKMzFJ
erg9zTu8uqfmWlSqBKjmXDch1jcX5BZI2tYpObQerjSeEjhbJXGRV0Tj/8i7KWk7b5PMasDEmQpW
BdEMgqe35hWaatoS5MtSW3rkdMWdqrjdIsOP4n7PQNm86nFY28VmkzN9+luWYxA7AwK09D9JxThE
aw5p5VCw1HK0AHoaOyfC1BWt2xL3PtRIWzwLlBUbaFoIIhjahDfex40q0YDw49mzBpIjUENr5Vcv
AURNwYZqw+mgG4ViR/GWPPftzyJyEoOOXFwt/gVkx/OxgzssZwIDAQABMA0GCSqGSIb3DQEBCwUA
A4IBAQAMZXfKqDT3W5cdlFsC7fRMfN1NSW03j7kK4SsKUXHi/X7COBN2nIP3evx8bkEemT1OT9Rr
ZWL+f0NMUBVrKTbrDdhH2tQ0mxYehVeyzXj6jT8avMYhB0c0N5WTXSSW+8Ida+qwZozXFxqda/t/
NpKOzwJYXLmH1calsoGnLGtr1su8Z6DrG9cQTbPk5NPxZKAqgT2LW1h4B/mFrf0loTXqTrpKMGaD
NeMDalHWBxq77PtxUfUg8K5SP//FgLfiAK56n0uzt/J2MZ6ZbJOnN/HoqGvQ4PvGR998/fH6MrW6
+lRTBBUDC0saTEYlp6TWkFib7Ub6LcWbncZJY1O3L2ZZ
-----END CERTIFICATE-----
EOT
humio_sso_signOnUrl      = "https://accounts.google.com/o/saml2/idp?idpid=C011isbhl"
humio_sso_entityID       = "https://accounts.google.com/o/saml2?idpid=C011isbhl"

#Replace the following ARD with a user given admin access to the cluster
aws_admin_arn = "arn:aws:iam::397791650528:user/cs-mb"

infra_type       = "aws"
humio_arch_model = "micro"
```


# Apply

Using terragrunt to deploy all required resources. 

```bash
terragrunt run-all apply -var-file=$(pwd)/stack.tfvars 
```