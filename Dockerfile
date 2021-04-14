FROM python:3-alpine

RUN apk add --no-cache bash gcc musl-dev && \
    pip install 'yamllint>=1.25.0' && \
    rm -rf ~/.cache/pip

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
