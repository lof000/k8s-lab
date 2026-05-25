locals {
    arn_elements = split(":", data.aws_caller_identity.current.arn)
    caller_name = substr(local.arn_elements[length(local.arn_elements)-1], 5, -1)
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "${var.az1}"

  tags = {
    Name = "Default subnet for az1."
  }
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = "${var.az2}"

  tags = {
    Name = "Default subnet for az2.."
  }
}

resource "aws_eks_cluster" "aws_eks" {
  #name     = "${var.cluster-name}-${local.caller_name}"
  name     = "${var.cluster-name}"
  role_arn = aws_iam_role.eks_cluster.arn
#  version  = "1.24"

  vpc_config {
    subnet_ids             = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
    endpoint_public_access = true
    public_access_cidrs    = var.cluster_api_public_access_cidrs
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
  ]

  tags = {
    Name = var.cluster-name,
  }
}

resource "aws_eks_node_group" "node" {
  cluster_name    = aws_eks_cluster.aws_eks.name
  node_group_name = "ng_${var.cluster-name}"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = [aws_default_subnet.default_az1.id]


  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

  # Optional: Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

# Set up local kubectl credential and context
resource "time_sleep" "wait_for_kube" {
  depends_on = [aws_eks_cluster.aws_eks]
  # EKS master endpoint may not be immediately accessible, resulting in error, waiting does the trick
  create_duration = "30s"
}

resource "null_resource" "local_k8s_context" {
  depends_on = [time_sleep.wait_for_kube]
  provisioner "local-exec" {
    # Update your local eks and kubectl credentials for the newly created cluster
    command = "export AWS_DEFAULT_PROFILE=${var.profile}; for i in 1 2 3 4 5; do aws eks --region ${var.region}  update-kubeconfig --name ${aws_eks_cluster.aws_eks.name} && break || sleep 60; done"    
  }
}

#install add-ons
#resource "aws_eks_addon" "addons"{
#  depends_on = [aws_eks_cluster.aws_eks]
#  cluster_name      = "${var.cluster-name}-${local.caller_name}"
#  addon_name        = "aws-ebs-csi-driver"
#  addon_version     = "v1.15.0-eksbuild.1"
#  resolve_conflicts = "OVERWRITE"
#  service_account_role_arn = "arn:aws:iam::857039790457:role/AmazonEKS_EBS_CSI_DriverRole"
#} 
