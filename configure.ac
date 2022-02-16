AC_INIT
AC_CONFIG_SRCDIR([configure])
gp_configure_options=$*
AC_CHECK_PROGS( MAKE, make )
if test -z "$MAKE";  then
AC_PATH_PROGS( MAKE, make, , /usr/ccs/bin )
fi
if test -z "$MAKE";  then
AC_MSG_ERROR([cannot find make])
fi
AC_SUBST(gp_configure_options)
AC_CONFIG_AUX_DIR([cnf])
AC_CANONICAL_TARGET
AC_PROG_CC
AC_PROG_MAKE_SET

#Allow the user to specify a configname:
AC_MSG_CHECKING([for CONFIGNAME])
AC_ARG_VAR(CONFIGNAME, [Set this to the CONFIGNAME of the GAP compilation
  against which you want to compile this package. Leave this
  variable empty for GAP versions < 4.5.])
if test "x$CONFIGNAME" = "x"; then
  SYSINFO="sysinfo.gap"
  AC_MSG_RESULT([none])
else
  SYSINFO="sysinfo.gap-$CONFIGNAME"
  AC_MSG_RESULT([$CONFIGNAME])
fi

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
  if test -e ${GAPROOT}/${SYSINFO}; then
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
. $GAPROOT/$SYSINFO
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
  echo "  ${GAPROOT}/${SYSINFO} file."
  echo "  This file be present: please check your GAP installation."
  echo "********************************************************************"
  echo ""
  
  AC_MSG_ERROR([Unable to find plausible GAParch information.])
fi  
AC_SUBST(GAPARCH)
AC_CONFIG_FILES([Makefile xgap.sh])
AC_CONFIG_COMMANDS([default],[chmod +x xgap.sh],[])
AC_OUTPUT
