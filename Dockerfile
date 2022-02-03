FROM alpine:latest

RUN apk update && apk add --no-cache bash python3 py3-pip && \
     pip3 install --upgrade pip && \
     pip3 install awscli==1.22.46 && \
     ln -s /usr/bin/python3 /usr/bin/python &&\
     rm -rf /var/cache/apk/*

COPY *.sh /

RUN chmod +x /*.sh


CMD ["sh", "-c", "/run.sh"]
