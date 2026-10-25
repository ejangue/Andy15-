FROM alpine:3.20
ARG XRAY_VERSION=latest
RUN apk add --no-cache ca-certificates curl unzip tzdata gettext caddy \
 && ARCH=$(uname -m) && case "$ARCH" in \
      x86_64) A=64 ;; aarch64) A=arm64-v8a ;; armv7l) A=arm32-v7a ;; *) echo "arch $ARCH non supportée"; exit 1 ;; esac \
 && if [ "$XRAY_VERSION" = "latest" ]; then URL="https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-$A.zip"; \
    else URL="https://github.com/XTLS/Xray-core/releases/download/$XRAY_VERSION/Xray-linux-$A.zip"; fi \
 && curl -fsSL "$URL" -o /tmp/xray.zip \
 && mkdir -p /usr/local/share/xray /etc/xray /etc/caddy \
 && unzip -o /tmp/xray.zip -d /tmp/xray \
 && install -m 755 /tmp/xray/xray /usr/local/bin/xray \
 && mv /tmp/xray/geoip.dat /tmp/xray/geosite.dat /usr/local/share/xray/ \
 && rm -rf /tmp/xray /tmp/xray.zip && apk del curl unzip
COPY config.template.json /etc/xray/config.template.json
COPY Caddyfile.template /etc/caddy/Caddyfile.template
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENV PORT=8080 \
    UUID=00000000-0000-0000-0000-000000000000 \
    WSS_PATH=/telegram-secure-proxy-2026 \
    XRAY_LOCATION_ASSET=/usr/local/share/xray
EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
