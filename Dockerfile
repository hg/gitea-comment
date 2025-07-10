FROM alpine:3.22
WORKDIR /bin

RUN apk add --no-cache curl jq gettext-envsubst git && \
    adduser -D -u 4321 app

COPY comment .

ENTRYPOINT ["/bin/comment"]
