output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = module.eks.cluster_endpoint
}

# output "bastion_host" {
#   value = {
#     name = aws_instance.bastion_host.tags["Name"]
#     ip   = aws_instance.bastion_host.public_ip
#   }

# }


output "Jenkins_Automate_instance" {
  value = {
    name = aws_instance.ec2_instance.tags["Name"]
    ip   = aws_instance.ec2_instance.public_ip
  }
}

output "eks_node_group_public_ips" {
  description = "Public IPs of the EKS node group instances"
  value       = data.aws_instances.eks_nodes.public_ips
}
