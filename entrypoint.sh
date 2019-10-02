#!/bin/bash
set -e

if [ -z "$FUNCTION_ID" ]; then
  echo "FUNCTION_ID is not set. Quitting."
  exit 1
fi

if [ -z "$FUNCTION_NAME" ]; then
  echo "FUNCTION_NAME is not set. Quitting."
  exit 1
fi

if [ -z "$BUCKET" ]; then
  echo "BUCKET is not set. Quitting."
  exit 1
fi

if [ -z "$ACCESS_KEY" ]; then
  echo "ACCESS_KEY is not set. Quitting."
  exit 1
fi

if [ -z "$SECRET_KEY" ]; then
  echo "SECRET_KEY is not set. Quitting."
  exit 1
fi

# Default to syncing entire repo if SOURCE_DIR not set.
if [ -z "$SOURCE_DIR" ]; then
  SOURCE_DIR="."
fi
mkdir -p ~/.aws
mkdir -p ~/.config/yandex-cloud
envsubst < /config.tmpl > ~/.config/yandex-cloud/config.yaml

envsubst < /credentials.tmpl > ~/.aws/credentials

zip -r latest.zip ${SOURCE_DIR} 
aws --endpoint-url=https://storage.yandexcloud.net s3 cp latest.zip s3://${BUCKET}/${FUNCTION_NAME}/${GITHUB_SHA}.zip

yc serverless function version create --token ${TOKEN} \
  --function-name ${FUNCTION_NAME} \
  --cloud-id ${CLOUD_ID}\
  --folder-id ${FOLDER_ID} \
  --runtime ${RUNTIME} \
  --memory ${MEMORY} \
  --execution-timeout ${TIMEOUT} \
  --entrypoint ${ENTRYPOINT} \
  --package-bucket-name ${BUCKET} \
  --package-object-name ${FUNCTION_NAME}/${GITHUB_SHA}.zip 
