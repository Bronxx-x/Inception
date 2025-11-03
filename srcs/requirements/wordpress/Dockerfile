FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    php7.4 php7.4-fpm php7.4-mysql \
    curl wget unzip mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

# Create WordPress directory and ensure runtime dirs
RUN mkdir -p /var/www/wordpress \
    && mkdir -p /run/php \
    && chown -R www-data:www-data /var/www/wordpress /run/php

WORKDIR /var/www/wordpress

# Copy a default wp-config if you want (it will be overwritten by volume or setup)
COPY conf/wp-config.php /var/www/wordpress/wp-config.php

# Copy setup script into image
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# Configure PHP-FPM to listen on all interfaces (so nginx container can connect)
RUN sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' /etc/php/7.4/fpm/pool.d/www.conf

EXPOSE 9000

# ENTRYPOINT: run setup script (install WP if needed, fix perms) then start php-fpm
ENTRYPOINT ["/usr/local/bin/setup.sh"]
CMD ["php-fpm7.4", "-F", "-R"]
