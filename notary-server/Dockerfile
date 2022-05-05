FROM alpine:3.12 as builder

ENV TAG v0.7.0
ENV NOTARYPKG github.com/theupdateframework/notary
ENV INSTALLDIR /notary/server

WORKDIR ${INSTALLDIR}

RUN set -eux; \
    apk add git make go; \
    export GOPATH=/go GOCACHE=/go/cache; \
    mkdir -p ${GOPATH}/src/${NOTARYPKG}; \
    git clone -b ${TAG} --depth 1 https://${NOTARYPKG} ${GOPATH}/src/${NOTARYPKG}; \
    make -C ${GOPATH}/src/${NOTARYPKG} SKIPENVCHECK=1 PREFIX=. ./bin/static/notary-server; \
    cp -vL ${GOPATH}/src/${NOTARYPKG}/bin/static/notary-server ./; \
    ./notary-server --version

FROM alpine:3.15

ENV INSTALLDIR /notary/server

EXPOSE 4443

WORKDIR ${INSTALLDIR}

COPY --from=builder ${INSTALLDIR}/notary-server .

COPY ./server-config.json .
COPY ./entrypoint.sh .

RUN adduser -D -H -g "" notary
USER notary
ENV PATH=$PATH:${INSTALLDIR}

ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "notary-server", "--version" ]
