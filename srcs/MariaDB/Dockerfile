FROM debian:bullseye

# Actualización de paquetes e instalación de MariaDB Server y herramientas adicionales
RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    dumb-init && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copiar el archivo de configuración personalizado
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/

# Copiar el script de inicialización
COPY init.sh /init.sh

# Asegurar permisos de ejecución para el script
RUN chmod +x /init.sh

# Crear los directorios necesarios y asignar permisos adecuados
RUN mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql /var/run/mysqld

# Exponer el puerto por defecto de MariaDB
EXPOSE 3306

# Definir el volumen para la persistencia de datos
VOLUME ["/var/lib/mysql"]

# Usar dumb-init para manejar correctamente las señales del contenedor
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Ejecutar el script de inicialización
CMD ["/init.sh"]


