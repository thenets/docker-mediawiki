[![Docker Pulls](https://img.shields.io/docker/pulls/thenets/mediawiki.svg?style=flat-square)](https://hub.docker.com/r/thenets/mediawiki/) [![Build Status](https://travis-ci.org/thenets/docker-mediawiki.svg?branch=master)](https://travis-ci.org/thenets/docker-mediawiki)

## Docker Compose

```yaml
version: "3"
services:
  thenets-wiki:
    image: thenets/mediawiki:latest
    ports:
      - 5555:80
    volumes: 
      - /opt/volumes/mediawiki_data:/var/www/data:rw
    restart: unless-stopped

  thenets-wiki-parsoid:
    image: thenets/parsoid:beta
    ports:
      - 5556:8000
    restart: unless-stopped
    environment:
      PARSOID_DOMAIN_localhost: http://127.0.0.1:5555/api.php
      PARSOID_NUM_WORKERS: 0
      PARSOID_LOGGING_LEVEL: debug
      PARSOID_DOMAIN_thenetswikiparsoid: http://127.0.0.1:5555/api.php
```