FROM alpine:3.8

ENV TAG v0.6.1
ENV NOTARYPKG github.com/theupdateframework/notary
ENV NOTARYREPO https://api.github.com/repos/theupdateframework/notary
ENV INSTALLDIR /notary/server
EXPOSE 4443

WORKDIR /usr/lib/go/src/${NOTARYPKG}

RUN apk --no-cache add tar go musl-dev && \
    wget -O notary.tar.gz "${NOTARYREPO}/tarball/${TAG}" && \
    tar xzf notary.tar.gz --strip-components=1 && \
    go install \
	-ldflags "-w -X ${NOTARYPKG}/version.GitCommit=`wget -qO- ${NOTARYREPO}/tags | \
		grep -A 5 ${TAG} | grep sha | \
		awk '{print substr($2,2,8)}'` \
		-X ${NOTARYPKG}/version.NotaryVersion=`cat NOTARY_VERSION`" \
	${NOTARYPKG}/cmd/notary-server && \
    mkdir -p ${INSTALLDIR} && \
    cp /usr/lib/go/bin/notary-server ${INSTALLDIR} && \
    apk --no-cache del tar go musl-dev && \
    rm -rf /usr/lib/go

WORKDIR ${INSTALLDIR}

COPY ./server-config.json .
COPY ./entrypoint.sh .

RUN adduser -D -H -g "" notary
USER notary
ENV PATH=$PATH:${INSTALLDIR}

ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "notary-server", "--help" ]
