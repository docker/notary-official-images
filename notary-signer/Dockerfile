FROM alpine:3.8

ENV TAG v0.6.1
ENV NOTARYPKG github.com/theupdateframework/notary
ENV INSTALLDIR /notary/signer
EXPOSE 4444
EXPOSE 7899

WORKDIR ${INSTALLDIR}

RUN set -eux; \
    apk --no-cache add git go make musl-dev; \
    export GOPATH=/go GOCACHE=/go/cache; \
    mkdir -p ${GOPATH}/src/${NOTARYPKG}; \
    git clone -b ${TAG} --depth 1 https://${NOTARYPKG} ${GOPATH}/src/${NOTARYPKG}; \
    make -C ${GOPATH}/src/${NOTARYPKG} PREFIX=. ./bin/static/notary-signer; \
    cp -vL ${GOPATH}/src/${NOTARYPKG}/bin/static/notary-signer ./; \
    apk --no-cache del git go make musl-dev; \
    rm -rf ${GOPATH}

COPY ./signer-config.json .
COPY ./entrypoint.sh .

RUN adduser -D -H -g "" notary
USER notary
ENV PATH=$PATH:${INSTALLDIR}

ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "notary-signer", "--help" ]
