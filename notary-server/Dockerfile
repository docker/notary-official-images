FROM alpine:latest

EXPOSE 4443

COPY ./server-config.json /notary/server/
COPY ./notary-server /notary/server/
COPY ./entrypoint.sh /notary/server/

WORKDIR /notary/server

RUN adduser -D -H -g "" notary

USER notary

ENV PATH=$PATH:/notary/server

ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "notary-server", "--help" ]
