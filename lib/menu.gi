#############################################################################
##
#W  menu.gi                     XGAP library                     Frank Celler
##
#H  @(#)$Id: menu.gi,v 1.2 1998/03/06 13:14:59 gap Exp $
##
#Y  Copyright 1993-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
##
Revision.pkg_xgap_lib_menu_gi :=
    "@(#)$Id: menu.gi,v 1.2 1998/03/06 13:14:59 gap Exp $";


#############################################################################
##
#R  IsPulldownMenuRep( <obj> )
##
DeclareRepresentation( "IsPulldownMenuRep", IsAttributeStoringRep,
    [ "title", "window", "labels", "entries", "functions" ] );


#############################################################################
##
#M  WindowId( <menu> )  . . . . . . . . . . . . . . . . . . . . . .  for menu
##
InstallOtherMethod( WindowId,
    "for menu",
    true,
    [ IsMenu and IsPulldownMenuRep ],
    0,
    menu -> WindowId( menu!.window ) );


#############################################################################
##
#M  Menu( <window>, <title>, <ents>, <fncs> )  add a menu to a graphic window
##
InstallMethod( Menu,
    "for graphic window",
    true,
    [ IsGraphicWindow and IsGraphicWindowRep,
      IsString,
      IsList,
      IsList ],
    0,

function( window, title, lbs, func )
    local   str,  i,  id,  menu;

    # if function is a list, check its length
    if IsList(func)  then
        if Number(lbs) <> Number(func)  then
            Error( "need ", Length(lbs), " menu functions" );
        fi;
    fi;

    # create a string from <lbs>
    str := "";
    for i  in [ 1 .. Length(lbs)-1 ]  do
    	if IsBound(lbs[i])  then
            Append( str, lbs[i] );
            Append( str, "|" );
    	else
    	    Append( str, "-|" );
        fi;
    od;
    Append( str, lbs[Length(lbs)] );

    # create menu in <window>
    id := WcMenu( WindowId(window), title, str );

    menu:= Objectify( NewType( MenuFamily, IsMenu and IsPulldownMenuRep ),
                      rec() );

    menu!.title      := title;
    menu!.window     := window;
    menu!.labels     := ShallowCopy(lbs);
#T was `Copy'!
    menu!.entries    := Compacted( lbs );
#T was `Copy'!
    menu!.functions  := func;

    SetMenuId( menu, id );
    SetFilterObj( menu, IsAlive );

    # store the menu (`MenuSelected' needs this)
    window!.menus[id+1] := menu;

    # return menu
    return menu;

end );


#############################################################################
##
#M  Menu( <window>, <title>, <zipped> ) . . .  add a menu to a graphic window
##
InstallOtherMethod( Menu,
    "for graphic window (three arguments)",
    true,
    [ IsGraphicWindow and IsGraphicWindowRep,
      IsString,
      IsList ],
    0,

function( window, title, zipped )
    local i, lbs, func;

    # distribute labels and functions
    lbs  := [];
    func := [];
    for i  in [ 1, 3 .. Length(zipped)-1 ]  do
        if IsBound(zipped[i])  then
            lbs[(i+1)/2] := zipped[i];
            Add( func, zipped[i+1] );
        fi;
    od;

    # call the standard method
    return Menu( window, title, lbs, func );
end );


#############################################################################
##
#M  PrintObj( <menu> )  . . . . . . . . . . . . . . . . . pretty print a menu
##
InstallMethod( PrintObj,
    "for menu",
    true,
    [ IsMenu and IsPulldownMenuRep ],
    0,
function( menu )
    if IsAlive( menu ) then
        Print( "<menu \"", menu!.title, "\">" );
    else
        Print( "<dead menu>" );
    fi;
end );



#############################################################################
##
#M  Check( <menu>, <entry>, <flag> )  . . . . . . . . . . .  check menu entry
##
InstallMethod( Check,
    "for menu",
    true,
    [ IsMenu and IsPulldownMenuRep,
      IsString,
      IsBool ],
    0,

function( menu, entry, flag )
    local   pos;

    pos := Position( menu!.entries, entry );
    if pos = fail  then
        Error( "unknown menu entry \"", entry, "\"" );
    fi;
    if flag  then
        WcCheckMenu( WindowId(menu), MenuId(menu), pos, 1 );
    else
        WcCheckMenu( WindowId(menu), MenuId(menu), pos, 0 );
    fi;
end );


#############################################################################
##
#M  Destroy( <menu> )   . . . . . . . . . . . . . . . . . . .  destroy a menu
##
InstallOtherMethod( Destroy,
    "for menu",
    true,
    [ IsMenu and IsPulldownMenuRep ],
    0,

function( menu )
    WcDestroyMenu( WindowId(menu), MenuId(menu) );
    ResetFilterObj( menu, IsAlive );
end );


#############################################################################
##
#M  Enable( <menu>, <entry>, <flag> ) . . . . . . . . . . . enable menu entry
##
InstallMethod( Enable,
    "for menu",
    true,
    [ IsMenu and IsPulldownMenuRep,
      IsString,
      IsBool ],
    0,

function( menu, entry, flag )
    local   pos;

    pos := Position( menu!.entries, entry );
    if pos = fail  then
        Error( "unknown menu entry \"", entry, "\"" );
    fi;
    if flag  then
        WcEnableMenu( WindowId(menu), MenuId(menu), pos, 1 );
    else
        WcEnableMenu( WindowId(menu), MenuId(menu), pos, 0 );
    fi;

end );


#############################################################################
##
#F  MenuSelected( <wid>, <mid>, <eid> ) . . . . . . . menu selector, internal
##
InstallGlobalFunction( MenuSelected, function( wid, mid, eid )
    local   menu;

    menu := WINDOWS[wid+1]!.menus[mid+1];
    menu!.functions[eid](WINDOWS[wid+1], menu, menu!.entries[eid]);

end );


#############################################################################
##

#E  menu.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

