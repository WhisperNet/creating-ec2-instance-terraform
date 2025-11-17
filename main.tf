provider "aws" {
    region = "us-east-1"
}

resource "aws_vpc" "nginx-app-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "${var.env_prefix}-vpc"
    }
}
# variable vpc_id  {}
# variable subnet_cidr_block {}
# variable avail_zone {}
# variable env_prefix {}
# variable default_route_table_id {}

module nginx-app-subnet-1 {
  source = "./modules/subnet"
  vpc_id = aws_vpc.nginx-app-vpc.id
  subnet_cidr_block = var.subnet_cidr_block
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  default_route_table_id = aws_vpc.nginx-app-vpc.default_route_table_id
}

# variable vpc_id {}
# variable env_prefix {}
# variable my_ip_cidr {}
# variable pubic_key_filepath {}
# variable ec2_instance_type {}
# variable subnet_id {}
# variable avail_zone {}

module nginx-webserver {
    source = "./modules/webserver"
    vpc_id = aws_vpc.nginx-app-vpc.id
    env_prefix = var.env_prefix
    my_ip_cidr = var.my_ip_cidr
    pubic_key_filepath = var.pubic_key_filepath
    ec2_instance_type = var.ec2_instance_type
    subnet_id= module.nginx-app-subnet-1.subnet-id
    avail_zone= var.avail_zone
}




