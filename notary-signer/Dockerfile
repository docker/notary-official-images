#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.16

RUN adduser -D -H -g "" notary
EXPOSE 4444
EXPOSE 7899

ENV INSTALLDIR /notary/signer
ENV PATH=$PATH:${INSTALLDIR}
WORKDIR ${INSTALLDIR}

COPY --from=notary:0.7.0-builder /notary-signer ./
RUN ./notary-signer --version

COPY ./signer-config.json .
COPY ./entrypoint.sh .

USER notary

ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "notary-signer", "--version" ]
