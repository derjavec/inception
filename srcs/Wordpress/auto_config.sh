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
    wp core download --allow-root --path=/var/www/wordpress || {
        echo "ERROR: No se pudo descargar WordPress.";
        exit 1;
    }
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

# Crear archivo wp-config.php si no existe
if [ ! -f /var/www/wordpress/wp-config.php ]; then
    echo "Creando archivo wp-config.php..."
    wp config create --allow-root \
        --dbname="$WORDPRESS_DB_NAME" \
        --dbuser="$WORDPRESS_DB_USER" \
        --dbpass="$WORDPRESS_DB_PASSWORD" \
        --dbhost="$WORDPRESS_DB_HOST" \
        --path='/var/www/wordpress' || {
        echo "ERROR: No se pudo crear wp-config.php. Revisa permisos y rutas.";
        exit 1;
    }
fi

# Instalar WordPress si no está instalado
if ! wp core is-installed --allow-root --path='/var/www/wordpress'; then
    echo "Instalando WordPress..."
    wp core install --allow-root \
        --url="http://localhost" \
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



