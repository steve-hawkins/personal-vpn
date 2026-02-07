#!/bin/bash
set -e

# Update and install dependencies
apt-get update
apt-get install -y wireguard qrencode

# Get the server's public IP
SERVER_PUBLIC_IP=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip)

# Generate keys
wg genkey | tee /etc/wireguard/server_private_key | wg pubkey > /etc/wireguard/server_public_key
wg genkey | tee /etc/wireguard/client_private_key | wg pubkey > /etc/wireguard/client_public_key

SERVER_PRIVATE_KEY=$(cat /etc/wireguard/server_private_key)
CLIENT_PUBLIC_KEY=$(cat /etc/wireguard/client_public_key)
CLIENT_PRIVATE_KEY=$(cat /etc/wireguard/client_private_key)

# Create server config
cat > /etc/wireguard/wg0.conf << EOF
[Interface]
Address = 10.0.0.1/24
SaveConfig = true
ListenPort = 51820
PrivateKey = $SERVER_PRIVATE_KEY
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = $CLIENT_PUBLIC_KEY
AllowedIPs = 10.0.0.2/32
EOF

# Enable IP forwarding
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

# Start WireGuard
systemctl start wg-quick@wg0
systemctl enable wg-quick@wg0

# Create client config
cat > /root/client.conf << EOF
[Interface]
PrivateKey = $CLIENT_PRIVATE_KEY
Address = 10.0.0.2/32
DNS = 1.1.1.1

[Peer]
PublicKey = $(cat /etc/wireguard/server_public_key)
Endpoint = $SERVER_PUBLIC_IP:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

# Output client config and QR code to serial console
echo "--- CLIENT CONFIG ---"
cat /root/client.conf
echo "--- END CLIENT CONFIG ---"
echo ""
echo "--- QR CODE ---"
qrencode -t ansiutf8 < /root/client.conf
echo "--- END QR CODE ---"
