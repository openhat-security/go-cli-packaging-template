#!/usr/bin/env bash
# Generate winget manifests under packaging/winget/<version>/.
# Usage: generate.sh <version> <windows-amd64-zip-url> [sha256]
# Replace ORG.BINARY_NAME PackageIdentifier before use.
set -euo pipefail

VER="${1:?version}"
URL="${2:?url}"
SHA="${3:-}"
ROOT="$(cd "$(dirname "$0")" && pwd)"
OUT="$ROOT/$VER"
PKG="ORG.BINARY_NAME"
mkdir -p "$OUT"

if [ -z "$SHA" ]; then
  tmp="$(mktemp)"
  curl -fsSL "$URL" -o "$tmp"
  SHA="$(shasum -a 256 "$tmp" | awk '{print $1}')"
  rm -f "$tmp"
fi
SHA="$(echo "$SHA" | tr '[:lower:]' '[:upper:]')"

cat > "$OUT/${PKG}.yaml" <<EOF
# yaml-language-server: \$schema=https://aka.ms/winget-manifest.version.1.6.0.schema.json
PackageIdentifier: ${PKG}
PackageVersion: ${VER}
DefaultLocale: en-US
ManifestType: version
ManifestVersion: 1.6.0
EOF

cat > "$OUT/${PKG}.locale.en-US.yaml" <<EOF
# yaml-language-server: \$schema=https://aka.ms/winget-manifest.defaultLocale.1.6.0.schema.json
PackageIdentifier: ${PKG}
PackageVersion: ${VER}
PackageLocale: en-US
Publisher: ORG
PublisherUrl: https://github.com/ORG
PackageName: PROJECT_NAME
ShortDescription: Replace with a short description.
License: MIT
EOF

cat > "$OUT/${PKG}.installer.yaml" <<EOF
# yaml-language-server: \$schema=https://aka.ms/winget-manifest.installer.1.6.0.schema.json
PackageIdentifier: ${PKG}
PackageVersion: ${VER}
InstallerType: zip
NestedInstallerType: portable
NestedInstallerFiles:
  - RelativeFilePath: BINARY_NAME.exe
    PortableCommandAlias: BINARY_NAME
Installers:
  - Architecture: x64
    InstallerUrl: ${URL}
    InstallerSha256: ${SHA}
ManifestType: installer
ManifestVersion: 1.6.0
EOF

echo "Wrote manifests under $OUT — open PR to microsoft/winget-pkgs or use komac/WINGET_PAT in release.yml"
