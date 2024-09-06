#!/usr/bin/env bash
set -Eeuo pipefail

docker image inspect notary:server > /dev/null
docker image inspect notary:signer > /dev/null
[ -d "$NOTARY_SOURCE" ]
NOTARY_SOURCE="$(readlink -ve "$NOTARY_SOURCE")"

[ -s "$NOTARY_SOURCE/fixtures/regenerateTestingCerts.sh" ]
docker volume create notary-fixtures

dir="$(dirname "$BASH_SOURCE")"
dir="$(readlink -ve "$dir")"

common=(
	--rm
	--mount type=volume,src=notary-fixtures,dst=/fixtures
	--mount "type=bind,src=$dir,dst=/config,ro"
)
interactive=(
	--interactive
)
if [ -t 0 ] && [ -t 1 ]; then
	interactive+=( --tty )
fi

docker run "${common[@]}" "${interactive[@]}" \
	--name notary-init \
	--mount "type=bind,src=$NOTARY_SOURCE/fixtures,dst=/notary-fixtures,ro" \
	--tmpfs /cmd/notary \
	--workdir /fixtures \
	--init \
	buildpack-deps:bullseye bash -Eeuo pipefail -x -c '
		find /fixtures -mindepth 1 -delete
		cp -vf /notary-fixtures/*.key /fixtures/
		sed -r -e "s/^command/exit 0 #/" /notary-fixtures/regenerateTestingCerts.sh > /fixtures/regenerateTestingCerts.sh # skip cfssl bits we do not need
		source /fixtures/regenerateTestingCerts.sh
	'

trap 'docker rm -vf notary-registry notary-server notary-signer > /dev/null' EXIT

docker rm -vf notary-signer &> /dev/null || :
docker run "${common[@]}" \
	--name notary-signer \
	--detach \
	notary:signer notary-signer -config=/config/signer.json

docker rm -vf notary-server &> /dev/null || :
docker run "${common[@]}" \
	--name notary-server \
	--detach \
	--link notary-signer \
	notary:server notary-server -config=/config/server.json

docker rm -vf notary-registry &> /dev/null || :
docker run --name notary-registry --rm --detach registry

args=(
	"${common[@]}"
	"${interactive[@]}"
	--link 'notary-registry:registry.local' \
	--link notary-server \
	--env DOCKER_CONTENT_TRUST_SERVER='https://notary-server:4443'
	--env DOCKER_CONTENT_TRUST=1
)

startDocker='
	unset DOCKER_HOST
	cp /fixtures/notary-server.crt /etc/ssl/certs/
	update-ca-certificates
	dockerd --insecure-registry registry.local:5000 &
	timeout 2 sh -euxc "while ! docker version; do sleep 1; done"
'

docker run "${args[@]}" \
	--name notary-docker-push \
	--privileged \
	--init \
	docker:dind sh -euxc "$startDocker"'
		docker pull --disable-content-trust hello-world
		docker tag hello-world registry.local:5000/docker/hello-world:latest
		export DOCKER_CONTENT_TRUST_ROOT_PASSPHRASE="mypassphrase123"
		export DOCKER_CONTENT_TRUST_REPOSITORY_PASSPHRASE="mypassphrase123"
		docker push registry.local:5000/docker/hello-world:latest
	'

docker run "${args[@]}" \
	--name notary-docker-pull \
	--privileged \
	--init \
	docker:dind sh -euxc "$startDocker"'
		docker pull registry.local:5000/docker/hello-world:latest
	'

user="$(id -u):$(id -g)"
args+=(
	--user "$user"
	--mount "type=bind,src=$NOTARY_SOURCE,dst=/notary-src"
	--mount type=volume,src=notary-fixtures,dst=/notary-src/fixtures
	--workdir /notary-src
)

docker run "${args[@]}" \
	--name notary-buildclient \
	--env GOCACHE=/tmp \
	--tmpfs /tmp \
	--init \
	golang:1.22-bookworm bash -Eeuo pipefail -xc '
		make client
	'

docker run "${args[@]}" \
	--name notary-testclient \
	--init \
	python:3.10-bullseye bash -Eeuo pipefail -xc '
		ln -svf ../../fixtures/root-ca.crt cmd/notary/
		python3 ./buildscripts/testclient.py \
			--reponame registry.local:5000/testclient/testclient \
			--server "$DOCKER_CONTENT_TRUST_SERVER"
	'
