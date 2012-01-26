<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet  version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <xsl:template match="item">
        <dl>
	    <dt><xsl:value-of select="date"/></dt>
	    <dd><xsl:copy-of select="news/node()"/></dd>
	</dl>
    </xsl:template>

</xsl:stylesheet>
