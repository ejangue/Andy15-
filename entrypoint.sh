#!/bin/sh
set -e
: "${PORT:=8080}"
: "${WSS_PATH:=/telegram-secure-proxy-2026}"
if [ -z "$UUID" ] || [ "$UUID" = "00000000-0000-0000-0000-000000000000" ]; then
  UUID=$(cat /proc/sys/kernel/random/uuid)
  echo "⚠️  Aucun UUID fourni, UUID généré : $UUID"
fi
case "$WSS_PATH" in /*) ;; *) WSS_PATH="/$WSS_PATH" ;; esac
export PORT UUID WSS_PATH

# Xray n'écoute qu'en interne (127.0.0.1:10085) ; Caddy est la seule porte d'entrée.
envsubst '${UUID} ${WSS_PATH}' < /etc/xray/config.template.json > /etc/xray/config.json
envsubst '${PORT} ${WSS_PATH}' < /etc/caddy/Caddyfile.template > /etc/caddy/Caddyfile

echo "Caddy sur 0.0.0.0:$PORT -> Xray VLESS+WS (interne) path $WSS_PATH"
/usr/local/bin/xray run -test -config /etc/xray/config.json
/usr/local/bin/xray run -config /etc/xray/config.json &
exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
