#!/bin/sh

#set -x

APP_DIR=/var/www/html
DATA_DIR=/var/www/data

RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}Update to the MediaWiki master branch...${NC}"
cd ${APP_DIR}/..
rm -rf ${APP_DIR}
git clone --depth 1 https://github.com/wikimedia/mediawiki.git html

echo -e "${CYAN}Installing Ubuntu dependencies...${NC}"
apt-get update >/dev/null 2>/dev/null
apt-get install -y zip unzip >/dev/null 2>/dev/null

echo -e "${CYAN}# Installing MediaWiki...${NC}"
rm $APP_DIR/LocalSettings.php 2>/dev/null
php maintenance/install.php \
    --dbtype=sqlite \
    --dbpath=$DATA_DIR \
    --scriptpath="" \
    --confpath=$APP_DIR \
    --pass=adminadmin \
    --mwdebug --globals MyWiki admin
ln -s $DATA_DIR/LocalSettings.php $APP_DIR/LocalSettings.php 2>/dev/null
php maintenance/update.php --quick 2>/dev/null

echo -e "${CYAN}# Installing Composer...${NC}"
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer 2>/dev/null

echo -e "${CYAN}# Installing MediaWiki dev dependencies...${NC}"
composer install 2>/dev/null

echo -e "${CYAN}# Run unit-tests${NC}"
cd tests/phpunit
php phpunit.php
