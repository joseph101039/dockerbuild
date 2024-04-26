#!/usr/bin/env bash

npm install --global cross-env

# only for game app
if [[ "${BUILD_APP}" == "1" ]]; then
  rm package-lock.json
  rm -rf node_modules
  npm install -f
  npm run serve
  exit 0
fi

# 取代開發服網址成為本地網址
if [[ "${REPLACE_FROM_BASE_URI}" != "" ]]; then
  sed -i "s#${REPLACE_FROM_BASE_URI}#${REPLACE_WITH_BASE_URI}#g" config/dev.env.js
fi

if [[ "${REPLACE_FROM_GATEWAY_CONFIG}" != "" ]]; then
  sed -i "s#${REPLACE_FROM_GATEWAY_CONFIG}#${REPLACE_WITH_GATEWAY_CONFIG}#g" config/dev.env.js
fi

# only for cloud
sed -i 's#npm run locales && ##' package.json

if [[ "$IGNORE_SCRIPT" == "1" ]]; then
  printf "npm install with IGNORE_SCRIPT\n"
  git config --global url."https://github".insteadOf github:
  npm install --ignore-scripts
else
  npm install -f
fi;


npm rebuild node-sass   # fix cloud-manager: Error: Node Sass does not yet support your current environment: Linux Unsupported architecture (arm64) with Node.js 14.x
npm run dev
