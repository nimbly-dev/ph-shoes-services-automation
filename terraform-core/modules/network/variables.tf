variable "vpc_cidr" {
  description = "CIDR block for the new VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "Explicit AZs for the subnets (optional)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
