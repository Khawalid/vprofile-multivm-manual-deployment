#!/bin/bash
set -e
echo "🐇 Installing RabbitMQ..."

dnf -y install wget epel-release centos-release-rabbitmq-38
dnf --enablerepo=centos-rabbitmq-38 -y install rabbitmq-server
systemctl enable --now rabbitmq-server

echo "🔐 Configuring RabbitMQ user..."
echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config
rabbitmqctl add_user test test
rabbitmqctl set_user_tags test administrator
rabbitmqctl set_permissions -p / test ".*" ".*" ".*"
systemctl restart rabbitmq-server

echo "🔥 Configuring firewall (allow from app01 only)..."
systemctl enable --now firewalld
firewall-cmd --permanent --new-zone=internal || true
firewall-cmd --permanent --zone=internal --add-source=192.168.56.12/32
firewall-cmd --permanent --zone=internal --add-port=5672/tcp
firewall-cmd --reload

echo "✅ RabbitMQ setup done."
