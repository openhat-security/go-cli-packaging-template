# Go CLI packaging template

GitHub **template repository** for OpenHat-style Go CLIs: [GoReleaser](https://goreleaser.com),
GitHub Releases, Homebrew Cask tap, Scoop, apt/dnf on shared GitHub Pages, optional npm/winget.

Fork with **Use this template**, then replace every placeholder below (search the tree).

| Placeholder | Example | Used for |
| --- | --- | --- |
| `PROJECT_NAME` | `mytool` | Human name in docs |
| `ORG` | `openhat-security` | GitHub org or user |
| `GITHUB_REPO` | `mytool` | App repository name |
| `MODULE_PATH` | `github.com/openhat-security/mytool` | Go module + `-X …/internal/version.Version` |
| `BINARY_NAME` | `mytool` | Binary, deb/rpm package, brew cask, scoop manifest |
| `PRODUCT` | `mytool` | `packaging/repo/products/PRODUCT` + `--product PRODUCT` in CI |

## What you get

```
.goreleaser.yaml              nfpms (deb/rpm), homebrew_casks, scoops
.github/workflows/
  release.yml                 tag push → GoReleaser (+ optional npm/winget)
  publish-linux-repos.yml     release published → merge into ORG/packages
packaging/
  README.md                   secrets + org companion repos
  repo/                       apt/dnf Pages builder (multi-product --merge)
  npm/                        optional global wrapper stub
  winget/                     manifest generator stub
```

## Companion org repos (create once)

See [packaging/README.md](packaging/README.md). Typical OpenHat layout:

- `ORG/homebrew-tap` — Homebrew Casks
- `ORG/scoop-bucket` — Scoop bucket
- `ORG/packages` — GitHub Pages apt + dnf **shared pool** for all CLIs

Enable **Pages → Deploy from branch `main` / (root)** on `ORG/packages`.

## Quick start

1. Replace placeholders (see [SETUP.md](SETUP.md)).
2. Rename `packaging/repo/products/example-cli` → `packaging/repo/products/PRODUCT` if needed.
3. Wire `cmd/BINARY_NAME`, `go.mod`, and `.goreleaser.yaml` `main` path to your layout.
4. Add secrets on `ORG/GITHUB_REPO`: `PACKAGING_TOKEN` (required for tap/scoop/packages), optional `NPM_TOKEN`, `WINGET_PAT`.
5. Tag `v0.1.0` and verify channels listed in [packaging/README.md](packaging/README.md).

## Shared packages site (important)

`openhat-security/packages` (or your org’s Pages repo) hosts **one deb pool** and **one rpm tree**
for every CLI. Each product must publish with:

```bash
packaging/repo/build-pages-repos.sh --merge --product PRODUCT …
```

Workflows that **delete the whole site** (except `README.md`) and copy only one product’s
`public/` tree will **remove other products’** packages and install scripts on the next release.

## Related templates

- [adamsiwiec1/foss-template](https://github.com/adamsiwiec1/foss-template) — broader FOSS + multi-language packaging notes
- Live reference: [openhat-security/truffles](https://github.com/openhat-security/truffles) `packaging/`

## License

MIT — see [LICENSE](LICENSE).
