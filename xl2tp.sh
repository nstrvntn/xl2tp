#!/bin/bash

set -e

echo "[*] Installing xl2tpd..."
apt update && apt install -y xl2tpd

echo "[*] Creating /etc/xl2tpd/xl2tpd.conf..."
cat > /etc/xl2tpd/xl2tpd.conf <<EOF
[global]
port = 1701

[lns default]
ip range = 192.168.10.10-192.168.10.100
local ip = 192.168.10.1
require chap = yes
refuse pap = yes
require authentication = yes
name = L2TPServer
ppp debug = yes
pppoptfile = /etc/ppp/options.xl2tpd
length bit = yes
EOF

echo "[*] Creating /etc/ppp/options.xl2tpd..."
cat > /etc/ppp/options.xl2tpd <<EOF
require-mschap-v2
refuse-mschap
refuse-eap
refuse-pap
ms-dns 8.8.8.8
asyncmap 0
auth
hide-password
debug
name l2tpd
proxyarp
lcp-echo-interval 30
lcp-echo-failure 4
EOF

# Detect external network interface
WAN_INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n 1)
echo "[*] Detected external interface: $WAN_INTERFACE"

echo "[*] Configuring iptables rules..."
iptables -A INPUT -p udp --dport 1701 -j ACCEPT
iptables -A INPUT -p gre -j ACCEPT
iptables -A OUTPUT -p gre -j ACCEPT
iptables -t nat -A POSTROUTING -o "$WAN_INTERFACE" -j MASQUERADE
iptables -A FORWARD -i ppp+ -o "$WAN_INTERFACE" -j ACCEPT
iptables -A FORWARD -i "$WAN_INTERFACE" -o ppp+ -m state --state RELATED,ESTABLISHED -j ACCEPT

echo "[*] Enabling IP forwarding..."
if ! grep -q "net.ipv4.ip_forward=1" /etc/sysctl.conf; then
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
fi
sysctl -p

echo "[*] Adding VPN user to chap-secrets..."
read -rp "Enter VPN username: " VPN_USER
read -rsp "Enter VPN password: " VPN_PASS
echo
echo "$VPN_USER * $VPN_PASS *" >> /etc/ppp/chap-secrets

echo "[*] Restarting xl2tpd service..."
systemctl restart xl2tpd

# Get public IP
PUBLIC_IP=$(curl -s ifconfig.me || curl -s ipinfo.io/ip)

echo "========================================"
echo "✅ L2TP VPN without IPsec is ready!"
echo
echo "Server IP:    $PUBLIC_IP"
echo "Username:     $VPN_USER"
echo "Password:     $VPN_PASS"
echo "========================================"
