variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "emr-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability Zones for the VPC"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "private_subnets" {
  description = "List of private subnets within the VPC"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets" {
  description = "List of public subnets within the VPC"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "single_nat_gateway" {
  description = "Flag to create a single NAT Gateway"
  type        = bool
  default     = true
}

variable "one_nat_gateway_per_az" {
  description = "Flag to create one NAT Gateway per Availability Zone"
  type        = bool
  default     = false
}
