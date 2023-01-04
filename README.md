# IPMI Simulator

[![Build Status](https://build.vio.sh/buildStatus/icon?job=vapor-ware/ipmi-simulator/master)](https://build.vio.sh/blue/organizations/jenkins/vapor-ware%2Fipmi-simulator/activity)

`ipmi_sim` in a lightweight Docker container.

## Usage
`lan.conf` and `sim.emu` are used to configure `ipmi_sim`. They are built into the image,
so if updating any configurations, this repo must be cloned, the configs updated, and the
image rebuilt.

### Getting the Image
To get the image, you can either pull it from DockerHub

```console
$ docker pull vaporio/ipmi-simulator
```
 
 
Or, build it directly from source

```console
$ docker build -f Dockerfile -t vaporio/ipmi-simulator .
```

A Makefile target is also provided

```console
$ make build
```

### Running the Simulator
The Docker image will run `ipmi_sim` with its default command. Starting it is as easy as

```console
$ docker run -d -p 623:623/udp vaporio/ipmi-simulator
```

This can also be done via the Makefile

```console
$ make run
```

With the container running, you can test it out with [`ipmitool`](https://github.com/ipmitool/ipmitool)

```console
$ ipmitool -H 127.0.0.1 -U ADMIN -P ADMIN -I lanplus chassis status
System Power         : on
Power Overload       : true
Power Interlock      : active
Main Power Fault     : true
Power Control Fault  : true
Power Restore Policy : unknown
Last Power Event     : 
Chassis Intrusion    : inactive
Front-Panel Lockout  : inactive
Drive Fault          : false
Cooling/Fan Fault    : false
```

### ipmitool support
Note that not all `ipmitool` commands are likely to work, since this is currently just
a simple simulator with minimal configuration. The snippet below describes the commands
that are currently supported by the IPMI similator via ipmitool

```bash
# Firmware Version
ipmitool [options] mc info

# User
ipmitool [options] user summary
ipmitool [options] user list
ipmitool [options] set name
ipmitool [options] set password
ipmitool [options] disable
ipmitool [options] enable
ipmitool [options] priv

# Chassis Commands
ipmitool [options] chassis status

# Chassis Power Commands
ipmitool [options] chassis power on
ipmitool [options] chassis power off
ipmitool [options] chassis power cycle
ipmitool [options] chassis power reset
ipmitool [options] chassis power status

# Chassis Power Commands (same as above block)
ipmitool [options] power on
ipmitool [options] power off
ipmitool [options] power cycle
ipmitool [options] power reset
ipmitool [options] power status

# Chassis Identify
ipmitool [options] identify [value]

# Get Boot Target
ipmitool [options] chassis bootparam get 5

# Set Boot Target
ipmitool [options] chassis bootdev [none|pxe|disk|cdrom|bios|floppy]

# Get LAN Settings
ipmitool [options] lan print
```

## Building the static binary

Because some modifications have not been accepted yet in OpenIPMI lanserv
upstream repository, you can build the `ipmi_sim` static binary and use it
rather the one provided by the alpine package `openipmi-lanserv`.

Building steps :
- Be sure to be in an Alpine environment if you want to build the binary for Alpine
  ```
  docker run -it alpine:3.17
  ```
- Add edge/main apk repository
  ```
  echo https://dl-cdn.alpinelinux.org/alpine/edge/main >> /etc/apk/repositories
  ```
- Install building dependencies
  ```
  apk update
  # building tools
  apk add git build-base automake autoconf libtool
  # required libraries for building openipmi
  apk add popt-dev python3 python3-dev py3-pip ncurses-dev linux-headers readline-dev libedit-dev
  ```
- Make sure `python` is an available command
  ```
  which python
  ```
- Clone OpenIPMI repo (or your fork)
  ```
  git clone https://github.com/wrouesnel/openipmi.git
  cd openipmi
  ```
- Run autotools
  ```
  autoupdate
  autoreconf -f -i
  ./configure
  ```
- Build and install
  ```
  make -j 4
  make install
  ```
- Copy the binary outside the docker container
  ```
  cp <container-id>:/usr/local/bin/ipmi_sim .
  ```

> You can also use the ipmi_sim.Dockerfile in this repository, it will automatically
> build the binary and place it in a `output` directory.
> Just call `make build-ipmisim` .
