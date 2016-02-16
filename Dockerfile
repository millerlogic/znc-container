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
RUN wget -O/tmp/znc-1.6.2.tar.gz http://znc.in/releases/znc-1.6.2.tar.gz
RUN cd /tmp && tar xzf znc-1.6.2.tar.gz

# Build.
RUN cd /tmp/znc-1.6.2/ && ./configure --enable-perl --enable-python --enable-tcl \
    --enable-openssl --enable-ipv6 | grep -v 'yes$'
RUN cd /tmp/znc-1.6.2/ && make && make install

RUN groupadd -g 28101 container || echo
RUN useradd -u 28101 -N -g 28101 container || echo

RUN mkdir -p /znc-state/configs
RUN chown -R container:container /znc-state

VOLUME ["/znc-state"]

USER container
CMD znc --datadir /znc-state --foreground $ZNC_ARGS || X=$?; echo The command failed, if you need to make config use: -it -e ZNC_ARGS=--makeconf; exit $X

# Put znc.conf in /znc-state/configs
# Either use the container volume /znc-state or -v volume from the host.
