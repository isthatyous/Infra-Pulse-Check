variable "bastion_ami" {
  description = "AMI ID for Ubuntu (e.g., Ubuntu 22.04 in ap-south-1)"
  default     = "ami-02d26659fd82cf299"
}

variable "bastion_instance_type" {
  default = "t3.micro"
}
# variable "key_name" {
#   description = "SSH key pair name"
# }