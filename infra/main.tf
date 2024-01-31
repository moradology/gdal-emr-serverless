provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Environment = terraform.workspace
      Terraform   = true
    }
  }
}

# data fields to get account, region, etc
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  is_default_workspace = terraform.workspace == "default" ? true : false
  ecr_repo_name = join("_", [var.repository_name, terraform.workspace])
  emr_app_name  = join("_", [var.emr_name, terraform.workspace])
}

# Fail if workspace is not set
# For details: https://developer.hashicorp.com/terraform/language/state/workspaces#using-workspaces
resource "null_resource" "fail_if_default_workspace" {
  triggers = {
    is_default_workspace = local.is_default_workspace
  }

  provisioner "local-exec" {
    command = "if ${self.triggers.is_default_workspace}; then echo 'A terraform workspace must be explicitly set!' >&2; exit 1; fi"
  }
}


# VPC Module
module "vpc" {
  source = "./vpc"
  depends_on = [null_resource.fail_if_default_workspace]
}

# ECR Module
module "ecr" {
  source = "./ecr"
  repository_name = local.ecr_repo_name
  depends_on = [null_resource.fail_if_default_workspace]
}

# Build container and push it
resource "null_resource" "build_and_push_image" {
  provisioner "local-exec" {
    command = "bash manage_docker.sh push ${module.ecr.repository_url} ${var.emr_release_label}"
  }
  depends_on = [null_resource.fail_if_default_workspace, module.ecr]
}

data "external" "check_image_pushed" {
  program = ["bash", "-c", "echo '{\"result\": \"Image Pushed Successfully\"}'"]
  depends_on = [null_resource.fail_if_default_workspace, null_resource.build_and_push_image]
}

# EMR Serverless Module
module "emr_serverless" {
  source = "./emr"
  name = local.emr_app_name
  release_label = var.emr_release_label
  image_uri = "${module.ecr.repository_url}:latest"
  private_subnet_ids = module.vpc.private_subnet_ids
  emr_sg_ids = [module.security_groups.emr_sg_id]
  account_id = data.aws_caller_identity.current.account_id
  region = data.aws_region.current.name
  ecr_repository_name = local.ecr_repo_name
  execution_role_template = var.execution_role_template
  depends_on = [null_resource.fail_if_default_workspace, data.external.check_image_pushed]
}

# Security Groups Module
module "security_groups" {
  source = "./security_groups"
  vpc_id  = module.vpc.vpc_id
}