#!/bin/bash

# Verificar que las variables estén definidas
if [ -z "$MYSQL_ROOT_PASSWORD" ] || [ -z "$MYSQL_DATABASE" ] || [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASSWORD" ]; then
    echo "ERROR: Variables de entorno no definidas. Revisa el archivo .env."
    exit 1
fi

# Iniciar MySQL en segundo plano con skip-networking
if ! pgrep mysqld > /dev/null; then
    echo "Iniciando MySQL..."
    mysqld_safe --user=root --skip-networking &
    sleep 5
else
    echo "MySQL ya está corriendo."
fi

# Esperar a que MySQL esté listo
for i in {1..10}; do
    if mysqladmin ping -u root -p"${MYSQL_ROOT_PASSWORD}" --silent; then
        echo "MySQL está listo."
        break
    fi
    echo "Esperando a MySQL... (intento $i/10)"
    sleep 2
done

# Verificar si MySQL está listo después del loop
if ! mysqladmin ping -u root -p"${MYSQL_ROOT_PASSWORD}" --silent; then
    echo "ERROR: MySQL no está listo después de múltiples intentos."
    exit 1
fi

# Configuración de la base de datos y usuarios
echo "Configurando MariaDB..."
mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;" || { echo "ERROR: No se pudo crear la base de datos."; exit 1; }
mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';" || { echo "ERROR: No se pudo crear el usuario."; exit 1; }
mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';" || { echo "ERROR: No se pudieron asignar privilegios."; exit 1; }

# Asegurar la configuración del usuario root
mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';" || { echo "ERROR: No se pudo asegurar el usuario root."; exit 1; }
mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';" || { echo "ERROR: No se pudo crear el usuario root para %."; exit 1; }
mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;" || { echo "ERROR: No se pudieron asignar privilegios a root."; exit 1; }
mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;" || { echo "ERROR: No se pudieron refrescar los privilegios."; exit 1; }

# Cerrar MySQL para reiniciarlo normalmente
echo "Cerrando MariaDB en modo seguro..."
mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown || { echo "ERROR: No se pudo cerrar MySQL."; exit 1; }

# Iniciar MySQL en modo seguro
exec mysqld_safe --user=root --bind-address=0.0.0.0
