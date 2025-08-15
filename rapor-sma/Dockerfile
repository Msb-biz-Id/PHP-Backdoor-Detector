FROM php:8.2-apache

RUN a2enmod rewrite \
	&& docker-php-ext-install pdo pdo_sqlite

WORKDIR /var/www/html

COPY public/ /var/www/html/
COPY . /var/www/html/..

# Set Apache DocumentRoot to /var/www/html
# Ensure AllowOverride for .htaccess
RUN sed -i 's#DocumentRoot /var/www/html#DocumentRoot /var/www/html#' /etc/apache2/sites-available/000-default.conf \
	&& sed -i 's#<Directory /var/www/>#<Directory /var/www/>\n\tAllowOverride All#' /etc/apache2/apache2.conf

EXPOSE 80