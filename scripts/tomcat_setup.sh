#!/bin/bash
set -e
echo "☕ Installing Tomcat 10.1.26..."

dnf install -y java-17-openjdk java-17-openjdk-devel wget git
useradd --home-dir /usr/local/tomcat --shell /sbin/nologin tomcat

cd /tmp
wget https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.26/bin/apache-tomcat-10.1.26.tar.gz
tar -xzf apache-tomcat-10.1.26.tar.gz
cp -r apache-tomcat-10.1.26/* /usr/local/tomcat/
chown -R tomcat:tomcat /usr/local/tomcat

cat <<EOF > /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
User=tomcat
Group=tomcat
WorkingDirectory=/usr/local/tomcat
Environment=JAVA_HOME=/usr/lib/jvm/jre
Environment=CATALINA_PID=/var/tomcat/%i/run/tomcat.pid
Environment=CATALINA_HOME=/usr/local/tomcat
Environment=CATALINA_BASE=/usr/local/tomcat
ExecStart=/usr/local/tomcat/bin/catalina.sh run
ExecStop=/usr/local/tomcat/bin/shutdown.sh
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now tomcat

echo "🔥 Configuring firewall (allow from Nginx only)..."
systemctl enable --now firewalld
firewall-cmd --permanent --new-zone=internal || true
firewall-cmd --permanent --zone=internal --add-source=192.168.56.11/32
firewall-cmd --permanent --zone=internal --add-port=8080/tcp
firewall-cmd --reload

echo "✅ Tomcat ready."
