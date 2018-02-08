FROM thenets/php

ENV APP_DIR=/home/easyphp/html

# Install updates & dependencies
RUN apt-get update && apt-get upgrade -y && apt-get autoremove -y && apt-get clean && \
    apt-get install -y php-pear php-mbstring php-apcu php-gd php-intl && \
    pear install mail net_smtp

# Download mediawiki and install composer dependencies
RUN cd $APP_DIR && \
    rm * && \
    git clone --depth 1 https://gerrit.wikimedia.org/r/p/mediawiki/core.git . && \
    mkdir $APP_DIR/data && \
    cd $APP_DIR && \
    composer install && \
    chown -R 1000.1000 $APP_DIR

WORKDIR $APP_DIR/data

# Install extensions
ADD ./extensions/ /tmp/extensions
RUN for file in /tmp/extensions/*; do \
        tar zxvf $file -C $APP_DIR/extensions/; \
    done && \
    chown -R 1000.1000 $APP_DIR/extensions/ && \
    rm -R /tmp/extensions

# Move all persistent data to $APP_DIR/data
# and fallback compatibility with symbolic links
RUN mkdir -p $APP_DIR/data && \
    # Image dir
    mv $APP_DIR/images/ $APP_DIR/data/images && \
    ln -s $APP_DIR/data/images $APP_DIR/images && \
    # Main config file
    ln -s $APP_DIR/data/LocalSettings.php $APP_DIR/LocalSettings.php

# Enable Apache Modules
RUN a2enmod rewrite

# .htaccess to volume
WORKDIR $APP_DIR
RUN ln -s data/conf_htaccess .htaccess

VOLUME ['$APP_DIR/data']