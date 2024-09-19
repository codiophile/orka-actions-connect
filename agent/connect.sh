#!/bin/bash
fetch_metadata() {
    curl -s "http://169.254.169.254/metadata/$1" | \
        python3 -c "import sys, json; print(json.load(sys.stdin)['value'])"
}

vm_name=`fetch_metadata orka_vm_name`
user=`fetch_metadata github_user`
repo=`fetch_metadata github_repo_name`
repo_url="https://github.com/$user/$repo"
which /usr/local/bin/get-github-pat
if [ $? -eq 1 ]; then
        echo 'get-github-pat not found. Trying to get pat from metadata.'
        pat=`fetch_metadata github_pat`
else
        pat=`/usr/local/bin/get-github-pat`
fi
runner_token=$(curl \
-XPOST \
-H"Accept: application/vnd.github.v3+json" \
-H"authorization: Bearer $pat" \
"https://api.github.com/repos/$user/$repo/actions/runners/registration-token" | \
        python3 -c "import sys, json; print(json.load(sys.stdin)['token'])")

cd $HOME/agent
echo "export GITHUB_TOKEN=$pat" >> $HOME/.bashrc
./config.sh --url $repo_url --token $runner_token --runnergroup "Default" --name $vm_name --work "_work" --labels $vm_name
./svc.sh install
./svc.sh start
