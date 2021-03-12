#!/bin/bash

# makes the script existing once an error occours
set -euo pipefail

# set version
npm --no-git-tag-version version $INPUT_PACKAGE_VERSION --force

# publish package to registry
echo "::group::Publish package"
# TODO: remove --registry
npm publish --registry=https://npm.pkg.github.com
echo "::endgroup::"
