FROM python:3.11-slim

# 安装下载工具和解压工具
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 复制启动脚本并赋予执行权限
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 暴露常用的应用端口
EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
