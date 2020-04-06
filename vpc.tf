module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.32.0"

  name = var.eks_vpc
  cidr = "10.0.0.0/16"

  azs = var.eks_availability_zones

  public_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  # one nat gw per subnet
  enable_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.eks_cluster}" = "shared"
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.eks_cluster}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}
