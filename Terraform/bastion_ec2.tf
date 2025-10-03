
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allow user to connect"
  vpc_id      = module.vpc.vpc_id
  
  dynamic "ingress" {
    for_each = [
      { description = "port 22 allow", from = 22, to = 22, protocol = "tcp", cidr = ["0.0.0.0/0"] },
      { description = "port 80 allow", from = 80, to = 80, protocol = "tcp", cidr = ["0.0.0.0/0"] },
      { description = "port 443 allow", from = 443, to = 443, protocol = "tcp", cidr = ["0.0.0.0/0"] }
    ]
    content {
      description = ingress.value.description
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr
    }
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Bastion-SG"
  }
}



resource "aws_instance" "bastion_host" {
  ami                         = data.aws_ami.os_image.id
  instance_type               = var.bastion_instance_type
  key_name                    = aws_key_pair.deployer.key_name
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  user_data = file("${path.module}/bastion_user_script.sh")
  tags = {
    Name = "Bastion-Host"
  }
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }
}