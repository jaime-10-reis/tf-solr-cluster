data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "jreis-spotsolr-tfstate"
    key = "prod/vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_network_interface" "solr" {
  count = 3
  description = "Primary network interface"
  private_ip = var.solr_private_ips[count.index]
  private_ips = [
    var.solr_private_ips[count.index],
  ]
  security_groups = [
    aws_security_group.instance.id,
  ]
  subnet_id = data.terraform_remote_state.vpc.outputs.aws_subnet_default_id
  source_dest_check = false
}

resource "aws_instance" "solr" {
  depends_on = [aws_instance.zookeeper]
  count = 3
  ami = var.solr_instance_ami
  instance_type = "t2.large"
  key_name = var.key_name

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.solr[count.index].id
  }

  tags = {
    "Name" = var.solr_instance_names[count.index]
  }

  root_block_device {
    volume_size = var.volume_size
  }
  user_data = data.template_cloudinit_config.config-solr.rendered

}

# Elastic IP for solr1
resource "aws_eip" "solr1_eip" {
  vpc = true
}

resource "aws_eip_association" "solr1_eip_assoc" {
  network_interface_id = aws_network_interface.solr[0].id
  allocation_id = aws_eip.solr1_eip.id
}

resource "aws_network_interface" "zookeeper" {
  count = 3
  description = "Primary network interface"
  private_ip = var.zookeeper_private_ips[count.index]
  private_ips = [
    var.zookeeper_private_ips[count.index],
  ]
  security_groups = [
    aws_security_group.instance.id,
  ]
  subnet_id = data.terraform_remote_state.vpc.outputs.aws_subnet_default_id
  source_dest_check = false
}

resource "aws_instance" "zookeeper" {
  count = 3
  ami = var.zookeeper_instance_ami
  instance_type = "t2.small"
  key_name = var.key_name
  #subnet_id =  data.terraform_remote_state.vpc.outputs.aws_subnet_default_id
  #private_ip =  var.zookeeper_private_ips[count.index]

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.zookeeper[count.index].id
  }

  tags = {
    "Name" = var.zookeeper_instance_names[count.index]
  }

  root_block_device {
    volume_size = var.volume_size
  }
  user_data = data.template_cloudinit_config.config-zookeeper[count.index].rendered

}

# Elastic IP for zookeeper1
resource "aws_eip" "zookeeper_eip" {
  vpc = true
}

resource "aws_eip_association" "zookeeper_eip_assoc" {
  network_interface_id = aws_network_interface.zookeeper[0].id
  allocation_id = aws_eip.zookeeper_eip.id
}

resource "aws_security_group" "instance" {
  vpc_id = data.terraform_remote_state.vpc.outputs.aws_vpc_main_id
  name = var.security_group_name
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description = ""
      from_port = 0
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      protocol = "-1"
      security_groups = []
      self = false
      to_port = 0
    },
  ]
  ingress = [
  for _fw_rule in var.fw_rules:
  {
    cidr_blocks = [
    for _ip in var.ip_list[_fw_rule[4]]:
    _ip
    ]
    description = _fw_rule[3]
    from_port = _fw_rule[1]
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    protocol = _fw_rule[0]
    security_groups = []
    self = false
    to_port = _fw_rule[2]
  }
  ]
}
