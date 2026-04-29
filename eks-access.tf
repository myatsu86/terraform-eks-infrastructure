# EKS Cluster Access Entries for admins
resource "aws_eks_access_entry" "admin" {
  count = length(var.cluster_admin_arns)

  cluster_name  = aws_eks_cluster.main.name
  principal_arn = var.cluster_admin_arns[count.index]
  type          = "STANDARD"

  tags = {
    Name = "${var.cluster_name}-admin-access-${count.index}"
  }
}

# Associate Admin Policy
resource "aws_eks_access_policy_association" "admin" {
  count = length(var.cluster_admin_arns)

  cluster_name  = aws_eks_cluster.main.name
  principal_arn = var.cluster_admin_arns[count.index]
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.admin]
}