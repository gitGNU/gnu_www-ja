# $Id: Makefile,v 1.7 2006/11/15 00:19:08 karl Exp $
# Makefile for text-to-html conversions in http://www.gnu.org/prep.
# See the gnustandards savannah project for how those pieces are updated.

RM              = rm -f
SED		= sed
ED		= /bin/sed

W = wrappers-and-scripts
FTPCONVPLSCRIPT = $W/ftp_convert.pl
MLISTCONVSCRIPT = $W/mlist_convert.pl

HTML_FILES = ftp.html

all: $(HTML_FILES)

clean:
	rm -f $(HTML_FILES)

ftp.html: FTP $(FTPCONVPLSCRIPT) $W/ftp-header.html $W/ftp-eof.html
	cat $W/ftp-header.html  > $@
	perl $(FTPCONVPLSCRIPT) FTP >> $@
	cat $W/ftp-eof.html >> $@

# the service page is maintained on fsf.org now.
#service.html: SERVICE $W/service-header.html $W/service-eof.html
#	cat $W/service-header.html	>  $@
#	$(SED)	-e 's/&/\&amp;/g' \
#		-e 's/</\&lt;/g' \
#		-e 's/>/\&gt;/g' \
#		-e 's/^[ \t]*\(\\|\^_\)[ \t]*$$/\<\/PRE\><HR\><PRE\>/' \
#		< SERVICE >> $@
# one of the ^_'s is the real character, the other is the two ASCII characters
# ^ and _.
#	echo '</PRE>'		>> $@
#	cat $W/service-eof.html	>> $@

# local variables:
# eval: (auto-fill-mode 0)
# eval: (make-local-variable 'compile-command)
# eval: (setq compile-command (concat "make -k -f " buffer-file-name))
# indent-line-function: indent-relative-maybe
# version-control: nil
# backup-by-copying: nil
# fill-column: 78
# end:
