FROM python:3-alpine

RUN pip install yamllint && \
    apk add --no-cache bash && \
    rm -rf ~/.cache/pip

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
