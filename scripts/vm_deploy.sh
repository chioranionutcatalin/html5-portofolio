#!/usr/bin/env bash
set -euo pipefail

APP_DIR="/opt/html5-portofolio"
REPO_URL="https://github.com/chioranionutcatalin/html5-portofolio.git"
BRANCH="main"
CONTAINER_NAME="portfolio-site"
HOST_PORT="8081"

if ! command -v git >/dev/null 2>&1; then
  echo "git is required on VM." >&2
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required on VM." >&2
  exit 1
fi

sudo mkdir -p "${APP_DIR}"
sudo chown -R "$USER":"$USER" "${APP_DIR}"

if [ -d "${APP_DIR}/.git" ]; then
  cd "${APP_DIR}"
  git fetch origin "${BRANCH}"
  git reset --hard "origin/${BRANCH}"
else
  rm -rf "${APP_DIR}"
  git clone --branch "${BRANCH}" "${REPO_URL}" "${APP_DIR}"
fi

if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  docker rm -f "${CONTAINER_NAME}"
fi

docker run -d \
  --name "${CONTAINER_NAME}" \
  --restart unless-stopped \
  -p "${HOST_PORT}:80" \
  -v "${APP_DIR}:/usr/share/nginx/html:ro" \
  nginx:alpine

echo "Deploy complete. ${CONTAINER_NAME} serves ${APP_DIR} on port ${HOST_PORT}."
