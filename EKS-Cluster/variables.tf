variable "cluster-name" {
  default = "eks_lab"
  type    = string
  description = "eks clustar name"
}

variable "profile" {
  description = "AWS profile"
  type        = string
  default     = "default"
}

variable "region" {
  description = "AWS region to deploy to"
  default     = "us-east-1"
  type        = string
}

variable "az1" {
  description = "AWS AZ 1"
  default     = "us-east-1a"
  type        = string
}


variable "az2" {
  description = "AWS AZ 2"
  default     = "us-east-1b"
  type        = string
}

variable "addons" {
  type = list(object({
    name    = string
    version = string
  }))

  default = [
    {
      name    = "aws-ebs-csi-driver"
      version = "v1.15.0-eksbuild.1"
    }
  ]
}

variable "cluster_api_public_access_cidrs" {
  description = "CIDR blocks allowed to reach the EKS public Kubernetes API endpoint."
  type        = list(string)

  validation {
    condition     = !contains(var.cluster_api_public_access_cidrs, "0.0.0.0/0")
    error_message = "Do not use 0.0.0.0/0 for cluster_api_public_access_cidrs; restrict to specific CIDRs."
  }

  validation {
    condition     = !contains(var.cluster_api_public_access_cidrs, "::/0")
    error_message = "Do not use ::/0 for cluster_api_public_access_cidrs; restrict to specific CIDRs."
  }
}
