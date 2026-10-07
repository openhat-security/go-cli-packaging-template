# BINARY_NAME (npm)

Optional global CLI wrapper: `postinstall` downloads the matching GitHub Release binary.

Replace `package.json` name, `bin`, and `install.js` download URL pattern (`ORG/GITHUB_REPO`).

Publish is automated from `.github/workflows/release.yml` when `NPM_TOKEN` is set.
