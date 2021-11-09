#!/bin/bash

# makes the script existing once an error occours
set -euo pipefail

export HELM_EXPERIMENTAL_OCI=1

# switch to working directory
cd ${INPUT_WORKING_DIRECTORY}

RUN apk add curl bash openssl
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
RUN chmod 700 get_helm.sh && ./get_helm.sh

# lint helm chart
echo "::group::Lint helm chart"
helm lint .
echo "::endgroup::"