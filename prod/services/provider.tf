terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 3.25.0"
    }
    cloudinit = {
      source = "hashicorp/cloudinit"
      version = ">= 2.1.0"
    }
  }
  backend "s3" {
    bucket = "jreis-spotsolr-tfstate"
    key = "prod/services/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "jreis-spotsolr-tfstate-lock"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "cloudinit" {

}

data "template_cloudinit_config" "config-solr" {
  gzip = true
  base64_encode = true

  part {
    filename = var.cloud_config-solr
    content_type = "text/x-shellscript"
    content = file(var.cloud_config-solr)
  }
}

data "template_cloudinit_config" "config-zookeeper" {
  count = 3
  gzip = true
  base64_encode = true

  part {
    filename = var.cloud_config-zookeeper
    content_type = "text/x-shellscript"
    content = file(var.cloud_config-zookeeper)
  }

  part {
    content_type = "text/cloud-config"
    content = jsonencode({
      write_files = [
        {
          content     = file(var.zookeeper_myids[count.index])
          path        = "/var/lib/zookeeper/myid"
          permissions = "0644"
        },
        {
          content     = file("zookeeper/zoo.cfg")
          path        = "/tmp/zoo.cfg"
          permissions = "0644"
        },
      ]
    })
  }
}
