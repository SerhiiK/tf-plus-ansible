provider "aws" {
  region     = "${var.AWS_REGION}"
}

resource "aws_key_pair" "aws_keypair" {
  key_name   = "mykey"
  public_key = "${file(var.ssh_key_public)}"
}

resource "aws_vpc" "vpc" {
  cidr_block = "${var.aws_vpc_cidr}"

  tags = {
    Name = "terraform_test_vpc"
  }
}

resource "aws_internet_gateway" "terraform_gw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "Internet gateway "
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.terraform_gw.id}"
  }

  tags = {
    Name = "route table"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "${aws_vpc.vpc.cidr_block}"

  # map_public_ip_on_launch = true
  tags = {
    Name = "terraform_test_subnet"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.subnet.id}"
  route_table_id = "${aws_route_table.route_table.id}"
}

resource "aws_security_group" "server_sg" {
  vpc_id = "${aws_vpc.vpc.id}"

  # SSH ingress access for provisioning
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH access for provisioning"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nginx" {
  ami                         = "${lookup(var.AMIS, var.AWS_REGION)}"
  instance_type               = "${var.server_instance_type}"
  subnet_id                   = "${aws_subnet.subnet.id}"
  vpc_security_group_ids      = ["${aws_security_group.server_sg.id}"]
  key_name                    = "${aws_key_pair.aws_keypair.key_name}"
  associate_public_ip_address = true
  count = 2
 
  
 provisioner "remote-exec" {
    inline = ["sudo apt -y install htop"]

 connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file(var.ssh_key_private)}"
      host = "${self.public_ip}"
    }
   
  }
  provisioner "local-exec" {
    command = "ansible-playbook -u ubuntu -i '${self.public_ip},' --private-key mykey playbook.yml" 
  }

}



    
   
  
