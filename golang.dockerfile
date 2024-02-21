ARG GOLANG_VERSION=1.20-alpine

FROM golang:${GOLANG_VERSION}

ENV PROJECT=""
ENV GENERATE_BEE_ROUTES=0
ENV TZ=Asia/Taipei
ENV BEEGO_CONF="conf/app.conf"
ENV CGO_ENABLED=1

# 套件原因修正
# https://github.com/confluentinc/confluent-kafka-go/issues/981
# explicitly link to libsasl2 installed as part of cyrus-sasl-dev
ENV CGO_LDFLAGS="-lsasl2"

RUN apk add tzdata
RUN apk add bash protoc git

 # CGO_ENABLED=1
RUN apk add --no-progress --no-cache \
    gcc \
    musl-dev

RUN apk add --no-cache cyrus-sasl-dev  # explicitly install SASL package

WORKDIR "/go/src/${PROJECT}"


# container 啟動, volumes mount 後, 執行編譯
CMD ["bash", "/go/src/dockerbuild/golang-run.sh"]


