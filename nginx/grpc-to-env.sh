#!/bin/bash

# 指定檔案路徑
input_files=(
  "cloud-project/base-cloud/resources/cloud-grpc.properties"
  "cloud-project/base-cloud/resources/game-grpc.properties"
  "game-project/backend/base-game/resources/cloud-grpc.properties"
  "game-project/backend/base-game/resources/game-grpc.properties"
)

output_file="grpc-server.env"
declare -A servicePortMap || exit 1  # 保存服務名和端口映射, bash dictionary requires bash 4.0 or later. Use `bash --version` to check your bash version.

echo "# 腳本產生 grpc 環境變數檔" > $output_file

for (( i=0; i < ${#input_files[@]}; i++ ))
do
  input_file=${input_files[$i]}
  echo >> $output_file
  echo "# Processed from $input_file" >> $output_file

  # 讀取檔案的每一行
  while IFS= read -r line || [[ -n "$line" ]]  # 或是讀取到最後一行, 沒有換行字元
  do
    # 解析 key 和 value
      key="${line%%=*}"
      value="${line##*=}"

      # 將 key 轉換成全大寫並替換 . 為 _
      env_key=$(echo "$key" | tr '.' '_' | tr '[:lower:]' '[:upper:]')

      # 提取 port 號
      port="${value##*:}"

      # 格式化輸出
      echo "export ${env_key}=grpc-proxy:${port}" # todo remove

      echo "${env_key}=grpc-proxy:${port}" >> $output_file

      # 保存服務名和端口映射
      service_key=${env_key//_/} # 將 _ 替換移除
      service_key=${service_key//GRPC/GRPC_} # 將 GRPC 替換成 GRPC_
      servicePortMap["$service_key"]="$port"
  done < "$input_file"
done

# todo 加個特例, 之後移除
echo "# Processed from special case"
echo "GRPC_HOST_MICRO_BACKEND_API=grpc-proxy:20101" >> $output_file



##############  開始處理 game-project 專案連線設置 ################
input_files=(
  "game-project/frontend/game-website/resources/grpc.properties"
)

for (( i=0; i < ${#input_files[@]}; i++ ))
do
  input_file=${input_files[$i]}
  echo >> $output_file
  echo "# Processed from $input_file" >> $output_file

  # 讀取檔案的每一行
  while IFS= read -r line || [[ -n "$line" ]]  # 或是讀取到最後一行, 沒有換行字元
  do
    # 解析 key 和 value
      key="${line%%=*}"
      value="${line##*=}"

      # 如果 key 前綴是 #, 代表是註解, 跳過
      if [[ "$key" == "#"* ]]; then
          continue
      fi

      # 將 key 轉換成全大寫並替換 . 為 _
      env_key=$(echo "$key" | tr '.' '_' | tr '[:lower:]' '[:upper:]')

      # 映射 port 號
      port=${servicePortMap["$env_key"]}

      if [[ -z "$port" ]]; then
          echo "Port not found for $env_key"
          exit 1
      fi

      # 格式化輸出
      echo "export ${env_key}=grpc-proxy:${port}" # todo remove

      echo "${env_key}=grpc-proxy:${port}" >> $output_file

  done < "$input_file"
done

echo "Finished processing all files"
