# 🚀 vProfile Multi-VM Manual Deployment (DevOps Project)

## 📘 Overview
This project demonstrates a **multi-tier Java web application (vProfile)** deployed manually across multiple **Linux VMs** using **Vagrant**.  
Each service is configured individually to simulate a real-world production architecture before containerization.

---

## 🧩 Architecture

🧱 **Nginx** → Reverse Proxy (Frontend)  
☕ **Tomcat** → Application Server  
🐬 **MySQL** → Database  
💾 **Memcached** → Caching Layer  
🐇 **RabbitMQ** → Message Broker  

**Flow:**  
`User → Nginx → Tomcat → (MySQL, Memcached, RabbitMQ)`
---

## ⚙️ Tech Stack

| Category | Tools / Technologies |
|-----------|----------------------|
| OS | CentOS Stream 9, Ubuntu 22.04 |
| Virtualization | Vagrant + VirtualBox |
| Web / App | Nginx, Tomcat 10.1.26 |
| Database | MariaDB (MySQL) |
| Caching | Memcached |
| Messaging | RabbitMQ |
| Build Tool | Maven 3.9 |
| Automation | Bash, systemd, firewalld |

---

## 🧰 Service Setup Summary

### 🐬 MySQL
- Installed MariaDB and secured installation (`mysql_secure_installation`)  
- Created `accounts` database and user `admin`  
- Allowed access only from Tomcat server IP using `firewalld`
- Dumped sql data file to initialize database records from source code

### 💾 Memcached
- Installed Memcached and enabled remote connections  
- Allowed port **11211** from Tomcat IP only

### 🐇 RabbitMQ
- Installed RabbitMQ via official repo  
- Created admin user `test` with full permissions  
- Allowed port **5672** from Tomcat IP only

### ☕ Tomcat
- Installed OpenJDK 17 and Tomcat 10.1.26  
- Created system user `tomcat` and deployed vProfile WAR built using Maven  
- Configured **systemd** service for auto-restart and boot startup  
- Allowed port **8080** only from Nginx IP

### 🌐 Nginx
- Installed Nginx reverse proxy on Ubuntu  
- Configured to forward HTTP traffic to Tomcat on port 8080  
- Removed default site and enabled new site configuration  
- Allowed public access on port **80**
