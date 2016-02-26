FROM alpine:latest

EXPOSE 4444
EXPOSE 7899

COPY ./signer-config.json /notary/signer/
COPY ./notary-signer /notary/signer/
COPY ./entrypoint.sh /notary/signer/

WORKDIR /notary/signer

RUN adduser -D -H -g "" notary

USER notary

ENV PATH=$PATH:/notary/signer

ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "notary-signer", "--help" ]
