FROM alpine:latest

RUN apk update && apk add --no-cache bash python3 py3-pip shadow && \
     pip3 install --upgrade pip && \
     pip3 install awscli==1.22.46 && \
     ln -sf /usr/bin/python3 /usr/bin/python &&\
     rm -rf /var/cache/apk/*

RUN adduser -u 1000 jenkins -D -s /bin/bash

COPY *.sh /

RUN chmod +x /*.sh


CMD ["sh", "-c", "/run.sh"]
