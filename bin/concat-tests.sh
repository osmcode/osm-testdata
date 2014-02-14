#!/bin/sh

OSMIUM=../osmium-tool/osmium

rm -f data/all.osm && $OSMIUM cat data/*/*/data.osm -o data/all.osm

