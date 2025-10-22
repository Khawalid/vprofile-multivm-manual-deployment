#!/bin/bash
set -e
echo "🌐 Installing Nginx..."

apt update -y
apt install -y nginx firewalld

cat <<EOF > /etc/nginx/sites-available/vproapp
upstream vproapp {
    server app01:8080;
}
server {
    listen 80;
    location / {
        proxy_pass http://vproapp;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/vproapp /etc/nginx/sites-enabled/vproapp
systemctl enable --now nginx

echo "🔥 Configuring firewall (allow public port 80)..."
systemctl enable --now firewalld
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --reload

echo "✅ Nginx deployed."
