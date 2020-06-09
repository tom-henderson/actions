FROM alpine:3.7

RUN	apk add --no-cache \
    bash \
    ca-certificates \
    curl \
    jq \
    git

COPY ./entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
