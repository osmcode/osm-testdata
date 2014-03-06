#!/bin/sh
#
#  compare-geometries.sh REFERENCE-DATA-FILE TEST-DATA-FILE
#
#  Compare lists of geometries. All geometries from the
#  reference data file are checked against geometries in the
#  test data file. One line per reference geometry is output
#  containing the id of the OSM object the geometry was
#  generated from (way or relation), the word "OK" or "ERR"
#  in green or red, respectively, and in square brackets
#  the results for each of the variants in the reference
#  data file.
#
#  More detailed (debug) output can be found in the file
#  compare-geometries.out.
#

#set -e

compare_wkt=`dirname $0`/compare-wkt.sh
reference_data_file=$1
test_data_file=$2

OUT_FILE="compare-geometries.out"

rm -f $OUT_FILE

cut -d' ' -f1 $reference_data_file | uniq | while read id; do
    echo -n "$id... ";
    echo "==================\n$id:" >>$OUT_FILE
    out=$(egrep "^$id " $reference_data_file | while read id stype variant wkt_ref; do
        wkt_test=`grep from_id=$id $test_data_file | cut -d' ' -f4-`
        result=`$compare_wkt "$wkt_ref" "$wkt_test" 2>>$OUT_FILE`
        echo -n " [$variant: $result]"
    done)
    if echo $out | egrep ' OK' >/dev/null; then
        echo -n "\033[1;32mOK\033[0m  "
    else
        echo -n "\033[1;31mERR\033[0m "
    fi
    echo $out
done

