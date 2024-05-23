
ping -c 1 "$RegCenterLocalIp"  # 確認是否連線成功

echo "Running go mod tidy ..."
go mod tidy

# 產生 beego routers
if [ -f "./routers/router.go" ]; then
  if ! command -v bee &> /dev/null
    then
        echo "bee could not be found, installing bee ..."
        go get github.com/beego/bee/v2
        go install github.com/beego/bee/v2
    fi

  bee generate routers
else
  echo "No routers folder is found."
fi

# gcc 編譯失敗: 需要 musl tag
# https://github.com/confluentinc/confluent-kafka-go/issues/454
# 除錯模式: 安裝 dlv
if [ "${DEBUG_PORT}" != "" ] &&  [ "${DEBUG_MODE}" != "0" ]; then

  if ! command -v dlv &> /dev/null
  then
      echo "dlv could not be found, installing dlv ..."
      go install -v github.com/go-delve/delve/cmd/dlv@latest
  fi


  echo "Ready to compile with debug mode."
  dlv version
  echo "Listen debug port ':${DEBUG_PORT}' at container"
  echo "building golang debug executable files ..."

  # reference: https://www.jetbrains.com/help/go/attach-to-running-go-processes-with-debugger.html#step-1-build-the-application
  go build -tags musl -gcflags="all=-N -l" -o $GOPATH/bin/golang-dlv .
  dlv --listen=":${DEBUG_PORT}" --headless=true --accept-multiclient --api-version=2 --continue --log exec $GOPATH/bin/golang-dlv
else
  echo "building golang executable files ..."
  go run -tags musl .
fi
