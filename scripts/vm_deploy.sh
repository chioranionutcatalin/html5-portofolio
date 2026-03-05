#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$HOME/html5-portofolio"
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

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required on VM." >&2
  exit 1
fi

if [ -d "${APP_DIR}/.git" ]; then
  cd "${APP_DIR}"
  git fetch origin "${BRANCH}"
  git reset --hard "origin/${BRANCH}"
else
  rm -rf "${APP_DIR}"
  git clone --branch "${BRANCH}" "${REPO_URL}" "${APP_DIR}"
fi

DOCKER_CMD=(docker)
if ! docker ps >/dev/null 2>&1; then
  if sudo -n docker ps >/dev/null 2>&1; then
    DOCKER_CMD=(sudo docker)
  else
    echo "docker requires elevated privileges for this user." >&2
    echo "Run on VM once: sudo usermod -aG docker $USER, then logout/login." >&2
    exit 1
  fi
fi

if [ ! -f "${APP_DIR}/index.html" ]; then
  echo "index.html not found in ${APP_DIR}. Deployment aborted." >&2
  exit 1
fi

if "${DOCKER_CMD[@]}" ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  "${DOCKER_CMD[@]}" rm -f "${CONTAINER_NAME}"
fi

"${DOCKER_CMD[@]}" run -d \
  --name "${CONTAINER_NAME}" \
  --restart unless-stopped \
  -p "${HOST_PORT}:80" \
  -v "${APP_DIR}:/usr/share/nginx/html:ro" \
  nginx:alpine

HEALTH_URL="http://127.0.0.1:${HOST_PORT}/"
ATTEMPTS=15

for attempt in $(seq 1 "${ATTEMPTS}"); do
  status_code="$(curl -s -o /dev/null -w "%{http_code}" "${HEALTH_URL}" || true)"
  if [ "${status_code}" = "200" ]; then
    echo "Health check passed on attempt ${attempt}: ${HEALTH_URL}"
    echo "Deploy complete. ${CONTAINER_NAME} serves ${APP_DIR} on port ${HOST_PORT}."
    exit 0
  fi
  sleep 1
done

echo "Health check failed for ${HEALTH_URL}. Last container logs:" >&2
"${DOCKER_CMD[@]}" logs --tail 50 "${CONTAINER_NAME}" >&2 || true
exit 1
