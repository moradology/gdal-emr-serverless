variable "aws_region" {
  description = "AWS region where the ECR repository will be created"
  type        = string
  default     = "us-east-1"
}

variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "The tag mutability settings for the repository"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository"
  type        = bool
  default     = true
}

variable "force_delete_ecr" {
  description = "Indicates whether terraform destroy should force deletion of repo even if images exist"
  type        = bool
  default     = true
}