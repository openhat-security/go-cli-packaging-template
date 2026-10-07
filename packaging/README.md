# Packaging (install channels)

Templates for shipping a Go CLI built with GoReleaser. Most channels need **separate org repos**
because Homebrew, Scoop, and Linux package indexes are not read from your app repository.

Replace placeholders: `ORG`, `GITHUB_REPO`, `BINARY_NAME`, `PRODUCT`, `PROJECT_NAME`.

## Channels

| Channel | User installs with | Lives in |
| --- | --- | --- |
| GitHub Release | install script / direct download | This app repo |
| Homebrew | `brew install --cask ORG/tap/BINARY_NAME` | `ORG/homebrew-tap` |
| Scoop | `scoop bucket add ORG …` then `scoop install BINARY_NAME` | `ORG/scoop-bucket` |
| apt | `curl …/install-apt-PRODUCT.sh \| sudo bash` | `ORG/packages` (Pages) |
| dnf | `curl …/install-dnf-PRODUCT.sh \| sudo bash` | same |
| winget | `winget install Publisher.Package` | PR to `microsoft/winget-pkgs` |
| npm | `npm i -g BINARY_NAME` | npmjs.org (optional wrapper) |

## Create org repos once

```bash
ORG=openhat-security   # replace with your ORG

gh repo create "$ORG/homebrew-tap" --public --description "Homebrew tap for ORG CLIs" --add-readme
gh repo create "$ORG/scoop-bucket" --public --description "Scoop bucket for ORG CLIs" --add-readme
gh repo create "$ORG/packages" --public --description "apt + dnf repos for ORG (GitHub Pages)" --add-readme
# Settings → Pages → Deploy from branch main / (root)
```

## Secrets (on `ORG/GITHUB_REPO`)

| Secret | Required for |
| --- | --- |
| `PACKAGING_TOKEN` | Push `homebrew-tap`, `scoop-bucket`, and `packages` |
| `HOMEBREW_TAP_TOKEN` / `SCOOP_TOKEN` | Optional overrides instead of `PACKAGING_TOKEN` |
| `NPM_TOKEN` | `npm publish` from `packaging/npm` |
| `WINGET_PAT` | Auto-PR to `microsoft/winget-pkgs` |
| `GPG_PRIVATE_KEY` | Optional apt InRelease signing (unset = `trusted=yes` in list file) |

`PACKAGING_TOKEN` must have **contents: write** on the three companion repos. Do **not** rely on
`GITHUB_TOKEN` for cross-repo pushes.

## Shared `ORG/packages` site (multi-product)

The Pages repo hosts **one deb pool** and **one rpm tree** for all CLIs in the org.

```bash
packaging/repo/build-pages-repos.sh --merge --product PRODUCT <pkg-dir> <packages-checkout>
```

- **`--merge`** adds new `.deb`/`.rpm` files and rebuilds indexes without deleting other products’ pool files.
- **Without `--merge`**, or workflows that `rm -rf` the site and copy only one product’s tree, **wipe other products** (lists, install scripts, and co-hosted packages).

Each product needs `packaging/repo/products/PRODUCT/` (see `example-cli/`). On publish, the script writes
`PRODUCT.list`, `PRODUCT.repo`, `install-apt-PRODUCT.sh`, and `install-dnf-PRODUCT.sh` at the site root.

## Layout

```
packaging/
  repo/           build-pages-repos.sh, index.html.in, products/PRODUCT/
  npm/            optional postinstall-downloader wrapper
  winget/         generate.sh stub for manifest PRs
```

## Verify after a release

```bash
gh release view vX.Y.Z -R ORG/GITHUB_REPO
curl -fsSL "https://${ORG}.github.io/packages/install-apt-PRODUCT.sh" | sudo bash
```
