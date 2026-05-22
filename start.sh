#!/bin/sh

# 替换配置文件中的 UUID
sed -i "s/PASTE_YOUR_UUID_HERE/$UUID/g" config.json

# 1. 改为前台运行 sing-box（或者保持后台，让 cloudflared 前台运行）
# 为了让 Koyeb 能顺利通过 8080 端口与 sing-box 通信，我们让 sing-box 作为主进程运行
sing-box run -c config.json &

echo "=================================================================="
echo "🚀 专属容器部署成功！您的 VLESS 万能快捷导入节点如下："
echo "------------------------------------------------------------------"
if [ -n "$UUID" ] && [ -n "$DOMAIN" ]; then
    echo "vless://${UUID}@${DOMAIN}:443?encryption=none&security=tls&sni=${DOMAIN}&type=ws&host=${DOMAIN}&path=%2Fvless#🇸🇬🌍🇸🇬新加坡备用_Railway"
    echo "非TLS，用80端口，节点如下fg："
    echo "vless://${UUID}@www.shopify.com:80?encryption=none&security=none&sni=${DOMAIN}&type=ws&host=${DOMAIN}&path=%2Fvless#🇸🇬🌍🇸🇬新加坡备用_Railway"
else
    echo "[提示] 如果需要自动输出成品链接，请在环境变量里补全 DOMAIN 参数"
fi
echo "=================================================================="

# 2. 如果配置了隧道 token，则启动隧道
if [ -n "$ARGO_TOKEN" ]; then
    echo "正在启动 Cloudflare Tunnel..."
    # 注意：这里去掉了后台符号 &，让它作为阻塞主进程运行
    cloudflared tunnel --no-autoupdate run --token $ARGO_TOKEN
else
    echo "[警告] 未检测到 ARGO_TOKEN，Cloudflare Tunnel 未启动"
    # 如果没有 tunnel，保持容器不退出
    wait
fi
