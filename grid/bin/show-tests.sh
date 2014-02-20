#!/bin/sh
#
#  show-tests.sh
#

set -e

tests=`find data -mindepth 2 -maxdepth 2 -type d | sed -s 's/data\///' | sort`

for t in $tests; do
    cat_no=${t%%-*}
    cat_name_test_id=${t#*-}
    cat_name=${cat_name_test_id%/*}
    test_id=${t#*/}
    if [ -f data/$t/README ]; then
        description=`cat data/$t/README`
    else
        description="NO README"
    fi
    if [ -f data/$t/result ]; then
        result=`cat data/$t/result`
    else
        result="UNKNOWN RESULT"
    fi
    echo "$cat_no $cat_name\t$test_id\t$result\t$description"
done

