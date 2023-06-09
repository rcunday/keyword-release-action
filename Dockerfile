FROM alpine

RUN apk add --no-cache \
        curl \
        bash           \
        httpie         \
        jq &&          \
        which curl &&  \
        which bash &&  \
        which http &&  \
        which jq

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 0755 /usr/local/bin/entrypoint.sh
COPY mock_push_event.json /mock_push_event.json

ENTRYPOINT ["entrypoint.sh"]