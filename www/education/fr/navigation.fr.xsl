<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE xsl:stylesheet [<!ENTITY nbsp "&#160;">]>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="/html[@lang='fr']/body/div">
    <!-- Title bar -->
    <table width="100%" border="0" cellspacing="0" cellpadding="4">
	<tr>
	  <td class="TopBody">
	    <a href="{$edu-fr}/education.fr.html">
	      <img src="{$edu-fr}/images/logoedufr.jpg" alt="logo" border="0"  />
	    </a>
	  </td>
	  <td class="TopBody" width="99%" height="99%">
	    <a class="TopTitleB">edu-fr</a>
	    <br />
	    <a class="TopTitle">Des Logiciels et Documents Libres pour l'Education</a>
	  </td>
	  <td align="right" valign="bottom" class="TopBody">
	    <a href="{$edu}/index.html" class="T2"><img src="{$edu-fr}/images/baby-gnu-sm.png" alt="logo" border="0" /><br />GNU/education</a> <br />
	  </td>
	</tr>
    </table>

    <table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
	  <td width="99%" valign="top">
	  <div class="content">
	  <xsl:apply-templates select="@*|node()"/>
	  </div>
	  </td>
	  <!-- Menu column. On the right to be Lynx friendly.  -->
	  <td>&nbsp;</td>
	  <td valign="top" class="TopBody">
	    <table summary="" width="150" border="0" cellspacing="0" cellpadding="4">
		<tr><td class="TopTitle" align="center">Textes</td></tr>
		<tr>
		  <td class="TopBody" align="right">
			  <a href="{$gnu}/philosophy/free-sw.fr.html" class="T2">Logiciel Libre ?</a><br/>
		          <a href="{$april}/groupes/gnufr/" class="T2">La Philosophie GNU</a><br/>
			  
                          <a href="{$gnu}/copyleft/gpl.html" class="T2">La GPL</a><br />
                          <a href="{$gnu}/copyleft/fdl.html" class="T2">La FDL</a><br />
	          </td>
		</tr>
		<tr><td class="TopTitle" align="center">Projets</td></tr>
		<tr>
		  <td class="TopBody" align="right">
                          <a href="{$freeduc}" class="T2">Freeduc</a><br />
                          <a href="{$texmacs}" class="T2">GNU/TeXmacs</a><br />
			  <a href="{$drgeo}" class="T2">DrGeo/DrGenius</a><br />
			  <a href="{$gcompris}" class="T2">GCompris</a><br />
			  <a href="{$gtypist}" class="T2">GTypist</a><br />
			  <a href="{$ggradebook}" class="T2">GGradebook</a><br />
			  
	          </td>
		</tr>
	    </table>
	  </td>
    	</tr>
    </table>

    <!-- Bottom line -->
    <table width="100%" border="0" cellspacing="0" cellpadding="2">
      <tr>
	<td class="TopTitle">
          <a href="{$filebase}.xhtml" class="T1">Source XHTML</a>&nbsp;&nbsp;|
          &nbsp;&nbsp;<a href="{$edu-fr}/edu-fr.xsl" class="T1">Feuille de Style XSL</a>&nbsp;&nbsp;|
          &nbsp;&nbsp;<a href="http://savannah.gnu.org/cgi-bin/viewcvs/edu-fr/{$path}?cvsroot=www.gnu.org" class="T1">Modifications</a><br/>
	</td>
	<td class="TopTitle" align="right">
	  &nbsp;<a href="mailto:obenassy@free.fr"
                   class="T1">webmaster</a>
        </td>
      </tr>
      <tr>
	<td class="Body" align="center">
	<font size="-2">
	    Copyright (C) 2001 FSF France,
	    8 rue de Valois, 75001 Paris, France
	    <br/>
            La reproduction exacte et la distribution intégrale de cet article
            sont permises sur n'importe quel support d'archivage, pourvu que
            cette notice soit préservée.
	</font>
	</td>
        <td class="Body">&nbsp;</td>
      </tr>
    </table>
  </xsl:template> 

<!--
Local Variables: ***
mode: xml ***
End: ***
-->
</xsl:stylesheet>

