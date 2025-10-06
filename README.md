#!/bin/bash
# Actualizar paquetes
yum update -y

# Instalar Nginx
amazon-linux-extras enable nginx1
yum install -y nginx

# Habilitar y arrancar servicio
systemctl enable nginx
systemctl start nginx

# Crear directorio del sitio
mkdir -p /usr/share/nginx/html
echo "<h1>Bienvenido a Widget Inc. -- Asparrin, Carlos</h1>" > /usr/share/nginx/html/index.html

# Ajustar permisos
chown -R nginx:nginx /usr/share/nginx/html
chmod -R 755 /usr/share/nginx/html
