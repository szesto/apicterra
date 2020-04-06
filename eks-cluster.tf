# EKS Cluster Resources

resource "aws_eks_cluster" "eks" {
  name = var.eks_cluster

  version = "1.15"

  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    security_group_ids = [module.cluster-sg.this_security_group_id]
    subnet_ids         = concat(module.vpc.private_subnets[*], module.vpc.public_subnets[*])
    endpoint_private_access = false
    endpoint_public_access = true
  }

#  enabled_cluster_log_types = ["api", "audit"]

  depends_on = [
    aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster-AmazonEKSServicePolicy,
  ]
}
