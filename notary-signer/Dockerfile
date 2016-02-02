FROM alpine:latest

EXPOSE 4444
EXPOSE 7899

COPY . /notary/signer

WORKDIR /notary/signer

ENTRYPOINT [ "/notary/signer/notary-signer" ]
CMD [ "-config=signer-config.json" ]
