# news system build.
# (C) Tapsell-Ferrier Limited 2004

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


# README 
# When you run this you should first "cvs update" the root,
# server and rss directories.

# DEPENDENCIES
# This Makefile requires libxml2 and libxslt tools.
# It also requires at least cvs version 12.9.
# GNU mailutils or BSD mail is necessary for mailing the latest news
# to the trans-coord-news mailing list.

# Do all the news updates.
all: quagga.rss gnunews

# Do the main GNU stuff.  Translations are handled by GNUN; see the
# node "GNU News" in the web-translators documentation.
gnunews: ../server/whatsnew.include ../gnusflashes.include whatsnew.rss 

# Options for CVS commands. Set to:
#  -n
# if you DO NOT want commits to be performed.
CVSOPTS=

# Update the whole directory, not just the Makefile.
Makefile:
	cvs -q update Makefile

# We could make this depend on an HTTP data check.
.PHONY: quagga.rss
quagga.rss: 
	./make-rss.sh > quagga.rss
	cvs $(CVSOPTS) ci -m \
	  "Automatic update of the free software directory RSS." quagga.rss



# Whatsnew update.
whatsnew.rss: ../server/whatsnew.txt
	gawk -f ../server/news-to-xml.awk $< | xsltproc whatsnew.xslt - > $@
	cvs $(CVSOPTS) ci -m "Automatic update of the whatsnew RSS." $@

# This is the target that sends the email to the translators list.
../server/whatsnew.include: ../server/whatsnew.txt ../server/whatsnew.xslt
	$(addfile)
# The Keywords: header is appended to support Mailman's "topics"
# feature.  Only short options are passed to `mail' for compatibility
# with BSD mail.
	head $< | mail -a Keywords:whatsnew -s "GNU news update" \
	  trans-coord-news@gnu.org
	gawk -f ../server/news-to-xml.awk $< \
	  | xsltproc ../server/whatsnew.xslt - > $@
# Delete declarations that are necessary for successful xsltproc
# operation, but make whatsnew.html invalid when the target is
# include'd in it.
	sed --in-place "/<?xml\|<\!DOCTYPE/D" $@
# Trick CVS to update the $Date$ RCS keyword to match the last news
# update.  Note that this Makefile is with "Sticky Options" set to
# "-kk" so that CVS does not expand the keywords in the expression.
	sed --in-place "s/^\$$Date.*\$$/\$$Date\$$/" ../server/whatsnew.html
	cvs $(CVSOPTS) ci -m "Automatic update of whatsnew." $@ \
	  ../server/whatsnew.html

../gnusflashes.include: ../server/whatsnew.txt
	gawk -f ../server/news-to-xml.awk $< \
	  | xsltproc ../gnusflashes.xslt - > $@
	cvs $(CVSOPTS) ci -m "Automatic update of the GNUs flashes." $@



# The command sequence we use to add non-existant files to CVS.
define addfile
[ -f $@ ] || ( touch $@ ; cvs $(CVSOPTS) add $@ )
endef

# End.
