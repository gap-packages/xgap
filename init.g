#############################################################################
##
#W  init.g                      XGAP library                     Frank Celler
##
#H  @(#)$Id: init.g,v 1.9 2003/05/17 12:05:29 gap Exp $
##
#Y  Copyright (C) 1993,  Lehrstuhl D fuer Mathematik,  RWTH, Aachen,  Germany
##

last := 0;    # to make GAP happy when this package is autoloaded

DeclarePackage("xgap","4.17",ReturnTrue);
DeclarePackageAutoDocumentation( "xgap", "doc" );

#############################################################################
##
#F  read1.g . . . . . . . . . . . . . . . . . . . . . . . . . . . basic stuff
##
ReadPkg( "xgap", "lib/read1.g" ); 


#############################################################################
##

#E  init.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

