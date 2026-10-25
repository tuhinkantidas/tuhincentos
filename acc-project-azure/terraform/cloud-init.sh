#!/bin/bash
set -euxo pipefail
exec > >(tee -a /var/log/acc-cloud-init.log) 2>&1

export DEBIAN_FRONTEND=noninteractive
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

APP_DIR=/opt/tuhincentos/acc-project-azure/app
if [ ! -d "$APP_DIR/.git" ]; then
  mkdir -p /opt
  git clone --depth 1 --branch acc-azure-cloud-reliability https://github.com/tuhinkantidas/tuhincentos.git /opt/tuhincentos
fi

test -f "$APP_DIR/Dockerfile"
test -f "$APP_DIR/app.py"
docker build --pull -t acc-healthcheck:1.0 "$APP_DIR"
docker rm -f acc-healthcheck 2>/dev/null || true
docker run -d --name acc-healthcheck --restart unless-stopped -p 80:8080 acc-healthcheck:1.0

for attempt in $(seq 1 20); do
  if curl --fail --silent http://127.0.0.1/health; then
    echo "Health endpoint is responding"
    exit 0
  fi
  sleep 3
done

echo "Health endpoint failed after container startup"
docker ps -a
docker logs acc-healthcheck
exit 1
