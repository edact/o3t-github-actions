#!/bin/bash

# makes the script existing once an error occours
set -euo pipefail

printf "${INPUT_NPM_SCOPE}:registry=https://${INPUT_NPM_REGISTRY_URL}/ \n //${INPUT_NPM_REGISTRY_URL}/:_authToken=${INPUT_NPM_TOKEN}"> .npmrc