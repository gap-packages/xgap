#!/bin/sh
#
# Regenerate configure from configure.ac. Requires GNU autoconf.
set -ex
autoconf -Wall -f

cd cnf
autoheader -Wall -f
autoconf -Wall -f
sed -E -e 's%^srcdir=$%srcdir=../../src.x11%' < configure > configure.out

chmod 755 configure.out
rm configure
