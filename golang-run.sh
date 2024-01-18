
go mod tidy

# Gate 需要產生 routes
if [ "${GENERATE_BEE_ROUTES}" = "1" ]; then
  go get github.com/beego/bee/v2
  go install github.com/beego/bee/v2
  bee generate routers
fi


if [ "${GENERATE_PROTO}" = "1" ]; then
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
    go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
fi

go run .