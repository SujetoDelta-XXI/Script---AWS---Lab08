#!/bin/bash

yum update -y
amazon-linux-extras enable nginx1
yum install -y nginx iptables-services

# Habilitar y arrancar Nginx
systemctl enable nginx
systemctl start nginx

# Crear página de bienvenida
echo "<h1>Widget Inc. – Sitio activo - Asparrin, Carlos</h1>
<p>Acceso restringido a IPs autorizadas</p>" > /usr/share/nginx/html/index.html

# Configurar firewall interno (iptables)
systemctl enable iptables
systemctl start iptables

iptables -F

# Permitir HTTP solo desde IP del campus
iptables -A INPUT -p tcp -s 45.236.45.96 --dport 80 -j ACCEPT

# IP publica
iptables -A INPUT -p tcp -s 54.226.72.4 --dport 80 -j ACCEPT

# Bloquear el resto de IPs en puerto 80
iptables -A INPUT -p tcp --dport 80 -j DROP

# Permitir SSH (22) para administración
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Permitir tráfico interno necesario
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Guardar y aplicar reglas
service iptables save
systemctl restart iptables
