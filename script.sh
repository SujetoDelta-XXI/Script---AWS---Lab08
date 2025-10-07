#!/bin/bash
set -e

echo "===== INICIO DE CONFIGURACIÓN EN EC2 (AMAZON LINUX) ====="

# 1. Actualizar sistema
sudo yum update -y

# 2. Instalar Apache y Git (QUITAMOS curl para evitar conflicto con curl-minimal)
sudo yum install -y httpd git

# 3. Habilitar y arrancar Apache
sudo systemctl enable httpd
sudo systemctl start httpd

# 4. Configurar dominio
DOMINIO="g28.asparrin.asesoresti.net"

sudo mkdir -p /var/www/$DOMINIO/public_html
sudo chown -R ec2-user:ec2-user /var/www/$DOMINIO/public_html
sudo chmod -R 755 /var/www/$DOMINIO

# 5. Crear página web personalizada
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

# 6. Configurar VirtualHost
sudo bash -c "cat > /etc/httpd/conf.d/$DOMINIO.conf" <<EOL
<VirtualHost *:80>
    ServerAdmin admin@$DOMINIO
    ServerName $DOMINIO
    DocumentRoot /var/www/$DOMINIO/public_html

    <Directory /var/www/$DOMINIO/public_html>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    ErrorLog /var/log/httpd/$DOMINIO-error.log
    CustomLog /var/log/httpd/$DOMINIO-access.log combined
</VirtualHost>
EOL

# 7. Reiniciar Apache
sudo systemctl restart httpd

# 8. Probar conexión local
echo "Probando el sitio localmente..."
curl http://localhost || true

echo "===== CONFIGURACIÓN COMPLETADA EXITOSAMENTE PARA: $DOMINIO ====="

