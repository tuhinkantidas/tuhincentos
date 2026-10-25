terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "app" {
  name_prefix = "${var.project_name}-"
  description = "Restricted HTTP access for ACC reliability demo"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP only from the presenter's IP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  egress {
    description = "Allow outbound traffic for package updates and image pulls"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = var.project_name
  }
}

resource "aws_instance" "demo" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = true
  user_data_replace_on_change = true

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail
    dnf update -y
    dnf install -y docker
    systemctl enable --now docker
    mkdir -p /opt/acc-demo
    cat > /opt/acc-demo/index.html <<'HTML'
    <!doctype html>
    <html><head><title>ACC Reliability Demo</title></head>
    <body><h1>ACC Cloud Reliability Demo</h1><p>EC2 + Docker deployment bootstrap completed.</p><p>For the container health-check demo, build and run the app image from the repository's app folder.</p></body></html>
    HTML
    docker run -d --name acc-demo-web --restart unless-stopped -p 80:80 -v /opt/acc-demo:/usr/share/nginx/html:ro nginx:stable
  EOF

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name    = "${var.project_name}-ec2"
    Project = var.project_name
  }

  depends_on = [aws_security_group.app]
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

