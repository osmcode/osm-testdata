
# You need osmium tool from https://github.com/osmcode/osmium-tool for this
OSMIUM := ../../osmium-tool/osmium

.PHONY: grid data all clean

all: grid data

grid: grid.db

grid.sql: data/?-* bin/create-grid.sh
	bin/create-grid.sh `find data -mindepth 1 -maxdepth 1 -type d | cut -d/ -f2 | cut -d- -f1 | sort` >$@

data-nodes.sql: data/*/*/out.wkt
	grep --no-filename POINT $^ | sed -re "s/^([0-9]+) (.*)/INSERT INTO nodes (id, geom) VALUES (\1, PointFromText('\2', 4326));/" >$@

data-ways.sql: data/*/*/out.wkt
	grep --no-filename LINESTRING $^ | sed -re "s/^([0-9]+) (.*)/INSERT INTO ways (id, geom) VALUES (\1, LineFromText('\2', 4326));/" >$@

labels.sql: data/*/*/labels.wkt
	cat $^ | sed -re "s/^(POINT\([0-9. ]+\)) (.*)/INSERT INTO labels (label, geom) VALUES ('\2', PointFromText('\1', 4326));/" >$@

grid.db: grid.sql data-nodes.sql data-ways.sql labels.sql
	rm -f $@
	cat $^ | spatialite -batch -bail $@

data: data/all.osm

data/all.osm: data/*/*/data.osm
	$(OSMIUM) cat data/*/*/*.osm --overwrite --generator=testdata --output-header=xml_josm_upload=false --output=data/all.osm

show:
	bin/show-tests.sh

clean:
	rm -f grid.db grid.sql
	rm -f data/all.osm

