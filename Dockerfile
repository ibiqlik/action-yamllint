FROM python:3-alpine

RUN pip install yamllint && \
    apk add bash && \
    rm -rf ~/.cache/pip

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
