#!/usr/local/bin/perl -w
# $Id: ftp_convert.pl,v 1.19 2011/02/28 23:45:28 karl Exp $
#
# Converts the FTP file to a html file - just prints on the standard out
# and it is the responsibility of who ever running this to redirect to a 
# flat_file. Also standard GNU HTML header and trailer needs to be added to
# this page. See the Makefile.
# 
# Original Script Written by joelh@gnu.org
#
# 01/02/1999 - Murali - Added support for http sites on the ftp list
#   Also fixed the bug with <tt></tt>
# 26/07/2010 - bjg - add rel="nofollow" to mirror links

use strict;

# State 0: Between paragraphs
# State 1: In paragraph
# State 2: In a bulleted list
my $state = 0;
my $printstr = "";
my $headlvl = 0;
my $start_of_ftp_list = 0;
my $last_place = "";
my $place = "";
my $ftpsite = "";
my $list_open = 0;
my $extra_bits = "";
my $actual_bits = "";
my $print_current_output = 1;
my @ftp_sites = ();

sub display_link {
  my ($url, $display) = @_;
  my $ret = "";
  $url =~ s/\)$//;  # omit the ) in url's
  $display = $url if !defined($display);
  if ($state == 1) {
      $ret = qq(<a href="$url">$display</a>);
  } else {
    # external links are nofollow by default to deter abuse
    $ret = qq(<a rel="nofollow" href="$url">$display</a>);
    if ($url =~ /alpha/) {
      # label alpha mirror sites for users; and don't put them on the
      # same line as the <li> so they will be omitted from mirmon.
      $ret = "(alpha)\n      $ret";
    }
  }
  return $ret;
}

$_ = <>;
die "Incorrect format, start with How to get." unless /^How to get/;

$state = 0;


while (<>) {
  # Take care of headers
  chomp;

  $print_current_output = 1;

  if (/^(\*+)\s*/) {
    $state = 0;
    $headlvl = length ($+) + 2;
    if ($headlvl >= 7) {
      die "Header depth exceeds HTML capabilities.";
    }
    $printstr = $';
    $printstr =~ s/(\b\S+\@\S\b)/&display_link($1)/eg;

    if ($printstr eq "GNU mirror list") {
      $start_of_ftp_list = 1;
      $last_place = "";
    } else {
      if ($start_of_ftp_list) {
        if ($list_open) {
          # that </li> is for Ukraine (the last $place, i.e., country)
          # then the </ul> is for Europe (the last continent)
          print " </ul></li> <!-- end of last place -->\n";
          print "</ul>       <!-- end of last country list -->\n";
          $list_open = 0;
        }
      }
      $start_of_ftp_list = 0;
    }
    (my $anchor_id = $printstr) =~ tr/ A-Z/_a-z/;
    print qq!\n<a id="$anchor_id"></a>\n!;
    print "<h$headlvl>$printstr</h$headlvl>\n";
    if ($start_of_ftp_list) {
      print "<!-- start of ftp -->\n";
    }
    $print_current_output = 0;
    next;
  }
   
  # Is this a blank line?
  if (/^\s*$/) {
    print "</ul>\n" if $state == 2;
    print "</p>\n" if $state == 1;
    $state = 0;
    next;
  }

  # Is this a text bulleted list?
  if (/^\t-/) {
    if ($state != 2) {
      print "<ul>\n";
      $state = 2;
    }
    print "  <li>";
    s/^\t-//;

    if (/http:\S+/) {
      s/(\b\S*http:\S*\b)([\.\s]*)/&display_link($1)."$2"/eg;
      next;
    }
    if (/ftp\.\S+/) {
      s/(ftp\.\S*[\[\]]*(?=\s))(\.*\s*)/&display_link("ftp:\/\/$1",$1)."$2"/eg;
      next;
    }
    next;
  }

  # Is this a filename sitting on its own?
  if (/^\t/) {
    if (/http:\S+/) {
      s/(\b\S*http:\S*\b)([\.\s]*)/&display_link($1)."$2"/eg;
      next;
    }
    if (/ftp\.\S+/) {
      s/(\b\S*ftp\.\S*[\[\]]*\b)(\.*\s*)/&display_link("ftp:\/\/$1",$1)."$2"/eg;
      next;
    }
    s:^\t(.*)$:<tt>$1</tt>:;
    next;
  }


  if ($start_of_ftp_list == 1) {
    if (/^(.+?):\s?$/) {
      # Continent
      if ($list_open) {
        print " </ul></li> <!-- end of last place -->\n";
        print "</ul><!-- end of continent -->\n";
        $list_open = 0;
      }
      $last_place = "";
      print "\n<h4>$1</h4>\n<ul>\n";
      $print_current_output = 0;
      next;
    }
  }

  if (/^(.+?)\s+\-\s+(\S+.*)$/) {
    # State (US) or country (everything else)
    $place = $1;
    @ftp_sites = ();
    @ftp_sites = split /,/,$2;

    if ((!$last_place) or ($place ne $last_place)) {
      if ($last_place) {
        if ($place ne $last_place) {
          $list_open = 0;
          print " </ul></li><!-- end of $last_place -->\n";
        }
      }
      $last_place = $place;
      $list_open = 1;
      print " <li>$place\n <ul>\n";
    }

    # seems to work better with each url as its own item.
    foreach $ftpsite (@ftp_sites) {
      print "  <li>";
      ($actual_bits,$extra_bits) = ($ftpsite =~ /(\S+)(.*$)/);
      if ($ftpsite =~ /((http|ftp):\S+)/) {
        print &display_link($1);
      } else {  # rsync or who-knows; not linkable
        my $val = $1;
        $val =~ s/\)$// if $val =~ /rsync/;
        print $val;
      }
      print "</li>\n";
    }
    $print_current_output = 0;
    next;
  }
    
  # Well, we've covered everything else... I guess this is text.
  # Now we add in URLs as necessary and send it off.
  if ($state == 0) {
    print "<p>\n";
    $state = 1;
  }

  if (/@/) {
    s/(\b\S+\@\S+\b)/&display_link("mailto:$1", "&lt;$1&gt;")/eg;
    next;
  }
  if (/http:\S+/) {
    s/(\b\S*http:\S*\b)([\.\s]*)/&display_link($1)."$2"/eg;
    next;
  }

  if (/ftp:\S+/) {
    s/(\b\S*ftp:\S*\b)([\.\s]*)/&display_link($1)."$2"/eg;
    next;
  } elsif (/ftp\.\S+/) {
    s/(\b\S*ftp\.\S*[\[\]]*\b)(\.*\s*)/&display_link("ftp:\/\/$1", $1)."$2"/eg;
    next;
  }

} continue {
   if ($print_current_output) {
    print "$_\n";
   }
}
