.SUFFIXES = .txt .html
.PHONY: localurl

SUBDIRS =

HTML_FILES = index.html

all : localurl ${HTML_FILES}

publish : weburl ${HTML_FILES}

weburl :
	@rm -f localurl *.html

clean :
	rm -f *~ *.html localurl

%.html : %.txt *.xsl
	@if [ -e localurl ]; then \
	  echo "(local)" $< "-->" $@; \
	  txt2xhtml --local $<; \
	else \
	  echo "(website)" $< "-->" $@; \
	  txt2xhtml $<; \
	fi
	@rm $*.xhtml

localurl :
	@if [ -e localurl ] && [ "$$(cat localurl)/fr@" = $$(pwd)@ ]; then \
	  echo localurl = $$(cat localurl); \
	else \
	  pwd > localurl; \
	  sed "s@\(<xsl:param name=\"edu-fr\">\).*\(</xsl:param>\)@\1$$(cat localurl)\2@" edu-fr.xsl > edu-fr.local.xsl; \
	fi
