FROM golang:1.19-alpine3.16 AS build

RUN apk add --no-cache git make

ENV NOTARYPKG github.com/theupdateframework/notary
ENV TAG v0.7.0

ENV GOFLAGS -mod=vendor

WORKDIR /go/src/$NOTARYPKG
RUN set -eux; \
	git clone -b "$TAG" --depth 1 "https://$NOTARYPKG.git" .; \
	make SKIPENVCHECK=1 PREFIX=. ./bin/static/notary-server ./bin/static/notary-signer; \
	cp -vL ./bin/static/notary-server ./bin/static/notary-signer /; \
	/notary-server --version; \
	/notary-signer --version

FROM alpine:3.16

RUN adduser -D -H -g "" notary
EXPOSE 4444
EXPOSE 7899

ENV INSTALLDIR /notary/signer
ENV PATH=$PATH:${INSTALLDIR}
WORKDIR ${INSTALLDIR}

COPY --from=build /notary-signer ./
RUN ./notary-signer --version

COPY ./signer-config.json .
COPY ./entrypoint.sh .

USER notary

ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "notary-signer", "--version" ]
