#!/bin/sh
echo Content-type: text/html
echo

cat<<EOF
<HTML>
<HEAD><TITLE>$(n=$(nvram get wan_hostname);echo ${n:-Freifunk.Net}) -
$TITLE</TITLE>
<META CONTENT="text/html; charset=iso-8859-1" HTTP-EQUIV="Content-Type">
<META CONTENT="no-cache" HTTP-EQUIV="cache-control">
<LINK HREF="../ff.css" REL="StyleSheet" TYPE="text/css">
<LINK HREF="sven-ola*ät*gmx*de" REV="made" TITLE="Sven-Ola">
EOF

unescape()
{
eval echo -n -e '$(sed "s/+/%20/g;s/%\\([[:xdigit:]][[:xdigit:]]\\)/\\\\x\\1/g"<<ESC
$1
ESC
)'
}
checkbridge()
{
ret=0
. /etc/functions.sh
dev=$(nvram get wifi_ifname)
if [ -z "$dev" ]; then
# 8Mb device may die in S15ffnvram, so correct
dev=$(sed -n 's/^ *\([^:]\+\):.*/\1/p' /proc/net/wireless 2>&-)
if [ -n "$dev" ]; then
nvram set wifi_ifname=$dev
ret=1
fi
fi
if [ -n "$dev" ]; then
fnd=
old="$(nvram get lan_ifnames)"
for i in $old; do
test "$i" = "$dev" && fnd=1
done
wbr=
adr=$(nvram get wifi_ipaddr)
if [ -z "$adr" ] || [ "$adr" = "$(nvram get lan_ipaddr)" ];then
# WIFI dev should be in the bridge list
wbr=1
fi
if [ "$wbr" != "$fnd" ]; then
if [ -z "$wbr" ]; then
new=
for i in $old; do
test "$i" != "$dev" && new="$new $i"
done
new=${new# }
else
new="$old $dev"
fi
/usr/sbin/nvram set lan_ifnames="$new"
if [ -z "$(/usr/sbin/nvram get lan_ifname)" ]; then
lan=$(nvram get lan_ifname)
test -z "$lan" || lan=br0
nvram set lan_ifname=$lan
fi
ret=1
fi
fi
return $ret
}

cat<<EOF
<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript"><!--
function help(e) {
if (!e) e = event;
// (virt)KeyVal is Konqueror, charCode is Moz/Firefox, else MSIE, Netscape, Opera
if (26 == e.virtKeyVal || !e.keyVal && !e.charCode && 112 == (e.which || e.keyCode)) {
var o = null;
if (e.preventDefault) {
if (e.cancelable) e.preventDefault();
o = e.target;
}
else {
e.cancelBubble = true;
o = e.srcElement;
}
while(!!o && '' == o.title) o = o.parentNode;
if (!!o) alert(o.title);
}
}
if (document.all) {
document.onkeydown = help;
document.onhelp = function(){return false;}
}
else {
document.onkeypress = help;
}
//--></SCRIPT>
</HEAD>
<BODY><TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" CLASS="body"><TR>
<TD CLASS="color" COLSPAN="5" HEIGHT="19"><SPAN CLASS="color"><A CLASS="color" HREF="../cgi-bin-index.html">Home</A></SPAN><IMG ALT="" HEIGHT="10" HSPACE="2" SRC="../images/vertbar.gif" WIDTH="1"><SPAN CLASS="color"><A CLASS="color" HREF="index.html">Admin</A></SPAN></TD>
</TR><TR><TD HEIGHT="5" WIDTH="150"></TD><TD HEIGHT="5" WIDTH="5"></TD>
<TD HEIGHT="5"><DIV STYLE="width:480px"></TD><TD HEIGHT="5" WIDTH="5"></TD><TD HEIGHT="5"
WIDTH="150"></TD>
</TR><TR><TD HEIGHT="33" WIDTH="150"></TD><TD HEIGHT="33" WIDTH="5"><IMG BORDER="0" HEIGHT="1" NAME="spacer" SRC="" WIDTH="5"></TD>
<TD ALIGN="right" HEIGHT="33"><A HREF="http://www.freifunk.net/"><IMG ALT="" BORDER="0" HEIGHT="33" SRC="../images/ff-logo-1l.gif" WIDTH="106"></A></TD>
<TD ALIGN="right" HEIGHT="33" WIDTH="5"><A HREF="http://www.freifunk.net/"><IMG ALT="" BORDER="0" HEIGHT="33" SRC="../images/ff-logo-1m.gif" WIDTH="5"></A></TD>
<TD HEIGHT="33" WIDTH="150"><A HREF="http://www.freifunk.net/"><IMG ALT="" BORDER="0" HEIGHT="33" SRC="../images/ff-logo-1r.gif" WIDTH="150"></A></TD>
</TR><TR><TD CLASS="magenta" COLSPAN="4" HEIGHT="19">&nbsp;v1.7.4</TD>
<TD CLASS="magenta" HEIGHT="19" WIDTH="150"><A HREF="http://www.freifunk.net/"><IMG ALT="" BORDER="0" HEIGHT="19" SRC="../images/ff-logo-2.gif" WIDTH="150"></A></TD>
</TR><TR><TD HEIGHT="5" WIDTH="150"></TD><TD HEIGHT="5" WIDTH="5"></TD>
<TD HEIGHT="5"></TD><TD HEIGHT="5" WIDTH="5"></TD><TD CLASS="color"
HEIGHT="5" ROWSPAN="2" VALIGN="top" WIDTH="150"><A HREF="http://www.freifunk.net/"><IMG BORDER="0" HEIGHT="62" SRC="../images/ff-logo-3.gif" WIDTH="150"></A></TD>
</TR><TR><TD CLASS="color" VALIGN="top" WIDTH="150">
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="7" WIDTH="150"><TR>
<TD><BIG CLASS="plugin">Admin</BIG></TD>
</TR>
EOF

for inc in /www/cgi-bin/[0-9][0-9]-*;do case ${inc##*.sh} in ""). $inc;;*)cat $inc;;esac;done

cat<<EOF
</TABLE>
<DIV CLASS="white"></DIV></TD><TD VALIGN="top" WIDTH="5"></TD>
<TD VALIGN="top">
EOF
