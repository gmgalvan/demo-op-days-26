locals {
  app_name          = "HolaMicroservicio"
  app_publish_dir   = "${path.module}/build/publish"
  systemd_unit_name = "${var.project_name}.service"
  systemd_unit_path = "/etc/systemd/system/${local.systemd_unit_name}"
  remote_app_dir    = "/opt/${var.project_name}"
}

data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
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

resource "tls_private_key" "ec2" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "pem" {
  content         = tls_private_key.ec2.private_key_pem
  filename        = "${path.module}/${var.pem_output_path}"
  file_permission = "0600"
}

resource "aws_key_pair" "ec2" {
  key_name   = var.public_key_name
  public_key = tls_private_key.ec2.public_key_openssh
}

resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-sg"
  description = "Reglas para SSH y la aplicacion"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidr_blocks
  }

  ingress {
    description = "App"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = var.app_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-sg"
    Project = var.project_name
  }
}

resource "aws_instance" "app" {
  ami                         = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.ec2.key_name
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail

    apt-get update
    apt-get install -y wget gnupg apt-transport-https ca-certificates

    wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O /tmp/packages-microsoft-prod.deb
    dpkg -i /tmp/packages-microsoft-prod.deb
    rm /tmp/packages-microsoft-prod.deb

    apt-get update
    apt-get install -y aspnetcore-runtime-8.0

    useradd --system --home ${local.remote_app_dir} --shell /usr/sbin/nologin ${var.project_name} || true
    mkdir -p ${local.remote_app_dir}
    chown -R ${var.project_name}:${var.project_name} ${local.remote_app_dir}
  EOF

  tags = {
    Name    = var.project_name
    Project = var.project_name
  }

  provisioner "local-exec" {
    command = "rm -rf ${local.app_publish_dir} && dotnet publish ${path.module}/../../HolaMicroservicio/HolaMicroservicio.csproj -c Release -o ${local.app_publish_dir}"
  }

  provisioner "file" {
    source      = local.app_publish_dir
    destination = "/tmp/publish"

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = tls_private_key.ec2.private_key_pem
      timeout     = "10m"
    }
  }

  provisioner "file" {
    content     = <<-EOF
      [Unit]
      Description=HolaMicroservicio ASP.NET Core Web App
      After=network.target

      [Service]
      WorkingDirectory=${local.remote_app_dir}
      ExecStart=/usr/bin/dotnet ${local.remote_app_dir}/${local.app_name}.dll
      Restart=always
      RestartSec=5
      KillSignal=SIGINT
      SyslogIdentifier=${var.project_name}
      User=${var.project_name}
      Environment=ASPNETCORE_URLS=http://0.0.0.0:${var.app_port}
      Environment=ASPNETCORE_ENVIRONMENT=Production

      [Install]
      WantedBy=multi-user.target
    EOF
    destination = "/tmp/${local.systemd_unit_name}"

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = tls_private_key.ec2.private_key_pem
      timeout     = "10m"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "while [ ! -x /usr/bin/dotnet ]; do sleep 5; done",
      "while [ ! -d /tmp/publish ]; do sleep 2; done",
      "sudo mkdir -p ${local.remote_app_dir}",
      "sudo cp -R /tmp/publish/. ${local.remote_app_dir}/",
      "sudo chown -R ${var.project_name}:${var.project_name} ${local.remote_app_dir}",
      "sudo mv /tmp/${local.systemd_unit_name} ${local.systemd_unit_path}",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable ${local.systemd_unit_name}",
      "sudo systemctl restart ${local.systemd_unit_name}"
    ]

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = tls_private_key.ec2.private_key_pem
      timeout     = "10m"
    }
  }
}
