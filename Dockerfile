FROM alpine

RUN apk --update --no-cache add openipmi-lanserv

# Create the directories that will be used to persist state information
# for the IPMI simulator instance.
RUN mkdir -p /tmp/chassis
RUN mkdir -p /tmp/lancontrol
# Directory to persist data (usch as SDR)
RUN mkdir -p /ipmi/var/ipmi_sim/IPMI-SIM-SERVER

COPY ./lan.conf /tmp/ipmisim/
COPY ./sim.emu /tmp/ipmisim/
COPY ./bin/* /tmp/ipmisim/bin/
COPY ./ipmisim1.bsdr /ipmi/var/ipmi_sim/IPMI-SIM-SERVER/sdr.20.main
COPY ./ipmi_sim /tmp/ipmisim/


# Used by the lancontrol script to search for ip_addr_src when an IPMI
# network command is handled (eg. ipmitool lan print)
COPY ./interfaces /etc/network/

EXPOSE 623/udp

CMD ["/tmp/ipmisim/ipmi_sim", "-n", "-c", "/tmp/ipmisim/lan.conf", "-f", "/tmp/ipmisim/sim.emu"]
