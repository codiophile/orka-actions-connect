#!/bin/bash

# Checking if gh is installed
gh version && gh token version
if (( $? > 0 )); then
    echo 'github cli and github extension Link-/gh-token not installed'
    exit 1
fi
# Exit immediately if a pipeline returns non-zero.
# Short form: set -e
set -o errexit

# Print a helpful message if a pipeline with non-zero exit code causes the
# script to exit as described above.
trap 'echo "Aborting due to errexit on line $LINENO. Exit code: $?" >&2' ERR

# Allow the above trap be inherited by all functions in the script.
#
# Short form: set -E
set -o errtrace

# Return value of a pipeline is the value of the last (rightmost) command to
# exit with a non-zero status, or zero if all commands in the pipeline exit
# successfully.
set -o pipefail

fetch_encrypted_metadata() {
    local metadata=$(curl -s "http://169.254.169.254/metadata/$1" | jq -r .value | openssl enc -d -aes-256-cbc -a -K $METADATA_ENCRYPTION_KEY -iv $METADATA_ENCRYPTION_IV);
    echo $metadata
}

main() {
    github_app_id=`fetch_encrypted_metadata github_app_id`
    github_app_installation_id=`fetch_encrypted_metadata github_app_installation_id`
    github_app_private_key_file=`mktemp`
    sed -E 's/(-+(BEGIN|END) RSA PRIVATE KEY-+) *| +/\1\n/g' <<< $(fetch_encrypted_metadata github_app_private_key) > $github_app_private_key_file
    repo_url="https://github.com/$user/$repo"
    pat=`gh token installations -k $github_app_private_key_file --app_id $github_app_id`
    rm $github_app_private_key_file
    echo $pat
}

## Run the main function
main
