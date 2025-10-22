#!/bin/bash
set -e
echo "💾 Installing Memcached..."

dnf install -y memcached
sed -i 's/127.0.0.1/0.0.0.0/' /etc/sysconfig/memcached
systemctl enable --now memcached

echo "🔥 Configuring firewall (allow from app01 only)..."
systemctl enable --now firewalld
firewall-cmd --permanent --new-zone=internal || true
firewall-cmd --permanent --zone=internal --add-source=192.168.56.12/32
firewall-cmd --permanent --zone=internal --add-port=11211/tcp
firewall-cmd --reload

echo "✅ Memcached ready."
