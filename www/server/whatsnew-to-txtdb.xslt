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


    <!-- This XSLT script generates the whatsnew text database from the HTML page.
	 It only needs to be run once, when the text database is first created.
	 Author: Nic Ferrier <nferrier@tapsellferrier.co.uk>
      -->

    <xsl:output method="xml" omit-xml-declaration="yes"/>

    <xsl:template match="/">
	<xsl:apply-templates select="//dd"/>
    </xsl:template>

    <xsl:template match="dd">
<xsl:value-of select="preceding-sibling::dt[1]"/><xsl:text>
</xsl:text>
<xsl:apply-templates select="node()"/><xsl:text>

</xsl:text>
    </xsl:template>


    <!-- Override style sheet default behaviour 
	 We do this so we can normalize-space in the text nodes more effectively.
	 An alternative would be to use copy-of to get the contents of the news item
	 and then post format the output with emacs or something.
      -->
    <xsl:template match="*">
	<xsl:variable name="element_name" select="local-name(.)"/>
	<xsl:element name="{$element_name}">
	    <xsl:copy-of select="@*"/>
	    <xsl:apply-templates select="node()"/>
	</xsl:element>
    </xsl:template>

    <xsl:template match="text()">
	<xsl:if test="string-length(normalize-space(.)) &gt; 0">
	    <xsl:if test="preceding-sibling::*">
		<xsl:text> </xsl:text>
	    </xsl:if>
	    <xsl:value-of select="normalize-space(.)"/>
	    <xsl:if test="following-sibling::*">
		<xsl:text> </xsl:text>
	    </xsl:if>
	</xsl:if>
    </xsl:template>

</xsl:stylesheet>
