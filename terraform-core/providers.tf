terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.93"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

provider "aws" {
  alias  = "ecr_public"
  region = "us-east-1"

  default_tags {
    tags = local.common_tags
  }
}
provider "cloudflare" {
  api_token = var.cloudflare_api_token != "" ? var.cloudflare_api_token : "dummy"
}