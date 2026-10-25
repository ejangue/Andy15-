# Xray VLESS + WS + TLS sur Railway (v2)

## Changements v2
- **Caddy devant Xray** : Xray n'écoute plus que sur `127.0.0.1:10085` (invisible de l'extérieur). Caddy reçoit le trafic sur `$PORT`, ne transmet à Xray que le chemin WebSocket secret, et répond `200 It works!` à toute autre requête — fini le `400 Bad Request` + en-tête `Sec-WebSocket-Version` qui trahissaient un proxy face aux sondes DPI.
- Chemin par défaut aligné sur `/telegram-secure-proxy-2026`.

## Déploiement Railway
1. Poussez ce dossier sur GitHub, créez un service Railway depuis le repo (build Dockerfile détecté).
2. Variables : `UUID` (obligatoire), `WSS_PATH` (optionnel).
3. Générez le domaine public Railway (`*.up.railway.app`).

## Configuration client (sans fronting)
```
vless://UUID@VOTRE-SERVICE.up.railway.app:443?encryption=none&security=tls&sni=VOTRE-SERVICE.up.railway.app&type=ws&host=VOTRE-SERVICE.up.railway.app&path=%2Ftelegram-secure-proxy-2026#Xray-WS
```
Le SNI **doit** être le domaine Railway : l'edge Railway ne présente de certificat que pour ses propres domaines. Un SNI étranger fait échouer le handshake TLS avant d'atteindre Xray.

## Camouflage SNI (domain fronting)
Le fronting est impossible directement sur Railway (pas un CDN mutualisé). Architecture fonctionnelle :
1. Ajoutez un domaine personnalisé au service Railway (ex. `vpn.votredomaine.com`).
2. Passez ce domaine derrière **Cloudflare** (DNS proxifié, nuage orange) — ou mieux, un **Cloudflare Worker** qui relaie le WebSocket vers Railway.
3. Côté client : `sni` = un domaine zero-rated hébergé sur Cloudflare, `host` = `vpn.votredomaine.com`, adresse = le domaine zero-rated.

Le handshake TLS se fait alors contre Cloudflare (qui possède le certificat du domaine zero-rated), et Cloudflare route vers votre backend via l'en-tête Host.
