FROM alpine:3.17

# edge/main apk repo needed for some libraries
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories

# Install build dependencies
RUN apk update
RUN apk add git build-base autoconf automake libtool
RUN apk add python3 python3-dev py3-pip\
            popt-dev \
            ncurses-dev \
            linux-headers \
            readline-dev \
            libedit-dev

#RUN ln -s /usr/bin/python3 /usr/bin/python

# Clone the OpenIPMI repo (or fork) specified in build arg variable
ARG openipmi_repo=https://github.com/wrouesnel/openipmi.git
RUN mkdir /openipmi && git clone ${openipmi_repo} /openipmi

WORKDIR /openipmi

# Autotools to generate the configure script
RUN autoupdate
RUN autoreconf -f -i

# Build and install the binary
RUN ./configure
RUN make -j 4
RUN make install

# Copy the binary in a shared directory
CMD ["cp", "/usr/local/bin/ipmi_sim", "/output"]

