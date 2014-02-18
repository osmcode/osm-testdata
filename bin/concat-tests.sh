#!/bin/sh

OSMIUM=../osmium-tool/osmium

rm -f data/all.osm && $OSMIUM cat data/*/*/*.osm -o data/all.osm

