#!/bin/bash
#
# Load iptables rules before interfaces are brought online
# This ensures that we are always protected by the firewall
##

if [[ -f "/etc/firewall.sh" ]] ; then
    sh /etc/firewall.sh
fi