#!/usr/bin/env bash
# Add the PRODUCT dnf/yum repo and install BINARY_NAME.
set -euo pipefail
REPO_URL="${REPO_URL:-@REPO_URL@}"
if [ "$(id -u)" -ne 0 ]; then
  echo "re-run with sudo" >&2
  exit 1
fi
curl -fsSL "${REPO_URL}/PRODUCT.repo" -o /etc/yum.repos.d/PRODUCT.repo
if command -v dnf >/dev/null 2>&1; then
  dnf install -y BINARY_NAME
elif command -v yum >/dev/null 2>&1; then
  yum install -y BINARY_NAME
else
  echo "need dnf or yum" >&2
  exit 1
fi
echo "OK: $(BINARY_NAME version)"
