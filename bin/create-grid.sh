#!/bin/sh
#
#  create-grid.sh TEST-CATEGORY...
#
#  Create "grid" of polygons showing the areas of the tests.
#
#  Call with the numbers of the test categories the grid
#  shall show, for instance:
#
#  bin/create-grid.sh 1 7
#

DATABASE=grid.db

rm -f $DATABASE

(cat << EOF
CREATE TABLE grid (
    test_id   INTEGER NOT NULL PRIMARY KEY,
    available INTEGER,
    result    VARCHAR
);
SELECT AddGeometryColumn('grid', 'geom', 4326, 'POLYGON', 2);
EOF

for t in $*; do
    for y in `seq 0 9`; do
        for x in `seq 0 9`; do
            if [ -d data/$t-*/$t$y$x ]; then
                available=1
                result=`cat data/$t-*/$t$y$x/result`
            else
                available=0
                result=""
            fi
            echo "INSERT INTO grid (test_id, geom, available, result) VALUES ($t$y$x, Envelope(LineFromText('LINESTRING(${t}.${x} ${t}.${y},${t}.${x}9999 ${t}.${y}9999)', 4326)), ${available}, '${result}');"
        done
    done
done) | spatialite $DATABASE >/dev/null 2>&1

