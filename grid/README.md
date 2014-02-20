
# Test Grid

This git repository contains OSM data files with valid and invalid data. It can
be used to test any OSM software.

## Organization of the Test Files

All test data is in the `data` directory. In it you'll find subdirectories for
different categories of tests. Below them there is a numbered directory for each
test.

Test data from different tests use different ID spaces and distinct geographic
areas. So when tests are used together their data must never interfere with
each other.

## Test Categories

* 1 - Basic geometries
* 7 - Multipolygon geometries

## Test Cases

Each test case is in its own directory. It contains the following files:

* `data.osm` - the test data itself
* `labels.osm` - labels for documentation of test cases in OSM format
* `README` - description of the test
* `result` - contains either the word "valid" or "invalid" to signify
  whether the data in the file is valid, ie it must be parseable by any OSM
  software, or invalid, in which case the handling of the data is unspecified.

## ID Space Used

OSM IDs in the tests are used as follows:

All IDs start with the three-digit test number, for instance 711. Nodes are
then numbered from 000, label nodes from 700, ways from 800 and relations from
900. So there are enough IDs in each test for 700 nodes, 100 label nodes,
100 ways, and 100 relations.

## Geometries

Node coordinates of one test category are always inside a bounding box with one
degree width and height. The position of the bounding box is given by the test
number.

Example: All tests numbered 7xx are inside the bounding box (7.0 7.0, 8.0 8.0).

Individual tests are inside those in a bounding box with 0.1 degree width and
height. They are arranged in a 10x10 square. So test 700 is in
(7.0 7.0, 7.1 7.1), 701 is in (7.1 7.0, 7.2 7.1), 710 is in (7.0 7.1, 7.1 7.2).

A script `bin/create_grid.sh` is provided that generates a grid of "tiles"
for those tests in spatialite format. The result can be used for instance as a
background layer in a GIS program.

## Label Nodes

Interesting points in the data can be labled by adding an optional `labels.osm`
file containing OSM nodes with a `label=*` tag. Test software is normally not
required to read these, but they can be used when visualizing tests for instance.

## Creating Tests

Unfortunately there is no easy way to create tests with JOSM or other software.
You just don't have enough control over the contents of the data file unless
you write it by hand.

The easiest way is probably something like this:
* draw the test case on a piece of paper with grid lines
* number all nodes
* number all used grid lines on x and y axis
* create directory for new test
* copy over `data.osm` from another test, globally search-and-replace test id
* add nodes, ways, relations as needed
* add `README` and `result` files

## License

All files are released into the public domain.

