#############################################################################
##
#W  window.g                  	XGAP library                     Frank Celler
##
#H  @(#)$Id: window.g,v 1.4 1997/12/09 12:37:11 frank Exp $
##
#Y  Copyright 1993-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
##
Revision.pkg_xgap_lib_window_g :=
    "@(#)$Id: window.g,v 1.4 1997/12/09 12:37:11 frank Exp $";


#############################################################################
##
#F  WcStoreWindow( <id>, <w> )	. . . . . . . . . . . . . store window object
##
WcStoreWindow := function( id, w )
    WINDOWS[id+1] := w;
end;

#############################################################################
##

#F  WcCloseWindow( <id> ) . . . . . . . . . . . . . . . . . . .  close window
##
WcCloseWindow := function( id )
    Unbind(WINDOWS[id+1]);
    WindowCmd([ "XCW", id  ]);
end;


#############################################################################
##
#F  WcOpenWindow( <name>, <width>, <height> ) . . . . . . . . . . open window
##
WcOpenWindow := function( name, width, height )
    return WindowCmd([ "XOW", name, width, height ])[1];
end;


#############################################################################
##
#F  WcResizeWindow( <id>, <width>, <height> ) . . . . . . . . . resize window
##
WcResizeWindow := function( id, width, height )
    WindowCmd([ "XRE", id, width, height ]);
end;


#############################################################################
##

#F  window.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
