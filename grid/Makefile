
# You need osmium tool from https://github.com/osmcode/osmium-tool for this
OSMIUM := ../../osmium-tool/osmium

.PHONY: grid data all clean

all: grid data

grid: grid.db

grid.sql: data/?-*
	bin/create-grid.sh `find data -mindepth 1 -maxdepth 1 -type d | cut -d/ -f2 | cut -d- -f1 | sort` >$@

grid.db: grid.sql
	rm -f $@
	spatialite -batch -bail $@ <$<

data: data/all.osm

data/all.osm: data/*/*/data.osm
	$(OSMIUM) cat data/*/*/*.osm --overwrite --generator=testdata --output-header=xml_josm_upload=false --output=data/all.osm

show:
	bin/show-tests.sh

clean:
	rm -f grid.db grid.sql
	rm -f data/all.osm

