%{ 
Converted to 2.2.6 by Miquel Vidal <miquel@barrapunto.com> (Dec 3, 2004)
%}
\version "2.2.0"

\header {
	filename = "free-software.ly"
	title = "La canción del software libre"
	enteredby = "David Madore"
%	language = "spanish"
%    inputencoding = "latin1"

 arranger = "La melodía es la de la canción popular búlgara ``Sadi Moma''."

 tagline = "Copyright \copyright~1993 Richard Stallman

 Se permite la reproducción literal por cualquier 
 medio, siempre que se mantenga esta nota.

 Escrito en GNU LilyPond por David Madore. \LaTeX eado y 
 convertido a la versión 2.2 de Lilypond para la edición de Traficantes de
 Sueños por Miquel Vidal."


}

%{
About the following two comments: I don't know how to get this Lilypond
to insert them in the LaTeX output.  I'm inserting them manually in the
titledefs file.  (Somebody *please* tell me a better way.)
          -- David Madore <david.madore@ens.fr>
%}

%{
Changed a syllabification a little, converted to 1.3.122  (feb 18, 2001)

Han-Wen Nienhuys <hanwen@cs.uu.nl> 
%}

%{
To the melody of Sadi Moma.
%}

%{
Copyright \copyright 1993 Richard Stallman

Verbatim copying and distribution of this entire score is permitted
in any medium, provided this notice is preserved.

Typeset by David Madore using GNU Lilypond.
%}

firstVoice = \notes \relative c' {
	\time 7/4
	\clef violin
	d'2 c4 b2 a2
	b2 c4 b4 ( a4) g2
	g2. a2. ( b4)
	c2. b2 b4  ( d4)
	a2. a1
	c2 ( d4 c4  b2.)
	d2 c4 b2 a2
	b2 c4 b4 ( a4) g2
	g2. a2. ( b4)
	c2. b2 b4 ( d4)
	a2. a1
	a1..
}

secondVoice = \notes \relative c' {
	\time 7/4
	\clef violin
	b'2 a4 g2 d2
	g2 g4 g2 d2
	g2. g1
	g2. g2 g2
	d2. d1
	g1..
	b2 a4 g2 d2
	g2 g4 g2 d2
	g2. g1
	g2. g2 g2
	d2. d1
	e1..
}

wordsOne = \lyrics {
	Join4 us now and
	share the so -- ftware
	You'll be
	free ha -- ckers,
	you'll be
	free  __
	Join us now and
	share the so -- ftware
	You'll be --
	free ha -- ckers,
	you'll be
	free.
}

wordsTwo = \lyrics {
	Hoar -- ders may get
	piles of mo --  ney,
	That is 
	true, ha -- ckers,
	that is
	true __
	But they can -- not
	help their neigh -- bors
	That's not __
	good, ha -- ckers,
	that's not
	good.
}

wordsThree = \lyrics {
	When we have e -- nough free so -- ftware 
	At our,
	call, ha -- ckers,
	at our
	call, __
	We'll kick out those
	dir -- ty li -- cen -- ces
	E -- ver more, ha -- ckers,
	E -- ver more.
}

\score {
	% exposes spacing bug in 1.3.129
	
	% \context StaffGroup
	<<
	 \addlyrics
		\context Staff = SA <<
			\set Staff.instrument = "whistle"
	               \unset Staff.melismaBusyProperties 

			\firstVoice
		>>
		<<		
		\context Lyrics = LA \wordsOne 
		\context Lyrics = LB \wordsTwo 
		\context Lyrics = LC \wordsThree
		>>
		\context Staff = SB <<
			\set Staff.instrument = "orchestral strings"
			\secondVoice
		>>
	>>
	\paper {
	#(set-paper-size "a4")
 	indent = 0
	linewidth = 150.00 \mm
	pagenumber = no
	\context { \StaffGroupContext
		\consists "Bar_engraver"
	} }
	
	\midi { \tempo 2 = 75 }
}
