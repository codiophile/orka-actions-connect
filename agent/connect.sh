#!/bin/bash
usage() {
    echo "
Usage: $0 [--user user/org] [--repo Repo] [--vm_name vm-name] [--pat pat] [--repo_url repo-url] [--help|-h]

    --user: (Optional) Username or the organisation of the repository
    --repo: (Optional) Name of the repository
    --vm_name: (Optional) Name of the VM. The runner will have the same name and label
    --pat: (Optional) The github PAT to use for registering the runner
    --repo_url: (Optional) Url of the repository to connect the runner to
    -h|--help
    "
}

fetch_metadata() {
    local metadata=$(curl -s "http://169.254.169.254/metadata/$1" | \
        python3 -c "import sys, json; print(json.load(sys.stdin)['value'])");
    echo $metadata
}

while [ $# -gt 0 ] ; do
  case $1 in
    --user)
      user="$2"
      ;;
    --repo)
      repo="$2"
      ;;
    --vm_name)
      vm_name="$2"
      ;;
    --pat)
      pat="$2"
      ;;
    --repo_url)
      repo_url="$2"
      ;;
    -h | --help)
      usage $1
      exit 1
      ;;
  esac
  shift
done

if [ -z ${user+x} ]; then user=`fetch_metadata github_user`; fi
if [ -z ${repo+x} ]; then repo=`fetch_metadata github_repo_name`; fi
if [ -z ${vm_name+x} ]; then vm_name=`fetch_metadata orka_vm_name`; fi
if [ -z ${pat+x} ]; then pat=`fetch_metadata github_pat`; fi
if [ -z ${repo_url+x} ]; then repo_url="https://github.com/$user/$repo"; fi

runner_token=$(curl \
-XPOST \
-H"Accept: application/vnd.github.v3+json" \
-H"authorization: Bearer $pat" \
"https://api.github.com/repos/$user/$repo/actions/runners/registration-token" | \
        python3 -c "import sys, json; print(json.load(sys.stdin)['token'])")

cd /Users/admin/agent/
./config.sh --url $repo_url --token $runner_token --runnergroup "Default" --name $vm_name --work "_work" --labels $vm_name
./svc.sh install
./svc.sh start
