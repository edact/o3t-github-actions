#!/bin/bash

# makes the script existing once an error occours
set -euo pipefail

# switch to working directory
cd ${INPUT_WORKING_DIRECTORY}

# log into docker registry
echo ${INPUT_DOCKER_REGISTRY_TOKEN} | docker login -u ${INPUT_DOCKER_REGISTRY_USER} --password-stdin ${INPUT_DOCKER_REGISTRY_URL}

FULL_IMAGE_NAME=${INPUT_DOCKER_REGISTRY_URL}/${GITHUB_REPOSITORY}/${INPUT_IMAGE_NAME}

# split image tags in array
IMAGE_TAGS=$(echo $INPUT_IMAGE_TAGS | tr ", " "\n")


if [ "$INPUT_USE_CACHE" = true ] ; then

    # docker build should use previous images of the tags provided as cache
    INPUT_CACHE_TAGS=${INPUT_CACHE_TAGS:-"$INPUT_IMAGE_TAGS"}
    CACHE_TAGS=$(echo $INPUT_CACHE_TAGS | tr ", " "\n")
    CACHE_FROM_STRING=""

    for CACHE_TAG in $CACHE_TAGS
    do
        docker pull ${FULL_IMAGE_NAME}:${CACHE_TAG} --quiet || true
        CACHE_FROM_STRING=${CACHE_FROM_STRING}" --cache-from=${FULL_IMAGE_NAME}:${CACHE_TAG}"
    done
fi

# build image
echo "::group::Build image"
docker build \
    --build-arg=DOCKER_REGISTRY_URL=${INPUT_DOCKER_REGISTRY_URL} \
    --build-arg=BASE_TAG=${INPUT_BUILD_BASE_TAG} \
    $( [ -n "$INPUT_TARGET_STAGE" ] && printf %s "--target $INPUT_TARGET_STAGE" ) \
    $( [ "$INPUT_USE_CACHE" = true ] && [ -n "$INPUT_CACHE_TAGS" ] && printf %s "$CACHE_FROM_STRING" ) \
    --file $INPUT_DOCKERFILE \
    --tag tempcontainer:latest .
echo "::endgroup::"

# set tags
for IMAGE_TAG in $IMAGE_TAGS
do
    docker tag tempcontainer:latest ${FULL_IMAGE_NAME}:${IMAGE_TAG}    
done

# push image to registry
echo "::group::Push image"
docker push ${FULL_IMAGE_NAME} --all-tags
echo "::endgroup::"