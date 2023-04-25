#!/bin/bash
RUNNER_APPLICATION_DIRECTORY=$HOME/agent/
source ./utils.sh
source $RUNNER_APPLICATION_DIRECTORY/.env

user=`fetch_encrypted_metadata github_user`
repo=`fetch_encrypted_metadata github_repo_name`
github_app_id=`fetch_encrypted_metadata github_app_id`
github_app_installation_id=`fetch_encrypted_metadata github_app_installation_id`
github_app_private_key_file=`mktemp`
sed -E 's/(-+(BEGIN|END) RSA PRIVATE KEY-+) *| +/\1\n/g' <<< $(fetch_encrypted_metadata github_app_private_key) > $github_app_private_key_file
vm_name=`fetch_metadata orka_vm_name`
repo_url="https://github.com/$user/$repo"
jwt=`$HOME/agent/get-jwt.py $github_app_private_key_file $github_app_id`
pat=`get_app_token $jwt $github_app_installation_id`

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
