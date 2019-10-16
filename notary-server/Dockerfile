FROM alpine:3.10

ENV TAG v0.6.1
ENV NOTARYPKG github.com/theupdateframework/notary
ENV INSTALLDIR /notary/server
EXPOSE 4443

WORKDIR ${INSTALLDIR}

RUN set -eux; \
    apk add --no-cache --virtual build-deps git go make musl-dev; \
    go version | grep 'go1.12.10 '; \
    export GOPATH=/go GOCACHE=/go/cache; \
    mkdir -p ${GOPATH}/src/${NOTARYPKG}; \
    git clone -b ${TAG} --depth 1 https://${NOTARYPKG} ${GOPATH}/src/${NOTARYPKG}; \
    make -C ${GOPATH}/src/${NOTARYPKG} SKIPENVCHECK=1 PREFIX=. ./bin/static/notary-server; \
    cp -vL ${GOPATH}/src/${NOTARYPKG}/bin/static/notary-server ./; \
    apk del --no-network build-deps; \
    rm -rf ${GOPATH}

COPY ./server-config.json .
COPY ./entrypoint.sh .

RUN adduser -D -H -g "" notary
USER notary
ENV PATH=$PATH:${INSTALLDIR}

ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "notary-server", "--help" ]
