<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet  version="1.0" 
		 xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!-- (C) Free Software Foundation 2004 -->
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


    <!-- This XSLT script generates the whatsnew RSS file from the HTML page -->
    <!-- It is very sensitive to the format of the HTML file so try and keep -->
    <!-- that file as consistent with what is currently there. -->
    <!-- The main point about the whatsnew.html is that each news item must -->
    <!-- be in a <dd> element. Each <dd> must have a preceeding <dt> which -->
    <!-- specifies the date in some parseable form. -->

    <xsl:output method="xml"/>

    <xsl:template match="/">
	<rss version="2.0">
	    <channel>
		<title>What's New at GNU</title>
		<link>http://www.gnu.org/whatsnew.html</link>
		<description>What's new at the GNU project</description>
		<copyright>(C) Free Software Foundation 2004</copyright>
		<items>
		    <xsl:for-each select="html/body//dd">
			<xsl:apply-templates select="."/>
		    </xsl:for-each>
		</items>
	    </channel>
	</rss>
    </xsl:template>

    <xsl:template match="dd">
	<item>
	    <date><xsl:value-of select="preceding-sibling::dt[1]"/></date>		
	    <description><xsl:copy-of select="node()"/></description>
	</item>
    </xsl:template>

</xsl:stylesheet>
