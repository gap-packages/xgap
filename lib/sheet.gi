#############################################################################
##
#W  sheet.gi                  	XGAP library                     Frank Celler
##
#H  @(#)$Id: sheet.gi,v 1.5 1998/03/06 13:15:02 gap Exp $
##
#Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
##
##  This file contains all methods for graphic sheets.
##  The low level window functions are in `window.g'.
##  The menu functions are in `menu.g'.
##

##
Revision.pkg_xgap_lib_sheet_gi :=
    "@(#)$Id: sheet.gi,v 1.5 1998/03/06 13:15:02 gap Exp $";


#############################################################################
##

#R  IsGraphicWindowRep  . . . . . . . . . . . . . . .  default representation
##
DeclareRepresentation( "IsGraphicWindowRep",
    IsComponentObjectRep and IsAttributeStoringRep,
    [ "name", "width", "height", "gapMenu", "callbackName", "callbackFunc",
      "menus" ],
    IsGraphicWindow );


#############################################################################
##
#V  DefaultGAPMenu  . . . . . . . . . . . . . . . . . . . .  default GAP menu
##
GMCloseGS := function( sheet, menu, entry ) Close(sheet); end;

InstallValue( DefaultGAPMenu,
[
    "save",                   Ignore,
    "save as",                Ignore,
    ,                         ,
    "save as postscript",     Ignore, #N XXX GMSaveAsPS,
    "save as LaTeX",          Ignore,
    ,                         ,
    "close graphic sheet",    GMCloseGS,
] );


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
    WcStoreWindow( id, w );

    # store list of callbacks
    w!.callbackName := [];
    w!.callbackFunc := [];

    # add menu to close GraphicSheet
    w!.menus := [];
    MakeGAPMenu(w);

    # return the window <w>
    return w;

end );


#############################################################################
##
#M  Callback( <window>, <func>, <args> )  . . . . execute a callback function
##
InstallMethod( Callback,
    "for graphic window",
    true,
    [ IsGraphicWindow and IsGraphicWindowRep,
      IsObject,
      IsList ],
    0,

function( window, func, args )
    local   p,  list,  f;

    p := Position( window!.callbackName, func );
    if p <> fail  then
        list := window!.callbackFunc[p];
        for f  in list  do
            CallFuncList( f, args );
        od;
    fi;
end );


#############################################################################
##
#M  Close( <window> ) . . . . . . . . . . . . . . . . . . close graphic sheet
##
InstallMethod( Close,
    "for graphic window",
    true,
    [ IsGraphicWindow and IsGraphicWindowRep ],
    0,

function( window )
    Callback( window, Close, [ window ] );
    ResetFilterObj( window, IsAlive );
    WcCloseWindow(WindowId(window));
end );


#############################################################################
##
#M  InstallCallback( <window>, <func>, <call> ) . . . .  install new callback
##
InstallMethod( InstallCallback,
    "for graphic window",
    true,
    [ IsGraphicWindow and IsGraphicWindowRep,
      IsObject,
      IsFunction ],
    0,

function( window, func, call )
    local   p,  list;

    p := Position( window!.callbackName, func );
    if p <> fail  then
        list := window!.callbackFunc[p];
        Add( list, call );
    else
        Add( window!.callbackName, func   );
        Add( window!.callbackFunc, [call] );
    fi;
end );


#############################################################################
##
#M  MakeGAPMenu( <window> ) . . . . . . . . . . . . .  create a standard menu
##
InstallMethod( MakeGAPMenu,
    "for graphic window",
    true,
    [ IsGraphicWindow and IsGraphicWindowRep ],
    0,

function( sheet )
    sheet!.gapMenu := Menu( sheet, "GAP", DefaultGAPMenu );
    Enable( sheet!.gapMenu, "save", false );
    Enable( sheet!.gapMenu, "save as", false );
    Enable( sheet!.gapMenu, "save as LaTeX", false );
end );


#############################################################################
##
#M  Resize( <window>, <width>, <height> ) . . . . . . . . . . .  resize sheet
##
InstallMethod( Resize,
    "for graphic window",
    true,
    [ IsGraphicWindow and IsGraphicWindowRep,
      IsInt,
      IsInt ],
    0,

function( window, width, height )
    WcResizeWindow( WindowId(window), width, height );
    window!.height := height;
    window!.width  := width;
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
    if IsAlive(win)  then
        Print( "<graphic window \"", win!.name, "\">" );
    else
        Print( "<dead graphic window>" );
    fi;
end );


#############################################################################
##

#R  IsGraphicSheetRep . . . . . . . . . . . . . . . .  default representation
##
DeclareRepresentation( "IsGraphicSheetRep",
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

    Callback( sheet, Close, [ sheet ] );
    ResetFilterObj( sheet, IsAlive );
    WcCloseWindow(WindowId(sheet));
    for obj  in sheet!.objects  do
        ResetFilterObj( obj, IsAlive );
    od;
end );


#############################################################################
##
#M  ViewObj( <sheet> )  . . . . . . . . . . . .  pretty print a graphic sheet
##
InstallMethod( ViewObj,
    "for graphic sheet",
    true,
    [ IsGraphicSheet and IsGraphicWindowRep ],
    0,

function( sheet )
    if IsAlive(sheet)  then
        Print( "<graphic sheet \"", sheet!.name, "\">" );
    else
        Print( "<dead graphic sheet>" );
    fi;
end );


#############################################################################
##
#M  Delete( <sheet>, <obj> )  . . . . . . . . . . . . delete <obj> in <sheet>
##
InstallMethod( Delete,
    "for graphic sheet, and object",
    true,
    [ IsGraphicSheet and IsGraphicWindowRep, IsGraphicObject ],
    0,
function( sheet, obj )
    local   pos;

    # find position of object
    pos := Position( sheet!.objects, obj );

    # destroy object
    Destroy(obj);

    # and remove it from the list of objects
    Unbind(sheet!.objects[pos]);
    Add( sheet!.free, pos );

end );


#############################################################################
##

#E  sheet.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

