#!/bin/bash

# makes the script existing once an error occours
set -euo pipefail

curl --fail https://api.getpostman.com/collections/${INPUT_POSTMAN_COLLECTION_ID}?apikey=${INPUT_POSTMAN_TOKEN} | (echo "::error::Collection could not be fetched."; exit 1)

# install newman & html reporter
npm install newman newman-reporter-htmlextra -g

# run newman
newman run https://api.getpostman.com/collections/${INPUT_POSTMAN_COLLECTION_ID}?apikey=${INPUT_POSTMAN_TOKEN} \
    --env-var baseUrl=nginx \
    --reporters cli,htmlextra --reporter-htmlextra-export ./newman/report.html
