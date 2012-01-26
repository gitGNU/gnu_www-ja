#! /bin/sh
# cvsrepo - change the repository location of a checked-out CVS module
#
# This script was written by a famous, but anonymous hacker.  I just
# named, de-Bashified, and documented it.
#
# - Gordon Matzigkeit <gord@gnu.org>, 1999-12-06

progname=`echo "$0" | sed 's%^.*/%%'`
help="Type \`$progname --help' for more information."
ROOT=
MODULE=
TOPDIR=

for arg
do
 case "$arg" in
 --help | --hel | --he | --h)
  cat <<EOF
Usage: $progname [OPTION]... ROOT MODULE [TOPDIR]

Modify the repository root and module name of a currently checked-out
CVS tree.

    --help           display this message and exit

ROOT is the new CVS repository root directory.

MODULE is the name of the module in the new CVS repository.

TOPDIR is the top of the checkout directory [default=MODULE].

Example: $progname :gserver:subversions.gnu.org:/home/cvs grub
EOF
  exit 0
  ;;

 -*)
  echo "$progname: unrecognized option \`$arg'" 1>&2
  echo "$help" 1>&2
  exit 1
  ;;

 *)
  if test -z "$ROOT"; then
   ROOT="$arg"
  elif test -z "$MODULE"; then
   MODULE="$arg"
  elif test -z "$TOPDIR"; then
   TOPDIR="$arg"
  else
   echo "$progname: too many arguments" 1>&2
   echo "$help" 1>&2
   exit 1
  fi
  ;;
 esac
done

if test -z "$ROOT"; then
 echo "$progname: you must specify a ROOT" 1>&2
 echo "$help" 1>&2
 exit 1
fi
if test -z "$MODULE"; then
 echo "$progname: you must specify a MODULE" 1>&2
 echo "$help" 1>&2
 exit 1
fi
test -z "$TOPDIR" && TOPDIR="$MODULE"

echo "Converting \`$TOPDIR'"
rep=`echo "$ROOT" | sed 's/.*://'`
find "$TOPDIR" \( -name Repository -o -name Root \) -print | while read f; do

 case "$f" in
 /*|./*|../*)
  echo "$progname: TOPDIR must be a relative path from the top of the checkout"\
 1>&2
  echo "$help" 1>&2
  exit 1
  ;;
 esac

 case "$f" in
 */CVS/Root) echo "$ROOT" > $f ;;
 */CVS/Repository)
  r=`echo "$f" | sed "s%^$TOPDIR%%"`
  r=`echo "$MODULE$r" | sed 's%/CVS/Repository$%%'`
  echo "$rep/$r" > "$f"
  ;;
 esac

done

exit 0
