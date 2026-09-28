#!/usr/bin/env bash
# Netlify build for the Quarto site (see netlify.toml).
#
# Installs pinned versions of uv and Quarto, then renders. uv is needed by the
# photo-gallery extension (postgallery/index.qmd), which runs a Python script
# on every render to make thumbnails. R is not available on Netlify: posts that
# run R code are rendered locally and their results committed in _freeze/.
set -euo pipefail

UV_VERSION="0.12.20"
QUARTO_VERSION="1.9.36"   # keep in step with the local Quarto used for _freeze/

TOOLS="${TMPDIR:-/tmp}/build-tools"
mkdir -p "$TOOLS/quarto"

curl -LsSf "https://astral.sh/uv/${UV_VERSION}/install.sh" \
  | env UV_INSTALL_DIR="$TOOLS/bin" UV_NO_MODIFY_PATH=1 sh
export PATH="$TOOLS/bin:$PATH"

curl -fsSL "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.tar.gz" \
  | tar -xz -C "$TOOLS/quarto" --strip-components=1

uv --version
"$TOOLS/quarto/bin/quarto" --version
"$TOOLS/quarto/bin/quarto" render
