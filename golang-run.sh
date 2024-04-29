
ping -c 1 "$RegCenterLocalIp"  # 確認是否連線成功

go mod tidy

# 產生 beego routers
if [ -f "./routers/router.go" ]; then
  go get github.com/beego/bee/v2
  go install github.com/beego/bee/v2
  bee generate routers
else
  echo "No routers folder found."
fi

# gcc 編譯失敗: 需要 musl tag
# https://github.com/confluentinc/confluent-kafka-go/issues/454
# 除錯模式: 安裝 dlv
if [ "${DEBUG_PORT}" != "" ] &&  [ "${DEBUG_MODE}" != "0" ]; then
  go install -v github.com/go-delve/delve/cmd/dlv@latest

  echo "Ready to compile with debug mode."
  dlv version
  echo "Listen debug port ':${DEBUG_PORT}' at container"

  # reference: https://www.jetbrains.com/help/go/attach-to-running-go-processes-with-debugger.html#step-1-build-the-application
  go build -tags musl -gcflags="all=-N -l" -o $GOPATH/bin/golang-dlv .
  dlv --listen=":${DEBUG_PORT}" --headless=true --accept-multiclient --api-version=2 exec $GOPATH/bin/golang-dlv
#  dlv debug --listen=":${DEBUG_PORT}" --headless=true --accept-multiclient --api-version=2 -- -tags musl -gcflags="all=-N -l"
else
  go run -tags musl .
fi
