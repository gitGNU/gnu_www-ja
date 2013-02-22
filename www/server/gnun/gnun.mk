# Copyright (C) 2007, 2008, 2009, 2010, 2011,
#   2012, 2013 Free Software Foundation, Inc.

# This file is part of GNUnited Nations.

# GNUnited Nations is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.

# GNUnited Nations is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with GNUnited Nations. If not, see <http://www.gnu.org/licenses/>.

# TRANSLATORS: Add here your language code.  Please keep the
# alphabetical order.
TEMPLATE_LINGUAS := af ar bg ca cs de el es fa fr he id it ja ko ml nb nl pl \
                    pt-br ro ru sk sq sr sv ta tr uk vi zh-cn zh-tw

# TRANSLATORS: Add here your language code if you want PO files with wdiffs
# to previous msgids.
FUZZY_DIFF_LINGUAS := de es fr it nl pl ru

# List of articles for which GRACE do not apply; i.e. they are
# regenerated even if there are fuzzy strings.
no-grace-articles := home server/sitemap server/takeaction

# The English sitemap HTML file is generated automatically outside of GNUN.
# GNUN uses compendia automatically generated for this file when available.
sitemap := server/sitemap

# List of mandatory templates (all %.$lang.po files are generated).
extra-templates := philosophy/philosophy-menu \
		   server/body-include-1 \
		   server/body-include-2 \
		   server/bottom-notes \
		   server/footer-text \
		   server/head-include-2 \
		   server/outdated \
		   server/skip-translations \
		   server/top-addendum

# List of templates that are translated or not on the discretion
# of the respective team (the PO files are merged, but are not created).
optional-templates := planetfeeds \
		      software/recent-releases-include

# List of articles for which VALIDATE has no full effect; i.e. the
# HTML files are never validated.
#no-validate-articles :=   fry/happy-birthday-to-gnu \
#                          education/education \
#                          education/edu-software-gimp

ALL_DIRS :=	accessibility \
		award \
		award/1998 \
		award/1999 \
		award/2000 \
		award/2001 \
		award/2002 \
		award/2003 \
		bulletins \
		contact \
		copyleft \
		distros \
		doc \
		education \
		education/misc \
		encyclopedia \
		events \
		fry \
		fun \
		fun/jokes \
		gnu \
		graphics \
		graphics/adrienne \
		graphics/bahlon \
		graphics/behroze \
		graphics/fsfsociety \
		graphics/gnu-post \
		help \
		licenses \
		licenses/old-licenses \
		links \
		manual \
		music \
		people \
		philosophy \
		philosophy/economics_frank \
		philosophy/sco \
		press \
		pronunciation \
		server \
		server/source \
		server/standards \
		software \
		testimonials \
		thankgnus

ROOT := gnu-404 \
		home \
		keepingup \
		provide

accessibility :=	accessibility

award :=	award \
		award-1998 \
		award-1999

award/1998 :=	finalists \
		nominees

award/1999 :=	1999

award/2000 :=	2000

award/2001 :=	2001

award/2002 :=	2002

award/2003 :=	2003 \
		2003-call

bulletins :=	bulletins \
		thankgnus-index

contact :=	contact \
		gnu-advisory

copyleft :=	copyleft

distros :=	common-distros \
		distros \
		free-distros \
		free-system-distribution-guidelines \
		optionally-free-not-enough \
		screenshot

doc :=	doc \
	other-free-books

education :=    edu-cases-argentina-ecen \
		edu-cases-argentina \
		edu-cases-india-ambedkar \
		edu-cases-india-irimpanam \
		edu-cases-india \
		edu-cases \
		edu-contents \
		edu-faq \
		edu-projects \
		edu-resources \
		edu-schools \
		edu-software-gcompris \
                edu-software-gimp \
		edu-software-tuxpaint \
		edu-software \
		edu-system-india \
		edu-team \
		edu-why \
		education

education/misc :=    edu-misc

encyclopedia :=	encyclopedia \
		free-encyclopedia

events :=	dinner-20030807 \
		events \
		first-assoc-members-meeting \
		nyc-2004-01 \
		porto-tech-city-2001 \
		rms-nyu-2001-transcript \
		sco_without_fear \
		usenix-2001-lifetime-achievement

fry :=	happy-birthday-to-gnu \
	happy-birthday-to-gnu-credits \
	happy-birthday-to-gnu-download \
	happy-birthday-to-gnu-in-your-language \
	happy-birthday-to-gnu-sfd-kaffeine \
	happy-birthday-to-gnu-sfd-mplayer \
	happy-birthday-to-gnu-sfd-totem \
	happy-birthday-to-gnu-sfd-vlc \
	happy-birthday-to-gnu-sfd-xine \
	happy-birthday-to-gnu-translation

fun :=	humor

fun/jokes :=	10-kinds-of-people \
		anagrams \
		any-key \
		brainfuck \
		bug.war \
		c+- \
		clinton.tree \
		courtroom.quips \
		deadbeef \
		declarations \
		dna \
		doctor.manifesto \
		echo-msg \
		ed \
		ed-msg \
		errno.2 \
		error-haiku \
		eternal-flame \
		evilmalware \
		filks \
		foreign-signs \
		freesoftware \
		fsf-in-german \
		gcc_audio \
		gcc \
		gingrinch \
		gnuemacs.acro.exp \
		gnuemacs \
		gnu.jive \
		gnu-overflow \
		gnu-song \
		gospel \
		gullibility.virus \
		hackersong \
		hackforfreedom \
		hakawatha \
		hap-bash \
		happy-new-year \
		helloworld \
		hello_world_patent \
		know.your.sysadmin \
		last.bug \
		linus-islam \
                long-options \
                merry-xmas \
                nobody-owns \
		purchase.agreement

gnu :=		about-gnu \
		byte-interview \
		gnu \
		gnu-history \
		gnu-linux-faq \
		gnu-users-never-heard-of-gnu \
		initial-announcement \
		linux-and-gnu \
		manifesto \
		rms-lisp \
		thegnuproject \
		why-gnu-linux

graphics :=	3dbabygnutux \
		3dgnuhead \
		agnubody \
		agnuhead \
		agnuheadterm \
		ahurdlogo \
		alternative-ascii \
		anfsflogo \
		anlpflogo \
		anothertypinggnu \
		atypinggnu \
		avatars \
		babygnu \
		bokma-gnu \
		bwcartoon \
		digital-restrictions-management \
		emacs-ref \
		freedom \
		fromagnulinux \
		fsf-logo \
		FSFS-logo \
		gleesons \
		gnu-alternative \
		gnu-ascii \
		gnu-ascii-liberty \
		gnu-ascii2 \
		gnu-jacket \
		gnu-slash-linux \
		gnubanner \
		gnuolantern \
		gnupascal \
		gnupumpkin \
		gnusvgart \
		graphics \
		groff-head \
		heckert_gnu \
		hitflip-gnu \
		httptunnel-logo \
		hurd_mf \
		jesus-cartoon \
		kafa \
		license-logos \
		listen \
		meditate \
		nandakumar-gnu \
		package-logos \
		philosophicalgnu \
		philosoputer \
		reiss-gnuhead \
		slickgnu \
		spiritoffreedom \
		supergnu-ascii \
		usegnu \
		wallpapers \
		whatsgnu \
		winkler-gnu

graphics/adrienne :=	index

graphics/bahlon :=	index

graphics/behroze :=	index

graphics/fsfsociety :=	fsfsociety

graphics/gnu-post :=	index

help :=		evaluation \
		gethelp \
                gnu-bucks \
                gnu-bucks-recipients \
		help \
		help-hardware \
		linking-gnu

licenses :=	200104_seminar \
		210104_seminar \
		agpl-3.0 \
		exceptions \
		fdl-1.3 \
		fdl-1.3-faq \
		fdl-howto \
		fdl-howto-opt \
		gcc-exception-3.0 \
		gcc-exception-3.1 \
		gcc-exception-3.1-faq \
		gpl-3.0 \
		gpl-faq \
		gpl-howto \
		gpl-violation \
		gplv3-the-program \
		hessla \
		javascript-labels \
		javascript-labels-rationale \
		lgpl-3.0 \
		lgpl-java \
		license-list \
		license-recommendations \
		licenses \
		NYC_Seminars_Jan2004 \
		quick-guide-gplv3 \
		recommended-copylefts \
		rms-why-gplv3 \
		translations \
		why-affero-gpl \
		why-assign \
		why-gfdl \
		why-not-lgpl

licenses/old-licenses :=	fdl-1.1 \
				fdl-1.1-translations \
				fdl-1.2-translations \
				fdl-1.2 \
				gcc-exception-translations \
				gpl-1.0 \
				gpl-2.0 \
				gpl-2.0-faq \
				gpl-2.0-translations \
				lgpl-2.0 \
				lgpl-2.1 \
				lgpl-2.1-translations \
				old-licenses

links :=	companies \
		links

manual :=	manual

music :=	blues-song \
		emacsvsvi \
		free-software-song \
		gdb-song \
		music \
		till_there_was_gnu \
		writing-fs-song

people :=	past-webmasters \
		people \
		speakers \
		webmeisters

philosophy := 	15-years-of-free-software \
		amazon \
		amazon-nat \
		amazon-rms-tim \
		android-and-users-freedom \
		anonymous-response \
		apsl \
		assigning-copyright \
		basic-freedoms \
		bdk \
		boldrin-levine \
		bsd \
		bug-nobody-allowed-to-understand \
		can-you-trust \
		categories \
		censoring-emacs \
		compromise \
		computing-progress \
		copyright-and-globalization \
		copyright-versus-community \
		copyright-versus-community-2000 \
		correcting-france-mistake \
		danger-of-software-patents \
		dat \
		digital-inclusion-in-freedom \
		dmarti-patent \
		drdobbs-letter \
		ebooks \
		ebooks-must-increase-freedom \
		eldred-amicus \
		enforcing-gpl \
		essays-and-articles \
		europes-unitary-patent \
		fighting-software-patents \
		fire \
		free-digital-society \
		free-doc \
		freedom-or-copyright \
		freedom-or-copyright-old \
		freedom-or-power \
		free-software-for-freedom \
		free-software-intro \
		free-sw \
		free-world \
		free-world-notes \
		fs-motives \
		fs-translations \
		funding-art-vs-funding-software \
		gates \
		gif \
		gnutella \
		google-engineering-talk \
		government-free-software \
		gpl-american-dream \
		gpl-american-way \
		greve-clown \
		guardian-article \
		hague \
		historical-apsl \
		ICT-for-prosperity \
		ipjustice \
		java-trap \
		javascript-trap \
		judge-internet-usage \
		keep-control-of-your-computing \
		kevin-cole-response \
		kragen-software \
		latest-articles \
		lessig-fsfs-intro \
		lest-codeplex-perplex \
		limit-patent-effect \
		linux-gnu-freedom \
		luispo-rms-interview \
		mcvoy \
		microsoft \
		microsoft-antitrust \
		microsoft-new-monopoly \
		microsoft-old \
		microsoft-verdict \
		misinterpreting-copyright \
		moglen-harvard-speech-2004 \
		motif \
		ms-doj-tunney \
		my_doom \
		netscape \
		netscape-npl \
		netscape-npl-old \
		network-services-arent-free-or-nonfree \
		new-monopoly \
		nit-india \
		no-ip-ethos \
		no-word-attachments \
		nonfree-games \
		nonsoftware-copyleft \
		not-ipr \
		open-source-misses-the-point \
		opposing-drm \
		ough-interview \
		patent-practice-panel \
		patent-reform-is-not-enough \
		philosophy \
		pirate-party \
		plan-nine \
		practical \
		pragmatic \
		privacyaction \
		programs-must-not-limit-freedom-to-run \
		proprietary-sabotage \
		proprietary-surveillance \
		protecting \
		public-domain-manifesto \
		push-copyright-aside \
		reevaluating-copyright \
		rieti \
		right-to-read \
		rms-aj \
		rms-comment-longs-article \
		rms-hack \
		rms-interview-edinburgh \
		rms-kol \
		rms-on-radio-nz \
		rtlinux-patent \
		savingeurope \
		second-sight \
		self-interest \
		selling \
		selling-exceptions \
		shouldbefree \
		social-inertia \
		software-libre-commercial-viability \
		software-literary-patents \
		software-patents \
		speeches-and-interview \
		stallman-kth \
		stallman-mec-india \
		stallmans-law \
		stophr3028 \
		sun-in-night-time \
		the-danger-of-ebooks \
		the-law-of-success-2 \
		the-root-of-this-problem \
		third-party-ideas \
		trivial-patent \
                ubuntu-spyware \
		ucita \
		udi \
		university \
		use-free-software \
		using-gfdl \
		vaccination \
		w3c-patent \
		wassenaar \
		when_free_software_isnt_practically_better \
		who-does-that-server-really-serve \
		why-audio-format-matters \
		why-copyleft \
		why-free \
		wipo-PublicAwarenessOfCopyright-2002 \
		words-to-avoid \
		wsis \
		wsis-2003 \
		x \
		your-freedom-needs-free-software

philosophy/economics_frank :=	frank

philosophy/sco :=	questioning-sco \
			sco \
			sco-gnu-linux \
			sco-preemption \
			sco-v-ibm \
			sco-without-fear \
			subpoena

press :=		2001-07-09-DotGNU-Mono \
			2001-07-20-FSF-India \
			2001-09-18-RTLinux \
			2001-09-24-CPI \
			2001-10-12-bayonne \
			2001-10-22-Emacs \
			2001-12-03-Takeda \
			2002-02-16-FSF-Award \
			2002-02-26-MySQL \
			2002-03-01-pi-MySQL \
			2002-03-18-digitalspeech \
			2002-03-19-Affero \
			press

pronunciation :=	pronunciation

server :=	08whatsnew \
		fsf-html-style-sheet \
		irc-rules \
		mirror \
		server \
		sitemap \
		takeaction \
		tasks

server/source :=	source

server/standards :=	README.editors \
			README.translations \
			webmaster-quiz

software :=	devel \
		for-windows \
		recent-releases \
		reliability \
		software \
		year2000 \
		year2000-list

testimonials :=	reliable \
		supported \
		testimonial_cadcam \
		testimonial_HIRLAM \
		testimonial_media \
		testimonial_mondrup \
		testimonial_research_ships \
		testimonials \
		useful

thankgnus :=	1997supporters \
		1998supporters \
		1999 \
		1999supporters \
		2000supporters \
		2001supporters \
		2002supporters \
		2003supporters \
		2004supporters \
		2005supporters \
		2006supporters \
		2007supporters \
		2008supporters \
		2009supporters \
		2010supporters \
		2011supporters \
		2012supporters \
		2013supporters \
		thankgnus
