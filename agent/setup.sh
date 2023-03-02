#!/bin/bash
# This is an old version, but we know it works, so will not attempt an upgrade right now.
version=2.284.0
arch=$(/usr/bin/arch)
# On Intel the arch is returned as i386, so we have to change it to x64.
if [ $arch != arm64 ]; then
	arch=x64
fi
file=actions-runner-osx-$arch-$version.tar.gz

mkdir -p /Users/admin/agent
cp connect.sh /Users/admin/agent/
cp svc.sh /Users/admin/agent/
cd /Users/admin/agent/

curl -o $file \
	-L https://github.com/actions/runner/releases/download/v$version/$file
tar xzf ./$file
