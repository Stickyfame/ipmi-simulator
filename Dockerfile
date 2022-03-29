FROM alpine

RUN apk --update --no-cache add openipmi-lanserv

# Create the directories that will be used to persist state information
# for the IPMI simulator instance.
RUN mkdir -p /tmp/chassis
RUN mkdir -p /tmp/lancontrol

COPY . /tmp/ipmisim

# Used by the lancontrol script to search for ip_addr_src when an IPMI
# network command is handled (eg. ipmitool lan print)
COPY ./interfaces /etc/network/


EXPOSE 623/udp

CMD ["ipmi_sim", "-n", "-c", "/tmp/ipmisim/lan.conf", "-f", "/tmp/ipmisim/sim.emu"]
