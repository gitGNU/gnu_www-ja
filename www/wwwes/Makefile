# Authors: Loic Dachary <loic@gnu.org> and Jaime Villate <villate@gnu.org>
# Modified for GNU Spain by Jose E. Marchesi <jemarch@gnu.org>
#



XSLTPROC = sabcmd

GNUES = http://www.es.gnu.org
FSFFRANCE = http://france.fsfeurope.org
FSFEUROPE = http://www.fsfeurope.org
FSF       = http://www.fsf.org
GNU       = http://www.gnu.org

ECHO	  = echo 
SSH	  = ssh

XSLTOPTS = \
	'$$fsffrance=$(FSFFRANCE)' \
	'$$fsf=$(FSF)' \
	'$$gnu=$(GNU)' \
	'$$gnues=$(GNUES)'

PAGES = $(shell find * -path "fr" -prune -o -regex '[^\.]*\.xhtml' -print | sed "s/xhtml$$/html/")


all: $(PAGES)

$(PAGES): %.html: %.xhtml gnues.xsl 
	@$(ECHO) "Building $@ ..."; \
	path=$< ; \
	base=`expr $$path : '\(.*\).xhtml'` ; \
	filebase=`basename $$base` ; \
	dir=`dirname $$path` ; \
	$(XSLTPROC) gnues.xsl $$path `echo $$path | sed -e 's/xhtml/html/'` $(XSLTOPTS) '$$filebase='$$filebase  

# remove html files for which an xhtml version exists (exclude fr/)
clean:
	rm -f $(PAGES)

sync:
	(CVS_RSH=ssh ; cvs -z3 -q update -I "$(PAGES)" -dP)

