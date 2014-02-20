#!/bin/sh
#
#  show-tests.sh
#

find data -mindepth 2 -maxdepth 2 -type d | sort | cut -d/ -f2,3 | sed -e 's/\// /' | sed -e 's/-/ /'

