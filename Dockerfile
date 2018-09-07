FROM golang:1.8.3 as mhbuild

# Add packages.
RUN set -xe; \
	apt-get update >/dev/null; \
	apt-get -y --no-install-recommends install >/dev/null \
        sudo \
        ; \
    apt-get clean;

RUN mkdir -p /usr/local/bin
COPY bin/andock.sh /usr/local/bin/andock

RUN chmod +x /usr/local/bin/andock
RUN andock _install-andock

ENTRYPOINT /bin/bash