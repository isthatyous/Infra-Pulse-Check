data "aws_ami" "os_image" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "state"
    values = ["available"]
  }
  filter {
    name   = "name"
    //values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
     values = ["ubuntu/images/hvm-ssd-gp3/*24.04-amd64*"]
  }
}
   

resource "aws_key_pair" "deployer" {
  key_name = "terra-automate-key"
  public_key = file("terra-key.pub")
}
  

# Security Group for Remote Access (SSH)
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = module.vpc.vpc_id

  dynamic "ingress" {
    for_each = [
      { description = "port 22 allow", from = 22, to = 22, protocol = "tcp", cidr = ["0.0.0.0/0"] },
      { description = "port 80 allow", from = 80, to = 80, protocol = "tcp", cidr = ["0.0.0.0/0"] },
      { description = "port 443 allow", from = 443, to = 443, protocol = "tcp", cidr = ["0.0.0.0/0"] },
      { description = "port 8080 allow", from = 8080, to = 8080, protocol = "tcp", cidr = ["0.0.0.0/0"] },
      { description = "port 9000 allow", from = 9000, to = 9000, protocol = "tcp", cidr = ["0.0.0.0/0"] }
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
    description = "Allow all outgoing traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "mysecurity"
  }
}

resource "aws_instance" "ec2_instance" {
  ami = data.aws_ami.os_image.id
  instance_type = "t3.large"
  key_name = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  subnet_id = module.vpc.public_subnets[0]
  user_data = file("${path.module}/ec2_instance_tool.sh")

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "Jenkins-Automate"
  }
}

resource "aws_eip" "jenkins_eip" {
  instance = aws_instance.ec2_instance.id
  domain = "vpc"
}
