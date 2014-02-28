
# You need osmium tool from https://github.com/osmcode/osmium-tool for this
OSMIUM := ../../osmium-tool/osmium

SQL_FILES := grid.sql data-nodes.sql data-ways.sql data-multipolygons.sql data-labels.sql

.PHONY: grid data all clean show create-wkt

all: grid data

grid: grid.db

grid.sql: data/? bin/create-grid.sh
	bin/create-grid.sh `find data -mindepth 1 -maxdepth 1 -type d | cut -d/ -f2 | cut -d- -f1 | sort` >$@

data-nodes.sql: data/*/*/nodes.wkt
	cat $^ | sed -re "s/^([0-9][0-9][0-9])([0-9][0-9][0-9]) (.*)/INSERT INTO nodes (test_id, id, geom) VALUES (\1, \1\2, PointFromText('\3', 4326));/" >$@

data-ways.sql: data/*/*/ways.wkt
	cat $^ | sed -re "s/^([0-9][0-9][0-9])([0-9][0-9][0-9]) (.*)/INSERT INTO ways (test_id, id, geom) VALUES (\1, \1\2, LineFromText('\3', 4326));/" >$@

data-multipolygons.wkt: data/*/*/multipolygons.wkt
	cat $^ >$@

data-multipolygons.sql: data-multipolygons.wkt
	sed -re "s/^([0-9][0-9][0-9])([0-9][0-9][0-9]) ([wr]) ([^ ]*) (.*)/INSERT INTO multipolygons (test_id, id, from_type, variant, geom) VALUES (\1, \1\2, '\3', '\4', MultiPolygonFromText('\5', 4326));/" <$< >$@

data-labels.sql: data/*/*/labels.wkt
	cat $^ | sed -re "s/^(POINT\([0-9. ]+\)) (.*)/INSERT INTO labels (label, geom) VALUES ('\2', PointFromText('\1', 4326));/" >$@

grid.db: setup.sql $(SQL_FILES)
	rm -f $@
	cat $^ | spatialite -batch -bail $@

data: data/all.osm

data/all.osm: data/*/*/data.osm
	$(OSMIUM) cat data/*/*/*.osm --overwrite --generator=testdata --output-header=xml_josm_upload=false --output=data/all.osm

show:
	bin/show-tests.sh

create-wkt:
	bin/create-wkt.sh

clean:
	rm -f grid.db $(SQL_FILES) data-multipolygons.wkt data/all.osm tests.qgs~

