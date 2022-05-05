FROM alpine:3.12 as builder

ENV TAG v0.7.0
ENV NOTARYPKG github.com/theupdateframework/notary
ENV INSTALLDIR /notary/signer

WORKDIR ${INSTALLDIR}

RUN set -eux; \
    apk add git make go; \
    export GOPATH=/go GOCACHE=/go/cache; \
    mkdir -p ${GOPATH}/src/${NOTARYPKG}; \
    git clone -b ${TAG} --depth 1 https://${NOTARYPKG} ${GOPATH}/src/${NOTARYPKG}; \
    make -C ${GOPATH}/src/${NOTARYPKG} SKIPENVCHECK=1 PREFIX=. ./bin/static/notary-signer; \
    cp -vL ${GOPATH}/src/${NOTARYPKG}/bin/static/notary-signer ./; \
    ./notary-signer --version

FROM alpine:3.15

ENV INSTALLDIR /notary/signer

EXPOSE 4444
EXPOSE 7899

WORKDIR ${INSTALLDIR}

COPY --from=builder ${INSTALLDIR}/notary-signer .

COPY ./signer-config.json .
COPY ./entrypoint.sh .

RUN adduser -D -H -g "" notary
USER notary
ENV PATH=$PATH:${INSTALLDIR}

ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "notary-signer", "--version" ]
