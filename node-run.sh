#!/usr/bin/env bash
# 取代開發服網址成為本地網址

if [[ "${REPLACE_FROM_BASE_URI}" != "" ]]; then
  sed -i "s#\"${REPLACE_FROM_BASE_URI}\"#\"${REPLACE_WITH_BASE_URI}\"#g" config/dev.env.js
fi

# only for cloud
sed -i 's#npm run locales && ##' package.json

if [[ "$IGNORE_SCRIPT" == "1" ]]; then
  printf "npm install with IGNORE_SCRIPT\n"
#    cp -r node_modules_copy node_modules
#    sleep 30
  git config --global url."https://github".insteadOf github:
  npm install --ignore-scripts
  #npm install
else
  npm install
fi;

npm install --global cross-env
npm rebuild node-sass   # fix cloud-manager: Error: Node Sass does not yet support your current environment: Linux Unsupported architecture (arm64) with Node.js 14.x
npm run dev