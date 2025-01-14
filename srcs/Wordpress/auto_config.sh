#!/bin/bash

# Instalar la herramienta ss si no está instalada
if ! command -v ss &> /dev/null; then
    echo "Instalando la herramienta ss..."
    apt-get update && apt-get install -y iproute2 || {
        echo "ERROR: Falló la instalación de ss.";
        exit 1;
    }
fi

# Verificar que las variables de entorno estén definidas
REQUIRED_VARS=("WORDPRESS_DB_HOST" "WORDPRESS_DB_USER" "WORDPRESS_DB_PASSWORD" "WORDPRESS_DB_NAME" "WORDPRESS_ADMIN_USER" "WORDPRESS_ADMIN_PASSWORD" "WORDPRESS_ADMIN_EMAIL")
for VAR in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!VAR}" ]; then
        echo "ERROR: La variable de entorno $VAR no está definida."
        exit 1
    fi
done

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
if [ ! -f "/var/www/wordpress/wp-config.php" ]; then
    echo "Creando archivo wp-config.php..."
    if ! wp config create --path='/var/www/wordpress' \
        --dbname="$WORDPRESS_DB_NAME" --dbuser="$WORDPRESS_DB_USER" --dbpass="$WORDPRESS_DB_PASSWORD" --dbhost="$WORDPRESS_DB_HOST" --allow-root; then
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
        --admin_user="$WORDPRESS_ADMIN_USER" \
        --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
        --admin_email="$WORDPRESS_ADMIN_EMAIL" \
        --path='/var/www/wordpress' || {
        echo "ERROR: No se pudo instalar WordPress.";
        exit 1;
    }
    echo "Creando un segundo usuario..."
    wp user create editor editor@example.com --role=editor --user_pass=editor_password --allow-root --path='/var/www/wordpress'

    echo "Habilitando comentarios..."
    wp option update default_comment_status open --allow-root --path='/var/www/wordpress'
fi

# Validar si el binario de php-fpm está disponible
if ! command -v php-fpm &> /dev/null; then
    echo "ERROR: php-fpm no está instalado."
    exit 1
fi

# Verificar y reiniciar php-fpm si es necesario
if ! ss -tuln | grep -q ":9000"; then
    echo "Iniciando PHP-FPM..."
    php-fpm8.1 -t || {
        echo "ERROR: La configuración de PHP-FPM tiene errores.";
        exit 1;
    }
fi

# Iniciar PHP-FPM
exec php-fpm8.1 -F





