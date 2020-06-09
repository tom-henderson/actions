FROM python:3.7-alpine3.9

RUN	apk add --no-cache \
    bash \
    ca-certificates \
    curl \
    nodejs-npm \
    jq

RUN npm install -g serverless

COPY ./entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
