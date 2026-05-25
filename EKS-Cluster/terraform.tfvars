cluster-name = "k8s-tf-demo"
profile      = "default"

# kubectl / terraform / CI egress — add office VPN or other admin CIDRs as needed
cluster_api_public_access_cidrs = [
  "x.x.x.x/32",
]

#example : 189.6.6.164/32