output "bastion_host" {
  value = {
    name = aws_instance.bastion_host.tags["Name"]
    ip   = aws_instance.bastion_host.public_ip
  }

}


output "ec2_instance" {
  value = {
    name = aws_instance.ec2_instance.tags["Name"]
    ip   = aws_instance.ec2_instance.public_ip
  }
}


