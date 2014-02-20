
all: grid.db data/all.osm

grid.db: data/?-*
	bin/create-grid.sh `find data -mindepth 1 -maxdepth 1 -type d | cut -d/ -f2 | cut -d- -f1 | sort`

data/all.osm: data/*/*/data.osm
	bin/concat-tests.sh

