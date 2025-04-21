#!/bin/bash
function portForwarding() {
  if ! command -v socat &> /dev/null; then
    echo "socat could not be found, installing socat ..."
    apk add socat
  fi

  declare -a input_files
  # if /go/src/backend/base-cloud/ is a folder
  if [[ -d "/go/src/backend/base-cloud/" ]]; then
    echo "base-cloud folder is found."
    input_files=(
      "/go/src/backend/base-cloud/module/.cloud-env"
      "/go/src/backend/base-cloud/resources/game-grpc.properties"
    )
  elif [[ -d "/go/src/backend/base-game" ]]; then
    echo "base-game folder is found."
    input_files=(
      "/go/src/backend/base-game/module/.game-env"
      "/go/src/backend/base-game/resources/cloud-grpc.properties"
    )
  else
    echo "no related port forwarding folder is not found."
  fi

  for (( i=0; i < ${#input_files[@]}; i++ ))
  do
    input_file=${input_files[$i]}
    echo "# Processed from $input_file"

    # 讀取檔案的每一行
    while IFS= read -r line || [[ -n "$line" ]]  # 或是讀取到最後一行, 沒有換行字元
    do
        # 解析 key 和 value
        key="${line%%=*}"
        value="${line##*=}"

        # 如果 key 開頭是 GRPC_
        if [[ "$key" == GRPC_* || "$key" == grpc.* ]]; then
            # 將 key 替換 GRPC_ 為空, 替換 MICRO_ 為空, 替換 _ 為 . , 轉換成全小寫
            service_key=$(echo "$key" | \
             sed 's/CLOUDMICRO/CLOUD_MICRO_/g' | sed 's/grpc.micro/grpc.micro./g' | \
             tr '[:upper:]' '[:lower:]' | sed 's/_/./g'  | sed 's/micro.//g' | sed 's/grpc.//g' | sed 's/\./-/g'  )
            service_key="${service_key//backend-api/backendapi}"  # 特例處理

            port=$(echo "$value" | cut -d':' -f2)
            # 不能 forward 到自身, 不應佔用 port
            if [[ "$service_key" == "$COMPOSE_SERVICE" ]]; then
              if [[ "$HEALTHCHECK_FORWARD_PORT" != "" ]]; then
                # 將 healthcheck 呼叫轉發到自己 grpc port
                PORT_MAPPING[$HEALTHCHECK_FORWARD_PORT]="${service_key}:${port}"
              fi

              continue
            fi

            PORT_MAPPING[$port]="${service_key}:${port}"
        fi

    done < "$input_file"
  done


  if [ ${#PORT_MAPPING[@]} -eq 0 ]; then
    echo "No port forwarding rules are found."
    return
  else
    for LOCAL_PORT in "${!PORT_MAPPING[@]}"; do
      REMOTE_SERVICE=${PORT_MAPPING[$LOCAL_PORT]}
      echo "Forwarding ${LOCAL_PORT} to ${REMOTE_SERVICE} ..."
      socat "TCP-LISTEN:${LOCAL_PORT},fork,reuseaddr" "TCP:${REMOTE_SERVICE}" >/dev/null 2>&1 &
    done
  fi
}



ping -c 1 "$RegCenterLocalIp"  # 確認是否連線成功

portForwarding
if [ "$?" != "0" ]; then
  echo "Port forwarding error!"
  exit 1
fi


echo "Running go mod tidy ..."
go mod tidy -x -v

# GRPC healthcheck 檢查
if ! command -v grpc-health-probe &> /dev/null; then
    echo "grpc-health-probe could not be found, installing grpc-health-probe ..."
    go get "github.com/grpc-ecosystem/grpc-health-probe@${GRPC_HEALTH_PROBE_VERSION}"
    go install "github.com/grpc-ecosystem/grpc-health-probe@${GRPC_HEALTH_PROBE_VERSION}"
fi

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

#  echo "Go clean cache ..."
#  go clean -cache

  echo "building golang 'DEBUG' executable files ..."
  # reference: https://www.jetbrains.com/help/go/attach-to-running-go-processes-with-debugger.html#step-1-build-the-application
  go build -tags musl -gcflags="all=-N -l" -o $GOPATH/bin/golang-dlv .

  if [ "$?" != "0" ]; then
    echo "Compile error!"
    exit 1
  else
    echo "Compile success!"
  fi

  dlv --listen=":${DEBUG_PORT}" --headless=true --accept-multiclient --api-version=2 --continue --log exec $GOPATH/bin/golang-dlv
else
  echo "building golang executable files ..."
  go build -tags musl -o /go/bin/main && /go/bin/main  # go build faster than go run
fi
