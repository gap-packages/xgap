#############################################################################
##
#W  init.g                      XGAP library                     Frank Celler
##
#H  @(#)$Id: init.g,v 1.3 1997/12/09 12:37:02 frank Exp $
##
#Y  Copyright (C) 1993,  Lehrstuhl D fuer Mathematik,  RWTH, Aachen,  Germany
##

#############################################################################
##

#V  WINDOWS . . . . . . . . . . . . . . . . . . . . . . . . . list of windows
##
WINDOWS := [];


#############################################################################
##

#F  ReadXGAP  . . . . . . . . . . . . . . . . . . . . read XGAP library files
##
ReadXGAP := ReadAndCheckFunc( "pkg/xgap/lib", "pkg_xgap_lib_" );


#############################################################################
##
#F  read1.g . . . . . . . . . . . . . . . . . . . . . . . . . . . basic stuff
##
ReadOrComplete( "pkg/xgap/lib/read1.g" );


#############################################################################
##

#F  init.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
