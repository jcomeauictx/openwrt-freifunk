#!/bin/ash

# allow env to override nvram
nvram () {
	case $1 in get)
		eval "case \${NVRAM_$2} in '')command nvram get $2;;*)echo \${NVRAM_$2};;esac"
	;;*)
		command nvram $*
	;;esac
}
. /etc/nvram.overrides

export NVRAM_wifi_ifname=$(sed -n 's/^ *\([^:]\+\):.*/\1/p' /proc/net/wireless 2>&-)

# ref: /sbin/ifup, /sbin/ifdown
if_init () {
	ignr=
	type=$1
	iface=$(nvram get ${type}_ifname)
	pidfile=/var/run/${iface}.pid

	case $iface in ppp[0-9])
		ppp=$iface
		iface=$(nvram get ${type}_device)
		iface=${iface:-$(nvram get pppoe_ifname)}
		# Don't fiddle with br0 if it's used for pppoe
		case $type in wan)case $iface in br[0-9])ignr=:;;esac;;esac
	;;esac
}

modules() {
	local pat='\(ip_conntrack_amanda\|ip_conntrack_ftp\|ip_conntrack_h323\|ip_conntrack_irc\|ip_conntrack\|ip_conntrack_pptp\|ip_conntrack_proto_gre\|ip_conntrack_rtsp\|ip_conntrack_sip\|ip_conntrack_tftp\|ip_nat_amanda\|ip_nat_ftp\|ip_nat_h323\|ip_nat_irc\|ip_nat_pptp\|ip_nat_rtsp\|ip_nat_sip\|ip_nat_tftp\|iptable_nat\|ipt_connbytes\|ipt_connlimit\|ipt_connmark\|ipt_CONNMARK\|ipt_conntrack\|ipt_helper\|ipt_layer7\|ipt_MASQUERADE\|ipt_REDIRECT\|ipt_state\|ipt_udplimit\)'
	case $1 in insmod_ct)
		sed -n "s/^[:space:]*$pat\b/insmod &/p" /etc/module /etc/modules.d/* 2>&-|ash
	;;rmmod_ct)
		sed '1!G;h;$!d' /etc/module /etc/modules.d/* 2>&-|sed -n "s/^[:space:]*$pat\b/rmmod &/p"|ash
	;;insmod_all)
		sed -n "/^[:space:]*$pat\b/d;s/^[^#]/insmod &/p" /etc/module /etc/modules.d/* 2>&-|ash
	;;esac
}

NATUSED=
use_nat() {
	case $NATUSED in "")
		test -f /proc/net/ip_conntrack || {
			skip_nat="$WIFIADR $WIFIMSK"
			force_nat=
			IFS=\;
			for dmz in $(nvram get ff_dmz); do
				force_nat="$force_nat ${dmz%[:,]*} 255.255.255.255"
			done
			unset IFS

			case $(nvram get ff_wldhcp_hna4) in 1);;*)
				ff_wldhcp=$(nvram get ff_wldhcp)
				case $ff_wldhcp in "");;*)
					IFS=\;
					for wldhcp in $ff_wldhcp; do
						force_nat="$force_nat ${wldhcp%%[/:,]*} ${wldhcp#*[:,]}"
					done
					unset IFS
				;;esac
			;;esac

			# If ip_conntrack fails: use without kernel params
			insmod ip_conntrack force_nat=$(echo $force_nat|sed 's/[^0-9]\+/,/g;s/^,//;s/,$//') skip_nat=$(echo $skip_nat|sed 's/[^0-9]\+/,/g;s/^,//;s/,$//') >&- && {
				case $ff_debug in 1)
					echo "force_nat=$force_nat, skip_nat=$skip_nat"
				;;esac
			} || insmod ip_conntrack >&-
			insmod iptable_nat >&-
			insmod ipt_MASQUERADE >&-
			insmod ipt_state >&-
			sysctl -w net.ipv4.ip_conntrack_max=8192 net.ipv4.netfilter.ip_conntrack_tcp_timeout_established=3600
			modules insmod_ct
		}
		NATUSED=1
	;;esac
}

unuse_nat() {
	grep -q ^ip_conntrack /proc/modules && {
		modules rmmod_ct
		rmmod ipt_state >&-
		rmmod ipt_MASQUERADE >&-
		rmmod iptable_nat >&-
		rmmod ip_conntrack >&-
	}
}

# $1==IP/PRE is in mesh range?
in_range() {
	case $FF_RANGE in "")
		FF_RANGE=$(nvram get ff_range)
		FF_RANGE=${FF_RANGE:-$WIFINET${WIFINET:+/}$WIFIPRE}
	;;esac
	IFS=\;\:\,
	for net in $FF_RANGE;do
		case $(ipcalc -n ${1%/*}/${net#*/} 2>&-|cut -d= -f2) in ${net%/*})
			unset IFS
			return 0
		;;esac
	done
	unset IFS
	return 1
}

# Get dev config
get_param() {
	local dev=$2
	eval local adr=\$adr_$dev
	eval local mtu=\$mtu_$dev
	case $adr in "")
		case $2 in ppp*);;*)grep -q $dev: /proc/net/dev || dev=;;esac
		eval $1"DEV="$dev";"$1"MTU=;"$1"ADR=;"$1"MSK=;"$1"BRC=;"$1"NET=;"$1"PRE="
	;;*)case $mtu in "")
		case $2 in ppp*);;*)grep -q $dev: /proc/net/dev || dev=;;esac
		eval $1"DEV="$dev";"$1"MTU=;"$1"ADR=;"$1"MSK=;"$1"BRC=;"$1"NET=;"$1"PRE="
	;;*)
		eval $(ipcalc -p -m -n -b $adr)
		eval $1"DEV="$dev";"$1"MTU="$mtu";"$1"ADR="${adr%/*}";"$1"MSK="$NETMASK";"$1"BRC="$BROADCAST";"$1"NET="$NETWORK";"$1"PRE="$PREFIX
	;;esac;;esac
}

# Get net config (LOADR,LOMSK...,LANADR...,WAN...,WIFI...)
get_netparam() {
	eval $(ip link show|sed -n '
		/^[0-9]\+:/{
			s/@[^:]\+:/:/
			s/^[0-9]\+: \+\([^ :]\+\).*mtu \+\([0-9]\+\).*/local mtu_\1=\2/
			p
		}
	')

	eval $(ip -f inet addr show primary|sed -n '
		/^[0-9]\+:/{
			s/@[^:]\+:/:/
			s/[0-9]\+: \+\([^:]\+\).*/local adr_\1=/
			h
			n
			s/^ \+inet \+\([0-9\.\/]\+\).*/\1/
			x
			G
			s/\n//
			p
		}
	')

	get_param LO lo

	local wifi=$(nvram get wifi_ifname)
	get_param WIFI $wifi

	local lan=$(nvram get lan_ifname)
	lan=${lan:-br0}
	eval mtu=\$mtu_$lan
	case $mtu in "")
		set $(nvram get lan_ifnames)
		lan=$1
		lan=${lan:-vlan0}
	;;esac

	get_param LAN $lan

	local wan=$(nvram get wan_ifname)
	case $wan in $lan)wan=;;esac
	case $wan in $wifi)wan=;;esac
	wan=${wan:-vlan1}

	get_param WAN $wan
}

# Make an IPv6 ip addr from MAC
make_ula() {
	IFS=:
	set $(ip link show $1|sed -n 's/ \+link\/ether \([^ ]\+\).*/\1/p')
	unset IFS
	bss=$(nvram get ff_bssid)
	echo $(echo ${bss:-02:ca:ff:ee:ba:be}::$(printf "%02x" $(( $1 ^ 2 ))):$2:$3:ff:fe:$4:$5:$6|sed 's/^[^:]\+/fd/;s/\([^:][^:]\):\([^:][^:]\)/\1\2/g')/64
}
