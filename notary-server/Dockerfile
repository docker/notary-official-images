FROM alpine:latest

EXPOSE 4443

COPY ./server-config.json /notary/server/
COPY ./notary-server /notary/server/

WORKDIR /notary/server

ENTRYPOINT [ "/notary/server/notary-server" ]
CMD [ "--help" ]
