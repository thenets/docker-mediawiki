FROM mediawiki

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

VOLUME ['/var/www/html/data']