#!/bin/bash

# Verificar que las variables de entorno estén definidas
if [ -z "$WORDPRESS_DB_HOST" ] || [ -z "$WORDPRESS_DB_USER" ] || [ -z "$WORDPRESS_DB_PASSWORD" ] || [ -z "$WORDPRESS_DB_NAME" ]; then
    echo "ERROR: Variables de entorno no definidas."
    exit 1
fi

# Asegurarse de que el directorio de WordPress tenga permisos correctos
echo "Verificando permisos para /var/www/wordpress..."
chown -R www-data:www-data /var/www/wordpress
chmod -R 755 /var/www/wordpress

# Descargar WordPress si no está presente
if [ ! -f /var/www/wordpress/wp-load.php ]; then
    echo "Descargando WordPress..."
    if ! wp core download --path='/var/www/wordpress' --locale=en_US --allow-root; then
        echo "ERROR: Falló la descarga de WordPress."
        exit 1
    fi
fi

# Esperar a que MariaDB esté listo
attempt=1
max_retries=30
while ! mysqladmin ping -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" --silent; do
    echo "Esperando a que MariaDB esté listo... (Intento $attempt/$max_retries)"
    sleep 2
    attempt=$((attempt + 1))
    if [ $attempt -gt $max_retries ]; then
        echo "ERROR: No se pudo conectar a MariaDB después de $max_retries intentos."
        exit 1
    fi
done

# Asegurarse de que el directorio /run/php/ exista
if [ ! -d /run/php ]; then
    echo "Creando directorio /run/php/"
    mkdir -p /run/php
    chown -R www-data:www-data /run/php
fi

# Crear archivo wp-config.php si no existe
if [ -d "/var/www/wordpress" ] && [ ! -f "/var/www/wordpress/wp-config.php" ]; then
    echo "Creando archivo wp-config.php..."
    if ! wp config create --path='/var/www/wordpress' \
        --dbname=app_db --dbuser=derjavec --dbpass=1234 --dbhost=mariadb --allow-root; then
        echo "ERROR: No se pudo crear wp-config.php."
        exit 1
    fi
fi

# Instalar WordPress si no está instalado
if ! wp core is-installed --allow-root --path='/var/www/wordpress'; then
    echo "Instalando WordPress..."
    wp core install --allow-root \
        --url="http://derjavec.42.fr" \
        --title="Mi sitio WordPress" \
        --admin_user=admin \
        --admin_password=admin_password \
        --admin_email=admin@example.com \
        --path='/var/www/wordpress' || {
        echo "ERROR: No se pudo instalar WordPress.";
        exit 1;
    }
fi

# Iniciar PHP-FPM
exec php-fpm -F



