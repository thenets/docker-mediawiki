FROM mediawiki:1.31

LABEL   org.thenets="TheNets.org" \
        org.thenets.wiki="TheNets.org Wiki" \
        version="0.1" \
        description="MediaWiki Docker version created by TheNets.org." \
        maintainer="luiz@thenets.org"

# Install updates
RUN apt-get update && apt-get upgrade -y && apt-get autoremove -y && \
    # Mail dependencies
    pear install mail net_smtp && \
    apt-get autoremove -y  && apt-get clean && rm -r /var/lib/apt/lists/*

ENV APP_DIR=/var/www/html \
    DATA_DIR=/var/www/data \
    EXTENSIONS="Duplicator Echo MobileFrontend VisualEditor NetworkAuth TextExtracts Popups"

WORKDIR $DATA_DIR

# Install extensions
RUN cd $APP_DIR/extensions && \
    for EXTENSION in $EXTENSIONS; do \
        cd $APP_DIR/extensions && \
        git clone --depth 1 -b $MEDIAWIKI_BRANCH https://gerrit.wikimedia.org/r/p/mediawiki/extensions/"$EXTENSION".git && \
        cd $APP_DIR/extensions/$EXTENSION && \
        git submodule update --init ; \
    done && \
    chown -R 1000.1000 $APP_DIR/extensions/

# Move all persistent data to $DATA_DIR
# and fallback compatibility with symbolic links
RUN mkdir -p $DATA_DIR && \
    # Image dir
    mv $APP_DIR/images/ $DATA_DIR/images && \
    ln -s $DATA_DIR/images $APP_DIR/images && \
    # LocalSettings.php to volume
    ln -s $DATA_DIR/LocalSettings.php $APP_DIR/LocalSettings.php && \
    # .htaccess to volume
    ln -s ../data/conf_htaccess .htaccess

# Enable Apache Modules
RUN a2enmod rewrite && \
    # .htaccess
    rm .htaccess && \
    ln -s ../data/conf_htaccess .htaccess

# Add Scripts
ADD *.sh /

# Entrypoint
ENTRYPOINT ["/entrypoint.sh"]
CMD [""]

WORKDIR $APP_DIR
VOLUME ["$DATA_DIR"]
EXPOSE 80
