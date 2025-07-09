#!/bin/bash


echo "Running go mod tidy ..."
go mod tidy -x -v

if [ "${AIR_VERSION}" == "" ]; then
  AIR_VERSION="latest"
fi


# install air for 監聽檔案變化
if ! command -v air &>/dev/null; then
  echo "air-verse/air could not be found, installing air-verse/air ..."
  go install "github.com/air-verse/air@${AIR_VERSION}"
fi

# install protobuf-related packages
if ! command -v protoc-gen-go &>/dev/null; then
  echo "protoc-gen-go could not be found, installing protoc-gen-go ..."
  go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
  go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
  go install github.com/envoyproxy/protoc-gen-validate@latest

  go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@latest
  go get -tool github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@latest
fi

#echo "$(air -v)"
#air -c /go/src/dockerbuild/air/proto.air.toml


# list all protobuf directories
protoDirs=($(find . -maxdepth 1 -type d \( -name "*-common" -o -name "*proto" \)))

# Run each command in the background and output to standard out  by tee
pids=()
for dir in "${!protoDirs[@]}"; do
    command="cd ${protoDirs[$dir]} && air -c /go/src/dockerbuild/air/proto.air.toml"
    echo "Running command in directory: ${protoDirs[$dir]}"
    echo "Command: $command"
    bash -c "$command" | tee >(cat) &
    pids+=($!) # Store the process ID
done

# Wait for all commands to finish
for pid in "${pids[@]}"; do
    wait $pid
done
