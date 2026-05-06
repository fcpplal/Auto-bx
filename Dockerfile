FROM alpine:latest

# 引入你图中的优秀设计：设置版本变量，以后做教程更新版本只改这里就行
ARG SING_BOX_VERSION=1.10.1
ARG CLOUDFLARED_VERSION=latest

# 【核心修复】：必须加上 busybox-extras 来支持 Web 网页展示！
RUN apk add --no-cache ca-certificates bash wget tar busybox-extras

# 1. 根据版本号下载并安装 sing-box
RUN wget https://github.com/SagerNet/sing-box/releases/download/v${SING_BOX_VERSION}/sing-box-${SING_BOX_VERSION}-linux-amd64.tar.gz && \
    tar -zxvf sing-box-${SING_BOX_VERSION}-linux-amd64.tar.gz && \
    mv sing-box-${SING_BOX_VERSION}-linux-amd64/sing-box /usr/local/bin/sing-box && \
    rm -rf sing-box-*

# 2. 下载并安装 cloudflared
RUN wget -O /usr/local/bin/cloudflared https://github.com/cloudflare/cloudflared/releases/${CLOUDFLARED_VERSION}/download/cloudflared-linux-amd64

# 3. 创建配置目录，并把文件放到 start.sh 认识的地方
RUN mkdir -p /etc/sing-box
COPY config.json /etc/sing-box/config.json
COPY start.sh /start.sh

# 4. 赋予执行权限
RUN chmod +x /usr/local/bin/sing-box && \
    chmod +x /usr/local/bin/cloudflared && \
    chmod +x /start.sh

# 声明端口
EXPOSE 8080

# 启动脚本
CMD ["/bin/bash", "/start.sh"]
