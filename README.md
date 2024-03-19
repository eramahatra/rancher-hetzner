### When scaling your rancher nodes on hetzner, it will be given a random ip address from the specified location.
### This cloud init configuration will assign an IP from your existing floating-ip if any
```
#cloud-config
# run commands
# default: none

bootcmd:
 - |
  wget -O - https://raw.githubusercontent.com/eramahatra/rancher-hetzner/main/bootcmd.sh | bash 

# create network file
config:
  user.network-config: |
    version: 1
    config:
      - type: physical
        name: eth0
        subnets:
          - type: static
            ipv4: true
            address: $FREE_IP
            netmask: 255.255.255.0
            gateway: 172.31.1.1
            control: auto
