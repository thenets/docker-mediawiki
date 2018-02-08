NAME = thenets/mediawiki
TAG = latest
SHELL = /bin/bash

build: pre-build docker-build post-build

pre-build:

post-build:

docker-build:
	docker build -t $(NAME):$(TAG) --rm .

shell:
	docker run -it --rm -e "SITE_DOMAIN=example.com" -v $(PWD)/LocalSettings.php:/home/easyphp/html/LocalSettings.php  --entrypoint=$(SHELL) -p 8080:80 $(NAME):$(TAG)

build-shell: build shell

build-test: build test

test:
	docker run -it --rm -e "SITE_DOMAIN=example.com" -v $(PWD)/LocalSettings.php:/home/easyphp/html/LocalSettings.php -p 8080:80 $(NAME):$(TAG)