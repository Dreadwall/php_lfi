FROM wocker/base


#
# PHP must be installed after Apache
#
RUN apt-get update \
  && apt-get clean \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    apache2 \
    libapache2-mod-php \
    php7.0 \
    php7.0-bz \
    php7.0-cli \
    php7.0-curl \
    php7.0-gd \
    php7.0-mbstring \
    php7.0-mysql \
    php7.0-xdebug \
    php7.0-xml \
  && rm -rf /var/lib/apt/lists/*


#
# Apache settings
#
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf \
  && sed -i -e '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf \
  && sed -i -e "s#DocumentRoot.*#DocumentRoot /var/www#" /etc/apache2/sites-available/000-default.conf \
  && sed -i -e "s/export APACHE_RUN_USER=.*/export APACHE_RUN_USER=wocker/" /etc/apache2/envvars \
  && sed -i -e "s/export APACHE_RUN_GROUP=.*/export APACHE_RUN_GROUP=wocker/" /etc/apache2/envvars \
  && a2enmod rewrite

#
# php.ini settings
#
RUN sed -i -e "s/^upload_max_filesize.*/upload_max_filesize = 32M/" /etc/php/7.0/apache2/php.ini \
  && sed -i -e "s/^post_max_size.*/post_max_size = 64M/" /etc/php/7.0/apache2/php.ini \
  && sed -i -e "s/^display_errors.*/display_errors = On/" /etc/php/7.0/apache2/php.ini \
  && sed -i -e "s/^;mbstring.internal_encoding.*/mbstring.internal_encoding = UTF-8/" /etc/php/7.0/apache2/php.ini \
  && sed -i -e "s#^;sendmail_path.*#sendmail_path = /usr/local/bin/mailhog sendmail#" /etc/php/7.0/apache2/php.ini

#
# Open ports
#
EXPOSE 8080

#
# Supervisor
#
ADD about.html /var/www/about.html
ADD dead.jpg /var/www/dead.jpg
ADD fine.png /var/www/fine.png
ADD index.php /var/www/index.php
ADD style.css /var/www/style.css
ADD contact.html /var/www/contact.html
ADD index.html /var/www/index.html
ADD skele.png /var/www/skele.png
CMD ["chmod +x /tmp/init.sh"]
CMD ["rm -r /var/www/wordpress"]
CMD ["rm /var/www/wp-cli.yml"]

CMD ["rm /etc/apache2/ports.conf"]
ADD ports.conf /etc/apache2/ports.conf
CMD ["rm /etc/apache2/sites-enabled/000-default.conf"]
ADD 000-default.conf /etc/apache2/sites-enabled/000-default.conf
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["rm /etc/logrotate.d/apache2"]
ADD apache2 /etc/logrotate.d/apache2
RUN chmod 777 /var/log/apache2
RUN chmod 777 /var/log/apache2/access.log
RUN ls -al /var/log/apache2

CMD apachectl
RUN ls -al /var/log/apache2
CMD apachectl -D FOREGROUND
