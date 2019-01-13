#!/bin/sh
echo Content-type: text/html
echo

cat<<EOF
<HTML>
<HEAD>
<TITLE>$(n=$(uname -n);echo ${n:-Freifunk.Net}) - $TITLE</TITLE>
<META CONTENT="text/html; charset=iso-8859-1" HTTP-EQUIV="Content-Type">
<META CONTENT="no-cache" HTTP-EQUIV="cache-control">
<LINK HREF="ff.css" REL="StyleSheet" TYPE="text/css">
<LINK HREF="sven-ola*�t*gmx*de" REV="made" TITLE="Sven-Ola">
<STYLE TYPE="text/css">
$(if ! grep -q '^LoadPlugin "olsrd_nameservice.so' /etc/olsrd.conf 2>&-;then echo '.plugin-services {display:none}';echo '.plugin-map {display:none}';elif test -z "`nvram get ff_adm_latlon`";then echo '.plugin-map {display:none}';fi)
</STYLE>
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
while(o && '' == o.title) o = o.parentNode;
if (o) alert(o.title);
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
<BODY>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" CLASS="body">
<TR>
<TD CLASS="color" COLSPAN="5" HEIGHT="19"><SPAN CLASS="color"><A CLASS="color" HREF="cgi-bin-index.html">Home</A></SPAN><IMG ALT="" HEIGHT="10" HSPACE="2" SRC="images/vertbar.gif" WIDTH="1"><SPAN CLASS="color"><A CLASS="color" HREF="cgi-bin-admin.html">Admin</A></SPAN></TD>
</TR>
<TR>
<TD HEIGHT="5" WIDTH="150"></TD>
<TD HEIGHT="5" WIDTH="5"></TD>
<TD HEIGHT="5"><DIV STYLE="width:480px"></TD>
<TD HEIGHT="5" WIDTH="5"></TD>
<TD HEIGHT="5" WIDTH="150"></TD>
</TR>
<TR>
<TD HEIGHT="33" WIDTH="150"></TD>
<TD HEIGHT="33" WIDTH="5"><IMG BORDER="0" HEIGHT="1" NAME="spacer" SRC="" WIDTH="5"></TD>
<TD ALIGN="right" HEIGHT="33"><A HREF="http://www.freifunk.net/"><IMG ALT="" BORDER="0" HEIGHT="33" SRC="images/ff-logo-1l.gif" WIDTH="106"></A></TD>
<TD ALIGN="right" HEIGHT="33" WIDTH="5"><A HREF="http://www.freifunk.net/"><IMG ALT="" BORDER="0" HEIGHT="33" SRC="images/ff-logo-1m.gif" WIDTH="5"></A></TD>
<TD HEIGHT="33" WIDTH="150"><A HREF="http://www.freifunk.net/"><IMG ALT="" BORDER="0" HEIGHT="33" SRC="images/ff-logo-1r.gif" WIDTH="150"></A></TD>
</TR>
<TR>
<TD CLASS="magenta" COLSPAN="4" HEIGHT="19">&nbsp;v1.7.4</TD>
<TD CLASS="magenta" HEIGHT="19" WIDTH="150"><A HREF="http://www.freifunk.net/"><IMG ALT="" BORDER="0" HEIGHT="19" SRC="images/ff-logo-2.gif" WIDTH="150"></A></TD>
</TR>
<TR>
<TD HEIGHT="5" WIDTH="150"></TD>
<TD HEIGHT="5" WIDTH="5"></TD>
<TD HEIGHT="5"></DIV></TD>
<TD HEIGHT="5" WIDTH="5"></TD>
<TD CLASS="color" HEIGHT="5" ROWSPAN="2" VALIGN="top" WIDTH="150"><A HREF="http://www.freifunk.net/"><IMG BORDER="0" HEIGHT="62" SRC="images/ff-logo-3.gif" WIDTH="150"></A></TD>
</TR>
<TR>
<TD CLASS="color" VALIGN="top" WIDTH="150">
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="7" WIDTH="150">
<TR>
<TD><BIG CLASS="plugin">Contents</BIG></TD>
</TR>
EOF

for inc in /www/[0-9][0-9]-*;do case ${inc##*.sh} in ""). $inc;;*)cat $inc;;esac;done

cat<<EOF
</TABLE></TD>
<TD VALIGN="top" WIDTH="5"></TD>
<TD VALIGN="top">
EOF
