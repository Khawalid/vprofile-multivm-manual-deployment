#!/bin/bash
set -e
echo "🐬 Starting MySQL (MariaDB) setup for vProfile project..."

# -----------------------------
# 1. Install dependencies
# -----------------------------
echo "📦 Installing MariaDB..."
dnf install -y epel-release mariadb-server git

# -----------------------------
# 2. Enable and start service
# -----------------------------
echo "🚀 Starting and enabling mariadb-server..."
systemctl enable --now mariadb

# -----------------------------
# 3. Secure installation (non-interactive)
# -----------------------------
echo "🔐 Securing MariaDB installation..."
mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY 'admin123';
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF

# -----------------------------
# 4. Create DB and application user
# -----------------------------
echo "🧱 Creating database and app user..."
mysql -u root -padmin123 <<EOF
CREATE DATABASE IF NOT EXISTS accounts;
CREATE USER IF NOT EXISTS 'admin'@'localhost' IDENTIFIED BY 'admin123';
CREATE USER IF NOT EXISTS 'admin'@'%' IDENTIFIED BY 'admin123';
GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'localhost';
GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'%';
FLUSH PRIVILEGES;
EOF

# -----------------------------
# 5. Initialize DB schema
# -----------------------------
echo "📥 Downloading vProfile source and importing DB schema..."
cd /tmp/
rm -rf vprofile-project || true
git clone -b local https://github.com/hkhcoder/vprofile-project.git
cd vprofile-project

if [ -f src/main/resources/db_backup.sql ]; then
    mysql -u root -padmin123 accounts < src/main/resources/db_backup.sql
    echo "✅ Database initialized from db_backup.sql"
else
    echo "⚠️ db_backup.sql not found, skipping import."
fi

# -----------------------------
# 6. Configure firewall (app01 only)
# -----------------------------
echo "🔥 Configuring firewall to allow MySQL only from Tomcat (192.168.56.12)..."
systemctl enable --now firewalld
firewall-cmd --permanent --new-zone=internal || true
firewall-cmd --permanent --zone=internal --add-source=192.168.56.12/32
firewall-cmd --permanent --zone=internal --add-port=3306/tcp
firewall-cmd --reload

# -----------------------------
# 7. Restart service and verify
# -----------------------------
systemctl restart mariadb
systemctl status mariadb --no-pager

echo "✅ MySQL setup completed successfully!"
