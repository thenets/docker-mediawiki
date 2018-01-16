FROM mediawiki

RUN mkdir -p /var/www/html/data && \
    mv /var/www/html/images/ /var/www/html/data/images && \
    ln -s /var/www/html/data/LocalSettings.php /var/www/html/LocalSettings.php

VOLUME ['/var/www/html/data']