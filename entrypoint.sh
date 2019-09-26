#!/bin/sh

set -x
set -e

APP_DIR=/var/www/html
VOLUME_DIR=/var/www/data

cd ${APP_DIR}

# Mover image dir to the volume
if [ ! -d ${VOLUME_DIR}/images ]; then 
    mv ${APP_DIR}/images/ ${VOLUME_DIR}/images
fi
rm -rf ${APP_DIR}/images
ln -s ${VOLUME_DIR}/images ${APP_DIR}/images

# Copy LocalSettings.php file if not exist
SETTINGS_FILE=${VOLUME_DIR}/LocalSettings.php
if [ -f ${SETTINGS_FILE} ]; then
    echo "File ${SETTINGS_FILE} exists. Skiping installation..."
else
    echo "Creating a new ${SETTINGS_FILE} file."
    php maintenance/install.php \
        --dbtype=sqlite \
        --dbpath=${VOLUME_DIR} \
        --scriptpath="" \
        --confpath=${APP_DIR} \
        --pass=adminadmin \
        --mwdebug --globals Wiki admin
    mv ${APP_DIR}/LocalSettings.php ${VOLUME_DIR}/LocalSettings.php
fi

# LocalSettings.php to volume
rm -f ${APP_DIR}/LocalSettings.php
ln -s ${VOLUME_DIR}/LocalSettings.php ${APP_DIR}/LocalSettings.php

# Always try to update before start
php maintenance/update.php --quick

# Fix permissions
chown -R www-data:www-data ${VOLUME_DIR}

# Start the default entrypoint
cd ${APP_DIR}/..
docker-php-entrypoint apache2-foreground