terraform {
  backend "s3" {
    bucket         = "ph-shoes-terraform-state"
    key            = "services-tf-state/deployments/service.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "ph-shoes-terraform-locks"
    encrypt        = true
  }
}
