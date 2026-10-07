# Setup after “Use this template”

1. **Search and replace** (whole repo):

   - `PROJECT_NAME` → display name
   - `ORG` → GitHub owner
   - `GITHUB_REPO` → repository name
   - `MODULE_PATH` → Go module path
   - `BINARY_NAME` → CLI binary / package name
   - `PRODUCT` → short id for Linux repo scripts (usually same as `BINARY_NAME`)

2. **Product folder:** if `PRODUCT` is not `example-cli`, rename:

   ```bash
   mv packaging/repo/products/example-cli "packaging/repo/products/${PRODUCT}"
   ```

   Update `index.html.in` with your product section.

3. **GoReleaser:** set `builds[].main`, `ldflags` version path, and metadata in `.goreleaser.yaml`.

4. **Workflows:** set `ORG/GITHUB_REPO` and `--product PRODUCT` in `.github/workflows/publish-linux-repos.yml`.

5. **Create companion repos** (once per org) — commands in [packaging/README.md](packaging/README.md).

6. **Secrets** on the app repo: `PACKAGING_TOKEN` with **contents: write** on `homebrew-tap`, `scoop-bucket`, and `packages`.

7. **First release:** push tag `vX.Y.Z`, confirm GitHub Release assets, then apt merge on `packages` main.
