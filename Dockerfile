FROM alpine:3.20
WORKDIR /app

RUN apk add --no-cache curl jq gettext-envsubst && \
    adduser -D -u 4321 app

COPY comment .

ENTRYPOINT ["/app/comment"]
