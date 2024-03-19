### When scaling your rancher nodes on hetzner, it will be given a random ip address from the specified location.
### This cloud init configuration will assign an IP from your existing floating-ip if any
```
#cloud-config
# run commands
# default: none

bootcmd:
 - |
  wget -O - https://raw.githubusercontent.com/eramahatra/rancher-hetzner/main/setPrimaryIp.sh | bash 

```
