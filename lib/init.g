#############################################################################
##
#W  init.g                      XGAP library                     Frank Celler
##
#H  @(#)$Id: init.g,v 1.4 1998/03/06 13:14:56 gap Exp $
##
#Y  Copyright (C) 1993,  Lehrstuhl D fuer Mathematik,  RWTH, Aachen,  Germany
##

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

#E  init.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

