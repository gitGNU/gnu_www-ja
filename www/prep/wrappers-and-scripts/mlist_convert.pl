#!/usr/bin/perl -w

# Perl script to generate HTML version of MAILINGLIST
# Author : Murali

use strict;
#use FileHandle;

# State 0: Between paragraphs
# State 1: In paragraph
# State 2: In a bulleted list
my $state = 0;
my $headlvl = 0;
my $inpfilename=0;
my $start_of_mailing_list=0;
my $section_name='';
my @toc_array=();
my $tmp_file_name='';
my $line='';


$tmp_file_name="/tmp/mlist$$";

open TMPOUTFILE, "> $tmp_file_name" or die "Cannot open output file : $! \n";

$state = 1;


while (<>) {
    # Take care of headers
		chomp;

    if ($. == 1)
    {
       if ($ARGV =~ /MAILINGLIST*/)
       {
           print STDERR "Processing Mailing List\n";
       }
       $inpfilename=$ARGV;
       
    }

		if (/^Last Updated (\d{4}-\d{2}-\d{2})/)
		{
			print TMPOUTFILE "<!-- Last updated $+ -->\n";
			next;
    }


		if (/^(\*+)\s*/)
		{
		 $state=0;
		 $headlvl=length $1;
		 if ($headlvl >= 7) 
		 {
		   die "Header depth exceeds HTML capabilities.";
		 }
     $section_name=$';

     if (($section_name =~ /Mailing list archives/) && ($headlvl == 1))
     {
          $start_of_mailing_list=1;
     }

     if (! $start_of_mailing_list)
     {
		   if ($headlvl == 1)
			 {
			   push @toc_array,$_;
			 }
		   print TMPOUTFILE "<A NAME=\"$&$'\"><H$headlvl>$'</H$headlvl></A>\n";
     }
     else
     {
			 if ($headlvl == 1)
			 {
			   push @toc_array,$_;
		   	 print TMPOUTFILE "<A NAME=\"$_\"><H$headlvl>$section_name</H$headlvl></A>\n";
       }
			elsif ($headlvl == 2) 
		  {
			   push @toc_array,$_;
				 print TMPOUTFILE "<A NAME=\"$'\"><H$headlvl>$section_name</H$headlvl></A>\n";
      }
			else
			{
				 print TMPOUTFILE "<H$headlvl>$'</H$headlvl>\n";
			 }
     }
		if (/@/)
		{
			s/(\b\S+\@\S+\b?)/<A HREF="mailto:$1">$1<\/A>/g;
		}
     next;
    }

		if (/@/)
		{
			s/(\b\S+\@\S+\b?)/<A HREF="mailto:$1">$1<\/A>/g;
		}
		if (/http:\S+/)
		{
			s/(\b\S*)(http:\S*\b)([\.\s]*)/<A HREF="$2">$1$2<\/A>$3/g;
		}
		if (/ftp:\S+/)
		{
			s/(\b\S*)(ftp:\S*\b)([\.\s]*)/<A HREF="$2">$1$2<\/A>$3/g;
		}
		if (/ftp\.\S+/)
		{
			s/(\b\S*)(ftp\.\S*[\[\]]*\b)(\.*\s*)/<A HREF="ftp:\/\/$2">$1$2<\/A>$3/g;
		}
		if (/newsgroup:\s+\S+\..*/)
		{
      s/(\bnewsgroup:\s+)(\S*\b)(\.*\s*)/$1<A HREF="news:\/\/$2">$2<\/A>$3/g;
		}

			
    # Is this a blank line?
    if (/^\s*$/) 
		{
			print TMPOUTFILE "</UL>\n" if $state == 2;
			$state = 0;
    }

    # Is this a text bulleted list?
    if (/^\s-/) 
		{
			if ($state != 2) 
			{
				print TMPOUTFILE "<UL>\n";
				$state = 2;
			}
			print TMPOUTFILE "  <LI>";
			s/^\s-//;
    }
    elsif (/^\s+\S/) 
		{
      # Is this a filename sitting on its own?
			s:^\s(.*)$:<BR><tt>$1</tt>:;
    }

		if (/(See section ')(.*)'/)
		{
		  s/(See section ')(.*)'/$1<A HREF="#$2">$2<\/A>'/;
		}

    # Well, we've covered everything else... I guess this is text.
    # Now we add in URLs as necessary and send it off.
    if ($state == 0) 
		{
				print TMPOUTFILE "<P>";
				$state = 1;
    }

    print TMPOUTFILE "$_\n"
} 


# Print the Table of Contents 

$state=1;
printf "<H2>Table of Contents</H2>\n";
printf "<MENU>\n";
foreach $section_name (@toc_array)
{
  if ($section_name =~ /^(\* )(.*)$/)
	{
	  print "<LI><A HREF=\"#$section_name\">$2</A></LI>\n";
	}
	elsif ($section_name =~ /^(\*\* )(.*)$/)
	{
	  if ($state == 1)
		{
		  printf "<MENU>\n";
			$state=0;
		}
	  print "<LI><A HREF=\"#$2\">$2</A></LI>\n";
	}
}

if ($state == 0)
{
   print "</MENU>\n";
}
print "</MENU>\n";


open (TMPOUTFILE, "$tmp_file_name") or die "Cannot open File!! : $!\n";

while (<TMPOUTFILE>)
{
   printf "$_\n";
}
close(TMPOUTFILE) or printf "File Closure error : $!\n";


unlink $tmp_file_name or printf "Cannot unlink $tmp_file_name : $!\n";

