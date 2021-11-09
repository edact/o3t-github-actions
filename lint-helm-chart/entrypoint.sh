#!/bin/bash

# makes the script existing once an error occours
set -euo pipefail

export HELM_EXPERIMENTAL_OCI=1

# switch to working directory
cd ${INPUT_WORKING_DIRECTORY}

# lint helm chart
echo "::group::Lint helm chart"
helm lint .
echo "::endgroup::"