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
    local   str,  i,  menu;

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
    id := WcAddMenu( WindowId(window), title, str );
    menu!.title      := title;
    menu!.window      := window;
    menu!.labels     := Copy(lbs);
    menu!.entries    := Copy( Filtered( lbs, IsBound ) );

    SetFilterObj( menu, IsAlive );

    menu!.functions       := func;

    # return menu
    return menu;
    
end );

Menu := function( arg )
    local   window,  title,  lbs,  func,  str,  i,  menu;

    # check arguments
    window := arg[1];
    title := arg[2];
    if Length(arg) = 3  then
        lbs  := [];
        func := [];
        for i  in [ 1, 3 .. Length(arg[3])-1 ]  do
            if IsBound(arg[3][i])  then
                lbs[(i+1)/2] := arg[3][i];
                Add( func, arg[3][i+1] );
            fi;
        od;
    else
        lbs  := arg[3];
        func := arg[4];
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
    menu            := WcAddMenu( window, title, str );
    menu.title      := title;
    menu.window      := window;
    menu.labels     := Copy(lbs);
    menu.entries    := Copy( Filtered( lbs, IsBound ) );
    menu.isAlive    := true;
    menu.operations := MenuOps;

    # if function is a list, check its length
    if IsList(func)  then
        if Number(lbs) <> Length(func)  then
            Error( "need ", Length(lbs), " menu functions" );
        fi;
    fi;
    menu.func       := func;

    # return menu
    return menu;
    
end;


#############################################################################
##
#M  Check( <menu>, <entry>, <flag> )  . . . . . . . . . . .  check menu entry
##
InstallMethod( Check,
    "for menu",
    true,
    [ IsMenu and IsMenuRep,
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
#M  Delete( <menu> )  . . . . . . . . . . . . . . . . . . . . . delete a menu
##
InstallMethod( Delete,
    "for menu",
    true,
    [ IsMenu and IsMenuRep ],

function( menu )
    WcDeleteMenu( WindowId(menu), MenuId(menu) );
    ResetFilterObj( menu, IsAlive );
end;


#############################################################################
##
#M  Enable( <menu>, <entry>, <flag> ) . . . . . . . . . . . enable menu entry
##
InstallMethod( Enable,
    "for menu",
    true,
    [ IsMenu and IsMenuRep,
      IsString,
      IsBool ],
    0,

function( menu, entry, flag )
    local   pos;

    pos := Position( menu.entries, entry );
    if pos = fail  then
        Error( "unknown menu entry \"", entry, "\"" );
    fi;
    if flag  then
        WcEnableMenu( WindowId(menu), MenuId(menu), pos, 1 );
    else
        WcEnableMenu( WindowId(menu), MenuId(menu), pos, 0 );
    fi;
    
end;


