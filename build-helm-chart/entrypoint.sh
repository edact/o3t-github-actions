#!/bin/bash

# makes the script existing once an error occours
set -euo pipefail

export HELM_EXPERIMENTAL_OCI=1

# switch to working directory
cd ${INPUT_WORKING_DIRECTORY}

# log into helm registry
helm registry login -u "${INPUT_HELM_REGISTRY_USER}" -p "${INPUT_HELM_REGISTRY_TOKEN}" ${INPUT_HELM_REGISTRY_URL}

# split chart tags in array
chart_tags=$(echo $INPUT_CHART_TAGS | tr ", " "\n")

# lint helm chart
echo "::group::Lint helm chart"
helm lint .
echo "::endgroup::"

# set tags
echo "::group::Push helm chart"
for chart_tag in $chart_tags
do 
    helm chart save . ${INPUT_HELM_REGISTRY_URL}/${GITHUB_REPOSITORY}/${INPUT_CHART_NAME}:${chart_tag}
    helm chart push ${INPUT_HELM_REGISTRY_URL}/${GITHUB_REPOSITORY}/${INPUT_CHART_NAME}:${chart_tag}
done
echo "::endgroup::"
