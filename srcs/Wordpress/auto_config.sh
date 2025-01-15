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
# attempt=1
# max_retries=30
# while ! mysqladmin ping -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" --silent; do
#     echo "Esperando a que MariaDB esté listo... (Intento $attempt/$max_retries)"
#     sleep 2
#     attempt=$((attempt + 1))
#     if [ $attempt -gt $max_retries ]; then
#         echo "ERROR: No se pudo conectar a MariaDB después de $max_retries intentos."
#         exit 1
#     fi
# done

# Verificar conexión a la base de datos
echo "Verificando conexión a la base de datos..."
echo "SHOW DATABASES;" | mysql -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD"
if [ $? -ne 0 ]; then
    echo "ERROR: No se puede conectar a la base de datos."
    exit 1
fi

# Crear archivo wp-config.php si no existe
if [ -d "/var/www/wordpress" ] && [ ! -f "/var/www/wordpress/wp-config.php" ]; then
    echo "Creando archivo wp-config.php..."
    if ! wp config create --path='/var/www/wordpress' \
        --dbname="$WORDPRESS_DB_NAME" --dbuser="$WORDPRESS_DB_USER" --dbpass="$WORDPRESS_DB_PASSWORD" --dbhost="$WORDPRESS_DB_HOST" --allow-root; then
        echo "ERROR: No se pudo crear wp-config.php."
        exit 1
    fi
fi

# Sobrescribir wp-config.php con tu archivo personalizado
if [ -f "/conf/wp-config.php" ]; then
    echo "Sobrescribiendo wp-config.php con archivo personalizado..."
    cp /conf/wp-config.php /var/www/wordpress/wp-config.php
    chown www-data:www-data /var/www/wordpress/wp-config.php
    chmod 644 /var/www/wordpress/wp-config.php
else
    echo "ERROR: No se encontró el archivo personalizado /conf/wp-config.php"
    exit 1
fi

# Verificar contenido de wp-config.php
if [ -f "/var/www/wordpress/wp-config.php" ]; then
    echo "El archivo wp-config.php final está configurado. Contenido:"
    cat /var/www/wordpress/wp-config.php
else
    echo "ERROR: No se generó wp-config.php correctamente."
    exit 1
fi

# Iniciar PHP-FPM específicamente para 7.4
echo "Iniciando PHP-FPM (versión 7.4)..."
exec php-fpm7.4 -F






