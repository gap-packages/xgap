#############################################################################
##
#W  window.g                  	XGAP library                     Frank Celler
##
#H  @(#)$Id: window.g,v 1.2 1997/12/05 17:30:46 frank Exp $
##
#Y  Copyright 1993-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
##
##  This files contains  the  low  level window   functions, the  high  level
##  functions are in "sheet.g".  The menu functions are in "menu.g".
##


#############################################################################
##
#V  WINDOWS . . . . . . . . . . . . . .  list of gap garphic sheets, internal
##
#if not IsBound(WINDOWS)  then WINDOWS := [];  fi;


#############################################################################
##
#V  SELECTORS . . . . . . . . . . . . . . .  list of text selectors, internal
##
#if not IsBound(SELECTORS)  then SELECTORS := [];  fi;


#############################################################################
##
#V  FONTS . . . . . . . . . . . . . . . . . . . . . . . . . . font dimensions
##
FONTS        := rec();
FONTS.tiny   := WindowCmd([ "XFI", 1 ]);
FONTS.small  := WindowCmd([ "XFI", 2 ]);
FONTS.normal := WindowCmd([ "XFI", 3 ]);
FONTS.large  := WindowCmd([ "XFI", 4 ]);
FONTS.huge   := WindowCmd([ "XFI", 5 ]);
FONTS.fonts  := [FONTS.tiny,FONTS.small,FONTS.normal,FONTS.large,FONTS.huge];


#############################################################################
##
#V  BUTTONS . . . . . . . . . . . . . . . . . . . . left/right pointer button
##
BUTTONS       := rec();
BUTTONS.left  := 1;
BUTTONS.right := 2;
BUTTONS.shift := 1;
BUTTONS.ctrl  := 2;


#############################################################################
##
#V  COLORS  . . . . . . . . . . . . . . . . . . . .  list of available colors
##
COLORS           := rec();
COLORS.model     := WindowCmd(["XCN"])[1];
COLORS.black     := 0;
COLORS.white     := 1;
COLORS.lightGray := false;
COLORS.dimGray   := false;
COLORS.red       := false;
COLORS.blue      := false;
COLORS.green     := false;

if COLORS.model = 1  then
    COLORS.model     := "monochrome";
elif COLORS.model = 2  then
    COLORS.model     := "gray";
    COLORS.lightGray := 2;
    COLORS.dimGray   := 3;
elif COLORS.model = 3  then
    COLORS.model     := "color3";
    COLORS.red       := 4;
    COLORS.blue      := 5;
    COLORS.green     := 6;
elif COLORS.model = 4  then
    COLORS.model     := "color5";
    COLORS.lightGray := 2;
    COLORS.dimGray   := 3;
    COLORS.red       := 4;
    COLORS.blue      := 5;
    COLORS.green     := 6;
fi;
COLORS.lightGrey := COLORS.lightGray;
COLORS.dimGrey   := COLORS.dimGray;


#############################################################################
##

#F  ButtonSelected( <sid>, <bid> )  . . . . . . . . button selected, internal
##
ButtonSelected := function( sid, bid )
    local   sel;
    
    sel := SELECTORS[sid+1];
    return sel.operations.ButtonPressed( sel, bid );
end;


#############################################################################
##
#F  Drag( <sheet>, <x>, <y>, <bt>, <func> ) . . . . . . . . .  drag something
##
Drag := function( sheet, x, y, bt, func )
    local   tmp;
    
    # wait for a small movement
    repeat
        tmp := WindowCmd([ "XQP", sheet.id ]);
        if tmp[3] <> bt  then return false;  fi;
    until 5 < AbsInt(x-tmp[1]) or 5 < AbsInt(y-tmp[2]);
    
    # now start dragging
    while true  do
        tmp := WindowCmd([ "XQP", sheet.id ]);
        if tmp[3] <> bt  then return true;  fi;
        if tmp[1] = -1  then tmp[1] := x;  fi;
        if tmp[2] = -1  then tmp[2] := y;  fi;
        if tmp[1] <> x or tmp[2] <> y  then
            func( tmp[1], tmp[2] );
            x := tmp[1];
            y := tmp[2];
        fi;
    od;
    
end;


#############################################################################
##
#F  MenuSelected( <wid>, <mid>, <eid> ) . . . . . . . menu selector, internal
##
MenuSelected := function( wid, mid, eid )
    local   menu;
    
    menu := WINDOWS[wid+1].menus[mid+1];
    if IsList(menu.func)  then
        return menu.func[eid]( WINDOWS[wid+1], menu, menu.entries[eid] );
    else
        return menu.func( WINDOWS[wid+1], menu, menu.entries[eid] );
    fi;
    
end;


#############################################################################
##
#F  PointerButtonDown( <wid>, <x>, <y>, <bt> )  . . . . button down, internal
##
PointerButtonDown := function( wid, x, y, bt )
    local    win,  qry;

    win := WINDOWS[wid+1];
    qry := WindowCmd([ "XQP", wid ]);
    return win.operations.PointerButtonDown( win, x, y, bt, qry[4] );

end;


#############################################################################
##
#F  TextSelected( <sid>, <tid> )  . . . . . . . . . . text selected, internal
##
TextSelected := function( sid, tid )
    local   sel;
    
    sel := SELECTORS[sid+1];
    return sel.operations.TextSelected( sel, tid );
end;


#############################################################################
##

#F  WcAddMenu( <win>, <title>, <str> )  . . . . . . .  add a menu to a window
##
WcAddMenu := function( win, title, str )
    local   id;

    id := WindowCmd([ "XME", win.id, title, str ])[1];
    win.menus[id+1] := rec( id := id, isMenu := true );
    return win.menus[id+1];
end;


#############################################################################
##
#F  WcCheckMenu( <wid>, <mid>, <pos>, <flag> )  . .  check/uncheck menu entry
##
WcCheckMenu := function( wid, mid, pos, flag )
    WindowCmd([ "XCM", wid, mid, pos, flag ]);
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
#F  WcDeleteMenu( <wid>, <mid> )  . . . . . . . . . . . . . . . delete a menu
##
WcDeleteMenu := function( wid, mid )
    WindowCmd([ "XDM", wid, mid ]);
end;


#############################################################################
##
#F  WcDestroy( <id>, <obj> )  . . . . . . . . . . destroy <obj> on sheet <id>
##
WcDestroy := function( arg )
    local   cmd;

    cmd := Concatenation( ["XRO"], arg );
    WindowCmd(cmd);
    
end;


#############################################################################
##
#F  WcDialog( <type>, <text>, <def> ) . . . . . . . . . . . . . . . .  dialog
##
WcDialog := function( type, text, def )
    return WindowCmd([ "XSD", type, text, def ]);
end;

#############################################################################
##
#F  WcDrawBox( <id>, <x1>, <y1>, <x2>, <y2> ) . . . . . . . . . .  draw a box
##
WcDrawBox := function( id, x1, y1, x2, y2 )
    return WindowCmd([ "XDB", id, x1, y1, x2, y2 ])[1];
end;


#############################################################################
##
#F  WcDrawCircle( <id>, <x>, <y>, <r> )	. . . . . . . . . . . . draw a circle
##
WcDrawCircle := function( id, x, y, r )
    return WindowCmd([ "XDC", id, x, y, r ])[1];
end;


#############################################################################
##
#F  WcDrawDisc( <id>, <x>, <y>, <r> ) . . . . . . . . . . . . . . draw a disc
##
WcDrawDisc := function( id, x, y, r )
    return WindowCmd([ "XDD", id, x, y, r ])[1];
end;


#############################################################################
##
#F  WcDrawLine( <id>, <x1>, <y1>, <x2>, <y2> )  . . . . . . . . . draw a line
##
WcDrawLine := function( id, x1, y1, x2, y2 )
    return WindowCmd([ "XDL", id, x1, y1, x2, y2 ])[1];
end;


#############################################################################
##
#F  WcDrawText( <id>, <fid>, <x>, <y>, <str> )	. . . . . . . . . draw a text
##
WcDrawText := function( id, fid, x, y, str )
    return WindowCmd([ "XDT", id, fid, x, y, str ])[1];
end;


#############################################################################
##
#F  WcEnableMenu( <wid>, <mid>, <pos>, <flag> ) . . . . en/disable menu entry
##
WcEnableMenu := function( wid, mid, pos, flag )
    WindowCmd([ "XEM", wid, mid, pos, flag ]);
end;


#############################################################################
##
#F  WcFastUpdate( <wid>, <flag> ) . . . . . . . . . .  en/disable fast update
##
WcFastUpdate := function( wid, flag )
    if flag  then
        WindowCmd([ "XFU", wid, 1 ]);
    else
        WindowCmd([ "XFU", wid, 0 ]);
    fi;
end;


#############################################################################
##
#F  WcOpenWindow( <name>, <width>, <height> ) . . . . . . . . . . open window
##
WcOpenWindow := function( name, width, height )
    local   id,  win;
    
    id  := WindowCmd([ "XOW", name, width, height ])[1];
    win := rec( id := id, isWindow := true, menus := [] );
    WINDOWS[id+1] := win;
    return win;

end;


#############################################################################
##
#F  WcPopupMenu( <title>, <str> ) . . . . . . . . . . . . create a popup menu
##
WcPopupMenu := function( title, str )
    local   pop;
    
    pop    := rec( isPopupMenu := true );
    pop.id := WindowCmd([ "XPS", title, str ])[1];
    return pop;
end;


#############################################################################
##
#F  WcQueryPointer( <id> )  . . . . . . . . . . . . . . . . . . query pointer
##
WcQueryPointer := function( id )
    return WindowCmd([ "XQP", id ]);
end;


#############################################################################
##
#F  WcQueryPopup( <id> )  . . . . . . . . . . . . . . . . .  query popup menu
##
WcQueryPopup := function( id )
    return WindowCmd([ "XSP", id ])[1];
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
#F  WcSetColor( <id>, <col> ) . . . . . . . . . . . . . . . . . .   set color
##
WcSetColor := function( id, col )
    WindowCmd([ "XCO", id, col ]);
end;


#############################################################################
##
#F  WcSetLineWidth( <id>, <w> ) . . . . . . . . . . . . . . .  set line width
##
WcSetLineWidth := function( id, w )
    WindowCmd([ "XLW", id, w ]);
end;


#############################################################################
##
#F  WcSetTitle( <id>, <text> )  . . . . . . . . . . . . . .  set window title
##
WcSetTitle := function( id, text )
    WindowCmd([ "XAT", id, text ]);
end;


#############################################################################
##

#F  WcTextSelector( <name>, <text>, <btn> ) . . . . .  create a text selector
##
WcTextSelector := function( name, text, btn )
    local   sel;
    
    # create text selector
    sel    := rec( isTextSelector := true );
    sel.id := WindowCmd([ "XOS", name, text, btn ])[1];

    # add selector to list of selectors
    SELECTORS[sel.id+1] := sel;

    # and return
    return sel;

end;


#############################################################################
##
#F  WcTsChangeText( <id>, <str> ) . . . . . . .  change text of text selector
##
WcTsChangeText := function( id, str )
    WindowCmd([ "XCL", id, str ]);
end;


#############################################################################
##
#F  WcTsClose( <id> ) . . . . . . . . . . . . . . . . . . close text selector
##
WcTsClose := function( id )
    WindowCmd([ "XCS", id ]);
    Unbind(SELECTORS[id+1]);
end;


#############################################################################
##
#F  WcTsEnable( <id>, <pos>, <flag> ) . . . .  enable button in text selector
##
WcTsEnable := function( id, pos, flag )
    WindowCmd([ "XEB", id, pos, flag ]);
end;


#############################################################################
##
#F  WcTsUnhighlight( <id> ) . . . . . . . . remove highlight in text selector
##
WcTsUnhighlight := function(id)
   WindowCmd([ "XUS", id ]);
end;

