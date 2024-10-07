FROM alpine:3.20
WORKDIR /bin

RUN apk add --no-cache curl jq gettext-envsubst git && \
    adduser -D -u 4321 app

COPY comment .

ENTRYPOINT ["/bin/comment"]
