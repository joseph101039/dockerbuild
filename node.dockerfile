ARG NODE_VERSION=node:14-alpine

FROM ${NODE_VERSION}
ARG PROJECT=""
ENV TZ=Asia/Taipei

RUN apk upgrade
RUN apk add tzdata

# alpine3.15 is the last version compatible with python2
RUN apk add --no-cache python2 # python2
RUN apk add bash
RUN apk add gcc g++ make cmake
RUN apk add gfortran libffi-dev openssl-dev libtool  # make tool
RUN apk add git  # 此項不可以除 需要 pull repo

WORKDIR "/var/www/html/${PROJECT}"



COPY "${PROJECT}/package*.json" \
     ./

CMD [ "bash", "/var/www/html/dockerbuild/node-run.sh" ]