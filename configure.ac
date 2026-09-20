AC_INIT
AC_CONFIG_SRCDIR([src.x11/xgap.c])
AC_CONFIG_HEADERS([config.h])
AC_PROG_CC
AC_PROG_MAKE_SET

######################################
# Find the GAP root directory by 
# checking for the sysinfo.gap file 
AC_MSG_CHECKING([for GAP root directory])
DEFAULT_GAPROOTS="../.."

#Allow the user to specify the location of GAP
#
AC_ARG_WITH(gaproot, 
  [AS_HELP_STRING([--with-gaproot=<path>], [specify root of GAP installation])],
  [DEFAULT_GAPROOTS="$withval"])

havesysinfo=0
# Otherwise try likely directories
for GAPROOT in ${DEFAULT_GAPROOTS} 
do
  # Convert the path to absolute
  GAPROOT=`cd $GAPROOT > /dev/null 2>&1 && pwd`
  if test -e ${GAPROOT}/sysinfo.gap; then
    havesysinfo=1
    break
  fi
done
  
if test "x$havesysinfo" = "x1"; then
  AC_MSG_RESULT([${GAPROOT}])
else
  AC_MSG_RESULT([Not found])
  
  echo ""
  echo "********************************************************************"
  echo "  ERROR"
  echo ""
  echo "  Cannot find your GAP installation. Please specify the location of"
  echo "  GAP's root directory using --with-gaproot=<path>"
  echo ""
  echo "  The GAP root directory (as far as this package is concerned) is"
  echo "  the one containing the file sysinfo.gap and the subdirectories "
  echo "  src/ and bin/."
  echo "********************************************************************"
  echo ""
  
  AC_MSG_ERROR([Unable to find GAP root directory])
fi
      
gapdir=$GAPROOT
AC_SUBST(gapdir)

#####################################
# Now find the architecture
      
AC_MSG_CHECKING([for GAP architecture])
GAPARCH="Unknown"
. $GAPROOT/sysinfo.gap
if test "x$GAParch" != "x"; then
  GAPARCH=$GAParch
fi

AC_MSG_RESULT([${GAPARCH}])

if test "x$GAPARCH" = "xUnknown" ; then
  echo ""
  echo "********************************************************************"
  echo "  ERROR"
  echo ""
  echo "  Found a GAP installation at $GAPROOT but could not find"
  echo "  information about GAP's architecture in the"
  echo "  ${GAPROOT}/sysinfo.gap file."
  echo "  This file be present: please check your GAP installation."
  echo "********************************************************************"
  echo ""
  
  AC_MSG_ERROR([Unable to find plausible GAParch information.])
fi  
AC_SUBST(GAPARCH)
dnl #########################################################################
dnl ##
dnl ## check for timing functions
dnl ##

AC_CHECK_HEADERS_ONCE([sys/time.h])


dnl #########################################################################
dnl ##
dnl ## check for fork, wait, execute functions
dnl ##

AC_HEADER_SYS_WAIT


dnl #########################################################################
dnl ##
dnl ## check for tty and pseudo tty functions
dnl ##

# openpty() is available on various BSD variants, but also in glibc.
# On BSD systems, one usually needs to add -lutil to LIBS in order
# to use it.
AC_SEARCH_LIBS([openpty], [util],
    AC_DEFINE([HAVE_OPENPTY], [1], [define as 1 if you have `openpty']))

AS_IF([test "x$ac_cv_search_openpty" = xno],[
  # Check for POSIX 98 pty APIs to use instead of openpty()
  AC_CHECK_FUNCS([ptsname grantpt unlockpt posix_openpt])
],[
  # Check for headers declaring openpty()
  AC_CHECK_HEADERS([util.h pty.h libutil.h])
])


dnl #########################################################################
dnl ##
dnl ## check for tty and pseudo tty functions
dnl ##

AC_CHECK_HEADERS( sgtty.h termios.h termio.h sys/ioctl.h sys/select.h )


dnl #########################################################################
dnl ##
dnl ## check for signal handling
dnl ##

AC_CHECK_HEADERS( signal.h sys/signal.h )
AC_CHECK_FUNCS( signal )


dnl #########################################################################
dnl ##
dnl ## check for directory handling
dnl ##

AC_HEADER_DIRENT
AC_FUNC_CLOSEDIR_VOID


dnl #########################################################################
dnl ##
dnl ## checks where the X11 libraries (this should be the last test)
dnl ##

AC_PATH_XTRA

if test "$have_x" != yes;  then
    AC_MSG_ERROR([XGAP needs XWindows X11R5 or later including the
    development files like header files, usually you can install these
    using the package manager of your operating system. For debian-derived
    Linux distributions these packages are called
        libx11-dev
        libxaw7-dev
        libxt-dev
    Note that depending on your operating system, these packages could
    be called differently.])
fi


AC_CONFIG_FILES([Makefile xgap.sh])
AC_CONFIG_COMMANDS([default],[chmod +x xgap.sh],[])
AC_OUTPUT
