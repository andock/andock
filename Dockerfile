FROM golang:1.13.3 as mhbuild

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

# Prevent services autoload (http://jpetazzo.github.io/2013/10/06/policy-rc-d-do-not-start-services-automatically/)
RUN set -xe; \
echo '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d

# Add packages.
RUN set -xe; \
	apt-get update >/dev/null; \
	apt-get -y --no-install-recommends install >/dev/null \
        apt-transport-https \
        gnupg \
        locales \
        wget \
        apt-utils \
        sudo \
        ; \
    apt-get clean;


RUN set -xe; \
	# Create a regular user/group "docker" (uid = 1000, gid = 1000 ) with access to sudo
	groupadd docker -g 1000; \
	useradd -m -s /bin/bash -u 1000 -g 1000 -G sudo -p docker docker; \
echo 'docker ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Set en_US.UTF-8 as the default locale
RUN set -xe; \
	localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LC_ALL en_US.utf8

# Additional packages
RUN set -xe; \
	apt-get update >/dev/null; \
	apt-get -y --no-install-recommends install >/dev/null \
		git \
		ghostscript \
		nano \
		pv \
		rsync \
		supervisor \
		unzip \
		zip \
		cron \
	;\
	# Cleanup
	apt-get clean; rm -rf /var/lib/apt/lists/*

ENV GOSU_VERSION=1.10 \
	GOMPLATE_VERSION=2.4.0
RUN set -xe; \
	# Install gosu and give access to the docker user primary group to use it.
	# gosu is used instead of sudo to start the main container process (pid 1) in a docker friendly way.
	# https://github.com/tianon/gosu
	curl -fsSL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture)" -o /usr/local/bin/gosu; \
	chown root:"$(id -gn docker)" /usr/local/bin/gosu; \
	chmod +sx /usr/local/bin/gosu; \
	# gomplate (to process configuration templates in startup.sh)
	curl -fsSL https://github.com/hairyhenderson/gomplate/releases/download/v${GOMPLATE_VERSION}/gomplate_linux-amd64-slim -o /usr/local/bin/gomplate; \
	chmod +x /usr/local/bin/gomplate


COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/startup.sh /opt/startup.sh

# Copy configs and scripts
COPY --chown=docker:docker docker/.ssh /home/docker/.ssh


ENV \
    # ssh-agent proxy socket (requires docksal/ssh-agent)
    SSH_AUTH_SOCK=/.ssh-agent/proxy-socket \
	TERM=xterm \
	PROJECT_ROOT=/var/www \
	# Default values for HOST_UID and HOST_GUI to match the default Ubuntu user. These are used in startup.sh
	HOST_UID=1000 \
	HOST_GID=1000

WORKDIR /var/www

# Install andock
RUN mkdir -p /usr/local/bin
COPY . /var/www/andock
RUN chmod -R 777 /var/www/andock
COPY bin/andock.sh /usr/local/bin/andock

RUN chmod +x /usr/local/bin/andock
WORKDIR /var/www/andock/bin
USER docker
RUN ./andock.sh _install-andock build

# Update andock configurations as docker user.
#RUN andock cup build
USER root
RUN rm -R /var/www/andock

USER docker
WORKDIR /var/www
# Starter script
ENTRYPOINT ["/opt/startup.sh"]

# By default, launch supervisord to keep the container running.
CMD ["supervisord"]