# Make an XML list of items from a news database.
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


# README!!!
# You should run this with gawk since I use gawk extensions sometimes.


# We're not using this function right now because of issues with i18n
function parse_date (string)
{
  if ((( "date --iso-8601 -d '" string "'" ) | getline time_specified) > 0)
    return time_specified
  return -1
}


BEGIN {
  STARTED=0
  if (ENVIRON["ENCODING"] != "") {
    print "<?xml version='1.0' encoding='" ENVIRON["ENCODING"] "' ?>";
  }
  print "<items>"
}

# Skip comments
/^# .*$/ {
  next
}

# Find dates; this pattern has to be quite general to cope with i18n date forms
/^[0-9]+(.)* .*$/ {
  if (STARTED != 0) {
    print "</item>\n"
  }
  else {
    STARTED = 1
  }
   
  printf "<item>\n<date>" $0 "</date>\n";
  next
}

# Find GNUS Flashes dates; this is the same as the previous form except for the * at the start of the line.
# GNUS Flashes are news items that go on the home page as well as in whatsnew
/^\* [0-9]+(.)* .*$/ {
  if (STARTED != 0) {
    print "</item>\n"
  }
  else {
    STARTED = 1
  }
 
#  time = parse_date(substr($0, 3))
  printf "<item flash='yes'>\n<date>" substr($0, 3) "</date>\n"
  next
}

# Everything else is an item
/[^ \t].*/  {
  line = $0;
  # Read the following lines of the news item, till the first blank line.
  getline linevar;
  while (linevar !~ /^$/) {
    line = line " " linevar;
    getline linevar;
  }
  print "<news>" line "</news>\n"
}

# And then the end.
END {
  print "</item>\n</items>"
}

# The end.
