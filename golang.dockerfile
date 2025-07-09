ARG GOLANG_VERSION=1.20-alpine

FROM golang:${GOLANG_VERSION}

ENV TZ=Asia/Taipei
ENV CGO_ENABLED=1

# 套件原因修正
# https://github.com/confluentinc/confluent-kafka-go/issues/981
# explicitly link to libsasl2 installed as part of cyrus-sasl-dev
ENV CGO_LDFLAGS="-lsasl2"

RUN apk add tzdata
RUN apk add bash protoc git curl

 # CGO_ENABLED=1
RUN apk add --no-progress --no-cache \
    gcc \
    musl-dev

RUN apk add protobuf-dev   # protobuf file include path (cloud-proto and proto)
RUN apk add --no-cache cyrus-sasl-dev # explicitly install SASL package
RUN apk add --no-cache socat # container inside port forwarding

WORKDIR /go/src/

# container 啟動, volumes mount 後, 執行編譯
CMD ["bash", "/go/src/dockerbuild/golang-run.sh"]


