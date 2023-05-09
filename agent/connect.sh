#!/usr/bin/env bash

RUNNER_APPLICATION_DIRECTORY=$HOME/
fetch_metadata() {
    curl -s "http://169.254.169.254/metadata/$1" | jq -r .value
}

vm_name=`fetch_metadata orka_vm_name`
user=`fetch_metadata github_user`
repo=`fetch_metadata github_repo_name`
pat=`get-github-pat`
if [ $? -eq 1 ]; then
	echo 'get-github-pat exited with error code 1. trying to get pat from metadata'
	unset pat
	pat=`fetch_metadata github_pat`
fi

runner_token=$(curl \
-XPOST \
-H"Accept: application/vnd.github.v3+json" \
-H"authorization: Bearer $pat" \
"https://api.github.com/repos/$user/$repo/actions/runners/registration-token" | \
        python3 -c "import sys, json; print(json.load(sys.stdin)['token'])")

cd $RUNNER_APPLICATION_DIRECTORY
echo "export GITHUB_TOKEN=$pat" >> $HOME/.bashrc
./config.sh --url $repo_url --token $runner_token --runnergroup "Default" --name $vm_name --work "_work" --labels $vm_name
./svc.sh install
./svc.sh start
