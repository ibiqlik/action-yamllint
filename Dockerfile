FROM python:3-alpine

RUN pip install 'yamllint>=1.25.0' && \
    apk add --no-cache bash && \
    rm -rf ~/.cache/pip

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
