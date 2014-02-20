
# OpenStreetMap Test Data Repository

OpenStreetMap data can be quite complex and software using the data difficult
to test. This git repository contains various pieces of OSM data to be used for
testing OSM software. The data is collected at this one location to help all
OSM software projects. Whether and how the tests are performed has to be
decided by each project.

## The Test Grid

The `grid` directory contains OSM data organized by test category into a "grid".
The tests are organized cleanly so that they can be easily used from automated
tests.

## Other Tests

Other tests that don't fit into the "grid" schema is currently collected in the
`misc` directory. In the future these tests might be organized better, as they
are, they are not really that useful for automated tests.

## License

All files are released into the public domain.

## Author

This repository was created and is maintained by Jochen Topf. Please use github
issues to report bugs and request changes. Or better, send pull requests.

