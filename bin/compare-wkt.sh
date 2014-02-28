#!/bin/sh
#
#  compare-wkt.sh WKT1 WKT2
#
#  Compares the two geometries given on the command line.
#
#  Outputs "OK" or "ERR" to show whether the test succeeded or failed together
#  with some more information in parenthesis.
#
#  Returns
#  0 - if they are identical
#  1 - if they are geometrically equivalent
#  2 - if they are different
#  3 - at least one of the geometries is broken
#
#  Instead of a WKT geometry the string "INVALID" can also be given which only
#  compares equal to another "INVALID".
#

set -e

WKT1=$1
WKT2=$2

#OK="OK"
#ERR="ERR"

OK="\033[1;32mOK\033[0m"
ERR="\033[1;31mERR\033[0m"

if [ "$WKT1" = "$WKT2" ]; then
    echo "$OK  (identical)"
    exit 0
fi

if [ "$WKT1" = "INVALID" -o "$WKT2" = "INVALID" ]; then
    echo "$ERR (one is invalid)"
    exit 2
fi

result=`echo "SELECT Equals(GeomFromText('$WKT1', 4326), GeomFromText('$WKT2', 4326));" | spatialite -batch -bail tmp$$.db 2>/dev/null | tail -1`
rm -f tmp$$.db

if [ "$result" = "1" ]; then
    echo "$OK  (equal)"
    exit 1
fi

if [ "$result" = "0" ]; then
    echo "$ERR (different)"
    exit 2
fi

echo "$ERR (failure)"
exit 3

