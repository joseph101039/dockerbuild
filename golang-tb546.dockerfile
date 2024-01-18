ARG GOLANG_VERSION=1.20-alpine

FROM golang:${GOLANG_VERSION}

ARG PROJECT=""
ENV GENERATE_BEE_ROUTES=0
ENV TZ=Asia/Taipei

RUN apk add tzdata
RUN apk add bash protoc
#RUN apk add git
RUN apk add openssh

WORKDIR "/go/src/${PROJECT}"

# append nacos 設定覆蓋各專案的 conf/app.conf
RUN mkdir -p conf
COPY dockerbuild/nacos-overwrite-app-tb546.conf conf/nacos-overwrite-app-tb546.conf
# proto do not have conf directory
COPY "${PROJECT}/conf/" conf/

# copy the lang file for router services

#RUN ls -l ${PROJECT}/conf/ && sleep 10


COPY "${PROJECT}/conf/locale_*.ini" conf/


#RUN cat  conf/app.conf && sleep 15

# sed 替換 [ ] => # [ ] 避免有些非法 nacos 設置
RUN cat conf/nacos-overwrite-app-tb546.conf  >> conf/app.conf && \
    sed -i  's/^\(\[\w*\]\)/# \1/' conf/app.conf  && \
    rm conf/nacos-overwrite-app-tb546.conf


# container 啟動, volumes mount 後, 執行編譯
CMD ["bash", "/go/src/dockerbuild/golang-run.sh"]


