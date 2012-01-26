<xsl:stylesheet  version="1.0" 
		 xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
 
    <!-- (C) Free Software Foundation 2004
	 This program is free software; you can redistribute it and/or modify
	 it under the terms of the GNU General Public License as published by 
	 the Free Software Foundation; either version 2, or (at your option) 
	 any later version. 
	 This program is distributed in the hope that it will be useful, 
	 but WITHOUT ANY WARRANTY; without even the implied warranty of 
	 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
	 GNU General Public License for more details. 
	 You should have received a copy of the GNU General Public License 
	 along with this program; see the file COPYING.  If not, write to the 
	 Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, 
	 Boston, MA 02110-1301, USA. 
      -->

    <xsl:import href="whatsnew_translations.xslt"/>
    <xsl:import href="whatsnew_include.xslt"/>

    <!-- Script to convert the whatsnew database into the whatsnew.html page.
	 This is run by a Makefile in the ../rss directory.
      -->
    <xsl:output method="xml" indent="yes"	
		doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
		doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml-strict.dtd"/>

    <xsl:template match="/">
		<!-- Coming Events changes regularly and this is another good place to  -->
		<!-- link from and catch people's eye.  -len tower 19Feb00 -->
		<!-- The link is currently dead, due to unfixed, faulty -->
		<!-- replication.  I have replaced it with a temporary file
		     <a href="/events.html"><strong>Coming Events</strong></a>
		     -->
		<p><a href="/events.tmp.html"><strong>Coming Events</strong></a>
		    | <a href="/keepingup.html"><strong>Keeping Up With GNU/FSF</strong></a>
		    | <a href="/press/press.html"><strong>Press Information</strong></a>
		    and <a href="/press/press.html#releases"><strong>Releases</strong></a>
		</p>    


		<!-- Every April or May split the prior year's entries out into a separate -->
		<!-- file, so the download time for this file isn't too long. -->
		
		<!-- Please make entries so the newest are at the top -->
		
		<!-- If you add something which is unusually interesting here, please -->
		<!-- consider sending an announcement to info-gnu@gnu.org -->

		<xsl:apply-templates select="items/item"/>

		<h4>What was New in Prior Years</h4>
		<ul>
		    <!-- Please add years so the latest is first -->
		    <li><a href="/server/08whatsnew.html"><strong>2008</strong></a></li>
		    <li><a href="/server/07whatsnew.html"><strong>2007</strong></a></li>
		    <li><a href="/server/06whatsnew.html"><strong>2006</strong></a></li>
		    <li><a href="/server/05whatsnew.html"><strong>2005</strong></a></li>
		    <li><a href="/server/04whatsnew.html"><strong>2004</strong></a></li>
		    <li><a href="/server/03whatsnew.html"><strong>2003</strong></a></li>
		    <li><a href="/server/02whatsnew.html"><strong>2002</strong></a></li>
		    <li><a href="/server/01whatsnew.html"><strong>2001</strong></a></li>
		    <li><a href="/server/00whatsnew.html"><strong>2000</strong></a></li>
		    <li><a href="/server/99whatsnew.html"><strong>1999</strong></a></li>
		    <li><a href="/server/98whatsnew.html"><strong>1998</strong></a></li>
		    <li><a href="/server/97whatsnew.html"><strong>1997</strong></a></li>
		    <li><a href="/server/96whatsnew.html"><strong>1996</strong></a></li>
		</ul>
    </xsl:template>

</xsl:stylesheet>
