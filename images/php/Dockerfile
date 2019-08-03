FROM rguntik/php7:latest

USER root
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
ADD php.ini /usr/local/etc/php/conf.d/custom.ini

RUN useradd -ms /bin/bash rg
USER rg

WORKDIR /var/www
CMD ["php-fpm"]

EXPOSE 9000
