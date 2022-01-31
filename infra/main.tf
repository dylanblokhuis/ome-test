terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

resource "aws_instance" "k3s_master_instance" {
  ami           = "ami-0a8a2a544398b975e"
  instance_type = "t4g.small"
  key_name      = "k3s-ya"

  tags         = {
    Name = "K3sMasterNode"
  }

  provisioner "local-exec" {
    command = <<EOT
            sleep 10s &&
            k3sup install \
            --ip ${self.public_ip} \
            --context k3s \
            --ssh-key ~/.ssh/aws_instance \
            --user ubuntu
        EOT
  }
}

resource "aws_instance" "k3s_worker_instance" {
  count        = 2
  ami           = "ami-0a8a2a544398b975e"
  instance_type = "t4g.micro"
  key_name      = "k3s-ya"

  tags         = {
    Name = "K3sWorkerNode"
  }

  provisioner "local-exec" {
    command = <<EOT
            sleep 10s &&
            k3sup join \
            --ip ${self.public_ip} \
            --server-ip ${aws_instance.k3s_master_instance.public_ip} \
            --ssh-key ~/.ssh/aws_instance \
            --user ubuntu
        EOT
  }
}