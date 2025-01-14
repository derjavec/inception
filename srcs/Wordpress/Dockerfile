FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    curl \
    less \
    mariadb-client \
    php8.1 php8.1-fpm php8.1-mysql php8.1-cli php8.1-curl php8.1-xml php8.1-mbstring \
    unzip \
    wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

RUN mkdir -p /var/www/wordpress && \
    chown -R www-data:www-data /var/www/wordpress && \
    chmod -R 775 /var/www/wordpress

# Crear el directorio /run/php/
RUN mkdir -p /run/php/ && \
    chown -R www-data:www-data /run/php/

COPY ./php-fpm.conf /etc/php/8.1/fpm/php-fpm.conf
COPY ./www.conf /etc/php/8.1/fpm/pool.d/www.conf
COPY auto_config.sh /auto_config.sh
RUN chmod +x /auto_config.sh
WORKDIR /var/www/wordpress
EXPOSE 9000
ENTRYPOINT ["/auto_config.sh"]

