#!/bin/bash

# 指定檔案路徑
input_files=(
  "cloud/cloud-grpc.properties"
  "cloud/game-grpc.properties"
  "game/cloud-grpc.properties"
  "game/game-grpc.properties"
)

output_file="grpc-server.env"
echo "# 腳本產生 grpc 環境變數檔" > $output_file

for (( i=0; i < ${#input_files[@]}; i++ ))
do
  input_file=${input_files[$i]}
  echo >> $output_file
  echo "# Processed from $input_file" >> $output_file

  # 讀取檔案的每一行
  while IFS= read -r line
  do
    # 解析 key 和 value
      key="${line%%=*}"
      value="${line##*=}"

      # 將 key 轉換成全大寫並替換 . 為 _
      env_key=$(echo "$key" | tr '.' '_' | tr '[:lower:]' '[:upper:]')

      # 提取 port 號
      port="${value##*:}"

      # 格式化輸出
      echo "${env_key}=grpc-proxy:${port}" >> $output_file
  done < "$input_file"
done
