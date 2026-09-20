#!/bin/sh
#
# Regenerate configure and config.h.in from configure.ac. Requires GNU
# autoconf.
set -ex
autoheader -Wall -f
autoconf -Wall -f
