#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.16

RUN adduser -D -H -g "" notary
EXPOSE 4443

ENV INSTALLDIR /notary/server
ENV PATH=$PATH:${INSTALLDIR}
WORKDIR ${INSTALLDIR}

COPY --from=notary:0.7.0-builder /notary-server /notary.spdx.json ./
RUN ./notary-server --version

COPY ./server-config.json .
COPY ./entrypoint.sh .

USER notary

ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "notary-server", "--version" ]
