#!/bin/sh

set -x

APP_DIR=/var/www/html
DATA_DIR=/var/www/data

cd $APP_DIR

# Copy LocalSettings.php file if not exist
SETTINGS_FILE=$DATA_DIR/LocalSettings.php
if [ -f $SETTINGS_FILE ]; then
    echo "File $SETTINGS_FILE exists. Checking for upgrade requirements."
    php maintenance/update.php
else
    echo "Creating a new $SETTINGS_FILE file."
    rm $APP_DIR/LocalSettings.php
    php maintenance/install.php \
        --dbtype=sqlite \
        --dbpath=$DATA_DIR \
        --scriptpath="" \
        --confpath=$APP_DIR \
        --pass=adminadmin \
        --mwdebug --globals MyWiki admin
    ln -s $DATA_DIR/LocalSettings.php $APP_DIR/LocalSettings.php
    php maintenance/update.php --quick
fi


# Start the default entrypoint
cd $APP_DIR/..
docker-php-entrypoint apache2-foreground