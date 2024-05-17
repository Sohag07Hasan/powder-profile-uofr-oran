#To enable forwarding and add the NAT rule, enter

### Enable IPv4/IPv6 Forwarding
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -w net.ipv6.conf.all.forwarding=1

### Add NAT Rule
sudo iptables -t nat -A POSTROUTING -s 10.45.0.0/16 ! -o ogstun -j MASQUERADE
sudo ip6tables -t nat -A POSTROUTING -s 2001:db8:cafe::/48 ! -o ogstun -j MASQUERADE


#Configure the firewall correctly. Some operating systems (Ubuntu) by default enable firewall rules to block traffic.

sudo ufw status
#Status: active
sudo ufw disable
#Firewall stopped and disabled on system startup
sudo ufw status
#Status: inactive


### Ensure that the packets in the `INPUT` chain to the `ogstun` interface are accepted
sudo iptables -I INPUT -i ogstun -j ACCEPT

### Prevent UE's from connecting to the host on which UPF is running
sudo iptables -I INPUT -s 10.45.0.0/16 -j DROP
sudo ip6tables -I INPUT -s 2001:db8:cafe::/48 -j DROP

### If your core network runs over multiple hosts, you probably want to block
### UE originating traffic from accessing other network functions.
### Replace x.x.x.x/y with the VNFs IP/subnet
##sudo iptables -I FORWARD -s 10.45.0.0/16 -d x.x.x.x/y -j DROP