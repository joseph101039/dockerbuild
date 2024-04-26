ARG MAVEN_VERSION=3.9.6-eclipse-temurin-8

FROM maven:${MAVEN_VERSION}

ENV PROJECT=""
ENV PROFILE="dev"
ENV TZ=Asia/Taipei


RUN apt-get update -y
RUN apt-get install -y tzdata bash git
RUN apt-get install -y iputils-ping

## container 啟動, volumes mount 後, 執行編譯
CMD ["bash", "/usr/src/dockerbuild/java-run.sh"]


