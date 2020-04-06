provider "aws" {
   profile = "default"
   region = var.eks_region
   version = "~> 2.54"
}

