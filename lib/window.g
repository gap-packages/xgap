#############################################################################
##
#W  window.g                  	XGAP library                     Frank Celler
##
#H  @(#)$Id: window.g,v 1.3 1997/12/08 21:48:13 frank Exp $
##
#Y  Copyright 1993-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
##
Revision.pkg_xgap_lib_window_g :=
    "@(#)$Id: window.g,v 1.3 1997/12/08 21:48:13 frank Exp $";


#############################################################################
##

#F  WcOpenWindow( <name>, <width>, <height> ) . . . . . . . . . . open window
##
WcOpenWindow := function( name, width, height )
    return WindowCmd([ "XOW", name, width, height ])[1];
end;


#############################################################################
##

#F  window.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
