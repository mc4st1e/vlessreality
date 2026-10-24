FROM alpine:latest

RUN apk add --no-cache ca-certificates curl unzip

# Устанавливаем официальное ядро Xray последней версии
RUN curl -L -H "Cache-Control: no-cache" -o /tmp/xray.zip https://github.com && \
    mkdir -p /usr/local/bin /usr/local/share/xray && \
    unzip /tmp/xray.zip -d /usr/local/bin && \
    chmod +x /usr/local/bin/xray && \
    rm -rf /tmp/xray.zip

# Render требует, чтобы приложение работало на порту 10000
EXPOSE 10000

# Создаем конфигурационный файл и запускаем VLESS через WebSockets
CMD echo '{\
  "inbounds": [{\
    "port": 10000,\
    "protocol": "vless",\
    "settings": {\
      "clients": [{"id": "88888888-4444-4444-8888-123456789abc"}],\
      "decryption": "none"\
    },\
    "streamSettings": {\
      "network": "ws",\
      "wsSettings": {"path": "/vless-ws"}\
    }\
  }],\
  "outbounds": [{"protocol": "freedom"}]\
}' > /usr/local/share/xray/config.json && /usr/local/bin/xray run -c /usr/local/share/xray/config.json
