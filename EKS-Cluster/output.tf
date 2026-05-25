output "account_id" {
  description = "AWS Account ID"
  value = data.aws_caller_identity.current.account_id
}

output "cluster_name" {
  description = "EKS Cluster Name"
  value = aws_eks_cluster.aws_eks.name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = aws_eks_cluster.aws_eks.endpoint
}

output "cluster_public_access_cidrs" {
  description = "CIDR blocks allowed to access the public Kubernetes API endpoint"
  value       = aws_eks_cluster.aws_eks.vpc_config[0].public_access_cidrs
}
