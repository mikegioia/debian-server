#!/bin/sh
#
# Located in /etc/firewall.sh
# Pre-up script located in /etc/network/if-pre-up.d/firewall
##

# Flush any Existing iptable Rules and start afresh
#
iptables -F INPUT
iptables -F OUTPUT
iptables -F FORWARD
iptables -F POSTROUTING -t nat
iptables -F PREROUTING -t nat

# Allow outgoing traffic and disallow any passthroughs
#
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD DROP

# Allow traffic already established to continue
#
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow ssh on port 30000
#
iptables -A INPUT -p tcp --dport 30000 -j ACCEPT

# Allow web ports
#
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Allow local loopback services
#
iptables -A INPUT -i lo -j ACCEPT

# Allow pings
#
iptables -A INPUT -p icmp -j ACCEPT
iptables -I INPUT -p icmp --icmp-type destination-unreachable -j ACCEPT
iptables -I INPUT -p icmp --icmp-type source-quench -j ACCEPT
iptables -I INPUT -p icmp --icmp-type time-exceeded -j ACCEPT

# Anti-spoofing rules
#
iptables -A INPUT -s 200.200.200.200 -i eth0 -j DROP
iptables -A INPUT -s 192.168.0.0/24 -i eth0 -j DROP
iptables -A INPUT -s 127.0.0.0/8 -i eth0 -j DROP
