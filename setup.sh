runcmd:
- sysctl -w net.ipv6.conf.all.disable_ipv6=1
- export TOKEN=<YOUR_HETZNER_TOKEN>
- export FREE_IP=$(curl -H 'Accept: application/json' -H "Authorization: Bearer ${TOKEN}" 'https://api.hetzner.cloud/v1/floating_ips' | jq -r '[.floating_ips[] | {ip,server} | select (.server == null)][0] | .
ip')
- if [ "ip_$FREE_IP" == "ip_" ]; then ip addr add $FREE_IP dev eth0; fi
