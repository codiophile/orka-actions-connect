#!/bin/bash
# This will always get the latest version of the runner binary.

version=`curl -s https://api.github.com/repos/actions/runner/releases/latest | jq -r .tag_name | cut -c 2-`
arch=$(/usr/bin/arch)
# On Intel the arch is returned as i386, so we have to change it to x64.
if [ $arch != arm64 ]; then
	arch=x64
fi
file=actions-runner-osx-$arch-$version.tar.gz
url=https://github.com/actions/runner/releases/download/v$version/$file

mkdir -p $HOME/agent
cp connect.sh $HOME/agent/
cp svc.sh $HOME/agent/
chmod +x get-github-pat.sh
sudo cp get-github-pat.sh /usr/local/bin/get-github-pat
cp get-github-jwt.py $HOME/agent/get-github-jwt.py
cd $HOME/agent/

curl -o $file -L $url 
tar xzf ./$file
