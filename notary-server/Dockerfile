#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM golang:1.20-alpine3.18 AS build

RUN apk add --no-cache git make

ENV NOTARYPKG github.com/theupdateframework/notary
ENV TAG v0.7.0

ENV GOFLAGS -mod=vendor

WORKDIR /go/src/$NOTARYPKG
RUN set -eux; \
	git clone -b "$TAG" --depth 1 "https://$NOTARYPKG.git" .; \
# In case the version in file doens't match the tag (like in 0.7.0)
	echo "${TAG//v/}" > NOTARY_VERSION; \
# https://github.com/notaryproject/notary/pull/1635
	git fetch --depth 2 origin efc35b02698644af16f6049c7b585697352451b8; \
	git -c user.name=foo -c user.email=foo@example.com cherry-pick -x efc35b02698644af16f6049c7b585697352451b8; \
# https://github.com/notaryproject/notary/issues/1602 (rough cherry-pick of ca095023296d2d710ad9c6dec019397d46bf8576)
	go get github.com/dvsekhvalnov/jose2go@v0.0.0-20200901110807-248326c1351b; \
	go mod vendor; \
# TODO remove for the next release of Notary (which should include efc35b02698644af16f6049c7b585697352451b8 & ca095023296d2d710ad9c6dec019397d46bf8576)
# Make the version detectable by scanners
	sed -i -r -E 's|(version.NotaryVersion=\$\(NOTARY_VERSION\))|\1 -X $(NOTARY_PKG)/version.Version=$(NOTARY_VERSION)|' Makefile; \
	make SKIPENVCHECK=1 PREFIX=. ./bin/static/notary-server ./bin/static/notary-signer; \
	cp -vL ./bin/static/notary-server ./bin/static/notary-signer /; \
	/notary-server --version; \
	/notary-signer --version;

FROM alpine:3.18

RUN adduser -D -H -g "" notary
EXPOSE 4443

ENV INSTALLDIR /notary/server
ENV PATH=$PATH:${INSTALLDIR}
WORKDIR ${INSTALLDIR}

COPY --from=build /notary-server ./
RUN ./notary-server --version

COPY ./server-config.json .
COPY ./entrypoint.sh .

USER notary

ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "notary-server", "--version" ]
