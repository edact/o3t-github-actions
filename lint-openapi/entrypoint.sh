#!/bin/bash

# makes the script existing once an error occours
set -euo pipefail

if [ ! -f "$INPUT_INPUT_PATH" ]; then
    echo "::error::$INPUT_INPUT_PATH does not exist!"
    exit 1
fi

# lint
npx --package @stoplight/spectral \
    spectral lint ${INPUT_INPUT_PATH} \
    --skip-rule oas3-unused-components-schema
