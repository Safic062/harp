#!/usr/bin/with-contenv bashio

echo "creating /etc/xray/config.json"

# rm /etc/xray/config.json || true

CF_BRIDGES=""
CF_OUTBOUNDS=""
CF_ROUTING=""
SEPARATOR=""

for index in $(bashio::config 'bridges|keys'); do
#while bashio::config "bridges.${index}.domain" > /dev/null; do
#   bashio::config.require.domain "bridges[${bridge}].domain"
#   bashio::config.require.local "bridges[${bridge}].local"
#   bashio::config.require.portal_address "bridges[${bridge}].portal_address"
#   bashio::config.require.portal_port "bridges[${bridge}].portal_port"
#   bashio::config.require.portal_user_id "bridges[${bridge}].portal_user_id"
#   bashio::config.require.in_tag "bridges[${bridge}].in_tag"
#   bashio::config.require.out_tag "bridges[${bridge}].out_tag"
    # - domain: my.example.com
    #   portalAddr: "portal-ip.example.com:port"
    #   portalPort: 1234
    #   bridge: "homeassistant:8123"
    #   uid: "5783a3e7-e373-51cd-8642-c83782b807c5"
    #   tag: tag

  DOMAIN=$(bashio::config "bridges[${index}].domain")
  PORTAL_ADDR=$(bashio::config "bridges[${index}].portalAddr")
  PORTAL_PORT=$(bashio::config "bridges[${index}].portalPort")
  BRIDGE=$(bashio::config "bridges[${index}].bridge")
  PORTAL_UID=$(bashio::config "bridges[${index}].uid")
  TAG=$(bashio::config "bridges[${index}].tag")

  IN_TAG="$TAG-bridge"
  OUT_TAG="$TAG-out"
  CONN_TAG="$TAG-conn"

  CF_BRIDGES=$CF_BRIDGES$(cat <<EOF
$SEPARATOR
      {
        "tag": "$IN_TAG",
        "domain": "$DOMAIN"
      }
EOF
)

  CF_OUTBOUNDS=$CF_OUTBOUNDS$(cat <<EOF
$SEPARATOR
    {
      "tag": "$OUT_TAG",
      "protocol": "freedom",
      "settings": {
        "redirect": "$BRIDGE"
      }
    },
    {
      "protocol": "vmess",
      "settings": {
        "vnext": [
          {
            "address": "$PORTAL_ADDR",
            "port": $PORTAL_PORT,
            "users": [
              {
                "id": "$PORTAL_UID"
              }
            ]
          }
        ]
      },
      "tag": "$CONN_TAG"
    }
EOF
)

  CF_ROUTING=$CF_ROUTING$(cat <<EOF
$SEPARATOR
      {
        "type": "field",
        "inboundTag": ["$IN_TAG"],
        "domain": ["full:$DOMAIN"],
        "outboundTag": "$CONN_TAG"
      },
      {
        "type": "field",
        "inboundTag": ["$IN_TAG"],
        "outboundTag": "$OUT_TAG"
      }
EOF
)

  SEPARATOR=","
done

cat <<EOF >> /etc/xray/config.json
{
  "reverse": {
    "bridges": [
$CF_BRIDGES
    ]
  },
  "outbounds": [
$CF_OUTBOUNDS
  ],
  "routing": {
    "rules": [
$CF_ROUTING
    ]
  }
}
EOF

echo "configuration created: /etc/xray/config.json"

cat /etc/xray/config.json

echo "-------"