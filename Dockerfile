# Docker-Moodle
# Dockerfile for moodle instance. more dockerish version of https://github.com/sergiogomez/docker-moodle
# Forked from Jade Auer's docker version. https://github.com/jda/docker-moodle
# Forked from Jonathan Hardison's docker version https://github.com/jmhardison/docker-moodle
FROM ubuntu:20.04
LABEL maintainer="Jorge Rodríguez <jorge@rodriguezmoreno.com>"

VOLUME ["/var/moodledata"]
EXPOSE 80 443

# Let the container know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

# Database info and other connection information derrived from env variables. See readme.
# Set ENV Variables externally Moodle_URL should be overridden.
ENV MOODLE_URL http://127.0.0.1

# Enable when using external SSL reverse proxy
# Default: false
ENV SSL_PROXY false

ARG MOODLE_LOCALE="en es"
ARG MOODLE_TAG=MOODLE_310_STABLE
ARG RUNTIME_DEPS="curl \
    unzip \
    apache2 \
    php \
    php-gd \
    php-mysql \
    php-curl \
    php-xmlrpc \
    php-intl \
    php-xml \
    php-mbstring \
    php-zip \
    php-soap \
    php-ldap \
    cron \
    locales \
    libapache2-mod-php"

ARG BUILD_DEPS="git"

RUN apt-get update && \
	apt-get -y install $RUNTIME_DEPS $BUILD_DEPS && \
	cd /tmp && \
	git clone -b $MOODLE_TAG git://git.moodle.org/moodle.git --depth=1 && \
	mv /tmp/moodle/* /var/www/html/ && \
    rm -rf /tmp/moodle && \
    rm /var/www/html/index.html && \
    chown -R www-data:www-data /var/www/html && \
	apt-get autoremove -y $BUILD_DEPS && \
    apt-get clean autoclean && \
	rm -rf /var/lib/apt/lists/*

RUN locale-gen $MOODLE_LOCALE && \
    a2enmod ssl && \
    a2ensite default-ssl && \
    mkdir -p /var/www/moodle && \
    mkdir -p /var/local/cache && \
    chown www-data:www-data /var/www/moodle /var/local/cache

COPY foreground.sh /etc/apache2/foreground.sh
COPY moodlecron /etc/cron.d/moodlecron
COPY moodle-config.php /var/www/html/config.php

ENTRYPOINT ["/etc/apache2/foreground.sh"]
