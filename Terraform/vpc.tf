module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.name
  cidr = local.vpc_cidr
  azs  = local.azs        
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  enable_nat_gateway = true   # private subnet to reach the internet to update,downloads packages
  single_nat_gateway = true   # 
  one_nat_gateway_per_az = false # NAT gateway per AZs cost more but highly available

  tags = {
    name = local.name
    Environment = local.env
  }
}