#!/bin/bash

# makes the script existing once an error occours
set -euo pipefail

JSON_FMT='{"github-oauth":{"%s": "%s"} }\n'
printf "$JSON_FMT" "$INPUT_REGISTRY_URL" "$INPUT_DEPLOY_TOKEN" > auth.json
mv auth.json ./$INPUT_LOCATION
