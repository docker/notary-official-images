#!/bin/bash

# save original dir
ORIG=$(pwd)

# get directory this script is located in: http://stackoverflow.com/a/246128/432193
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do 
	DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
	SOURCE="$(readlink "$SOURCE")"
	[[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" 
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# build the binaries
cd $GOPATH/src/github.com/docker/notary
make static

cd $DIR

cp $GOPATH/src/github.com/docker/notary/bin/static/notary-server ./notary-server
cp $GOPATH/src/github.com/docker/notary/bin/static/notary-signer ./notary-signer

# return user to original location
cd $ORIG
