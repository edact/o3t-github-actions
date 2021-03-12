#!/bin/bash

# makes the script existing once an error occours
set -euo pipefail

# install dependencies
echo "::group::Install package dependencies"
npm install
echo "::endgroup::"

# build for production
echo "::group::Build package"
npm run build
echo "::endgroup::"