#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nix-prefetch-scripts curl jshon jq
# @version 2022.04
# @license MPL-2.0
# @author Manifold Finance, Inc.
# @description: Nix Overlay
set -e

# @DEV set GITHUB_TOKEN before running this script
# export GITHUB_TOKEN=ghp_$TOKEN

echo "Running Manifold Nix Overlay..."
json="{}"
add() { json=$(jshon "$@" <<<"$json"); }

rm -rf overlay/upstream
mkdir -p overlay/upstream

GET() {
  curl -s -H "Authorization: token ${GITHUB_TOKEN? Requires OAuth token}" "$@"
}

package() {
  echo -n bumping "$1 "
  pkg="$1"
  name=$(basename "$pkg")
  tag=$(GET https://api.github.com/repos/"$pkg"/tags | jshon -e 0)
  version=$(jshon -e name -u <<<"$tag")
  hash=$(jshon -e commit -e sha -u <<<"$tag")
  echo -n "$version"
  sha256=$(
    nix-prefetch-url \
      --unpack \
      https://github.com/"$pkg"/archive/"$version".tar.gz 2>/dev/null)
  add -n {} \
      -s "${version#v}" -i version \
      -n {} \
      -s "$hash" -i rev \
      -s "$sha256" -i sha256 \
      -s "$(dirname "$pkg")" -i owner \
      -s "$name" -i repo \
      -i src \
      -i "$name"

  tree=$(GET https://api.github.com/repos/"$pkg"/git/trees/"$hash")
  nix=$(jq -r <<<"$tree" '.tree | .[] | select(.path == "default.nix") | .url')
  GET "$nix" | jshon -e content -u | base64 -d > overlay/upstream/"$name".nix
  echo
}

# @DEV add your packages here
# These are the GitHub packages in the overlay
package dapphub/dapp
package dapphub/hevm
package dapphub/seth

echo "$json" | jq . > overlay/versions.json
