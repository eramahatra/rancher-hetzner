# Assign floating ip on new node
give specific IP on your rancher node
When scaling your rancher nodes on hetzner, it will be given a random ip address from the specified location.
this cloud init configuration will assign an IP from your existing floating-ip if any.
```
runcmd:
- sysctl -w net.ipv6.conf.all.disable_ipv6=1
- export TOKEN=<YOUR_HETZNER_TOKEN>
- export FREE_IP=$(curl -H 'Accept: application/json' -H "Authorization: Bearer ${TOKEN}" 'https://api.hetzner.cloud/v1/floating_ips' | jq -r '[.floating_ips[] | {ip,server} | select (.server == null)][0] | .
ip')
- if [ "ip_$FREE_IP" == "ip_" ]; then ip addr add $FREE_IP dev eth0; fi
```
