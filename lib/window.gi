#############################################################################
##
#W  window.gi                 	XGAP library                     Frank Celler
##
#H  @(#)$Id: window.gi,v 1.1 1997/12/05 17:32:04 frank Exp $
##
#Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
##


#############################################################################
##

#M  ViewObj( <sheet> )  . . . . . . . . . . . .  pretty print a graphic sheet
##
InstallMethod( Close,
    "for graphic sheet",
    [ IsGraphicSheet and IsGraphicSheetRep and IsAlive ],
    0,

function( sheet )
    Print( "<graphic sheet \"", sheet.name, "\">" );
end );
    

#############################################################################
##
#M  Resize( <window>, <width>, <height> ) . . . . . . . . . . . resize window
##
InstallMethod( Resize,
    "for graphic window",
    [ IsGraphicWindow and IsGraphicWindowRep,
      IsInt,
      IsInt ],
    0,

function( window, width, height )
    WcResizeWindow( window.id, width, height );
    window!.height := height;
    window!.width  := width;
end;

    
#############################################################################
##

#E  window.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
