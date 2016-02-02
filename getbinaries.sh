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

# copy this binaries in the appropriate dirs
cp bin/static/notary-server $DIR/notary-server/notary-server
cp bin/static/notary-signer $DIR/notary-signer/notary-signer

# copy default/example configurations
cp fixtures/server-config.json $DIR/notary-server/server-config.json
cp fixtures/signer-config.json $DIR/notary-signer/signer-config.json

# copy default certs and keys
cp fixtures/root-ca.crt $DIR/notary-server/root-ca.crt
cp fixtures/notary-server.key $DIR/notary-server/notary-server.key
cp fixtures/notary-server.crt $DIR/notary-server/notary-server.crt

cp fixtures/root-ca.crt $DIR/notary-signer/root-ca.crt
cp fixtures/notary-signer.key $DIR/notary-signer/notary-signer.key
cp fixtures/notary-signer.crt $DIR/notary-signer/notary-signer.crt

# return user to original location
cd $ORIG
