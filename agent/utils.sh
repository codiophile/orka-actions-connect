#!/bin/bash

fetch_metadata() {
    local metadata=$(curl -s "http://169.254.169.254/metadata/$1" | jq -r .value);
    echo $metadata
}

fetch_encrypted_metadata() {
    local metadata=$(curl -s "http://169.254.169.254/metadata/$1" | jq -r .value | openssl enc -d -aes-256-cbc -a -K $METADATA_ENCRYPTION_KEY -iv $METADATA_ENCRYPTION_IV);
    echo $metadata
}

get_app_token() {
    jwt=$1
    token=$(curl -s -k -X POST \
        -H "Authorization: Bearer ${jwt}" \
        -H "Accept: application/vnd.github.v3+json" \
        https://api.github.com/app/installations/$2/access_tokens | jq -r .token)
    echo $token
}
