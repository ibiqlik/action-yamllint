FROM python:3-alpine

RUN apk add --no-cache bash yamllint

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
