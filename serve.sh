#!/bin/bash
# ============================================
# 量房工具 - 本地服务器启动脚本
# ============================================

PORT=8899

clear
echo ""
echo "  ┌──────────────────────────────────┐"
echo "  │                                  │"
echo "  │      📐  量  房  工  具          │"
echo "  │                                  │"
echo "  └──────────────────────────────────┘"
echo ""

# Find local IP
if command -v python3 &>/dev/null; then
  LOCAL_IP=$(python3 -c "
import socket
s=socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.settimeout(0)
try:
  s.connect(('8.8.8.8',1))
  print(s.getsockname()[0])
except:
  print('')
s.close()
" 2>/dev/null)
elif command -v ifconfig &>/dev/null; then
  LOCAL_IP=$(ifconfig 2>/dev/null | grep 'inet ' | grep -v '127.0.0.1' | head -1 | awk '{print $2}')
else
  LOCAL_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
fi

if [ -z "$LOCAL_IP" ]; then
  LOCAL_IP="请手动查找本机 IP"
fi

echo "  🌐  手机浏览器访问："
echo "      http://${LOCAL_IP}:${PORT}"
echo ""

# QR code
if command -v qrencode &>/dev/null; then
  echo "  📱  扫描二维码："
  echo ""
  qrencode -t ANSI -s 2 -m 1 "http://${LOCAL_IP}:${PORT}"
elif python3 -c "import qrcode" 2>/dev/null; then
  echo "  📱  扫描二维码："
  echo ""
  python3 -c "
import qrcode, sys
qr = qrcode.QRCode(box_size=2, border=1)
qr.add_data('http://${LOCAL_IP}:${PORT}')
qr.make(fit=True)
qr.print_ascii(invert=True)
"
else
  echo "  ⚠️  未安装二维码工具"
  echo "     安装: pip3 install qrcode --break-system-packages"
fi

echo ""
echo "  按 Ctrl+C 停止服务器"
echo ""

cd "$(dirname "$0")"
python3 -m http.server $PORT 2>&1 | head -1
