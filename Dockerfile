FROM docksal/cli:2.0-php7.1

RUN mkdir -p /usr/local/bin
COPY bin/andock.sh /usr/local/bin/andock

RUN chmod +x /usr/local/bin/andock
RUN andock _install-andock
