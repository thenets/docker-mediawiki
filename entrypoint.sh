#!/bin/sh

# Set parsoid config
sed -i s/DOMAIN_HERE/$SITE_DOMAIN/g /var/www/html/parsoid/config.yaml

# Start the default entrypoint
docker-php-entrypoint apache2-foreground