<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet  version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!-- Turn the whatsnew_translations.xml into HTML.
	 This is to be imported into the whatsnew.xx.xslt stylesheets for 
	 handling the list of available translations.

	 To be honest, it would be just as easy to use an SSI to get
	 the list of translations. But since the page is generated
	 with XSLT it might as well be done this way.
      -->


    <!-- The variable holds the translations -->
    <xsl:variable name="translations" select="document('whatsnew_translations.xml')"/>


    <xsl:template match="whatsnew_translations">
	<xsl:apply-templates select="translation[1]"/>
	<xsl:apply-templates select="translation[1]/following-sibling::translation" mode="followon"/>
    </xsl:template>

    <xsl:template match="translation">
	<a>
	    <xsl:attribute name="href"><xsl:value-of select="@uri"/></xsl:attribute>
	    <xsl:value-of select="."/>
	</a>
    </xsl:template>

    <xsl:template match="translation" mode="followon">
	<xsl:text> | </xsl:text><a>
	    <xsl:attribute name="href"><xsl:value-of select="@uri"/></xsl:attribute>
	    <xsl:value-of select="."/>
	</a>
    </xsl:template>

</xsl:stylesheet>
