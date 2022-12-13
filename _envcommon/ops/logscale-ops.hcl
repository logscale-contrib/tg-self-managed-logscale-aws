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

  dns = read_terragrunt_config(find_in_parent_folders("dns.hcl"))

  domain_name = local.dns.locals.domain_name

  humio                    = read_terragrunt_config(find_in_parent_folders("humio.hcl"))
  humio_rootUser           = local.humio.locals.humio_rootUser
  humio_license            = local.humio.locals.humio_license
  humio_sso_idpCertificate = local.humio.locals.humio_sso_idpCertificate
  humio_sso_signOnUrl      = local.humio.locals.humio_sso_signOnUrl
  humio_sso_entityID       = local.humio.locals.humio_sso_entityID
}
dependency "eks" {
  config_path = "${get_terragrunt_dir()}/../../aws/infra/eks/"
}
dependency "acm_ui" {
  config_path = "${get_terragrunt_dir()}/../../aws/infra/acm-ui/"
}
dependency "bucket" {
  config_path = "${get_terragrunt_dir()}/../aws-logscale-ops-bucket_iam/"
}
dependencies {
  paths = [
    "${get_terragrunt_dir()}/../logscale-ops-zookeeper/",
    "${get_terragrunt_dir()}/../logscale-ops-otel/",
    "${get_terragrunt_dir()}/../logscale-ops-strimzi/",
    "${get_terragrunt_dir()}/../logscale-ops-project/"
  ]
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

  repository = "https://logscale-contrib.github.io/helm-logscale"

  release          = "ops"
  chart            = "helm-logscale"
  chart_version    = "1.1.8"
  namespace        = "logscale-ops"
  create_namespace = false
  project          = "logscale-ops"

  values = {
    platform = "aws"
    humio = {
      s3mode            = "aws"
      kafkaManager      = "strimzi"
      kafkaPrefixEnable = true
      strimziCluster    = "ops-logscale-strimzi-kafka"
      fqdn              = "logscale-ops.${local.domain_name}"
      rootUser          = local.humio_rootUser
      license           = local.humio_license
      image = {
        tag = "1.68.0--SNAPSHOT--build-312111--SHA-373d3ce6166cbbe26b82ae3f31c5a41212f7da25"
      }
      sso = {
        idpCertificate = local.humio_sso_idpCertificate
        signOnUrl      = local.humio_sso_signOnUrl
        entityID       = local.humio_sso_entityID
      }
      serviceAccount = {
        name = "logscale-ops"
        annotations = {
          "eks.amazonaws.com/role-arn" = dependency.bucket.outputs.iam_role_arn
        }
      }

      buckets = {
        region  = local.aws_region
        storage = dependency.bucket.outputs.s3_bucket_id
      }
      podAnnotations = {
        "config.linkerd.io/skip-outbound-ports" = "443"
        #"sidecar.opentelemetry.io/inject": "true"
        "instrumentation.opentelemetry.io/inject-java" : "true"
        "instrumentation.opentelemetry.io/container-names" : "humio"
      }
      nodeCount = 3
      resources = {
        requests = {
          memory = "2Gi"
          cpu    = 2
        }
        limits = {
          memory = "4Gi"
          cpu    = 4
        }
      }
      affinity = {
        nodeAffinity = {
          requiredDuringSchedulingIgnoredDuringExecution = {
            nodeSelectorTerms = [
              {
                matchExpressions = [
                  {
                    key      = "kubernetes.io/arch"
                    operator = "In"
                    values   = ["amd64"]
                  },
                  {
                    key      = "kubernetes.io/os"
                    operator = "In"
                    values   = ["linux"]
                  }
                ]
              }
            ]
          }
        }
        podAntiAffinity = {
          requiredDuringSchedulingIgnoredDuringExecution = [
            {
              labelSelector = {
                matchExpressions = [
                  {
                    key      = "app.kubernetes.io/instance"
                    operator = "In"
                    values = [
                      "ops-humio-cluster"
                    ]
                  }
                ]
              }
              topologyKey = "kubernetes.io/hostname"
            }
          ]
        }
      }
      config = {
        dataVolumePersistentVolumeClaimSpecTemplate = {
          accessModes = [
            "ReadWriteOnce"
          ]
          resources = {
            requests = {
              storage = "100Gi"
            }
          }
          storageClassName = "ebs-gp3-enc"
        }
      }
      externalzookeeperHostname = "ops-zookeeper-headless:2181"
      externalKafkaHostname     = "ops-logscale-strimzi-kafka-kafka-bootstrap:9092"
      service = {
        type = "ClusterIP"
      }
      ingress = {
        enabled = true
        tls     = false
        annotations = {
          "alb.ingress.kubernetes.io/certificate-arn" = dependency.acm_ui.outputs.acm_certificate_arn
          "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
          "alb.ingress.kubernetes.io/ssl-redirect"    = "443"
          "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
          "alb.ingress.kubernetes.io/target-type"     = "ip"
          "alb.ingress.kubernetes.io/group.name"      = "logscale-${local.env}"
          "external-dns.alpha.kubernetes.io/hostname" = "logscale-ops.${local.domain_name}"
        }
        className = "alb"
      }
    }
    opentelemetryOperator = {
      enabled = true
    }


  }
}
