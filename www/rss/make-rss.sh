#!/bin/bash

# Make RSS from the front page of the directory
# (C) Free Software Foundation, 2003

# Author: Nic Ferrier, <nferrier@tapsellferrier.co.uk>

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; see the file COPYING.  If not, write to the
# Free Software Foundation, Inc., 51 Franklin St, Fifth Floor,
# Boston, MA 02110-1301, USA.


# Usage.

# For usage details see the function called 'usage' below or 
# execute this script with the option "--help" or "-h".


function usage ()
{
cat <<EOF
Usage: make-rss.sh [http-url]

Calling this script causes RSS 2.0 for the free software directory 
(located at the specified http-url) to be written to stdout.

By default the 'http-url' is assumed to be:
    http://www.gnu.org/directory/index.html

By default an internal stylesheet is used but an external stylesheet
can be used by setting the environment variable:

    HTMLTORSS2

to the location of the style sheet, eg:

    HTMLTORSS2=/freedir/xslt/rss2.xsl make-rss.sh

EOF

exit 0;
}


# Spit the stylesheet out.
function make_xslt ()
{
  cat <<EOF
<?xml version="1.0"?>

<!-- RSS the FSF/UNESCO Free Software Directory. -->
<!-- (C) Free Software Foundation 2003 -->
 
<!-- This program is free software; you can redistribute it and/or modify -->
<!-- it under the terms of the GNU General Public License as published by -->
<!-- the Free Software Foundation; either version 2, or (at your option) -->
<!-- any later version. -->

<!-- This program is distributed in the hope that it will be useful, -->
<!-- but WITHOUT ANY WARRANTY; without even the implied warranty of -->
<!-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the -->
<!-- GNU General Public License for more details. -->

<!-- You should have received a copy of the GNU General Public License -->
<!-- along with this program; see the file COPYING.  If not, write to the -->
<!-- Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, -->
<!-- Boston, MA 02110-1301, USA. -->


<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

    <xsl:output method="xml"/>

    <xsl:param name="last_build_date">Sun, 27th April 2003 13:00:00 GMT</xsl:param>

    <xsl:template match="/">
	<rss version="2.0">
	    <channel>
		<title>Free Software Programs</title>
		<link>http://www.gnu.org/directory/</link>
		<description>Free Software programs available.</description>
		<language>en-us</language>
		<copyright>Copyright 2003 Free Software Foundation</copyright>
		<lastBuildDate><xsl:value-of select='\$last_build_date'/></lastBuildDate>
		<docs>http://backend.userland.com/rss</docs>
		<generator>GNU xslt script</generator>
		<managingEditor>bug-directory@gnu.org</managingEditor>
		<webMaster>webmasters@gnu.org</webMaster>

		<xsl:apply-templates select="//strong[contains(text(), 'Ten most') &gt; 0]/following-sibling::table"/>

	    </channel>
	</rss>
    </xsl:template>


    <xsl:template match="table">
	<xsl:for-each select="descendant::tr[td/a]">
	    <item>
		<title><xsl:value-of select="td/a"/></title>
                <link>http://www.gnu.org/directory/<xsl:value-of select="td/a/@href"/></link>
		<!-- date><xsl:value-of select="../../preceding-sibling::dt[1]"/></date -->
	        <description>
	            <xsl:value-of select="td/br/following-sibling::text()"/>
	            <xsl:value-of select="td/a/following-sibling::text()"/>
	        </description>
	</item>
    </xsl:for-each>
</xsl:template>

</xsl:stylesheet>

EOF
}


# Output help if we're asked.
case $1 in
  "-h" | "--help") usage ;;
esac



# The main script, convert the directory HTML to RSS.

# The xslt script location can be overloaded by this env var.
XSLTLOC=${HTMLTORSS2:--}


# Front page can be overloaded by the first parameter.
NEWSPAGE=${1:-'http://www.gnu.org/directory/index.html'}

# Output the RSS 2.0.
DATE=`date -R`

if [ "$XSLTLOC" == "-" ]
then
    make_xslt |\
	xsltproc --html --param last_build_date \""${DATE}"\" - ${NEWSPAGE} |\
	xmllint --format -
else
    xsltproc --html --param last_build_date \""${DATE}"\" ${XSLTLOC} ${NEWSPAGE} |\
	xmllint --format -
fi

if [ $? -ne 0 ]
then
  echo "make-rss.sh: couldn't execute xslt on: ${NEWSPAGE}" > /dev/stderr
fi

# End.