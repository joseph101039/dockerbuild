ARG GOLANG_VERSION=1.20-alpine

FROM golang:${GOLANG_VERSION}

ARG PROJECT=""
ENV GENERATE_BEE_ROUTES=0
ENV GENERATE_PROTO=0
ENV TZ=Asia/Taipei

RUN apk add tzdata
RUN apk add bash protoc

WORKDIR "/go/src/${PROJECT}"

# container 啟動, volumes mount 後, 執行編譯
CMD ["bash", "/go/src/dockerbuild/golang-run.sh"]


