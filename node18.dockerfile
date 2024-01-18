ARG NODE_VERSION=node:18-alpine

FROM ${NODE_VERSION}
ARG PROJECT=""
ENV TZ=Asia/Taipei

RUN apk upgrade
RUN apk add tzdata

# This hack is widely applied to avoid python printing issues in docker containers.
# See: https://github.com/Docker-Hub-frolvlad/docker-alpine-python3/pull/13
ENV PYTHONUNBUFFERED=1

# alpine3.15 is the last version compatible with python2
RUN apk add --no-cache python2 # python2
RUN apk add bash
RUN apk add gcc g++ make cmake
RUN apk add gfortran libffi-dev openssl-dev libtool  # make tool


RUN apk add git
WORKDIR "/var/www/html/${PROJECT}"

COPY "${PROJECT}/package*.json" \
     ./

CMD [ "bash", "/var/www/html/dockerbuild/node-run.sh" ]