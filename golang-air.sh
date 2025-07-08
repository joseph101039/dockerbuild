#!/bin/bash


echo "Running go mod tidy ..."
go mod tidy -x -v

if [ "${AIR_VERSION}" == "" ]; then
  AIR_VERSION="latest"
fi

# 監聽檔案變化
if ! command -v air &>/dev/null; then
  echo "air-verse/air could not be found, installing air-verse/air ..."
  go install "github.com/air-verse/air@${AIR_VERSION}"
fi

# protobuf
if ! command -v protoc-gen-go &>/dev/null; then
  echo "protoc-gen-go could not be found, installing protoc-gen-go ..."
  go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
  go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
fi

echo "$(air -v)"
air -c /go/src/dockerbuild/air/cloud-proto.air.toml
