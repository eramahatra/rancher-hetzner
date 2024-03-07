### When scaling your rancher nodes on hetzner, it will be given a random ip address from the specified location.
### This cloud init configuration will assign an IP from your existing floating-ip if any
```
#cloud-config
# run commands
# default: none

runcmd:
 - |
  apt update && apt install jq -y
  export TOKEN=<YOUR_HETZNER_API_TOKEN>
  # get the server id of the server which has no floating ip
  export FILTER=".servers[] | select(.labels.nodegroup == \"transcoder\") | select (.public_net.floating_ips | length == 0) .id"
  export SERVER_ID=$(curl -s -H "Authorization: Bearer $TOKEN" "https://api.hetzner.cloud/v1/servers" | jq -r "$FILTER")
  # get the first free available floating ip
  export FILTER="[.floating_ips[] | {ip,server,id} | select (.server == null)][0] | {ip: .ip, id: .id}"
  export ENDPOINT=https://api.hetzner.cloud/v1/floating_ips
  export IP_DATA=$(curl -s -H 'Accept: application/json' -H "Authorization: Bearer ${TOKEN}" $ENDPOINT | jq -r "$FILTER")
  export FREE_IP=$(echo $IP_DATA | jq -r ".ip")
  export IP_ID=$(echo $IP_DATA | jq -r ".id")
  export ENDPOINT="https://api.hetzner.cloud/v1/floating_ips/$IP_ID/actions/assign"
  export DATA="{\"server\":$SERVER_ID}"
  # assign the free floating ip to the server
  curl -s -X POST -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d $DATA $ENDPOINT
  sysctl -w net.ipv6.conf.all.disable_ipv6=1
```
