#!/bin/bash

# makes the script existing once an error occours
set -e

# install dependencies
echo "::group::Install dependencies"
npm install
echo "::endgroup::"

# run tests specified in package.json
echo "::group::Run tests"
npm run test --if-present
echo "::endgroup::"

# set mode to production
export NODE_ENV="production"

# lint project
echo "::group::Run linter"
npm run lint --if-present --no-fix
echo "::endgroup::"
