#!/bin/sh

set -x

APP_DIR=/var/www/html
DATA_DIR=/var/www/data

RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}Install Ubuntu dependencies${NC}"
apt-get update
apt-get install -y zip unzip

echo -e "${CYAN}# Install MediaWiki${NC}"
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

echo -e "${CYAN}# Installing Composer${NC}"
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

echo -e "${CYAN}# Install MediaWiki dev dependencies${NC}"
composer install

echo -e "${CYAN}# Run unit-tests${NC}"
cd tests/phpunit
php phpunit.php

