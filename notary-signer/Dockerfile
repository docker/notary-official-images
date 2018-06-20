FROM golang:1.10.3-alpine
ENV TAG v0.6.1
ENV NOTARYPKG github.com/theupdateframework/notary
WORKDIR /go/src/${NOTARYPKG}
RUN apk --update add tar
RUN wget -O notary.tar.gz "https://api.github.com/repos/theupdateframework/notary/tarball/${TAG}" && tar xzf notary.tar.gz --strip-components=1
# Since we are not using git to get the repo, use the REST API to get the sha of the digest for the tag.
RUN go install \
    -ldflags "-w -X ${NOTARYPKG}/version.GitCommit=`wget -qO- https://api.github.com/repos/theupdateframework/notary/tags | grep -A 5 ${TAG} | grep sha | awk '{print substr($2,2,8)}'` -X ${NOTARYPKG}/version.NotaryVersion=`cat NOTARY_VERSION`" \
    ${NOTARYPKG}/cmd/notary-signer


FROM alpine:latest
EXPOSE 4444
EXPOSE 7899
WORKDIR /notary/signer

COPY ./signer-config.json .
COPY ./entrypoint.sh .
COPY --from=0 /go/bin/notary-signer .

RUN adduser -D -H -g "" notary
USER notary
ENV PATH=$PATH:/notary/signer

ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "notary-signer", "--help" ]
