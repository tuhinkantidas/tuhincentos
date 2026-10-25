#!/bin/bash
set -euxo pipefail
apt-get update
apt-get install -y ca-certificates curl git
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
. /etc/os-release
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable" > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin
systemctl enable --now docker
git clone --depth 1 --branch acc-azure-cloud-reliability https://github.com/tuhinkantidas/tuhincentos.git /opt/tuhincentos
cd /opt/tuhincentos/acc-project-azure/app
docker build -t acc-healthcheck:1.0 .
docker run -d --name acc-healthcheck --restart unless-stopped -p 80:8080 acc-healthcheck:1.0
