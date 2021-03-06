<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet  version="1.0" 
		 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		 xmlns:html="http://www.w3.org/1999/xhtml">
 
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

    <!-- Script to convert the whatsnew database into the whatsnew.sr.html page.
	 This is run by a Makefile in the ../rss directory.
      -->
    <xsl:output method="xml" indent="yes"	
		doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
		doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml-strict.dtd"/>

    <xsl:template match="/">
	<html xml:lang="sr">
	    <head>
		<title>Шта има ново у вези са Пројектом ГНУ — Пројекат ГНУ — Задужбина за слободни софтвер (ЗСС)</title>
		<link rev="made" href="mailto:webmasters@www.gnu.org" />
		<link rel="stylesheet" type="text/css" href="/gnu.css" />
		<xsl:comment>
		    Webmasters: Do not Edit this file. Edit the news database instead.
		    See the webmaster guide.
		</xsl:comment>
		<link rel="alternate" title="Шта има ново" href="http://www.gnu.org/rss/whatsnew.rss" type="application/rss+xml" />
<link rel="alternate" title="Нови слободни софтвер" href="http://www.gnu.org/rss/quagga.rss" type="application/rss+xml" />
	    </head>
	    <body>
		<h3>Шта има ново у вези са Пројектом ГНУ</h3>

		<p>
		    <a href="/graphics/agnuhead.sr.html">
			<img src="/graphics/gnu-head-sm.jpg"
			     alt=" [слика ГНУ-ове главе] "
			     width="129" height="122" />
		    </a>
		</p>
  
		<p>
		    [<xsl:apply-templates select="$translations/whatsnew_translations"/>]
		</p>

		<!-- Coming Events changes regularly and this is another good place to  -->
		<!-- link from and catch people's eye.  -len tower 19Feb00 -->
		<!-- The link is currently dead, due to unfixed, faulty -->
		<!-- replication.  I have replaced it with a temporary file
		     <a href="/events.html"><strong>Предстојећа збивања</strong></a>
		     -->
		<p><a href="/events.tmp.html"><strong>Предстојећа збивања</strong></a>
		    | <a href="/keepingup.html"><strong>Укорак са ГНУ-ом и ЗСС</strong></a>
		    | <a href="/press/press.html"><strong>Информације за штампу</strong></a>
		    и <a href="/press/press.html#releases"><strong>Издања</strong></a>
		</p>    


		<!-- Every April or May split the prior year's entries out into a separate -->
		<!-- file, so the download time for this file isn't too long. -->
		
		<!-- Please make entries so the newest are at the top -->
		
		<!-- If you add something which is unusually interesting here, please -->
		<!-- consider sending an announcement to info-gnu@gnu.org -->

		<xsl:apply-templates select="items/item"/>

		<h4>Шта је било ново претходних година</h4>
		<ul>
		    <!-- Please add years so the latest is first -->
		    <li><a href="/server/03whatsnew.html"><strong>2003</strong></a></li>
		    <li><a href="/server/02whatsnew.html"><strong>2002</strong></a></li>
		    <li><a href="/server/01whatsnew.html"><strong>2001</strong></a></li>
		    <li><a href="/server/00whatsnew.html"><strong>2000</strong></a></li>
		    <li><a href="/server/99whatsnew.html"><strong>1999</strong></a></li>
		    <li><a href="/server/98whatsnew.html"><strong>1998</strong></a></li>
		    <li><a href="/server/97whatsnew.html"><strong>1997</strong></a></li>
		    <li><a href="/server/96whatsnew.html"><strong>1996</strong></a></li>
		</ul>
		<br />

		<div class="copyright">

		    <p>Повратак на <a href="/home.sr.html">домаћу страницу Пројекта ГНУ</a>.</p>

		    <p>Молимо да постављате питања о ГНУ-у и ЗСС-у на адресу:
			<a href="mailto:gnu@gnu.org"><em>gnu@gnu.org</em></a>. Постоје и
			<a href="/home.html#ContactInfo">други начини да се обратите</a> ЗСС-у.  <br/>
			Молимо да шаљете обавештења о неисправним везама и друге исправке (или предлоге)
			на адресу <a href="mailto:webmasters@gnu.org"><em>webmasters@gnu.org</em></a>.
		    </p>

		    <p><b>Ауторска права:</b><br />Copyright © 1996, 1997, 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005 Free Software Foundation, Inc.,
			51 Franklin St — Fifth Floor, Boston, MA  02110,  USA<br />
			Дозвољено је дословно умножавање и расподела овог целог
			чланка широм света, без надокнаде, на било којем медијуму,
			уз услов да је очувано ово обавештење.
		    </p>
		    <p><b>Превод:</b> <a href="http://alas.matf.bg.ac.yu/~mr99164/index.php">Страхиња 
			Радић</a>, <a href="http://alas.matf.bg.ac.yu/~mr99164/posta.php"><em>vilinkamen</em>
			на серверу <em>mail.ru</em></a>
		    </p>

		    <p>Ажурирано: 
			<!-- timestamp start -->
			<xsl:comment> timestamp start </xsl:comment>
			$Date: 2007/04/10 21:07:14 $ $Author: Ctpajgep $
			<xsl:comment> timestamp end </xsl:comment>
			<!-- timestamp end -->
		    </p>

		</div>
	    </body>
	</html>
    </xsl:template>

    <xsl:template match="item">
	<dl>
	    <dt><xsl:value-of select="date/@day"/><xsl:text> </xsl:text><xsl:value-of select="date"/></dt>
	    <dd><xsl:copy-of select="news/node()"/></dd>
	</dl>
    </xsl:template>

</xsl:stylesheet>
