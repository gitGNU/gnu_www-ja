# Copyright (C) 2007, 2008, 2009, 2010, 2011,
#   2012, 2013, 2014, 2015, 2016 Free Software Foundation, Inc.

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
TEMPLATE_LINGUAS := af ar bg ca cs da de el es fa fr he hr id it ja ko lt ml \
                    nb nl pl pt-br ro ru sk sq sr sv ta tr uk zh-cn zh-tw

# TRANSLATORS: Add here your language code if you want PO files with wdiffs
# to previous msgids.
FUZZY_DIFF_LINGUAS := de es fr hr it ml nl pl ru

# List of articles for which GRACE do not apply; i.e. they are
# regenerated even if there are fuzzy strings.
no-grace-articles := home prep/ftp server/sitemap server/takeaction

# The English sitemap HTML file is generated automatically outside of GNUN.
# GNUN uses compendia automatically generated for this file when available.
sitemap := server/sitemap

# List of templates whose URLs are localized, but their "translations"
# are maintained without PO files.
localized-ssis :=	server/header server/head-include-1 \
			server/banner \
			server/html5-header server/html5-head-include-1 \
			server/footer server/generic

# List of mandatory templates (all %.$lang.po files are generated).
extra-templates :=	server/body-include-1 \
			server/body-include-2 \
			server/bottom-notes \
			server/footer-text \
			server/head-include-2 \
			server/outdated \
			server/top-addendum

# List of templates that are translated or not on the discretion
# of the respective team (the PO files are merged, but are not created).
optional-templates :=	education/education-menu \
			licenses/fsf-licensing \
			manual/allgnupkgs \
			philosophy/philosophy-menu \
			planetfeeds \
			server/fs-gang \
			server/home-pkgblurbs \
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
		graphics/gnu-and-freedo \
		graphics/gnu-post \
		graphics/umsa \
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
		prep \
		press \
		proprietary \
		server \
		server/source \
		server/standards \
		software \
		testimonials \
		thankgnus

ROOT :=	gnu-404 \
	home \
	keepingup

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

distros :=	common-distros \
		distros \
		free-distros \
		free-non-gnu-distros \
		free-system-distribution-guidelines \
		optionally-free-not-enough \
		screenshot \
		screenshot-gnewsense

doc :=	doc \
	other-free-books

education :=	edu-cases-argentina-ecen \
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
		freesoftware \
		fsf-in-german \
		gcc_audio \
		gcc \
		gingrinch \
		gnuemacs.acro.exp \
		gnuemacs \
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
		purchase.agreement \
		users-lightbulb

gnu :=		about-gnu \
		byte-interview \
		gnu \
		gnu-history \
		gnu-linux-faq \
		gnu-users-never-heard-of-gnu \
		initial-announcement \
		linux-and-gnu \
		manifesto \
		pronunciation \
		rms-lisp \
		thegnuproject \
		why-gnu-linux \
		why-programs-should-be-shared \
		yes-give-it-away

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
		bold-initiative-GNU-head \
		BVBN \
		bwcartoon \
		copyleft-sticker \
		digital-restrictions-management \
		dog \
		emacs-ref \
		freedom \
		free-software-dealers \
		french-motto \
		fromagnulinux \
		fsf-logo \
		FSFS-logo \
		gleesons \
		gnu-30 \
		gnu-alternative \
		gnu-and-tux-icon \
		gnu-ascii \
		gnu-ascii-liberty \
		gnu-ascii2 \
		gnu-born-free-run-free \
		gnu-head-luk \
		gnu-head-shadow \
		gnu-inside \
		gnu-jacket \
		gnu-slash-linux \
		gnubanner \
		gnuhornedlogo \
		gnulove \
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
		navaneeth-gnu \
		package-logos \
		philosophicalgnu \
		philosoputer \
		reiss-gnuhead \
		runfreegnu \
		santa-gnu \
		scowcroft \
		skwetu-gnu-logo \
		slickgnu \
		spiritoffreedom \
		stallman-as-saint-ignucius \
		supergnu-ascii \
		this-is-freedom-wallpaper \
		usegnu \
		wallpapers \
		whatsgnu \
		winkler-gnu

graphics/adrienne :=	index

graphics/bahlon :=	index

graphics/behroze :=	index

graphics/fsfsociety :=	fsfsociety

graphics/gnu-and-freedo :=	gnu-and-freedo

graphics/gnu-post :=	index

graphics/umsa :=	umsa

help :=		evaluation \
		gnu-bucks \
		gnu-bucks-recipients \
		help \
		help-hardware \
		linking-gnu

licenses :=	200104_seminar \
		210104_seminar \
		agpl-3.0 \
		autoconf-exception-3.0 \
		bsd \
		copyleft \
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
		license-compatibility \
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

manual :=	blurbs \
		manual

music :=	blues-song \
		emacsvsvi \
		free-birthday-song \
		free-software-song \
		gdb-song \
		music \
		till_there_was_gnu \
		whole-gnu-world \
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
		applying-free-sw-criteria \
		apsl \
		assigning-copyright \
		basic-freedoms \
		bdk \
		bill-gates-and-other-communists \
		boldrin-levine \
		bug-nobody-allowed-to-understand \
		can-you-trust \
		categories \
		censoring-emacs \
		compromise \
		computing-progress \
		contradictory-support \
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
		floss-and-foss \
		free-digital-society \
		free-doc \
		freedom-or-copyright \
		freedom-or-copyright-old \
		freedom-or-power \
		free-hardware-designs \
		free-open-overlap \
		free-software-even-more-important \
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
		imperfection-isnt-oppression \
		ipjustice \
		is-ever-good-use-nonfree-program \
		java-trap \
		javascript-trap \
		judge-internet-usage \
		keep-control-of-your-computing \
		kevin-cole-response \
		komongistan \
		kragen-software \
		latest-articles \
		lessig-fsfs-intro \
		lest-codeplex-perplex \
		limit-patent-effect \
		linux-gnu-freedom \
		loyal-computers \
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
		rms-nyu-2001-transcript \
		rms-on-radio-nz \
		rms-patents \
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
		surveillance-vs-democracy \
		technological-neutrality \
		the-danger-of-ebooks \
		the-law-of-success-2 \
		the-root-of-this-problem \
		third-party-ideas \
		trivial-patent \
		ubuntu-spyware \
		ucita \
		udi \
		university \
		uruguay \
		use-free-software \
		using-gfdl \
		vaccination \
		w3c-patent \
		wassenaar \
		whats-wrong-with-youtube \
		when-free-depends-on-nonfree \
		when-free-software-isnt-practically-superior \
		who-does-that-server-really-serve \
		why-audio-format-matters \
		why-call-it-the-swindle \
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

prep :=			ftp \
			index

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

proprietary :=	malware-adobe \
		malware-apple \
		malware-appliances \
		malware-games \
		malware-kindle-swindle \
		malware-microsoft \
		malware-mobiles \
		proprietary \
		proprietary-back-doors \
		proprietary-censorship \
		proprietary-coverups \
		proprietary-deception \
		proprietary-drm \
		proprietary-insecurity \
		proprietary-interference \
		proprietary-jails \
		proprietary-sabotage \
		proprietary-subscriptions \
		proprietary-surveillance \
		proprietary-tethers \
		proprietary-tyrants

server :=	08whatsnew \
		fsf-html-style-sheet \
		irc-rules \
		mirror \
		select-language \
		server \
		sitemap \
		takeaction \
		tasks

server/source :=	source

server/standards :=	README.editors \
			README.translations \
			webmaster-quiz

software :=	devel \
		for-ios \
		for-windows \
		free-software-for-education \
		gethelp \
		maintainer-tips \
		recent-releases \
		reliability \
		repo-criteria \
		repo-criteria-evaluation \
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
		2014supporters \
		2015supporters \
		2016supporters \
		2017supporters \
		thankgnus
