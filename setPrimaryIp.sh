#!/bin/bash

#apt update && apt install jq -y
export TOKEN={{TOKEN}}
# get the server id of the server which has no floating ip
HOSTNAME="$(hostname)"
echo "current server : $HOSTNAME"
export FILTER=".servers[] | select(.labels.nodegroup == \"transcoder\") | select(.name == \"$HOSTNAME\") | {id: .id, ip: .public_net.ipv4.ip}"
export SERVER_DATA=$(curl -s -H "Authorization: Bearer $TOKEN" "https://api.hetzner.cloud/v1/servers" | jq -r "$FILTER")
# if the server is not found, we exist
if [ "$SERVER_DATA!!" == "!!" ]; then
  echo "server $HOSTNAME not found"
  exit 0
fi

export SERVER_ID=$(echo $SERVER_DATA | jq -r ".id")
export SERVER_IP=$(echo $SERVER_DATA | jq -r ".ip")

echo "get the first free available primary IP"
exit 0;

export FILTER="[.primary_ips[] | select (.assignee_id == null)][0] | {ip: .ip, id: .id}"
export ENDPOINT=https://api.hetzner.cloud/v1/primary_ips
export IP_DATA=$(curl -s -H 'Accept: application/json' -H "Authorization: Bearer ${TOKEN}" $ENDPOINT | jq -r "$FILTER")
export FREE_IP=$(echo $IP_DATA | jq -r ".ip")
export IP_ID=$(echo $IP_DATA | jq -r ".id")
echo $IP_DATA

# power off the server to assign the primary ip
echo "power off the server"
curl -X POST -H "Authorization: Bearer ${TOKEN}" "https://api.hetzner.cloud/v1/servers/$SERVER_ID/actions/poweroff"

# find the current primary ip
export FILTER="[.primary_ips[] | select (.assignee_id == $SERVER_ID and .type == \"ipv4\") ][0] | .id"
export ENDPOINT=https://api.hetzner.cloud/v1/primary_ips
export CURRENT_IP_ID=$(curl -s -H 'Accept: application/json' -H "Authorization: Bearer ${TOKEN}" $ENDPOINT | jq -r "$FILTER")

# remove the current primary IP
curl \
	-X POST \
	-H "Authorization: Bearer ${TOKEN}" \
	"https://api.hetzner.cloud/v1/primary_ips/$CURRENT_IP_ID/actions/unassign"

# assign the free primary ip to the server
echo "assign the free primary ip to the server"
export ENDPOINT="https://api.hetzner.cloud/v1/floating_ips/$IP_ID/actions/assign"
export DATA="{\"assignee_type\":\"server\",\"assignee_id\":$SERVER_ID}"
echo $DATA
curl \
	-X POST \
	-H "Authorization: Bearer $TOKEN" \
	-H "Content-Type: application/json" \
	-d $DATA \
	"https://api.hetzner.cloud/v1/primary_ips/$IP_ID/actions/assign"

# power on the server
curl \
	-X POST \
	-H "Authorization: Bearer $TOKEN" \
	"https://api.hetzner.cloud/v1/servers/$SERVER_ID/actions/poweron"
