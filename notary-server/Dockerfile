FROM alpine:latest

EXPOSE 4443

COPY . /notary/server

WORKDIR /notary/server

ENTRYPOINT [ "/notary/server/notary-server" ]
CMD [ "-config=server-config.json" ]
