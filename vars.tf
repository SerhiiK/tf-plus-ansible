variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "AWS_REGION" {
  default = "us-east-2"
}

variable "aws_vpc_cidr" {
  default = "172.16.10.0/24"
}

variable "server_instance_type" {
  default = "t2.micro"
}
variable "AMIS" {
  type = "map"
  default = {
     us-east-2 ="ami-05c1fa8df71875112"
    us-west-2 = "ami-06b94666"
    eu-west-1 = "ami-844e0bf7"
  }
}

variable "ssh_key_public" {
  default     = "./mykey.pub"
}

variable "ssh_key_private" {
  default     = "./mykey"
 
}
