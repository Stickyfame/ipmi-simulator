#!/bin/sh

#
# An example script for handling external LAN configuration from the
# IPMI simulator.  This command is generally invoked by the IPMI
# simulator to get and set external LAN configuration parameters.
#
# It's parameters are:
#
#  ipmi_sim_lancontrol <device> get [parm [parm ...]]
#  ipmi_sim_lancontrol <device> set|check [parm val [parm val ...]]
#
# where <device> is a network device (eth0, etc.) and parm is one of:
#  ip_addr
#  ip_addr_src
#  mac_addr
#  subnet_mask
#  default_gw_ip_addr
#  default_gw_mac_addr
#  backup_gw_ip_addr
#  backup_gw_mac_addr
# These are config values out of the IPMI LAN config table that are
# not IPMI-exclusive, they require setting external things.
#
# The output of the "get" is "<parm>:<value>" for each listed parm.
# The output of the "set" is empty on success.  Error output goes to
# standard out (so it can be captured in the simulator) and the program
# returns an error.
#
# The IP address values are standard IP addresses in the form a.b.c.d.
# The MAC addresses ar standard 6 octet xx:xx:xx:xx:xx:xx values.  The
# only special one is ip_addr_src, which can be "dhcp" or "static".
#  
# The "check" operation checks to see if a value is valid without
# committing it.  It is only implemented for the ip_addr_src parm.
#

lan_control_path="/tmp/lancontrol"
prog=$0

device=$1
if [ "x$device" = "x" ]; then
    echo "No device given"
    exit 1;
fi
shift

op=$1
if [ "x$op" = "x" ]; then
    echo "No operation given"
    exit 1
fi
shift

do_get() {
    while [ "x$1" != "x" ]; do
	case $1 in
	    ip_addr)
		val=`ifconfig $device | grep '^ *inet addr:' | tr ':' ' ' | sed 's/.*inet addr \([0-9.]*\).*$/\1/'`
		if [ "x$val" = "x" ]; then
		    val="0.0.0.0"
		fi
		;;

	    ip_addr_src)
                path="$lan_control_path/ipsrc"
                if [ ! -f "$path" ]; then
                    echo "dhcp" > "$path"
                fi

                val=$(cat $path)
		;;

	    mac_addr)
		val=`ifconfig $device | grep 'HWaddr' | sed 's/.*HWaddr \([0-9a-fA-F:]*\).*$/\1/'`
		if [ "x$val" = "x" ]; then
		    val="00:00:00:00:00:00"
		fi
		;;

	    subnet_mask)
		val=`ifconfig $device | grep '^ *inet addr:' | tr ':' ' ' | sed 's/.*Mask \([0-9.]*\).*$/\1/'`
		if [ "x$val" = "x" ]; then
		    val="0.0.0.0"
		fi
		;;

	    default_gw_ip_addr)
		val=`route -n | grep '^0\.0\.0\.0' | grep "$device\$" | tr ' ' '\t' | tr -s '\t' '\t' | cut -f 2`
		if [ "x$val" = "x" ]; then
		    val="0.0.0.0"
		fi
		;;

	    default_gw_mac_addr)
		val=`route -n | grep '^0\.0\.0\.0' | grep "$device\$" | tr ' ' '\t' | tr -s '\t' '\t' | cut -s -f 2`
		if [ "x$val" = "x" ]; then
		    val="00:00:00:00:00:00"
		else
		    val=`arp -n $val | grep "^$val" | tr ' ' '\t' | tr -s '\t' '\t' | cut -f 3 | tr -d -c '0-9a-f:'`
		    if [ "x$val" = "x" ]; then
			val="00:00:00:00:00:00"
		    fi
		fi
		;;

	    backup_gw_ip_addr)
		val="0.0.0.0"
		;;

	    backup_gw_mac_addr)
		val="00:00:00:00:00:00"
		;;

	    *)
		echo "Invalid parameter: $1"
		exit 1
		;;
	esac

	echo -n "$1:$val"
	shift
    done
}

do_set() {
    while [ "x$1" != "x" ]; do
	parm="$1"
	shift
	if [ "x$1" = "x" ]; then
	    echo "No value present for parameter $parm"
	    exit 1
	fi
	val="$1"
	shift

	case $parm in
	    ip_addr)
                ifconfig $device $val netmask 255.255.255.0
                exit 0
		;;

	    ip_addr_src)
                path="$lan_control_path/ipsrc"
                echo "$val" > "$path"
		;;

	    mac_addr)
		;;

	    subnet_mask)
		;;

	    default_gw_ip_addr)
		;;

	    default_gw_mac_addr)
		;;

	    backup_gw_ip_addr)
		;;

	    backup_gw_mac_addr)
		;;

	    *)
		echo "Invalid parameter: $1"
		exit 1
		;;
	esac
    done
}

do_check() {
    while [ "x$1" != "x" ]; do
	parm="$1"
	shift
	case $parm in
	    ip_addr_src)
		# We only support static and dhcp IP address sources
		case $1 in
		    static)
			;;
		    dhcp)
			;;
		    *)
			echo "Invalid ip_addr_src: $1"
			exit 1
			;;
		esac
		;;

	    *)
		echo "Invalid parameter: $parm"
		exit 1
		;;
	esac
	shift
    done
}

case $op in
    get)
	do_get $@
	;;
    set)
	do_set $@
	;;
    
    check)
	do_check $@
	;;

*)
	echo "Unknown operation: $op"
	exit 1
esac
