dnl #########################################################################
dnl ##
dnl ## check for a unique program in the source directory
dnl ##

AC_INIT
AC_CONFIG_SRCDIR([xgap.c])
AC_CONFIG_AUX_DIR(../cnf)


dnl #########################################################################
dnl ##
dnl ## create a config file from "config.hin"
dnl ##

AC_CONFIG_HEADERS([config.h:../cnf/config.hin])


dnl #########################################################################
dnl ##
dnl ## check for compiler features
dnl ##

AC_PROG_CC
AC_PROG_CC_C_O
AC_C_CONST


dnl #########################################################################
dnl ##
dnl ## find a canonical name for the system
dnl ##

AC_CANONICAL_TARGET


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


dnl #########################################################################
dnl ##
dnl ## Ignore --with-gaproot coming from parent configure script
dnl ##

AC_ARG_WITH(gaproot, [], [])



dnl #########################################################################
dnl ##
dnl ## generate a makefile
dnl ##

AC_CONFIG_FILES([Makefile:../cnf/Makegap.in])
AC_OUTPUT
