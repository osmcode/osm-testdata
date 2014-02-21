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

cat << EOF
--
--  Automatically created with create-grid.sh
--

PRAGMA synchronous = OFF;

CREATE TABLE grid (
    test_id     INTEGER NOT NULL PRIMARY KEY,
    available   INTEGER,
    result      VARCHAR,
    description VARCHAR
);
SELECT AddGeometryColumn('grid', 'geom', 4326, 'POLYGON', 2);

CREATE TABLE titles (
    title       VARCHAR
);
SELECT AddGeometryColumn('titles', 'geom', 4326, 'LINESTRING', 2);

CREATE TABLE nodes (
    id INTEGER NOT NULL PRIMARY KEY
);
SELECT AddGeometryColumn('nodes', 'geom', 4326, 'POINT', 2);

CREATE TABLE ways (
    id INTEGER NOT NULL PRIMARY KEY
);
SELECT AddGeometryColumn('ways', 'geom', 4326, 'LINESTRING', 2);

CREATE TABLE labels (
    label VARCHAR
);
SELECT AddGeometryColumn('labels', 'geom', 4326, 'POINT', 2);

EOF

for t in $*; do
    title=`echo data/$t-* | cut -d/ -f2`
    echo "INSERT INTO titles (title, geom) VALUES ('${title}', LineFromText('LINESTRING(${t}.0 2.1,${t}.9999 2.1)', 4326));\n"
    for y in `seq 0 9`; do
        for x in `seq 0 9`; do
            if [ -d data/$t-*/$t$y$x ]; then
                available=1
                if [ -f data/$t-*/$t$y$x/result ]; then
                    result=`cat data/$t-*/$t$y$x/result`
                else
                    result=""
                fi
                if [ -f data/$t-*/$t$y$x/README ]; then
                    description=`cat data/$t-*/$t$y$x/README`
                else
                    description=""
                fi
            else
                available=0
                result=""
                description=""
            fi
            echo "INSERT INTO grid (test_id, geom, available, result, description) VALUES ($t$y$x, Envelope(LineFromText('LINESTRING(${t}.${x} 1.${y},${t}.${x}9999 1.${y}9999)', 4326)), ${available}, '${result}', '${description}');"
        done
        echo
    done
done

