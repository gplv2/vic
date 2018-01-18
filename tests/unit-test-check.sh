#!/bin/bash
prNumber=$(drone build info --format "{{ .Ref }}" vmware/vic $DRONE_BUILD_NUMBER | cut -f 3 -d'/')
prBody=$(curl https://api.github.com/repos/vmware/vic/pulls/$prNumber | jq -r ".body")

if ! (echo $prBody | grep -q "\[skip unit\]"); then
  make test
fi
