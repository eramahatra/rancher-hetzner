# Assign floating ip on new node
give specific IP on your rancher node
When scaling your rancher nodes on hetzner, it will be given a random ip address from the specified location.
this cloud init configuration will assign an IP from your existing floating-ip if any.
