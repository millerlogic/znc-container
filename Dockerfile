# Example:
#   docker run -d -v $(readlink -f znc-state):/znc-state millerlogic/znc-docker
# Then connect to the configured port on the IP address of the container.
#   docker inspect --format '{{ .NetworkSettings.IPAddress }}' <container_name>

FROM debian:7

RUN apt-get update

# For: downloading.
RUN apt-get install wget -y

# Compiler and tools.
RUN apt-get install gcc make -y

# Dependencies
RUN apt-get install build-essential libssl-dev libperl-dev pkg-config -y
RUN apt-get install python3-dev tcl-dev -y

# Get source.
ENV ZNC_VER=latest
RUN rm -rf /tmp/setup-znc-tmp && mkdir /tmp/setup-znc-tmp
RUN wget -nv -O/tmp/setup-znc-tmp/znc-$ZNC_VER.tar.gz http://znc.in/releases/znc-$ZNC_VER.tar.gz
RUN cd /tmp/setup-znc-tmp && tar xzf znc-$ZNC_VER.tar.gz

# Build.
RUN cd /tmp/setup-znc-tmp/znc-*/ && ./configure --enable-perl --enable-python --enable-tcl \
    --enable-openssl --enable-ipv6 | grep -v 'yes$'
RUN cd /tmp/setup-znc-tmp/znc-*/ && make && make install

# Clean.
RUN rm -rf /tmp/setup-znc-tmp

RUN groupadd -g 28101 container || echo
RUN useradd -u 28101 -N -g 28101 container || echo

RUN mkdir -p /znc-state/configs
RUN chown -R container:container /znc-state

VOLUME ["/znc-state"]

USER container
CMD znc --datadir /znc-state --foreground $ZNC_ARGS || X=$?; echo The command failed, if you need to make config use: -it -e ZNC_ARGS=--makeconf; exit $X

# Put znc.conf in /znc-state/configs
# Either use the container volume /znc-state or -v volume from the host.
