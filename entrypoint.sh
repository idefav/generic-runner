#!/bin/bash
set -e

# 检查必需的环境变量
if [ -z "$CODE_URL" ]; then
  echo "Error: CODE_URL environment variable is not set."
  exit 1
fi

if [ -z "$START_CMD" ]; then
  echo "Error: START_CMD environment variable is not set."
  exit 1
fi

echo "Starting generic python runner..."

# 处理 GitLab 私有仓库认证 (如果有提供 Token)
CURL_OPTS="-sL"
if [ -n "$GITLAB_TOKEN" ]; then
  echo "Using provided GitLab Token for authentication."
  CURL_OPTS="$CURL_OPTS -H \"PRIVATE-TOKEN: $GITLAB_TOKEN\""
fi

echo "Downloading code archive from $CODE_URL..."
# 下载代码压缩包并解压到当前工作目录 (/app)
# 使用 eval 来正确展开带空格的 CURL_OPTS 变量
eval curl $CURL_OPTS "$CODE_URL" -o code.tar.gz

echo "Extracting code archive..."
tar -xzf code.tar.gz
rm code.tar.gz

# 动态查找 requirements.txt (可能解压后在一个子目录中，通常取顶层)
REQ_FILE=$(find . -maxdepth 2 -name "requirements.txt" | head -n 1)

if [ -n "$REQ_FILE" ]; then
  echo "Found requirements.txt at $REQ_FILE. Installing dependencies..."
  pip install --no-cache-dir -r "$REQ_FILE"
else
  echo "No requirements.txt found. Skipping dependency installation."
fi

echo "Executing start command: $START_CMD"
# 执行启动命令
exec $START_CMD
