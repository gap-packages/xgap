#############################################################################
##
#W  sheet.gi                  	XGAP library                     Frank Celler
##
#H  @(#)$Id: sheet.gi,v 1.2 1997/12/08 21:48:12 frank Exp $
##
#Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
##
##  This  file contains all methods for  graphic sheets.
##


#############################################################################
##

#R  IsGraphicWindowRep  . . . . . . . . . . . . . . .  default representation
##
IsGraphicWindowRep := NewRepresentation(
    "IsGraphicWindowRep",
    IsComponentObjectRep and IsAttributeStoringRep,
    [ "name", "width", "height" ],
    IsGraphicWindow );


#############################################################################
##
#M  GraphicWindow( <catrep>, <name>, <width>, <height> ) a new graphic window
##
InstallMethod( GraphicWindow,
    true,
    [ IsObject,
      IsString,
      IsInt,
      IsInt ],
    0,

function( catrep, name, width, height )
    local   w,  id;

    # open a new window and store the identifier
    w := rec();
    w.name   := name;
    w.width  := width;
    w.height := height;
    Objectify( NewType( GraphicWindowsFamily, catrep ), w );
    
    # really create a window and store the id
    id := WcOpenWindow( name, width, height );
    SetWindowId( w, id );
    SetFilterObj( w, IsAlive );

    # store in list of windows
    #N XXX StoreWindow(w);

    # return the window <w>
    return w;

end );


#############################################################################
##
#M  ViewObj( <window> ) . . . . . . . . . . . . pretty print a graphic window
##
InstallMethod( ViewObj,
    "for graphic window",
    true,
    [ IsGraphicWindow and IsGraphicWindowRep ],
    0,

function( win )
    if HasIsAlive(win)  then
        Print( "<graphic sheet \"", win!.name, "\">" );
    else
        Print( "<dead graphic sheet>" );
    fi;
end );
    

#############################################################################
##

#R  IsGraphicSheetRep . . . . . . . . . . . . . . . .  default representation
##
IsGraphicSheetRep := NewRepresentation(
    "IsGraphicSheetRep",
    IsGraphicWindowRep,
    [ "objects", "free" ],
    IsGraphicSheet );


#############################################################################
##
#M  GraphicSheet( <name>, <width>, <height> ) . . . . . . a new graphic sheet
##
InstallMethod( GraphicSheet,
    true,
    [ IsString,
      IsInt,
      IsInt ],
    0,

function( name, width, height )
    local   w,  defaults;

    # open a new graphic sheet and store the identifier
    w := GraphicWindow( IsGraphicSheet and IsGraphicSheetRep,
                        name, width, height );

    # there are no objects right now
    w!.objects := [];
    w!.free    := [];

    # no fast update
    ResetFilterObj( w, UseFastUpdate );

    # set defaults for color, line width, shape
    defaults       := rec();
    defaults.color := COLORS.black;
    defaults.width := 1;
    defaults.shape := 1;
    defaults.label := false;
    SetDefaultsForGraphicObject( w, defaults );

    # add menu to close GraphicSheet
    #N XXX MakeGAPMenu(w);

    # add close function
    #N XXX InstallCallback( w, "Close", Ignore );

    # return the graphic sheet <w>
    return w;

end );


#############################################################################
##
#M  Close( <sheet> )  . . . . . . . . . . . . . . . . . . close graphic sheet
##
InstallMethod( Close,
    "for graphic sheet",
    true,
    [ IsGraphicSheet and IsGraphicSheetRep ],
    0,

function( sheet )
    local   obj;

    #N XXX Callback( sheet, "Close" );
    ResetFilterObj( sheet, IsAlive );
    WcCloseWindow(WindowId(sheet));
    for obj  in sheet.objects  do
        ResetFilterObj( obj, IsAlive );
    od;
end );


#############################################################################
##

#E  sheet.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
