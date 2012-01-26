<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE xsl:stylesheet [<!ENTITY nbsp "&#160;">]>

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="html"
	    encoding="ISO-8859-1"
	    doctype-public="-//W3C//DTD HTML 4.0 Transitional//EN"
	    doctype-system="http://www.w3.org/TR/REC-html40/loose.dtd"
	    indent="yes"
	    />

  <xsl:param name="fsf">http://www.fsf.org</xsl:param>
  <xsl:param name="gnu">http://www.gnu.org</xsl:param>
  <xsl:param name="ofset">http://www.gnu.org</xsl:param>
  <xsl:param name="lse">http://libresoftware-educ.org</xsl:param>
  <xsl:param name="april">http://www.april.org</xsl:param>
  <xsl:param name="edu">http://www.gnu.org/education/</xsl:param>
  <xsl:param name="edu-fr">http://www.gnu.org/education/fr</xsl:param>
  <xsl:param name="freeduc"></xsl:param>
  <xsl:param name="texmacs"></xsl:param>
  <xsl:param name="drgeo"></xsl:param>
  <xsl:param name="gcompris"></xsl:param>
  <xsl:param name="gtypist"></xsl:param>
  <xsl:param name="ggradebook"></xsl:param>

  <xsl:param name="filebase">index</xsl:param>
  <xsl:param name="path">index.html</xsl:param>

  <xsl:template match="/">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/html/body">
    <body topmargin="0" bottommargin="0" leftmargin="0" rightmargin="0" marginheight="0" marginwidth="0" bgcolor="white">
      <xsl:apply-templates select="node()"/>
    </body>
  </xsl:template>

  <xsl:template match="/html/head">
    <head>
      <link rel="stylesheet" type="text/css" href="{$edu-fr}/green.css" />
      <xsl:apply-templates select="@*|node()"/>
    </head>
  </xsl:template>

  <xsl:include href="navigation.fr.xsl" />

  <xsl:template match="@*|node()" priority="-1">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

<!--
Local Variables: ***
mode: xml ***
End: ***
-->
</xsl:stylesheet>
