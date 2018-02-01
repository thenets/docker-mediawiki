FROM mediawiki

# Install updates
RUN apt-get update && apt-get upgrade -y && apt-get autoremove -y && apt-get clean

WORKDIR /var/www/html/data

# Install extensions
ADD ./extensions/ /tmp/extensions
RUN for file in /tmp/extensions/*; do \
        tar zxvf $file -C /var/www/html/extensions/; \
    done && \
    chown -R www-data.www-data /var/www/html/extensions/ && \
    rm -R /tmp/extensions

# Move all persistent data to /var/www/html/data
# and fallback compatibility with symbolic links
RUN mkdir -p /var/www/html/data && \
    # Image dir
    mv /var/www/html/images/ /var/www/html/data/images && \
    ln -s /var/www/html/data/images /var/www/html/images && \
    # Main config file
    ln -s /var/www/html/data/LocalSettings.php /var/www/html/LocalSettings.php

# Enable Apache Modules
RUN a2enmod rewrite

# .htaccess to volume
RUN ln -s data/conf_htaccess .htaccess

VOLUME ['/var/www/html/data']