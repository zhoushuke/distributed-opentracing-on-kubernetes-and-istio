#!/bin/bash
#
# author: Gary A. Stafford
# site: https://programmaticponderings.com
# license: MIT License
# purpose: Build Go microservices for demo

#readonly -a arr=(a b c d e f g h rev-proxy)
readonly -a arr=(a b c d e f g h)
#readonly -a arr=(f)
readonly tag=1.5.2

for i in ${arr[@]}
do
  cp -f Dockerfile service-${i}
  pushd service-${i}
  CGO_ENABLED=0 go build  -ldflags '-w -s' -a -installsuffix cgo -o hello .
  docker build -t garystafford/go-srv-${i}:${tag} . --no-cache
  rm -rf Dockerfile
  popd
done

docker image ls | grep 'garystafford/go-srv-'
