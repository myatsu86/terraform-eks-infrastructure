# resource "aws_eks_node_group" "example" {
#   cluster_name    = aws_eks_cluster.main.name
#   node_group_name = "${var.cluster_name}-nodegroup"
#   node_role_arn   = aws_iam_role.node.arn
#   subnet_ids      = aws_subnet.private[*].id
#   version         = var.kubernetes_version

#   scaling_config {
#     desired_size = var.desired_capacity
#     max_size     = var.max_capacity
#     min_size     = var.min_capacity
#   }

#   update_config {
#     max_unavailable = var.min_capacity
#   }


#   instance_types = var.instance_types
#   capacity_type  = "ON_DEMAND"
#   disk_size      = 20

#   labels = {
#     Environment = var.environment
#     NodeGroup   = "${var.cluster_name}-nodegroup"
#   }

#   tags = {
#     Name                                        = "${var.cluster_name}-nodegroup"
#     "kubernetes.io/cluster/${var.cluster_name}" = "owned"
#   }

#   depends_on = [
#     aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
#     aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
#     aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
#   ]
# }

# # Launch Template for custom node configuration (optional, for advanced use cases)
# resource "aws_launch_template" "node" {
#   name_prefix = "${var.cluster_name}-node-lt-"
#   description = "Launch template for EKS node group"

#   block_device_mappings {
#     device_name = "/dev/xvda"

#     ebs {
#       volume_size           = 20
#       volume_type           = "gp3"
#       delete_on_termination = true
#       encrypted             = true
#     }
#   }

#   metadata_options {
#     http_endpoint               = "enabled"
#     http_tokens                 = "required"
#     http_put_response_hop_limit = 1
#   }

#   monitoring {
#     enabled = true
#   }

#   network_interfaces {
#     associate_public_ip_address = false
#     delete_on_termination       = true
#     security_groups             = [aws_security_group.node.id]
#   }

#   tag_specifications {
#     resource_type = "instance"

#     tags = {
#       Name                                        = "${var.cluster_name}-node"
#       "kubernetes.io/cluster/${var.cluster_name}" = "owned"
#     }
#   }

#   user_data = base64encode(templatefile("${path.module}/user-data.sh.tpl", {
#     cluster_name     = var.cluster_name
#     cluster_endpoint = aws_eks_cluster.main.endpoint
#     cluster_ca       = aws_eks_cluster.main.certificate_authority[0].data
#   }))

#   tags = {
#     Name = "${var.cluster_name}-node-lt"
#   }
# }

# EKS Node Group
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-nodegroup"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = aws_subnet.private[*].id
  version         = var.kubernetes_version

  scaling_config {
    desired_size = var.desired_capacity
    max_size     = var.max_capacity
    min_size     = var.min_capacity
  }

  update_config {
    max_unavailable = 1
  }

  instance_types = var.instance_types
  capacity_type  = "ON_DEMAND"
  disk_size      = 20

  labels = {
    Environment = var.environment
    NodeGroup   = "${var.cluster_name}-nodegroup"
  }

  tags = {
    Name                                        = "${var.cluster_name}-nodegroup"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
  ]
}