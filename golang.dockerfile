ARG GOLANG_VERSION=1.20-alpine

FROM golang:${GOLANG_VERSION}

ENV PROJECT=""
ENV GENERATE_BEE_ROUTES=0
ENV TZ=Asia/Taipei
ENV BEEGO_CONF="conf/app.conf"

RUN apk add tzdata
RUN apk add bash protoc git


WORKDIR "/go/src/${PROJECT}"

# append nacos 設定覆蓋各專案的 conf/app.conf
#RUN mkdir -p conf

# proto do not have conf directory
#COPY "${PROJECT}/conf/" conf/

#COPY dockerbuild/nacos-overwrite-app.conf conf/nacos-overwrite-app.conf

#RUN cat  conf/app.conf && sleep 15

# sed 替換 [ ] => # [ ] 避免有些非法 nacos 設置
#RUN cat conf/nacos-overwrite-app.conf  >> conf/app.conf && \
#    sed -i  's/^\(\[\w*\]\)/# \1/' conf/app.conf
#    && rm conf/nacos-overwrite-app.conf

# container 啟動, volumes mount 後, 執行編譯
CMD ["bash", "/go/src/dockerbuild/golang-run.sh"]


