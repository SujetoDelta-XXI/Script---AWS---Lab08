#!/bin/bash
set -e

# Actualizar sistema
sudo apt update -y
sudo apt upgrade -y

# Instalar Apache, UFW y Curl
sudo apt install -y apache2 ufw curl git

# Habilitar Apache en el arranque
sudo systemctl enable apache2
sudo systemctl start apache2

# Nombre del dominio (ajusta si tu grupo usa otro nombre)
DOMINIO="g28.asparrin.asesoresti.net"

# Crear estructura de directorios
sudo mkdir -p /var/www/$DOMINIO/public_html
sudo chown -R ubuntu:ubuntu /var/www/$DOMINIO/public_html
sudo chmod -R 755 /var/www/$DOMINIO

# Crear página web personalizada
cat <<EOF | sudo tee /var/www/$DOMINIO/public_html/index.html
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Widget Inc. - $DOMINIO</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0; padding: 0;
            background: linear-gradient(120deg, #e8f0f8, #f9fcff);
            color: #222;
            text-align: center;
        }
        header {
            background-color: #0073bb;
            color: white;
            padding: 25px 10px;
        }
        main { padding: 50px 20px; }
        h1 { color: #0073bb; font-size: 2.2em; margin-bottom: 10px; }
        p { font-size: 18px; margin: 8px 0; }
        footer {
            background-color: #f1f1f1;
            font-size: 14px;
            padding: 10px 0;
            margin-top: 40px;
        }
    </style>
</head>
<body>
    <header>
        <h1>Bienvenido a Widget Inc.</h1>
    </header>
    <main>
        <p>Servidor configurado automáticamente en <strong>Amazon EC2</strong>.</p>
        <p>Este entorno pertenece a <strong>Asparrin, Carlos</strong>.</p>
        <p>Acceso mediante el dominio asignado: <strong>$DOMINIO</strong></p>
    </main>
    <footer>
        &copy; 2025 Widget Inc. | Configuración de Práctica – Seguridad en la Nube
    </footer>
</body>
</html>
EOF

# Configurar VirtualHost
sudo bash -c "cat > /etc/apache2/sites-available/$DOMINIO.conf" <<EOL
<VirtualHost *:80>
    ServerAdmin admin@$DOMINIO
    ServerName $DOMINIO
    DocumentRoot /var/www/$DOMINIO/public_html

    <Directory /var/www/$DOMINIO/public_html>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOL

# Activar sitio y reiniciar Apache
sudo a2ensite $DOMINIO.conf
sudo a2dissite 000-default.conf
sudo apache2ctl configtest
sudo systemctl reload apache2
sudo systemctl restart apache2

# Configurar firewall 
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow ssh
sudo ufw --force enable

# Probar conexión
echo "Probando el sitio localmente..."
curl http://localhost || true

echo "Configuración completada correctamente para: $DOMINIO"
