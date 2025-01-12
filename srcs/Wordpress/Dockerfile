FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    curl \
    less \
    mariadb-client \
    php-cli \
    php-fpm \
    php-mysql \
    php-curl \
    unzip \
    wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
chmod +x wp-cli.phar && \
mv wp-cli.phar /usr/local/bin/wp

RUN mkdir -p /var/www/wordpress && \
    chown -R www-data:www-data /var/www/wordpress && \
    chmod -R 775 /var/www/wordpress
    
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY auto_config.sh /auto_config.sh
RUN chmod +x /auto_config.sh
WORKDIR /var/www/wordpress
EXPOSE 9000
ENTRYPOINT ["/auto_config.sh"]
