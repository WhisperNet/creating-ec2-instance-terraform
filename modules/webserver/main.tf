resource "aws_default_security_group" "nginx-sg" {
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.env_prefix}-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow-8080" {
  security_group_id = aws_default_security_group.nginx-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

resource "aws_vpc_security_group_ingress_rule" "allow-ssh" {
  security_group_id = aws_default_security_group.nginx-sg.id
  cidr_ipv4         = var.my_ip_cidr
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow-all-inbound" {
  security_group_id = aws_default_security_group.nginx-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file(var.pubic_key_filepath)
}


data "aws_ami" "aws-linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.9.20251110.1-kernel-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # Amazon
}

resource "aws_instance" "nginx-server" {
  ami           = data.aws_ami.aws-linux.id
  instance_type = var.ec2_instance_type
  subnet_id = var.subnet_id
  availability_zone = var.avail_zone
  vpc_security_group_ids = [aws_default_security_group.nginx-sg.id]
  key_name = aws_key_pair.deployer.key_name
  associate_public_ip_address = true
  user_data= file("start-up.sh")
  user_data_replace_on_change = true
  tags = {
    Name = "${var.env_prefix}-nginx-server"
  }
}
