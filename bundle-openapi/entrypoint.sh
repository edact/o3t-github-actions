#!/bin/bash

# makes the script existing once an error occours
set -euo pipefail

INPUT_PATH="$INPUT_INPUT_DIR/$INPUT_INPUT_FILENAME"
OUTPUT_PATH="$INPUT_OUTPUT_DIR/$INPUT_OUTPUT_FILENAME"

if [ ! -f "$INPUT_PATH" ]; then
    echo "::error::$INPUT_PATH does not exist!"
    exit 1
fi

# check if requested filetype is correct
if [ "$INPUT_OUTPUT_FILETYPE" != "yaml" ] && [ "$INPUT_OUTPUT_FILETYPE" != "json" ] ; then
    echo "::error::FILETYPE must be either 'yaml' or 'json'!"
    exit 1
fi

# bundle
echo "::group::Bundle file"
npx --package @apidevtools/swagger-cli swagger-cli bundle \
    --outfile ${OUTPUT_PATH} \
    --type ${INPUT_OUTPUT_FILETYPE} \
    $( [ "$INPUT_DEREFERENCE" = true ] && printf %s "--dereference" ) \
    ${INPUT_PATH}
echo "::endgroup::"


# delete sub files by glob
echo "::group::Delete sub files"
if [ "$INPUT_DELETE_FILES" = true ] ; then
    DIR=$(dirname "${INPUT_PATH}")
    cd ${DIR}
    rm ${INPUT_DELETE_GLOB} -v -f
fi
echo "::endgroup::"
