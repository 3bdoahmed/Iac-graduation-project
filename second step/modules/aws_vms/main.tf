data "aws_ami" "ami-block" {
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-*", "amzn2-ami-hvm"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon"]
}


resource "aws_instance" "this" {
  ami           = data.aws_ami.ami-block.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = true
  key_name                    = var.key_name
  user_data = var.user_data
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }
  tags = {
    Name = var.instance_name
  }
}