variable "emr_name" {
  description = "The EMR cluster name"
  type        = string
  default     = "deployment_test"

}

variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
  default     = "us-east-1"
}

variable "emr_release_label" {
  description = "The EMR release to build"
  type        = string
  default     = "emr-6.9.0"
}

variable "repository_name" {
  description = "The ECR repository name to be used by our EMR deployment"
  type        = string
  default     = "gdal_emr_serverless"
}

variable "execution_role_template" {
  description = "Path to the template defining an EMR execution role to be created"
  type        = string
  default     = "./emr/execution_role.json.tpl"
}
