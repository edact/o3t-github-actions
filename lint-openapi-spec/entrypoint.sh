#/bin/bash

# makes the script existing once an error occours
set -euo pipefail

if [ ! -f "${{ inputs.input_path }}" ]; then
    echo "::error::${{ inputs.input_path }} does not exist!"
    exit 1
fi

# install
npm i @stoplight/spectral@^5.0.0 --global --quiet

echo "::group::linting results"
# lint
spectral lint ${{ inputs.input_path }} --skip-rule oas3-unused-components-schema
echo "::endgroup::"