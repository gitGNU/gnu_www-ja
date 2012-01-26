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


    <xsl:output method="xml"/>

    <xsl:template match="/">
	<rss version="2.0">
	    <channel>
		<title>What's New at GNU</title>
		<link>http://www.gnu.org/whatsnew.html</link>
		<description>What's new at the GNU project</description>
		<copyright>(C) Free Software Foundation 2004</copyright>
		<xsl:apply-templates select="/items/item[position() &lt; 16]"/>
	    </channel>
	</rss>
    </xsl:template>

    <xsl:template match="item">
	<item>
	    <pubDate><xsl:value-of select="date"/></pubDate>
            <xsl:choose>
                <xsl:when test="string-length(news) &gt; 40">
                    <title><xsl:value-of select="substring(news, 1, 40)"/>...</title>
	            <description><xsl:value-of select="news"/></description>
                </xsl:when>
                <xsl:otherwise>
                    <title><xsl:value-of select="news"/></title>
                </xsl:otherwise>
            </xsl:choose>
	    <xsl:if test="news/a/@href">
		<link><xsl:apply-templates select="news/a[1]/@href"/></link>
	    </xsl:if>
	    <pubDate><xsl:value-of select="date"/></pubDate>
	</item>
        <xsl:text>
</xsl:text>
    </xsl:template>

    <xsl:template match="@href">
	<xsl:choose>
	    <xsl:when test="starts-with(., 'http://')
			    or starts-with(., 'mailto:')">
		<xsl:value-of select="."/>
	    </xsl:when>
	    <xsl:otherwise>http://www.gnu.org<xsl:value-of select="."/>
	    </xsl:otherwise>
	</xsl:choose>
    </xsl:template>

</xsl:stylesheet>
