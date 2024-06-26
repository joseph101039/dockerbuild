#!/bin/bash

# 指定檔案路徑
input_files=(
  "cloud/cloud-grpc.properties"
  "cloud/game-grpc.properties"
  "game/cloud-grpc.properties"
  "game/game-grpc.properties"
)

grpc_ports=(
  "80"
  "8080"
  "80"
  "8080"
)

template_file="nginx.grpc.conf.template"
output_dir="/etc/nginx/conf.d/"

mkdir -p "$output_dir"
for (( i=0; i < ${#input_files[@]}; i++ ))
do
  input_file=${input_files[$i]}
  grpc_port=${grpc_ports[$i]}

  # 讀取檔案的每一行
  while IFS= read -r line
  do
      # 移除前綴 grpc.host
      modified_line=${line#grpc.host.}
      # 將 micro. 替換成 -
      modified_line=${modified_line//.micro./-}
      # 取得 IP 和端口
      ip_port=${modified_line#*=}
      # 取得主機名
      host_name=${modified_line%%=*}
      # 將主機名中的點替換成-
      host_name=${host_name//./-}
      # 取得端口號
      port=${ip_port##*:}

      # 檢查變數是否為空
      if [[ -z "$host_name" || -z "$port" ]]; then
          echo "Host name or port is empty in line: $line"
          exit 1
      fi

      # 使用 envsubst 進行變數替換並輸出到指定文件
      export GRPC_DOMAIN=$host_name
      export GRPC_PORT=$grpc_port
      export PROXY_PORT=$port

      if [[ "$GRPC_DOMAIN" == "micro-backend-api" ]]; then
        continue
      fi

      envsubst '${GRPC_DOMAIN},${GRPC_PORT},${PROXY_PORT}' < "$template_file" > "$output_dir/${GRPC_DOMAIN}.conf"

      # 輸出結果
      echo "Processed: $host_name, $port"
  done < "$input_file"
done
