#!/bin/bash
iptables -F
iptables -t nat -F
iptables -A FORWARD -i wlan0 -s 192.168.0.0/255.255.0.0 -j ACCEPT
iptables -A FORWARD -i eth0  -d 192.168.0.0/255.255.0.0 -j ACCEPT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
echo 1 > /proc/sys/net/ipv4/ip_forward
