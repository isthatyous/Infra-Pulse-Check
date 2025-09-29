# Security Group for Remote Access (SSH)
resource "aws_security_group" "node_group_remote_access" {
  name        = "allow-SSH"
  description = "Allow SSH access from your IP"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    description = "Allow all outgoing traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name                    = local.name
  kubernetes_version      = "1.33"
  endpoint_public_access  = false # API server not accessible from Internet
  endpoint_private_access = true

  # Access entry for IAM User (extra authentication layer)
  access_entries = {
    example = {
      principal_arn = "arn:aws:iam::339713072285:user/Shivam"

      policy_associations = {
        example = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  # Security Group Additional Rules (for Bastion & Jenkins hosts)
  security_group_additional_rules = {
    access_for_bastion_jenkins_hosts = {
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all HTTPS traffic from Jenkins and Bastion host"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      type        = "ingress"
    }
  }

  # Core EKS Add-ons
  addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  # Networking (VPC + Subnets)
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    easy-shop-ng = {
    ami_id                             = "ami-02d26659fd82cf299"
    instance_types                     = ["t3.large"]
    attach_cluster_primary_security_group = true


      min_size     = 1
      max_size     = 3
      desired_size = 2

      disk_size                  = 30
      use_custom_launch_template = false # Important to apply disk size!

      remote_access = {
        ec2_ssh_key               = resource.aws_key_pair.deployer.key_name
        source_security_group_ids = [aws_security_group.node_group_remote_access.id]
      }

      tags = {
        Name        = "easy-shop-ng"
        Environment = "prod"
        ExtraTag    = "e-commerce-app"
      }
    }
  }

  tags = local.tag
}

# Data source: Get all running EKS node instances
data "aws_instances" "eks_nodes" {
  instance_tags = {
    "eks:name" = module.eks.cluster_name
  }

  filter {
    name   = "instance_state"
    values = ["running"]
  }

  depends_on = [module.eks]
}
