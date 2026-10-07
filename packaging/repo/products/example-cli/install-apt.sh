#!/usr/bin/env bash
# Add the ORG apt repo and install BINARY_NAME.
set -euo pipefail
REPO_URL="${REPO_URL:-@REPO_URL@}"
if [ "$(id -u)" -ne 0 ]; then
  echo "re-run with sudo" >&2
  exit 1
fi
curl -fsSL "${REPO_URL}/PRODUCT.list" -o /etc/apt/sources.list.d/PRODUCT.list
if curl -fsSL "${REPO_URL}/PRODUCT.asc" -o /usr/share/keyrings/PRODUCT.asc 2>/dev/null; then
  sed -i 's/\[trusted=yes\]/[signed-by=\/usr\/share\/keyrings\/PRODUCT.asc]/' /etc/apt/sources.list.d/PRODUCT.list || true
fi
apt-get update -qq
apt-get install -y BINARY_NAME
echo "OK: $(BINARY_NAME version)"
