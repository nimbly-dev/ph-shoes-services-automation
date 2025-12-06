variable "cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "vpc_id" {
  description = "VPC where the ECS instances live"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for the Auto Scaling Group"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type for ECS hosts"
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  type    = number
  default = 0
}

variable "max_size" {
  type    = number
  default = 1
}

variable "desired_capacity" {
  type    = number
  default = 0
}

variable "key_name" {
  description = "Optional EC2 key pair for SSH"
  type        = string
  default     = ""
}

variable "instance_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 20
}

variable "instance_ingress_rules" {
  description = "Ingress rules for the ECS instance security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "tags" {
  description = "Tags applied to resources"
  type        = map(string)
  default     = {}
}
