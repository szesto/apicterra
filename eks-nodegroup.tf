resource "aws_eks_node_group" "nodegroup" {
  cluster_name = var.eks_cluster

  node_group_name = "${var.eks_cluster}-worker-nodes"
  node_role_arn = aws_iam_role.node.arn

  scaling_config {
    min_size = 3
    max_size = 3
    desired_size = 3
  }

  subnet_ids = module.vpc.private_subnets[*]

  ami_type = "AL2_x86_64"
  disk_size = 20 
  instance_types = ["t3.2xlarge"]

  remote_access {
    # by default access to worker nodes is allowed from: 0.0.0.0/0
    ec2_ssh_key = var.eks_node_ssh_key
  }
}
